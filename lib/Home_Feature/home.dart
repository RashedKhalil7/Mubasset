import 'package:flutter/material.dart';


import '../Login_Feature/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed:(){ Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>LoginScreen()));},icon: Icon(Icons.logout),
    )
        ],
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             
              Text("Home Screen",style: TextStyle(fontSize: 26),)
            ],
          )
        ),
      ),
    );
  }
}
