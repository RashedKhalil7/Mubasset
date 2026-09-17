import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'PasswordLogin.dart';
import 'Register/Presentaion/OTPRregister.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierController = TextEditingController();

  bool isidentifierValid = false;
  bool isLoading = false;

  // Email validation
  final emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');

  // Phone validation
  final phoneRegex =
      RegExp(r'^\+?[0-9]{9,15}$');

  @override
  void dispose() {
    identifierController.dispose();
    super.dispose();
  }

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
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 18, 162, 119),
        ),
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
          backgroundColor: enabled && !isLoading
              ? const Color.fromARGB(255, 18, 162, 119)
              : Colors.grey,
        ),
        onPressed: enabled && !isLoading ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
      ),
    );
  }

  // --------------------------------------------------
  // CHECK IDENTIFIER
  // --------------------------------------------------

  Future<void> _continue() async {
    final identifier = identifierController.text.trim();

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or phone number'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Ask Django if this email/phone already exists
      final result = await ApiService.checkIdentifier(identifier);

      print('CHECK IDENTIFIER RESPONSE: $result');

      final exists = result['exists'] == true;

      if (!mounted) return;

      // --------------------------------------------------
      // EXISTING USER
      // --------------------------------------------------

      if (exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PassLogin(
              email: identifier,
            ),
          ),
        );
      }

      // --------------------------------------------------
      // NEW USER
      // --------------------------------------------------

      else {
        // Send registration OTP
        await ApiService.sendOtp(
          identifier: identifier,
          purpose: 'register',
        );

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpRegisterScreen(
              email: identifier,
            ),
          ),
        );
      }
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
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              // --------------------------------------------------
              // CONTENT
              // --------------------------------------------------

              Expanded(
                child: _identifierWidget(),
              ),

              // --------------------------------------------------
              // TERMS
              // --------------------------------------------------

              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          "By continuing, you agree to Mubasset ",
                    ),

                    TextSpan(
                      text: "Terms of Use ",
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {},
                    ),

                    const TextSpan(
                      text: "and ",
                    ),

                    TextSpan(
                      text: "Privacy Policy.",
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --------------------------------------------------
              // CONTINUE BUTTON
              // --------------------------------------------------

              buildBottomButton(
                enabled: isidentifierValid,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // IDENTIFIER WIDGET
  // --------------------------------------------------

  Widget _identifierWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 15),

        const Text(
          'Please enter your Email Address or phone number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 30),

        const Text(
          'Email address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: identifierController,

          keyboardType: TextInputType.emailAddress,

          onChanged: (value) {
            final identifier = value.trim();

            setState(() {
              isidentifierValid =
                  emailRegex.hasMatch(identifier) ||
                  phoneRegex.hasMatch(identifier);
            });
          },

          decoration: inputDecoration(
            label: '',
            hint: 'Enter your Email Address or Phone Number',
          ),
        ),
      ],
    );
  }
}