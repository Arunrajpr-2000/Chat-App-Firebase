import 'package:chat_app_firebase/model/user_model.dart';
import 'package:flutter/material.dart';

import '../utils/app_color.dart';

class ChatUserInfo extends StatelessWidget {
  const ChatUserInfo({
    super.key,
    required this.userModel,
  });

  final UserModel userModel;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(userModel.userImg),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userModel.username,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            Text(
              userModel.isOnline == true ? 'Online' : 'Offline',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyColor,
              ),
            )
          ],
        ),
      ],
    );
  }
}
