import 'package:flutter/material.dart';

class UserManualScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Login & Registration
            sectionTitle("🔐 1. Login & Registration"),
            bulletPoint("Open the app."),
            bulletPoint("Enter your Name and Mobile Number."),
            bulletPoint(
                "You will receive an OTP on your mobile – enter it to verify."),
            bulletPoint("Complete your registration (if first-time user)."),
            bulletPoint("You’ll be redirected to the Dashboard."),

            //Dashboard
            sectionTitle("🏠 2. Dashboard Navigation"),
            bulletPoint("The dashboard displays categories:"),
            subBullet("Service & Treatments"),
            subBullet("In-Clinic Appointment"),
            subBullet("Video Consultation"),
            bulletPoint("Tap on any one category to proceed."),

            //Booking Service & Treatments
            sectionTitle("💆 3. Booking Service & Treatments"),
            bulletPoint("Tap on Service & Treatments from the Dashboard."),
            bulletPoint("Select a Category → Then Service."),
            bulletPoint("A dropdown will show related Subservices."),
            bulletPoint("Select a Subservice to view prices and details."),
            bulletPoint("Choose a Hospital (Recommended or scroll)."),
            bulletPoint("Navigate to Doctors screen for that hospital."),
            bulletPoint(
                "Use filters (Gender, Rating) to find the right doctor."),
            bulletPoint("Choose a Date, Time Slot, and Patient."),
            bulletPoint("Select Payment Option:"),
            subBullet("Online"),
            subBullet("Pay at Hospital"),
            bulletPoint("Booking is confirmed."),
            bulletPoint("View in Appointments Tab."),
            //Booking an In-Clinic Appointment
            sectionTitle("🏥 4. Booking an In-Clinic Appointment"),
            bulletPoint("Tap on In-Clinic Appointment from the Dashboard."),
            bulletPoint("Select a Category → Then Service → Then Subservice."),
            bulletPoint("View Doctors list with:"),
            subBullet("Price"),
            subBullet("Hospital Name"),
            bulletPoint(
                "Select a Doctor → Choose a Date, Time Slot, and Patient."),
            bulletPoint("Choose Payment Method:"),
            subBullet("Online"),
            subBullet("Pay at Hospital"),
            bulletPoint("Appointment is booked successfully."),
            bulletPoint("View it in the Appointments Tab."),

            //Booking a Video Consultation
            sectionTitle("📹 5. Booking a Video Consultation"),
            bulletPoint("Tap on Video Consultation from the Dashboard."),
            bulletPoint("Select a Category → Then choose a Service."),
            bulletPoint("View Doctors list with:"),
            subBullet("Price"),
            subBullet("Hospital Name"),
            bulletPoint(
                "Select a Doctor → Choose a Date, Time Slot, and Patient."),
            bulletPoint("Select a Patient (if multiple profiles exist)."),
            bulletPoint("Choose Payment Method:"),
            subBullet("Online Payment Only (No Pay at Hospital option)."),
            bulletPoint("Appointment is booked successfully."),
            bulletPoint("View it in Online Consultation Tab."),
            // /Profile Tab
            sectionTitle("👤 6. Profile Tab"),
            bulletPoint("View your:"),
            subBullet("Personal details"),
            subBullet("Appointments History"),
            subBullet("Online Consultation History"),
            subBullet("Support/Help Section"),

            //Additional Notes
            sectionTitle("✅ Additional Notes"),
            bulletPoint("All appointment bookings follow:"),
            subBullet("Category → Service → Subservice"),
            subBullet("Hospital → Doctor"),
            subBullet("Date & Slot → Payment"),
            bulletPoint("Video Consultation: Only Online Payment"),
            bulletPoint(
                "In-Clinic & Treatments: Both Online & Pay at Hospital"),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("•  "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget subBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 2.0, bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("◦  "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
