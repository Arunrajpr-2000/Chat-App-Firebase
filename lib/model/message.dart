import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final String messageType;

  Message(
      {required this.senderId,
      required this.senderEmail,
      required this.receiverId,
      required this.message,
      required this.timestamp,
      required this.messageType});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'message_type': messageType
    };
  }

  static Message fromJson(Map<String, dynamic> json) => Message(
    message: json['message'],
    messageType: json['message_type'],
    receiverId: json['receiverId'],
    senderEmail: json['senderEmail'],
    senderId: json['senderId'],
    timestamp: json['timestamp'],

  );
}
