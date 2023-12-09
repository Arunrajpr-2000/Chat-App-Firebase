import 'package:chat_app_firebase/model/message.dart';
import 'package:chat_app_firebase/widgets/network_audio_player.dart';
import 'package:chat_app_firebase/widgets/network_video_view.dart';
import 'package:flutter/material.dart';


class PostImageVideoView extends StatelessWidget {
   PostImageVideoView({
    Key? key,
    required this.fileType,
    required this.fileUrl,
    required this.message
  }) : super(key: key);

  final String fileType;
  final String fileUrl;
  Message message;

  @override
  Widget build(BuildContext context) {
    if (fileType == 'image') {
      return Container(
        height: 350,
          width: 300,

          decoration: BoxDecoration(

              image: DecorationImage(image: NetworkImage(fileUrl, ),fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(20) ),
         // child: Image.network(fileUrl, fit: BoxFit.contain,)
      );
    }else if(fileType=='audio'){
      return NetworkAudioPlayer(
          audioUrl: fileUrl,
      );
    }
    else {
      return NetworkVideoView(
        videoUrl: fileUrl,
      );
    }
  }
}
