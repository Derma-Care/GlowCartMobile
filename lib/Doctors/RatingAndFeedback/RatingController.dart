import 'package:flutter/material.dart';

import 'RatingModal.dart';
import 'RatingService.dart';

class RatingScreen extends StatefulWidget {
  final String hospitalId;
  final String doctorId;

  const RatingScreen(
      {super.key, required this.hospitalId, required this.doctorId});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  late Future<RatingSummary> ratingFuture;

  @override
  void initState() {
    super.initState();
    ratingFuture = fetchAndSetRatingSummary(widget.hospitalId, widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ratings")),
      body: FutureBuilder<RatingSummary>(
        future: ratingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Overall Doctor Rating: ${data.overallDoctorRating.toStringAsFixed(1)}"),
                Text(
                    "Overall Hospital Rating: ${data.overallHospitalRating.toStringAsFixed(1)}"),
                SizedBox(height: 20),
                Text("Comments:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.comments.length,
                    itemBuilder: (context, index) {
                      final comment = data.comments[index];
                      return Card(
                        child: ListTile(
                          title: Text(comment.feedback),
                          subtitle: Text(
                              'Doctor: ${comment.doctorRating}, Hospital: ${comment.hospitalRating}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
