import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../services/api_service.dart';

/// Standalone "Menu" screen for the Mubasset app.
/// Run on its own with: flutter run -t lib/menu_screen.dart
/// Or drop `MenuScreen` into your app and delete `main` / `MenuApp` below.

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const MenuScreen(),
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

// ── Data ─────────────────────────────────────────────────────────────────
class _Recent {
  final String title, preview, time;

  const _Recent(this.title, this.preview, this.time);
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _fullName = 'User';
  String? _avatarUrl;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ── Load logged-in user from Django ─────────────────────────────────────
  Future<void> _loadUser() async {
    try {
      final data = await ApiService.getMe();

      if (!mounted) return;

      setState(() {
        _fullName = data['fullName']?.toString().trim().isNotEmpty == true
            ? data['fullName'].toString()
            : 'User';

        _avatarUrl = data['avatarUrl']?.toString();

        _isLoadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingUser = false;
      });

      debugPrint('Failed to load user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: _newChatButton(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'RECENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: _muted,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'MUBASSET',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: _muted,
                      ),
                    ),
                  ),

                  _navTile(Icons.home_outlined, 'Home'),
                  _navTile(Icons.school_outlined, 'My Learning'),
                  _navTile(Icons.quiz_outlined, 'Quizzes'),
                  _navTile(Icons.menu_book_outlined, 'Study Materials'),
                  _navTile(Icons.document_scanner_outlined, 'Scan & Learn'),
                  _navTile(Icons.insights_outlined, 'My Progress'),
                  _navTile(Icons.lightbulb_outline, 'Recommendations'),
                  _navTile(Icons.bookmark_border, 'Saved'),
                  _navTile(Icons.settings_outlined, 'Settings'),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: _line,
            ),
            _userRow(),
          ],
        ),
      ),
    );
  }

  // ── Sections ────────────────────────────────────────────────────────────
  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              size: 20,
              color: _ink,
            ),
          ),
          const Expanded(
            child: Text(
              'Menu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
          const Icon(
            Icons.search,
            size: 24,
            color: _ink,
          ),
        ],
      ),
    );
  }

  Widget _newChatButton() {
    return Material(
      color: _dark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 14),
              Text(
                'New Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentTile(_Recent r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: _dark,
            child: Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      r.time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  r.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _mint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: _green,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: _muted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── User profile row ────────────────────────────────────────────────────
  Widget _userRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          _buildAvatar(),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoadingUser ? 'Loading...' : _fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),

                const SizedBox(height: 2),

                const Row(
                  children: [
                    Text(
                      'Free plan · ',
                      style: TextStyle(
                        fontSize: 13,
                        color: _muted,
                      ),
                    ),
                    Text(
                      'Upgrade',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile avatar ──────────────────────────────────────────────────────
  Widget _buildAvatar() {
    // User has an uploaded avatar
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: _mint,
        backgroundImage: NetworkImage(_avatarUrl!),
      );
    }

    // No avatar → show initials
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _mint,
        shape: BoxShape.circle,
      ),
      child: Text(
        _getInitials(_fullName),
        style: const TextStyle(
          color: _green,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Generate initials from user's name ──────────────────────────────────
  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}