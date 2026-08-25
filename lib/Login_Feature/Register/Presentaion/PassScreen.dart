import 'package:flutter/material.dart';

import '../data/SignData.dart';
import 'avatar_Screen.dart';

class PasswordScreen extends StatefulWidget {
  final SignUpData data;
  const PasswordScreen({super.key, required this.data});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  double progress=3/6;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool get hasMinLength => _passwordController.text.length >= 8;
  bool get hasNumber =>
      RegExp(r'\d').hasMatch(_passwordController.text);
  bool get passwordsMatch =>
      _passwordController.text == _confirmController.text &&
          _passwordController.text.isNotEmpty;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get hasSpecialChar => RegExp(r'[!@#$%^&*(),.?";{}|<>]').hasMatch(_passwordController.text);

  Widget _checkRow(String text, bool valid) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: valid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValid = hasMinLength  && passwordsMatch && hasUppercase && hasLowercase && hasSpecialChar;

    return Scaffold(
  resizeToAvoidBottomInset: false,
        appBar: AppBar(
            centerTitle: true,
            title: SizedBox(
            width: 150,
            child: LinearProgressIndicator(
              minHeight: 4,
              borderRadius: BorderRadius.circular(20),
              value: progress,backgroundColor: Colors.grey.shade300,color:  Colors.yellow[600],))),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
               Text(
                "let's secure your account ,${widget.data.fullName}",
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
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.yellow),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ), onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  ),
                ),
                onChanged: (_) => setState(() {}
                ),

              ),

              const SizedBox(height: 30),
              Text("Confirm Password",style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: obscureConfirmPassword,
                decoration:
                 InputDecoration(labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.yellow),
                  ),
                   suffixIcon: IconButton(
                     icon: Icon(
                       obscureConfirmPassword
                           ? Icons.visibility_off
                           : Icons.visibility,
                     ), onPressed: () {
                     setState(() {
                       obscureConfirmPassword = !obscureConfirmPassword;
                     });
                   },
                   ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 25),
              Text(
                "Password must contain ",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              _checkRow('At least 8 characters', hasMinLength),
           //   _checkRow('Contains a digit', hasNumber),
              _checkRow('Passwords match', passwordsMatch),
              _checkRow('1 upper case character', hasUppercase),
              _checkRow('1 lower case character', hasLowercase),
              _checkRow('1 special character', hasSpecialChar),
           //   const SizedBox(height: 210),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid
                        ? Colors.yellow[600] : Colors.grey,
                  ),
                  onPressed: isValid
                      ? () {
                    widget.data.password = _passwordController.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AvatarScreen(data: widget.data),
                      ),
                    );
                  }
                      : null,
                  child: const Text('Continue'),
                ),
              ),

            ],
          ),
        ),

    );
  }
}