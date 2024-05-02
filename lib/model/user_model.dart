class UserModel {
  final String username;
  final String userEmail;
  final String userUid;
  final String userImg;
  final String? userPassword;
  final bool isOnline;
  final String token;

  UserModel({
    required this.userEmail,
    required this.username,
    required this.userUid,
    required this.userImg,
     this.userPassword,
    required this.isOnline,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'email': userEmail,
        'name': username,
        'uid': userUid,
        'img': userImg,
        'password': userPassword,
        'online': isOnline,
    'token':token
      };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        userEmail: json['email'],
        username: json['name'],
        userUid: json['uid'],
        userImg: json['img'],
        userPassword: json['password'],
        isOnline: json['online'],
        token: json['token'],

      );
}
