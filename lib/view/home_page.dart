import 'package:chat_app_firebase/model/user_model.dart';
import 'package:chat_app_firebase/utils/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth/auth_service.dart';
import '../utils/app_color.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final email = FirebaseAuth.instance.currentUser!.email;
  final myUid = FirebaseAuth.instance.currentUser!.uid;
  String? imgUrl;
  String? username;
  String? mtoken = '';




  ///token
  void getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      await messaging.getToken().then((token) {
        setState(() {
          mtoken = token;
          print('My token is $mtoken');
        });
        saveToken(token!);
      });
    } else {
      print('User declined');
      await FirebaseMessaging.instance.requestPermission();
    }
  }

 /// Save Token
  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .update({'token': token});
  }

  /// Sign Out
  void signOut() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await setStatus(false);
      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  ///Get user data
  Future<void> getUserDetails() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(myUid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        // Access specific fields from the user document
        setState(() {
          imgUrl = userData!['img'];
          username= userData!['name'];
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error retrieving user details: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('init');
     FirebaseMessaging.instance.requestPermission();
    getToken();
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);
    getUserDetails();
  }

  setStatus(bool status) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"online": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus(true);
    } else {
      setStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.realWhiteColor,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                imgUrl ??
                    'https://cdn-icons-png.flaticon.com/512/149/149071.png',
              ),
            ),
          ),
          title: const Text(
            'Chats',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            InkWell(
              onTap: () {
                signOut();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.greyColor,
                  radius: 20,
                  child: Icon(
                    Icons.exit_to_app,
                    color: AppColors.blackColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: Column(
            children: [
              k20height,
              _buildChatsSearchWidget(),
              k20height,
              Expanded(child: _buildUserList()),
            ],
          ),
        ));
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildUserListItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  ///_buildUserListItem
  Widget _buildUserListItem(DocumentSnapshot document) {

    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (_auth.currentUser!.email != data['email']) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    username: username?? 'User',
                    userModel: UserModel(
                        userEmail: data['email'],
                        username: data['name'],
                        userUid: data['uid'],
                        userImg: data['img'],
                        userPassword: data['password'],
                        isOnline: data['online'],
                        token: data['token']),
                  ),
                ));
          },
          child: Row(
            children: [
              // Profile Pic
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(data['img']),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      data['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data['online'] == true ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: AppColors.darkGreyColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Message status
               Padding(
                padding:const EdgeInsets.only(left: 10, right: 10),
                child: Icon(
                  data['online'] == true? Icons.public :  Icons.public,
                  color: data['online'] == true?AppColors.greenColor: AppColors.messengerDarkGrey,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  ///search widget
  Widget _buildChatsSearchWidget() => Container(
        decoration: BoxDecoration(
          color: AppColors.greyColor.withOpacity(.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 15),
            Icon(Icons.search),
            SizedBox(width: 15),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                  hintStyle: TextStyle(),
                ),
              ),
            ),
          ],
        ),
      );
}
