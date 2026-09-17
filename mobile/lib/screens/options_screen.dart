import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Login_Feature/login.dart';
import '../services/api_service.dart';

/// Standalone "Options" screen (right screen of the Mubasset mockup).
/// Run on its own with:  flutter run -t lib/options_screen.dart
/// Or drop `OptionsScreen` into your app and delete `main` / `OptionsApp` below.


class OptionsApp extends StatelessWidget {
  const OptionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OptionsScreen(),
    );
  }
}

// ── Palette ──────────────────────────────────────────────────────────────
const _dark = Color(0xFF1E2621);
const _green = Color(0xFF2E9E6B);
const _mint = Color(0xFFE7F4EC);
const _ink = Color(0xFF15201A);
const _muted = Color(0xFF8B938D);
const _line = Color(0xFFEDEFEE);
const _bg = Color(0xFFF5F7F6);
const _danger = Color(0xFFE5484D);

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool _mute = true;
  bool _pin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  _profileCard(),
                  const SizedBox(height: 20),
                  _card([
                    _rowTile(
                      icon: Icons.search,
                      label: 'Search in conversation',
                      trailing: const _Chevron(),
                    ),
                    _inset(),
                    _rowTile(
                      icon: Icons.notifications_none,
                      label: 'Mute notifications',
                      trailing: CupertinoSwitch(
                        value: _mute,
                        activeTrackColor: _green,
                        onChanged: (v) => setState(() => _mute = v),
                      ),
                    ),
                    _inset(),
                    _rowTile(
                      icon: Icons.push_pin_outlined,
                      label: 'Pin chat',
                      trailing: CupertinoSwitch(
                        value: _pin,
                        activeTrackColor: _green,
                        onChanged: (v) => setState(() => _pin = v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _card([
                    _rowTile(
                      icon: Icons.download_outlined,
                      label: 'Export chat',
                      trailing: const _Chevron(),
                    ),
                    _inset(),
                    _rowTile(
                      icon: Icons.ios_share,
                      label: 'Share chat',
                      trailing: const _Chevron(),
                    ),
                    _inset(),
                    _rowTile(
                      icon: Icons.delete_outline,
                      label: 'Clear conversation',
                      trailing: const _Chevron(),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _card([
                    _rowTile(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      trailing: const _Chevron(),
                    ),
                    _inset(),
                    _rowTile(
                      icon: Icons.info_outline,
                      label: 'About Mubasset',
                      trailing: const _Chevron(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _deleteButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sections ─────────────────────────────────────────────────────────────
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _ink),
          ),
          const Expanded(
            child: Text(
              'Options',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _ink),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mubasset chatbot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('Online', style: TextStyle(color: _green, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(children: children),
    );
  }

  Widget _inset() => const Padding(
        padding: EdgeInsets.only(left: 70),
        child: Divider(height: 1, thickness: 1, color: _line),
      );

  Widget _rowTile({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: _mint, shape: BoxShape.circle),
              child: Icon(icon, color: _green, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          // Show confirmation dialog
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Log out'),
                content: const Text(
                  'Are you sure you want to log out?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Log out'),
                  ),
                ],
              );
            },
          );

          if (shouldLogout != true) {
            return;
          }

          try {
            await ApiService.logout();

            if (!context.mounted) return;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          } catch (e) {
            print('Logout error: $e');
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: const BorderSide(
            color: _danger,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Log out',
          style: TextStyle(
            color: _danger,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.chevron_right, color: _muted, size: 22);
  }
}
