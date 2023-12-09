import 'dart:io';
import 'package:chat_app_firebase/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatService extends ChangeNotifier{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///send message
Future<void>sendMessage(String receiverId, String message, String messageType, String receiverEmail)async{
final String currentUserId = _firebaseAuth.currentUser!.uid;
final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
final Timestamp timestamp = Timestamp.now();

///create  a new message
Message newMessage = Message(
    senderId: currentUserId,
    senderEmail: currentUserEmail,
    receiverId: receiverId,
    message: message,
    timestamp: timestamp,
    messageType: messageType
   );

/// construct chat room id from currentuserId and reciverId (sort to ensure uniqueness)
  List<String>ids= [currentUserId,receiverId];
  ids.sort();
  String chatRoomId = ids.join("_");

await _firestore.collection('chat_rooms').doc(chatRoomId).set({
  'senderEmail': currentUserEmail,
  'receiverEmail':receiverEmail,
  'chatRoomId':chatRoomId,
  'lastMessage':messageType=='text'?message:'Send a File'
});

  ///add new message to db
  await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());

// DocumentReference documentReference = FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);
//
// // Use the update method to add or update fields
// await documentReference.set({
//   'senderEmail': currentUserEmail,
//   'receiverEmail':receiverEmail,
//   'uid':currentUserId
// });

}

/// send Audio file
  Future<void> sendAudioMessage({
    required String receiverUserId,
    required File file,
    required String messageType,
    required String receiverEmail
  }) async {
    try {
      if (file == null) return;

      final messageId = const Uuid().v1();
      final ref = FirebaseStorage.instance.ref(messageType).child(messageId);
      final snapshot = await ref.putFile(file);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await sendMessage(receiverUserId, downloadUrl, messageType,receiverEmail);
    } catch (e) {
      print('Error sending image message: $e');
    }
  }





  ///send Image video File
  Future<void> sendImageVideoMessage({
   required String receiverUserId,
   required File file,
    required String messageType,
   required String receiverEmail
  }) async {
    try {
      if (file == null) return;

      final messageId = const Uuid().v1();
      final ref = FirebaseStorage.instance.ref(messageType).child(messageId);
      final snapshot = await ref.putFile(file);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await sendMessage(receiverUserId, downloadUrl, messageType,receiverEmail);
    } catch (e) {
      print('Error sending image message: $e');
    }
  }


///Get Messages
Stream<QuerySnapshot>getMessages(String userId, String otherUserId){
  List<String>ids = [userId,otherUserId];
  ids.sort();
  String chatRoomId= ids.join("_");
  return _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp',descending: false).snapshots();
  
}



}