import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, audio, call }
enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String chatId;

  MessageModel({
    required this.id, required this.senderId, required this.content,
    required this.timestamp, this.type = MessageType.text,
    this.status = MessageStatus.sent, this.chatId = '',
  });

  // تحويل من فايربيز
  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere((e) => e.toString() == map['type'], orElse: () => MessageType.text),
      status: MessageStatus.values.firstWhere((e) => e.toString() == map['status'], orElse: () => MessageStatus.sent),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'content': content,
    'timestamp': FieldValue.serverTimestamp(),
    'type': type.toString(),
    'status': status.toString(),
  };
}

class ChatPreviewModel {
  final String id;        // معرف المحادثة (غالباً UID الطبيب + UID المستخدم)
  final String name;
  final String lastMessage;
  final DateTime time;
  final int unreadCount;
  final bool isOnline;
  final String image;
  final String type;      // Private or Group

  ChatPreviewModel({
    required this.id, required this.name, required this.lastMessage,
    required this.time, this.unreadCount = 0, this.isOnline = false,
    required this.image, this.type = 'Private',
  });

  factory ChatPreviewModel.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    Map data = doc.data() as Map;
    // هنا نقوم بفلترة الاسم والصورة بناءً على الطرف الآخر
    return ChatPreviewModel(
      id: doc.id,
      name: data['doctorName'] ?? 'طبيب',
      lastMessage: data['lastMessage'] ?? '',
      time: (data['lastTime'] as Timestamp).toDate(),
      unreadCount: data['unreadCount']?[currentUserId] ?? 0,
      isOnline: data['isOnline'] ?? false,
      image: data['doctorImage'] ?? '',
      type: data['chatType'] ?? 'Private',
    );
  }
}