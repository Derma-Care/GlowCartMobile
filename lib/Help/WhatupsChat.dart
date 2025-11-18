import 'package:flutter/material.dart';
import 'package:whatsapp_chatbot/whatsapp_chatbot.dart';

class WhatsappChatScreen extends StatelessWidget {
  final Config config;

  const WhatsappChatScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // This ensures that the content is not cut off by system UI elements like status bar.
        child: Column(
          children: [
            Expanded(
              child: WhatsappChatBot(
                settings: config,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
