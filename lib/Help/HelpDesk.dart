import 'package:cutomer_app/Help/Numbers.dart';
import 'package:cutomer_app/Help/WhatupsChat.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_chatbot/whatsapp_chatbot.dart';

import 'HelpBottomSheet.dart';

class HelpDeskScreen extends StatelessWidget {
  HelpDeskScreen({super.key});

  Future<List<Map<String, String>>> fetchFAQs() async {
    // Simulate fetching FAQs from a backend
    await Future.delayed(const Duration(seconds: 2));
    return [
      {
        'question': 'How to reset my password?',
        'answer':
            'To reset your password, go to the settings page and click on "Reset Password". Follow the instructions to reset it.'
      },
      {
        'question': 'How to update my profile?',
        'answer':
            'To update your profile, go to the "Profile" section and click "Edit Profile". You can modify your details there.'
      },
      {
        'question': 'Why is OTP not received?',
        'answer':
            'Make sure that your mobile number is correct. If the OTP is not received, try resending it or check your network connection.'
      },
      {
        'question': 'How to contact customer service?',
        'answer':
            'You can contact customer service by going to the "Support" section in the app and choosing your preferred contact method.'
      },
      {
        'question': 'How to report a service issue?',
        'answer':
            'To report a service issue, go to the "Service Issues" section and submit a ticket. Our team will get back to you shortly.'
      },
    ];
  }

  final config = Config(
    botDelay: 3,
    waitText: 'Bot Thinking...',
    defaultResponseMessage: "Sorry! I didn't catch that!\nPlease try again!",
    keywords: [
      'hello',
      'hi',
      'how are you',
    ],
    response: [
      'Hi\nHow can I assist you today?',
      'Hello!\nHow can I be of help?',
      'I am doing great!',
    ],
    greetings: "Hi there\uD83D\uDC4B\uD83C\uDFFE\nHow can I help you?",
    headerText: 'SureCare ',
    subHeaderText: 'Online',
    buttonText: 'Start Chat',
    buttonColor: Color.fromARGB(255, 40, 1, 88),
    chatIcon: const Icon(Icons.person),
    headerColor: Color.fromARGB(255, 40, 1, 88),
    message: 'Hello! This is a direct WhatsApp message.',
    phoneNumber: '+233550138086',
    chatBackgroundColor: const Color.fromARGB(255, 238, 231, 223),
    onlineIndicator: const Color.fromARGB(255, 37, 211, 102),
  );

  void _showBottomSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return HelpDeskBottomScreen(
          phoneNumber: '898509173803', issues: title,
          // Pass the phone number here
        );
      },
    );
  }

 

  @override
  Widget build(BuildContext context) {
    final BoxDecoration containerDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help Desk',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildHelpOption(
              title: 'Service-Related Issues',
              icon: Icons.build,
              color: const Color.fromARGB(255, 243, 164, 190),
              onTap: () => _showBottomSheet(context, "Service-Related Issues"),
              decoration: containerDecoration,
            ),
            const SizedBox(height: 16),
            _buildHelpOption(
              title: 'Login Issues',
              icon: Icons.login,
              color: const Color.fromARGB(255, 122, 202, 239),
              onTap: () => _showBottomSheet(context, 'Login Issues'),
              decoration: containerDecoration,
            ),
            const SizedBox(height: 16),
            _buildHelpOption(
              title: 'OTP Issues',
              icon: Icons.message,
              color: const Color.fromARGB(255, 165, 236, 202),
              onTap: () => _showBottomSheet(context, 'OTP Issues'),
              decoration: containerDecoration,
            ),
            const SizedBox(height: 16),
            _buildHelpOption(
              title: 'Troubleshoot Issues',
              icon: Icons.bug_report,
              color: const Color.fromARGB(255, 239, 183, 122),
              onTap: () => _showBottomSheet(context, 'Troubleshoot Issues'),
              decoration: containerDecoration,
            ),
            const SizedBox(height: 40),
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, String>>>(
              future: fetchFAQs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final faq = snapshot.data![index];
                      return ExpansionTile(
                        title: Text(faq['question'] ?? 'No Question'),
                        children: [
                          ListTile(
                            title: Text(faq['answer'] ?? 'No Answer'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  return const Text('No FAQs available');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
       await whatsUpChat("7842259803");
        },
        child: const FaIcon(
          FontAwesomeIcons.whatsapp,  
          color: Colors.white,
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        tooltip: 'WhatsApp Chat',
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/surecare_launcher.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 33, 33, 33),
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHelpOption({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required BoxDecoration decoration,
  }) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: decoration.copyWith(color: color),
          child: Row(
            children: [
              Icon(icon, size: 28, color: const Color.fromARGB(255, 0, 0, 0)),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
