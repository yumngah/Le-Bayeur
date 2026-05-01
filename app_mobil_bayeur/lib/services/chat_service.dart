import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_mobil_bayeur/models/message_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChatService {
  final ApiService _api;
  late io.Socket socket;
  final _messageController = StreamController<ChatMessage>.broadcast();

  ChatService(this._api) {
    _initSocket();
  }

  void _initSocket() {
    socket = io.io('http://localhost:5000', io.OptionBuilder() // URL matching backend
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    socket.onConnect((_) => debugPrint('Connected to socket'));
    socket.on('receive_message', (data) {
      _messageController.add(ChatMessage.fromJson(data));
    });
  }

  void connect(String userId) {
    socket.connect();
    socket.emit('join', userId);
  }

  void disconnect() {
    socket.disconnect();
  }

  Stream<ChatMessage> get messageStream => _messageController.stream;

  Future<ChatMessage> sendMessage(String receiverId, String content, {String? propertyId, MessageType type = MessageType.TEXT}) async {
    final response = await _api.post('/api/messages/send', data: {
      'receiver_id': receiverId,
      'content': content,
      'property_id': propertyId,
      'message_type': type.name,
    });
    
    final message = ChatMessage.fromJson(response.data);
    socket.emit('send_message', message.toJson());
    return message;
  }

  Future<List<ChatMessage>> getConversation(String otherUserId) async {
    final response = await _api.get('/api/messages/conversation/$otherUserId');
    return (response.data as List).map((m) => ChatMessage.fromJson(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getChatList() async {
    final response = await _api.get('/api/messages/chats');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<File> exportChatToPdf(String otherUserId, String otherUserName, List<ChatMessage> messages) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Historique de Discussion - Bayeurs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Conversation avec: $otherUserName'),
            pw.Text('Date d\'export: ${DateTime.now().toString()}'),
            pw.Divider(),
            pw.SizedBox(height: 20),
            ...messages.map((msg) {
              final isMe = msg.senderId != otherUserId;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                alignment: isMe ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: isMe ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: isMe ? PdfColors.blue100 : PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Text(msg.content),
                    ),
                    pw.Text(
                      msg.createdAt.toString(),
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/chat_$otherUserId.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  void dispose() {
    _messageController.close();
    socket.dispose();
  }
}
