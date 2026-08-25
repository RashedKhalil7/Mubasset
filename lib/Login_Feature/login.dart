import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'PasswordLogin.dart';
import 'Register/Presentaion/OTPRegister.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();


  bool isEmailValid = false;

  bool isLoading=false;


  final emailRegex =
  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  InputDecoration inputDecoration({
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.yellow),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget buildBottomButton({
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ?  Colors.yellow[600] : Colors.grey,
        ),
        onPressed: enabled ? onPressed : null,
        child: isLoading? const CircularProgressIndicator(): const Text(
          'Continue',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading:
           IconButton(onPressed: (){
      
           }, icon: Icon(Icons.arrow_back))
      
        ),
        body:
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// CONTENT
                Expanded(
                  child: _emailWidget(),
                ),
          RichText(text: TextSpan(style: TextStyle(color: Colors.black),
              children: [
                TextSpan(text:"By continuing, you agree to AL Gharafa SC's "),
                TextSpan(text: "Terms of Use ",style: TextStyle(decoration: TextDecoration.underline),recognizer: TapGestureRecognizer()..onTap=(){}),
                TextSpan(text: "and "),
                TextSpan(text: "Privacy Policy.",style: TextStyle(decoration: TextDecoration.underline),recognizer: TapGestureRecognizer()..onTap=(){})
      
              ]
              )
              ),
        SizedBox(height: 30),
      
      
                /// BUTTON (BOTTOM)
                buildBottomButton(
                  enabled: isEmailValid,
                  onPressed: ()async {

                      setState(() {
                        isLoading=true;
                      });


                      await Future.delayed(const Duration(seconds: 2));
                      setState(() {
                          isLoading=false;

                      });
                      if(isEmailValid){
                        if(emailController.text=="ahmed@gmail.com"){
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>PassLogin(email: emailController.text,)));
                        }else{
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>OtpRegisterScreen(email: emailController.text,)));
                        }

                      }


                    }
      
                ),
              ],
            ),
          ),
        ),

    );
  }

  /// EMAIL STEP
  Widget _emailWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text(
          'Please enter your email or phone number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 30),
        Text("Email address",style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    ),),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {
              isEmailValid = emailRegex.hasMatch(value);
            });
          },
          decoration: inputDecoration(
            label: '',
            hint: 'Enter your Email or Phone Number',
          ),
        ),
      ],
    );
  }

  /// PASSWORD STEP

}