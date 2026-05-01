import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/services/chat_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';
import 'package:app_mobil_bayeur/screens/chat/chat_screen.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  late ChatService _chatService;
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(ApiService());
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final chatsList = await _chatService.getChatList();
      setState(() {
        _chats = chatsList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement liste chats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Messages", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chats.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    final lastMsgDate = DateTime.parse(chat['last_message_at']);
                    final timeStr = DateFormat('HH:mm').format(lastMsgDate);
                    
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              otherUserId: chat['other_user_id'],
                              otherUserName: chat['other_user_name'],
                              propertyId: chat['property_id'],
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          chat['other_user_name'].substring(0, 1).toUpperCase(),
                          style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(chat['other_user_name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          chat['last_message'] ?? "Pas de message",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: chat['unread_count'] > 0 ? Colors.black : Colors.grey[600]),
                        ),
                      ),
                      trailing: chat['unread_count'] > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              child: Text(
                                "${chat['unread_count']}",
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text("Aucune conversation", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Vos échanges avec les propriétaires\napparaîtront ici.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
