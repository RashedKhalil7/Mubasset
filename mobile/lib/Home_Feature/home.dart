import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/menu_screen.dart';
import '../screens/options_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // =====================================================
  // CONTROLLERS
  // =====================================================

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  // =====================================================
  // STATE
  // =====================================================

  bool _isLoading = false;

  // Messages displayed in the Flutter UI.
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'مرحبًا! أنا مبسط مساعدك التعليمي الشخصي. كيف يمكنني مساعدتك اليوم؟',
      isUser: false,
      time: 'Now',
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    // Don't send an empty message.
    if (text.isEmpty || _isLoading) {
      return;
    }

    // Add user's message to the UI.
    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: true, time: _currentTime()),
      );

      _isLoading = true;
    });

    // Clear the input field.
    _messageController.clear();

    // Scroll down so the new message is visible.
    _scrollToBottom();

    try {
      final data = await ApiService.chat(message: text);
      final answer = (data['answer'] as String?)?.trim();
      if (answer == null || answer.isEmpty) {
        throw Exception('The assistant returned an empty response.');
      }

      // Add Gemini's answer to the UI.
      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(text: answer, isUser: false, time: _currentTime()),
        );

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _messages.add(
          _ChatMessage(
            text:
                'تعذر الاتصال بالمساعد الآن.\n\n'
                '${_readableError(e)}',
            isUser: false,
            time: _currentTime(),
          ),
        );
      });

      debugPrint('Chatbot error: $e');

      _scrollToBottom();
    }
  }

  String _readableError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      return 'تأكد من تشغيل الخادم وأن عنوان API مناسب لجهازك.';
    }
    return message.isEmpty
        ? 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.'
        : message;
  }

  // =====================================================
  // CURRENT TIME
  // =====================================================

  String _currentTime() {
    final now = DateTime.now();

    final hour = now.hour == 0
        ? 12
        : now.hour > 12
        ? now.hour - 12
        : now.hour;

    final minute = now.minute.toString().padLeft(2, '0');

    final period = now.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // =====================================================
  // SCROLL TO BOTTOM
  // =====================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===================================================
      // APP BAR
      // ===================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: const Text(
          'Mubasset chatbot',
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            );
          },
          icon: const Icon(Icons.menu, color: Colors.black, size: 32),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OptionsScreen()),
              );
            },
            icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
          ),
        ],
      ),

      // ===================================================
      // BODY
      // ===================================================
      body: SafeArea(
        child: Column(
          children: [
            // ===============================================
            // CHAT AREA
            // ===============================================

            Expanded(
              child: ListView(
                controller: _scrollController,

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),

                children: [
                  // =========================================
                  // ROBOT AVATAR
                  // =========================================

                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF19231F),
                      border: Border.all(
                        color: const Color(0xFF12A277),
                        width: 6,
                      ),
                    ),

                    child: Center(
                      child: Container(
                        width: 205,
                        height: 205,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),

                        child: Center(
                          child: SvgPicture.asset(
                            'assets/images/robot.svg',
                            width: 85,
                            height: 85,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =========================================
                  // CHAT MESSAGES
                  // =========================================
                  ..._buildMessages(),

                  // =========================================
                  // TYPING INDICATOR
                  // =========================================
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 20),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF19231F),
                            ),

                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/robot.svg',
                                width: 27,
                                height: 27,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFF19231F),
                              borderRadius: BorderRadius.circular(24),
                            ),

                            child: const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 60),
                ],
              ),
            ),

            // =================================================
            // MESSAGE INPUT
            // =================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),

              child: Row(
                children: [
                  // ===========================================
                  // PLUS BUTTON
                  // ===========================================

                  Container(
                    width: 42,
                    height: 42,

                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF19231F),
                    ),

                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ===========================================
                  // TEXT FIELD
                  // ===========================================
                  Expanded(
                    child: Container(
                      height: 44,

                      padding: const EdgeInsets.symmetric(horizontal: 18),

                      decoration: BoxDecoration(
                        color: const Color(0xFF19231F),
                        borderRadius: BorderRadius.circular(25),
                      ),

                      child: TextField(
                        controller: _messageController,

                        enabled: !_isLoading,

                        textInputAction: TextInputAction.send,

                        onSubmitted: (_) {
                          _sendMessage();
                        },

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),

                        decoration: const InputDecoration(
                          hintText: 'Message Mubasset chatbot...',
                          hintStyle: TextStyle(
                            color: Color(0xFF8995B5),
                            fontSize: 14,
                          ),

                          border: InputBorder.none,

                          contentPadding: EdgeInsets.only(bottom: 10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ===========================================
                  // SEND BUTTON
                  // ===========================================
                  Container(
                    width: 50,
                    height: 50,

                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF19231F),
                    ),

                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,

                      icon: SvgPicture.asset(
                        'assets/images/send.svg',
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // BUILD CHAT MESSAGES
  // =====================================================

  List<Widget> _buildMessages() {
    final widgets = <Widget>[];

    for (final message in _messages) {
      if (message.isUser) {
        widgets.add(
          Align(
            alignment: Alignment.centerRight,

            child: _MessageBubble(
              text: message.text,
              time: message.time,
              isUser: true,
            ),
          ),
        );
      } else {
        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // Small bot avatar
              Container(
                width: 45,
                height: 45,

                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF19231F),
                ),

                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/robot.svg',
                    width: 27,
                    height: 27,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Bot message
              Expanded(
                child: _MessageBubble(
                  text: message.text,
                  time: message.time,
                  isUser: false,
                ),
              ),
            ],
          ),
        );
      }

      widgets.add(const SizedBox(height: 20));
    }

    return widgets;
  }
}

// =====================================================
// CHAT MESSAGE MODEL
// =====================================================

class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

// =====================================================
// MESSAGE BUBBLE
// =====================================================

class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isUser;

  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: isUser ? null : const BoxConstraints(maxWidth: 330),

      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),

      decoration: BoxDecoration(
        color: const Color(0xFF19231F),
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // MESSAGE
          Text(
            text,
            textDirection: RegExp(r'[\u0600-\u06FF]').hasMatch(text)
                ? TextDirection.rtl
                : TextDirection.ltr,
            textAlign: RegExp(r'[\u0600-\u06FF]').hasMatch(text)
                ? TextAlign.right
                : TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 5),

          // TIME
          Align(
            alignment: Alignment.bottomRight,

            child: Text(
              time,
              style: const TextStyle(color: Color(0xFFA0A7B8), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
