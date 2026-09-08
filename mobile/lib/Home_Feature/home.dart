import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: const Text(
          'Mubasset chatbot',
          style: TextStyle(
            color: Colors.black,
            fontSize: 19, // Smaller title
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: Colors.black, size: 32),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // CHAT AREA
            // =========================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
                child: Column(
                  children: [
                    // =========================
                    // ROBOT AVATAR
                    // =========================
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

                    const SizedBox(height: 45),

                    // =========================
                    // USER MESSAGE
                    // =========================
                    Align(
                      alignment: Alignment.centerRight,
                      child: _MessageBubble(
                        text: 'What can you do?',
                        time: '9:40 AM',
                        isUser: true,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // BOT MESSAGE
                    // =========================
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
                            text:
                                'I can answer questions, generate ideas, '
                                'solve problems, explain complex topics, '
                                'and more.\nAsk me anything!',
                            time: '9:40 AM',
                            isUser: false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // USER MESSAGE
                    // =========================
                    Align(
                      alignment: Alignment.centerRight,
                      child: _MessageBubble(
                        text: 'Awesome 👍',
                        time: '9:41 AM',
                        isUser: true,
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),

            // =========================
            // MESSAGE INPUT AREA
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  // PLUS BUTTON
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

                  // MESSAGE FIELD
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF19231F),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Message Mubasset chatbot...',
                        style: TextStyle(
                          color: Color(0xFF8995B5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // SEND BUTTON
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF19231F),
                    ),
                    child: IconButton(
                      onPressed: () {},
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
      // User messages shrink to fit their content.
      // Bot messages can grow up to 330 pixels.
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
          // MESSAGE TEXT
          Text(
            text,
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
