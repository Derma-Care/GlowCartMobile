import 'package:cutomer_app/UserManuval/UserManual.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

class AppointmentManualScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          title: Text('How to Use the App'),
          bottom: TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(
                text: 'Booking',
              ),
              Tab(text: 'Appointments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserManualScreen(),
            AppointmentsTabContent(),
          ],
        ),
      ),
    );
  }
}

class AppointmentsTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('🔜 1. Upcoming Appointments'),
          bullet('Shows appointments with Confirmed or Pending status.'),
          bullet('Includes:'),
          subBullet('Service & Treatments'),
          subBullet('In-Clinic Appointments'),
          bullet('Displays:'),
          subBullet('Appointment Date & Time'),
          subBullet('Doctor Name'),
          subBullet('Hospital/Clinic Name'),
          subBullet('Status: Confirmed / Pending'),
          subBullet('Consultation Type'),
          bullet('Filters:'),
          subBullet('In-Clinic'),
          subBullet('Service & Treatments'),
          sectionTitle('✅ 2. Completed Appointments'),
          bullet('Shows all completed appointments.'),
          bullet('Includes:'),
          subBullet('Video Consultations'),
          subBullet('In-Clinic Appointments'),
          subBullet('Service & Treatments'),
          bullet('Displays:'),
          subBullet('Doctor Name'),
          subBullet('Hospital Name'),
          subBullet('Consultation Type'),
          subBullet('Date & Time'),
          subBullet('Status: Completed'),
          bullet('Filters:'),
          subBullet('Online Consultation'),
          subBullet('In-Clinic'),
          subBullet('Service & Treatments'),
          bullet('Doctor & Hospital Review:'),
          subBullet('Rate the doctor (1 to 5 stars)'),
          subBullet('Rate the hospital'),
          subBullet('Write a review/comment'),
          sectionTitle('📹 3. Online Consultation Tab'),
          bullet('Shows only Online Consultations.'),
          bullet('Includes:'),
          subBullet('Confirmed / Pending appointments'),
          bullet('Displays:'),
          subBullet('Appointment Date & Time'),
          subBullet('Doctor Name'),
          subBullet('Status'),
          subBullet('Type: Online only'),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget subBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('◦ ', style: TextStyle(fontSize: 15)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
