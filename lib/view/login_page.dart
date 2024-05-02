import 'package:chat_app_firebase/components/button.dart';
import 'package:chat_app_firebase/utils/const.dart';
import 'package:chat_app_firebase/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/text_field.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  ///sign in user
  void signIn() async {
    final authservice = Provider.of<AuthService>(context, listen: false);
    try {
      await authservice.signInWithEmailAndPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.message,
              size: 100,
              color: Colors.black,
            ),
            k20height,
            const Text('Welcome Back!!'),
            k30height,
            TextfieldWidget(
              controller: emailController,
              obscureText: false,
              hintText: 'Email',
            ),
            k10height,
            TextfieldWidget(
              controller: passwordController,
              obscureText: true,
              hintText: 'Password',
            ),
            k30height,
            MyButton(
                text: 'Sign In',
                onTap: () {
                  signIn();
                }),
            k40height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const  Text('Not a member?'),
                k5width,
                GestureDetector(
                    onTap: widget.onTap,
                    child:const Text(
                      'Register Now!!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
