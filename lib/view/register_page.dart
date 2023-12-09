import 'package:chat_app_firebase/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/button.dart';
import '../components/text_field.dart';
import '../services/auth/image_service.dart';
import '../utils/const.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {
  final emailcontroller = TextEditingController();
  final namecontroller = TextEditingController();

   final passwordcontroller= TextEditingController();

   final confirmpasswordcontroller= TextEditingController();
   String userImage='https://www.goodmorningimagesdownload.com/wp-content/uploads/2021/12/Best-Quality-Profile-Images-Pic-Download-2023.jpg';




   void signUp()async{
     if(passwordcontroller.text!=confirmpasswordcontroller.text){
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not Match !!')));
       return ;
     }
final authService = Provider.of<AuthService>(context,listen: false);
     try{
       await authService.signUpWithEmailandPassword(email: emailcontroller.text, password: passwordcontroller.text, username: namecontroller.text, userImage: userImage);


     }catch(e){
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));

     }
   }



  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body:Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const  Icon(Icons.message,size: 100,color: Colors.black,),
                  // k20height,
                  const  Text('Lets create an account for you!!', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  k40height,
                  _buildAvatarWithAddButton(userImage),
                  k40height,
                  TextfieldWidget(controller: emailcontroller,obscureText: false, hintText: 'Email',),
                  k10height,
                  TextfieldWidget(controller: namecontroller,obscureText: false, hintText: 'User Name',),
                  k10height,
                  TextfieldWidget(controller: passwordcontroller,obscureText: true, hintText: 'Password',),
                  k10height,
                  TextfieldWidget(controller: confirmpasswordcontroller,obscureText: true, hintText: 'Confirm Password',),

                  k30height,
                  MyButton(text: 'Sign Up', onTap: (){
                  signUp();
                  }),
                  k40height,
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?'),
                      k5width,
                      GestureDetector(
                          onTap:widget.onTap,
                          child: Text('Login Now!!', style: TextStyle(fontWeight: FontWeight.bold),)),

                    ],)

                ]),
          ),
        ),
      ),);
  }

  Widget _buildAvatarWithAddButton(String image) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(image),
          // Replace with your image asset
        ),
        Positioned(
          bottom: 5,
          right: 2,
          child: InkWell(
            onTap: () {
              setState(() async {
                final imageUrl = await ImageService.getimage();
                //image.add(imageurl.toString());
                setState(() {});
                userImage = imageUrl!;

                print(userImage.toString());
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.add_a_photo_rounded,
                size: 23,
                color: Colors.grey[800],
              ),
            ),
          ),
        )
      ],
    );
  }
}
