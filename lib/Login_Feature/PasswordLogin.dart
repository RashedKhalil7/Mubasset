import 'package:flutter/material.dart';
import '../Home_Feature/home.dart';
import 'OTPLogain.dart';

class PassLogin extends StatefulWidget {
  final String? email;
  const PassLogin({super.key,this.email});

  @override
  State<PassLogin> createState() => _PassLoginState();
}

class _PassLoginState extends State<PassLogin> {
  bool obscurePassword = true;
  final passwordController = TextEditingController();



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
        borderSide: const BorderSide(color: Color.fromARGB(255, 18, 162, 119)),
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
          backgroundColor: enabled ?  Color.fromARGB(255, 18, 162, 119) : Colors.grey,
        ),
        onPressed: enabled ? onPressed : null,
        child:  const Text(
          'Continue',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children:[
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    'Please Enter your password to login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text("Password",style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    onChanged: (value) {
                      setState(() {

                      });

                    },
                    decoration: inputDecoration(
                      label: '',
                      hint: 'Enter your password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      // forget password action
                    },
                    child: const Text(
                      'Forget Password?',
                      style: TextStyle(
                        color: Colors.brown,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: TextButton(onPressed: (){

                     Navigator.push(context, MaterialPageRoute(builder: (_)=>OtpScreen(email: widget.email!)));

                    },
                        child: Text("Login using OTP",style: TextStyle(color: Colors.blueAccent,fontSize: 16),)),
                  ),

                ],
                            ),
              ),
              buildBottomButton(enabled: passwordController.text.length>=6, onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              })
          ],
          ),
        ),
      ),
    );
  }
}


