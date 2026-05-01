// ignore_for_file: constant_identifier_names

enum MessageType {
  TEXT,
  IMAGE,
  DOCUMENT
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String? propertyId;
  final String content;
  final MessageType type;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? readAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.propertyId,
    required this.content,
    this.type = MessageType.TEXT,
    this.attachmentUrl,
    required this.createdAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      propertyId: json['property_id'],
      content: json['content'],
      type: _parseType(json['message_type']),
      attachmentUrl: json['attachment_url'],
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  static MessageType _parseType(String? type) {
    switch (type) {
      case 'IMAGE': return MessageType.IMAGE;
      case 'DOCUMENT': return MessageType.DOCUMENT;
      default: return MessageType.TEXT;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
      'property_id': propertyId,
      'content': content,
      'message_type': type.name,
      'attachment_url': attachmentUrl,
    };
  }
}
