import 'package:url_launcher/url_launcher.dart';

String customerNumber = "7842259803";
String customerWhatsupNumber = "7842259803";
String emailID = "surecare@gmail.com";

customerCare(clinicNumber) async {
  final Uri callNow = Uri.parse("tel:+91${clinicNumber}");

  // Check if the URL can be launched
  if (await canLaunchUrl(callNow)) {
    // Launch the WhatsApp URL
    await launchUrl(callNow);
  } else {
    // If the URL cannot be launched, show an error or fallback
    print('Could not launch WhatsApp');
  }
}

whatsUpChat(clinicNumber) async {
  final Uri whatsappNumber =
      Uri.parse("https://wa.me/+91${clinicNumber}");

  // Check if the URL can be launched
  if (await canLaunchUrl(whatsappNumber)) {
    // Launch the WhatsApp URL
    await launchUrl(whatsappNumber);
  } else {
    // If the URL cannot be launched, show an error or fallback
    print('Could not launch WhatsApp');
  }
}
