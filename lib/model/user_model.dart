class UserModel {
  final String username;
  final String userEmail;
  final String userUid;
  final String userImg;
  final String userPassword;
  final bool isOnline;

  UserModel({
    required this.userEmail,
    required this.username,
    required this.userUid,
    required this.userImg,
    required this.userPassword,
    required this.isOnline,
  });

  Map<String, dynamic> toJson() => {
        'email': userEmail,
        'name': username,
        'uid': userUid,
        'img': userImg,
        'password': userPassword,
        'online': isOnline
      };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        userEmail: json['email'],
        username: json['name'],
        userUid: json['uid'],
        userImg: json['img'],
        userPassword: json['password'],
        isOnline: json['online'],
      );
}
