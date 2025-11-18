import 'package:cutomer_app/Customers/GetCustomerModel.dart';
import 'package:cutomer_app/Dashboard/GetCustomerData.dart';
import 'package:cutomer_app/Doctors/RatingAndFeedback/RatingModal.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeago;
import '../ListOfDoctors/DoctorController.dart';
import '../ListOfDoctors/HospitalAndDoctorModel.dart';

class Allfeedbacks extends StatefulWidget {
  final HospitalDoctorModel item;
  final DoctorController controller;
  final RatingSummary rating;

  const Allfeedbacks(
      {super.key,
      required this.item,
      required this.controller,
      required this.rating});

  @override
  State<Allfeedbacks> createState() => _AllfeedbacksState();
}

class _AllfeedbacksState extends State<Allfeedbacks> {
  @override
  Widget build(BuildContext context) {
    final doctor = widget.item.doctor;

    return Scaffold(
      appBar: CommonHeader(
        title: "All Feedbacks",
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor, Color.fromARGB(255, 255, 255, 255)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ), // ✅ Your custom gradient function
              borderRadius: BorderRadius.circular(8), // optional
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // optional
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${doctor.doctorName}, ${doctor.qualification}",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold), // ensure text is visible
                      ),
                      Text(
                        "${doctor.specialization} ",
                        style: const TextStyle(
                            color: Color.fromARGB(
                                255, 50, 40, 40)), // ensure text is visible
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "Overal Rating",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          widget.rating.overallDoctorRating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Text("(${widget.rating.comments.length} Reviews)",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Rating

                  const SizedBox(height: 16),

                  // Comments
                  ...widget.rating.comments.map((comment) {
                    return FutureBuilder<GetCustomerModel?>(
                      future: fetchUserData(comment.customerMobileNumber),
                      builder: (context, snapshot) {
                        final customerName = snapshot.hasData
                            ? capitalizeEachWord(snapshot.data!.fullName)
                            : "Anonymous";

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.shade300,
                                    child: Text(
                                      comment.patientNamme.isNotEmpty
                                          ? comment.patientNamme[0]
                                              .toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Comment Body
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Name + Rating Row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                comment.patientNamme,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.amber),
                                                Text(
                                                  comment.doctorRating
                                                      .toStringAsFixed(
                                                          1), // 1 decimal
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Time ago
                                        Text(
                                          timeago
                                              .format(comment.parsedDateTime),
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),

                                        const SizedBox(height: 4),

                                        // Feedback
                                        Text(
                                          comment.feedback,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color.fromARGB(161, 158, 158, 158),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
