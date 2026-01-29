/// Chat model matching backend Chat schema
class Chat {
  final String chatId;
  final String user1Id;
  final String user2Id;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  // Joined data
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final int unreadCount;

  Chat({
    required this.chatId,
    required this.user1Id,
    required this.user2Id,
    this.lastMessageAt,
    this.createdAt,
    this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chat_id']?.toString() ?? '',
      user1Id: json['user1_id']?.toString() ?? '',
      user2Id: json['user2_id']?.toString() ?? '',
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.tryParse(json['last_message_at']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      otherUserName: json['other_user_name'],
      otherUserAvatar: json['other_user_avatar'],
      lastMessage: json['last_message'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Message model matching backend Message schema
class Message {
  final String messageId;
  final String chatId;
  final String senderId;
  final String messageType;
  final String messageContent;
  final String? mediaUrl;
  final bool isRead;
  final DateTime? createdAt;

  // Joined data
  final String? senderName;
  final String? senderAvatar;

  Message({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    this.messageType = 'text',
    required this.messageContent,
    this.mediaUrl,
    this.isRead = false,
    this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      messageType: json['message_type'] ?? 'text',
      messageContent: json['message_content'] ?? '',
      mediaUrl: json['media_url'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'chat_id': chatId,
      'sender_id': senderId,
      'message_type': messageType,
      'message_content': messageContent,
      'media_url': mediaUrl,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Check if message is from the specified user
  bool isFromUser(String userId) => senderId == userId;

  /// Get formatted time
  String get formattedTime {
    if (createdAt == null) return '';
    final hour = createdAt!.hour;
    final minute = createdAt!.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

/// Message type enum
enum MessageType {
  text,
  image,
  audio,
  video,
}

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.audio:
        return 'audio';
      case MessageType.video:
        return 'video';
    }
  }
}
