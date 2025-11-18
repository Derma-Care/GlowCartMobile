import 'package:cutomer_app/Help/Numbers.dart';
import 'package:flutter/material.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_chatbot/whatsapp_chatbot.dart';

class HelpDeskBottomScreen extends StatelessWidget {
  final String phoneNumber;
  final String issues;

  HelpDeskBottomScreen({
    super.key,
    required this.phoneNumber,
    required this.issues,
  });

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
    greetings: "Hi there👋🏾\nHow can I help you?",
    headerText: 'Iksoft Technologies',
    subHeaderText: 'Online',
    buttonText: 'Start Chat',
    buttonColor: const Color.fromARGB(255, 73, 4, 4),
    chatIcon: const Icon(Icons.person),
    headerColor: const Color.fromARGB(255, 73, 4, 4),
    message: 'Hello! This is a direct WhatsApp message.',
    phoneNumber: '+233550138086',
    chatBackgroundColor: const Color.fromARGB(255, 238, 231, 223),
    onlineIndicator: const Color.fromARGB(255, 37, 211, 102),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              issues,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.call, color: Colors.blue, size: 30),
              title: const Text(
                'Request a Callback',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () => _requestCallback(context),
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.green, size: 30),
                title: Text(
                  'Call Now \n ${customerNumber}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  await customerCare("7842259803");
                }),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.green, size: 30),
              title: Text(
                'Email \n ${emailID}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () => openGmail(),
            ),
          ),
        ],
      ),
    );
  }

  void _requestCallback(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Callback request submitted')),
    );
  }

  void _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneUri');
    }
  }

  void openGmail() async {
    const email = 'surecare@gmail.com';
    const subject = 'Subject Placeholder';
    const body = 'Body Placeholder';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject&body=$body', // Add subject and body if needed
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print('Could not launch $emailUri');
    }
  }

  static void showHelpDeskBottomSheet(
      BuildContext context, String phoneNumber, String title) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return HelpDeskBottomScreen(
          phoneNumber: phoneNumber,
          issues: title,
        );
      },
    );
  }
}
