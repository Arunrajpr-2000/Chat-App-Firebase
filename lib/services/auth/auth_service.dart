import 'package:chat_app_firebase/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///sign in user
  Future<UserCredential> signInWithEmailandpassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // _firestore.collection('users').doc(userCredential.user!.uid).set({
      //   'uid':userCredential.user!.uid,
      //   'email':email
      // },
      // SetOptions(merge: true)
      // );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  ///Create user
  Future<UserCredential> signUpWithEmailandPassword(
      {required String email,
      required String password,
      required String username,
      required String userImage}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel _user = UserModel(
          userEmail: email,
          username: username,
          userUid: userCredential.user!.uid,
          userImg: userImage,
          userPassword: password,
          isOnline: true);

      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(_user.toJson());

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  ///sign user out
  Future<void> signOut() async {

    return await FirebaseAuth.instance.signOut();
  }
}
