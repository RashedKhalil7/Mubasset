import 'dart:async';

import 'onboarding_screen.dart';

import '../services/api_service.dart';

import 'package:flutter/material.dart';

import '../Home_Feature/home.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
    void initState() {
      super.initState();

      _checkSession();
    }


    Future<void> _checkSession() async {
      // Keep the splash screen visible for 3 seconds.
      await Future.delayed(
        const Duration(seconds: 3),
      );

      // Check whether the user has a valid session.
      final isLoggedIn =
          await ApiService.restoreSession();

      if (!mounted) return;

      if (isLoggedIn) {
        // User is already logged in.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        // User is not logged in.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12A277),

      body: Center(child: Image.asset('assets/images/logo.png', width: 220)),
    );
  }
}
