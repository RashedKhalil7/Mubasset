import 'package:flutter/material.dart';
import '../Home_Feature/home.dart';
import 'OTPLogain.dart';
import '../services/api_service.dart';

class PassLogin extends StatefulWidget {
  final String? email;

  const PassLogin({
    super.key,
    this.email,
  });

  @override
  State<PassLogin> createState() => _PassLoginState();
}

class _PassLoginState extends State<PassLogin> {
  bool obscurePassword = true;
  bool isLoading = false;

  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
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

  // This function MUST be outside build()
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

  // Login using email/phone + password
  Future<void> _login() async {
    if (widget.email == null || widget.email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email or phone number is missing'),
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.login(
        identifier: widget.email!,
        password: passwordController.text,
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
          isLoading = false;
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
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

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,

                      // Rebuild screen so Continue button
                      // becomes enabled/disabled.
                      onChanged: (value) {
                        setState(() {});
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
                        // Forget password action
                      },
                      child: const Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Colors.brown,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: isLoading
                          ? null
                          : () async {
                              if (widget.email == null ||
                                  widget.email!.isEmpty) {
                                return;
                              }

                              setState(() {
                                isLoading = true;
                              });

                              try {
                                final response = await ApiService.sendOtp(
                                  identifier: widget.email!,
                                  purpose: 'login',
                                );

                                print('LOGIN OTP RESPONSE: $response');

                                if (!mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OtpScreen(
                                      email: widget.email!,
                                    ),
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
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                        child: const Text(
                          'Login using OTP',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Continue button
              buildBottomButton(
                enabled: passwordController.text.length >= 6,
                onPressed: _login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}