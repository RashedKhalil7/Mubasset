import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Home_Feature/home.dart';
import 'PasswordLogin.dart';
import 'login.dart';
import '../services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;


   const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isLoading = false;
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
   bool isFill=false;
   bool enabled=false;

  final List<FocusNode> _focusNodes =
  List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    bool hasEmpty=_controllers.any((e)=>e.text.isEmpty);

      if (value.length == 1 && index < 3) {
        if(hasEmpty){
          setState(() {
            enabled=false;
          });
        }else{
          setState(() {
            enabled=true;
          });
        }

        _focusNodes[index + 1].requestFocus();
      }else{
        if(hasEmpty){
          setState(() {
            enabled=false;
          });
        }else{
          setState(() {
            enabled=true;
          });
        }
      }


  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete OTP'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.loginWithOtp(
        identifier: widget.email,
        otp: _otpCode,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Title
              const Text(
                'Please enter the 4-digit OTP sent to',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Email + Change
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                     Text(
                      widget.email,
                      style: const TextStyle(fontSize: 16),
                    ),
               SizedBox(width: 10,),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
                      },
                      child: const Text('Change',style: TextStyle(color:Colors.blue),),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 32),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  bool hasDigit=_controllers[index].text.isNotEmpty;
                  return SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration:  InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: hasDigit?Color.fromARGB(255, 18, 162, 119):Colors.white70 ,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)
                        ),
                      ),
                      onChanged: (value) =>
                          _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Resend + Timer
              Row(
                children: [
                  TextButton(
                    onPressed:
                    _secondsRemaining == 0 ? _startTimer : null,
                    child: const Text('Resend code'),
                  ),
                  _secondsRemaining > 0?
                      Row(
                        children: [
                          Text("You can request new code in"),
                          Text(" $_secondsRemaining s", style: const TextStyle(fontWeight: FontWeight.bold))
                        ],
                      )
                      :
                  Text(
                   'You can resend now',
                    style: const TextStyle(color: Colors.grey),
                  ),
             /*     Text(
                    _secondsRemaining > 0
                        ? 'You can request new code in $_secondsRemaining s'
                        : 'You can resend now',
                    style: const TextStyle(color: Colors.grey),
                  ),*/
                ],
              ),

              const SizedBox(height: 24),

              // Login with password
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>PassLogin(email: widget.email,)));

                  },
                  child: const Text('Login with password',style: TextStyle(color: Colors.blueAccent,fontSize: 16)),
                ),
              ),

              const Spacer(),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: enabled && !_isLoading
                        ? const Color.fromARGB(255, 18, 162, 119)
                        : Colors.grey,
                  ),
                  onPressed: enabled && !_isLoading ? _verifyOtp : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}