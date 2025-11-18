// ignore: file_names
import 'package:cutomer_app/SigninSignUp/LoginScreen.dart';
import 'package:cutomer_app/Screens/splashScreen.dart';

import 'package:cutomer_app/Terms/TermsAndConditionsScreen.dart';
import 'package:cutomer_app/UserManuval/AppointmentManual.dart';
import 'package:flutter/material.dart';

import '../Help/HelpDesk.dart';
import '../Registration/RegisterScreen.dart';

var onGenerateRoute = (RouteSettings settings) {
  print('my routs: ${settings.name}');
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (builder) => const SplashScreen());

    case "/login":
      return MaterialPageRoute(builder: (builder) => Loginscreen());

    case "/termsandcondition":
      return MaterialPageRoute(
          builder: (builder) => TermsAndConditionsScreen());

    case "/manualscreen":
      return MaterialPageRoute(
          builder: (builder) => AppointmentManualScreen());

// termsandcondition

    case "/gethelp":
      return MaterialPageRoute(builder: (builder) => HelpDeskScreen());

    case "/registerScreen":
      final args = settings.arguments as List; // Expecting a List of arguments
      final fullName = args[0] as String; // Extract username
      final mobileNumber = args[1] as String; // Extract mobile number

      return MaterialPageRoute(
        builder: (_) => RegisterScreen(
          fullName: fullName,
          mobileNumber: mobileNumber, // Pass mobile number
        ),
      ); // Pass the fullName here

    default:
  }
};
