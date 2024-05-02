import 'dart:io';
import 'package:chat_app_firebase/components/chat_bubble.dart';
import 'package:chat_app_firebase/model/user_model.dart';
import 'package:chat_app_firebase/services/chat/audio_service.dart';
import 'package:chat_app_firebase/utils/const.dart';
import 'package:chat_app_firebase/model/message.dart';
import 'package:chat_app_firebase/services/chat/chat_service.dart';
import 'package:chat_app_firebase/utils/app_color.dart';
import 'package:chat_app_firebase/widgets/chat_user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../services/chat/chat_image_video_service.dart';

class ChatPage extends StatefulWidget {
  UserModel userModel;
  String username;

  ChatPage({super.key, required this.userModel, required this.username});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void sentMessages() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.userModel.userUid,
          _messageController.text, 'text', widget.userModel.userEmail,widget.userModel.token,                      widget.username
      );

      _messageController.clear();
    }
  }






  bool isRecording = false;
  String filepath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ChatUserInfo(userModel: widget.userModel),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
          k20height
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.userModel.userUid,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> reversedMessages =
            List.from(snapshot.data!.docs.reversed);

        return reversedMessages.isEmpty
            ? const Center(
                child: Text(
                  'Say Hello..!!',
                  style: TextStyle(color: Colors.red),
                ),
              )
            : ListView.builder(
                reverse: true,
                itemCount: reversedMessages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildMessageItem(reversedMessages[index]);
                },
              );
      },
    );
  }

  ///
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    Timestamp timestamp = data['timestamp'];

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        timestamp.seconds * 1000 + timestamp.nanoseconds ~/ 1000000);

    String formattedTime = _formatTimestamp(dateTime);

// print();
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            // Text(data['senderEmail']),
            ChatBubble(
                message: data['message'],
                messageModel: Message(
                    senderId: data['senderId'],
                    senderEmail: data['senderEmail'],
                    receiverId: data['receiverId'],
                    message: data['message'],
                    timestamp: data['timestamp'],
                    messageType: data['message_type'])),
            Text(
              formattedTime,
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d ago';
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      // Format the timestamp using your desired format
      return DateFormat.jm().format(timestamp);
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          /// Image Send Button
          IconButton(
            icon: const Icon(
              Icons.image,
              color: AppColors.messengerDarkGrey,
            ),
            onPressed: () async {
              final image = await pickImage();

              await _chatService.sendImageVideoMessage(
                receiverUserId: widget.userModel.userUid,
                file: image!,
                messageType: 'image',
                receiverEmail: widget.userModel.userEmail,
                token: widget.userModel.token,
                  user:
                  widget.username
              );
            },
          ),

          /// Video Send Button
          IconButton(
            icon: const Icon(
              Icons.video_file,
              color: AppColors.messengerDarkGrey,
              // size: 20,
            ),
            onPressed: () async {
              final video = await pickVideo();
              await _chatService.sendImageVideoMessage(
                  receiverUserId: widget.userModel.userUid,
                  file: video!,
                  messageType: 'video',
                  receiverEmail: widget.userModel.userEmail,
                  token: widget.userModel.token,
                  user:
                  widget.username
              );
            },
          ),

          /// audio Recorder Button
          SizedBox(
            width: 40,
            height: 40,
            child: GestureDetector(
                onLongPress: () async {
                  if (!isRecording) {
                    // Start recording
                    print(' recording');

                    filepath = await getFilePath();
                    await AudioService.startRecording(filepath);
                  } else {
                    print('Not recording');
                  }

                  setState(() {
                    isRecording = !isRecording;
                  });
                },
                onLongPressEnd: (value) async {
                  await AudioService.record.stop();

                  File audioFile = File(filepath);
                  print('Audio path====================== $filepath');
                  print('Audio File ====================== $audioFile');

                  await _chatService.sendAudioMessage(
                      receiverUserId: widget.userModel.userUid,
                      file: audioFile!,
                      messageType: 'audio',
                      receiverEmail: widget.userModel.userEmail,
                      token: widget.userModel.token,
                      user:
                      widget.username
                  );

                  AudioService.record.dispose();

                  audioFile.delete();
                  setState(() {
                    isRecording = false;
                  });
                },
                child: isRecording == true
                    ?const Icon(
                        Icons.mic,
                        color: AppColors.blueColor,
                        size: 40,
                      )
                    :const Icon(
                        Icons.mic_rounded,
                        color: AppColors.messengerDarkGrey,
                        size: 30,
                      )),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.messengerGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Aa',
                  hintStyle: TextStyle(),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                    left: 20,
                    bottom: 10,
                  ),
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: AppColors.messengerBlue,
            ),
            onPressed: ()async {
              sentMessages();

            },
          ),
        ],
      ),
    );
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test_${i++}.mp3";
  }
}
