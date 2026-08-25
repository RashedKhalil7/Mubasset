import 'dart:io';

import 'package:mubasset/Home_Feature/home.dart';
import 'package:flutter/material.dart';

import '../data/SignData.dart';
import 'package:image_picker/image_picker.dart';

class AvatarScreen extends StatefulWidget {
  final SignUpData data;
  const AvatarScreen({super.key, required this.data});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  double progress=4/6;
  File? image;
  final imagePicker=ImagePicker();
  
  Future<void> pickImage()async{
    final XFile? pick=await imagePicker.pickImage(source: ImageSource.gallery);
      if(pick != null){
        setState(() {
          image= File(pick.path);
          widget.data.avatarPath=pick.path;
        });
      }
  }
  
  
  void go(){
    Navigator.push(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
    debugPrint(widget.data.toJson().toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: SizedBox(
          width: 150,
          child: LinearProgressIndicator(
            minHeight: 4,
            borderRadius: BorderRadius.circular(20),
            value: progress,backgroundColor: Colors.grey.shade300,color:  Color.fromARGB(255, 18, 162, 119),))),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text("Upload Your Profile Picture",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
              const SizedBox(height: 14),
              Text("Upload Your Profile Picture",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16),),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  image==null ?
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.black,
                   child: Text(widget.data.fullName[0].toUpperCase(),style: TextStyle(color: Colors.white,fontSize: 45,fontWeight: FontWeight.bold),),
                  ):
                  CircleAvatar(
                    radius: 80,
                    backgroundImage:
                    FileImage(image!),
                  )
                  ,
                  InkWell(
                    onTap: (){
                    pickImage();
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Color.fromARGB(255, 18, 162, 119),
                      child: Icon(image==null?Icons.add:Icons.edit, size:20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              TextButton(onPressed: (){
                setState(() {
                  image=null;
                });
              }, child: Text("Remove",style: TextStyle(color: Colors.deepOrange,fontSize: 14),)),

              const Spacer(),
             /* TextButton(
                onPressed:(){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>PlayersScreen(data: widget.data,)));
                },
                child: const Text(
                    'Not Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),*/
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Color.fromARGB(255, 18, 162, 119)
                  ),
                  onPressed: () {
                go();
                    // Send to database here
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
    );
  }
}