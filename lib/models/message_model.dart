import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedTime;
    if (map['timestamp'] is Timestamp) {
      parsedTime = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String && (map['timestamp'] as String).isNotEmpty) {
      parsedTime = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return MessageModel(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: parsedTime,
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}

