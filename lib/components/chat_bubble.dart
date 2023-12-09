import 'package:chat_app_firebase/model/message.dart';
import 'package:flutter/material.dart';

import '../widgets/post_image_video_view.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  Message messageModel;

  ChatBubble({super.key, required this.message, required this.messageModel});

  @override
  Widget build(BuildContext context) {
    if (messageModel.messageType == 'text') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue,
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      );
    } else {
      return PostImageVideoView(
        fileUrl: messageModel.message,
        fileType: messageModel.messageType,
        message: messageModel,
      );
    }
  }
}
