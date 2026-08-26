import 'package:flutter/material.dart';

import '../Login_Feature/login.dart';
import '../Home_Feature/home.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF19231F),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // =========================
          // BACKGROUND IMAGE
          // =========================
          Image.asset(
            'assets/images/onboarding.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const ColoredBox(color: Color(0xFF19231F));
            },
          ),

          // =========================
          // DARK OVERLAY
          // =========================
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE6000000),
                  Color(0x33000000),
                  Color(0x66000000),
                  Color(0xCC19231F),
                  Color(0xFF19231F),
                ],
                stops: [0.0, 0.30, 0.55, 0.75, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),

          // =========================
          // CONTENT
          // =========================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 35),

                  // =========================
                  // HEADING
                  // =========================
                  const Text(
                    'مُبسِّط يجعل التعلم مُبسَّط مع الذكاء الاصطناعي',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      height: 0.98,
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const Spacer(),

                  // =========================
                  // USE EMAIL OR PHONE
                  // =========================
                  _PrimaryButton(
                    label: 'Use Email or Phone',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // =========================
                  // GOOGLE BUTTON
                  // =========================
                  _GoogleButton(onPressed: () {}),

                  const SizedBox(height: 22),

                  // =========================
                  // CONTINUE AS GUEST
                  // =========================
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB8B8B8),
                    ),
                    child: const Text(
                      'Continue as guest',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PRIMARY BUTTON
// =====================================================

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,

          // Off-white color from the design
          backgroundColor: const Color(0xFFF5F5FA),

          // Black button text
          foregroundColor: Colors.black,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// =====================================================
// GOOGLE BUTTON
// =====================================================

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,

          // White outline
          side: const BorderSide(color: Colors.white, width: 1.5),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleLogo(),

            const SizedBox(width: 12),

            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// GOOGLE LOGO
// =====================================================

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/google_icon.png',
      width: 26,
      height: 26,

      // Fallback if Google logo is not found
      errorBuilder: (_, __, ___) {
        return Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Text(
            'G',
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
