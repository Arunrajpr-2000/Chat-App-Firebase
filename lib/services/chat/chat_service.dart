import 'dart:io';
import 'package:chat_app_firebase/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///send message
  Future<void> sendMessage(
      String receiverId,
      String message,
      String messageType,
      String receiverEmail,
      String token,
      String user) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
        messageType: messageType);

    /// construct chat room id from currentuserId and reciverId (sort to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'senderEmail': currentUserEmail,
      'receiverEmail': receiverEmail,
      'chatRoomId': chatRoomId,
      'lastMessage': messageType == 'text' ? message : 'Send a File'
    });

    ///add new message to db
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    sendPushMessage(
        token, messageType == 'text' ? message :messageType == 'audio' ? 'Received an audio':messageType == 'video' ?'Received a video':'Received an Image', user);

  }

  /// send Audio file
  Future<void> sendAudioMessage(
      {required String receiverUserId,
      required File file,
      required String messageType,
      required String receiverEmail,
      required String token,
      required String user}) async {
    try {
      if (file == null) return;

      final messageId = const Uuid().v1();
      final ref = FirebaseStorage.instance.ref(messageType).child(messageId);
      final snapshot = await ref.putFile(file);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await sendMessage(
          receiverUserId, downloadUrl, messageType, receiverEmail, token,user);
    } catch (e) {
      print('Error sending image message: $e');
    }
  }

  ///send Image video File
  Future<void> sendImageVideoMessage(
      {required String receiverUserId,
      required File file,
      required String messageType,
      required String receiverEmail,
  required String token ,
        required String user
      }) async {
    try {
      if (file == null) return;

      final messageId = const Uuid().v1();
      final ref = FirebaseStorage.instance.ref(messageType).child(messageId);
      final snapshot = await ref.putFile(file);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await sendMessage(
        receiverUserId,
        downloadUrl,
        messageType,
        receiverEmail,
        token,user
      );
    } catch (e) {
      print('Error sending image message: $e');
    }
  }

  ///Get Messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  ///send push notification
  void sendPushMessage(String token, String body, String user) async {
    try {

      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAYz6yWko:APA91bHCUCrhXrkvqTmv-svf18oAGeZH94SjDAiNK1gJNFzGWIA9QmE7jHD1VJrdyoY-N2K7irgKcMx6OJUEiUh7krU5nMHQT4H3e3gqWvPk7mMdHIdNhxMpEiPLay3KoFNi6C1enH4C'
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': 'Message from $user'
          },
          'notification': <String, dynamic>{
            'title': 'Message from $user',
            'body': body,
            'android_channel_id': 'chatnoti'
          },
          'to': token,
        }),
      );

      print('Message sent to: $token');
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }
}
