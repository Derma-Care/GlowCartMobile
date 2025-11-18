import 'dart:convert';
import 'package:cutomer_app/BottomNavigation/Appoinments/AppointmentController.dart';
import 'package:cutomer_app/ConfirmBooking/ConsultationController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Doctors/RatingAndFeedback/AllFeedbacks.dart';
import 'package:cutomer_app/Doctors/RatingAndFeedback/RatingModal.dart';
import 'package:cutomer_app/Doctors/RatingAndFeedback/RatingService.dart';
import 'package:cutomer_app/Review/ReviewScreen.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:cutomer_app/Widget/CommentController.dart';
import 'package:flutter/material.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/GradintColor.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../Help/Numbers.dart';
import '../../Utils/MapOnGoogle.dart';
import '../ListOfDoctors/DoctorController.dart';
import '../RatingAndFeedback/RatingAndFeedback.dart';

class RatingAndFeedback extends StatefulWidget {
  final HospitalDoctorModel item;
  final DoctorController controller;

  const RatingAndFeedback({
    Key? key,
    required this.item,
    required this.controller,
  }) : super(key: key);

  @override
  State<RatingAndFeedback> createState() => _RatingAndFeedbackState();
}

class _RatingAndFeedbackState extends State<RatingAndFeedback> {
  String? loggedInUserMobile;
  final consultationcontroller = Get.find<Consultationcontroller>();
  final commentController = Get.put(CommentController());

  @override
  void initState() {
    super.initState();
    _loadLoggedInUserMobile();
  }

  Future<void> _loadLoggedInUserMobile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserMobile = prefs.getString('mobileNumber');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RatingSummary>(
      future: fetchAndSetRatingSummary(
        consultationcontroller.selectedBranchId.value,
        widget.item.doctor.doctorId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildEmptyState();
        }

        final ratingSummary = snapshot.data!;
        final userHasRated = loggedInUserMobile != null &&
            ratingSummary.comments.any((c) =>
                c.customerMobileNumber == loggedInUserMobile &&
                c.rated == true);

        return _buildRatingContent(ratingSummary, userHasRated);
      },
    );
  }

  Widget _buildRatingContent(RatingSummary ratingSummary, bool userHasRated) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(ratingSummary),
          const SizedBox(height: 16),
          // _buildRatingBreakdown(ratingSummary),
          const Divider(height: 32),

          if (ratingSummary.comments.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ratingSummary.comments.length.clamp(0, 5),
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) =>
                  _buildCommentTile(ratingSummary.comments[index], index),
            ),

          const SizedBox(height: 16),

          /// Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // if (userHasRated)
              //   OutlinedButton(
              //     onPressed: () async {
              //       final controller = Get.find<AppointmentController>();
              //       final booking = controller.filteredBookings;
              //       final result = await Get.to(() => ReviewScreen(
              //             doctorData: widget.item,
              //             doctorBookings: null, // TODO: check this
              //             mobileNUmber: loggedInUserMobile!,
              //           ));
              //       if (result == true) setState(() {});
              //     },
              //     child: const Text("Rated"),
              //   ),
              if (userHasRated)
                OutlinedButton(
                  onPressed: () {},
                  child: const Text("Rated"),
                ),
              OutlinedButton(
                onPressed: () {
                  Get.to(Allfeedbacks(
                    item: widget.item,
                    controller: widget.controller,
                    rating: ratingSummary,
                  ));
                },
                child: const Text("Read all feedback"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader(RatingSummary ratingSummary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Title & Hospital Rating
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patients Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Hospital Rating : ${ratingSummary.overallHospitalRating.toStringAsFixed(1)}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),

        /// Doctor Rating + Count
        Column(
          children: [
            Row(
              children: [
                _buildStars(ratingSummary.overallDoctorRating),
                const SizedBox(width: 6),
                Text(
                  ratingSummary.overallDoctorRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              "${ratingSummary.count} Reviews",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildRatingBreakdown(RatingSummary ratingSummary) {
  //   if (ratingSummary.ratingCategoryStats.isEmpty) return const SizedBox();

  //   return Column(
  //     children: ratingSummary.ratingCategoryStats.map((stat) {
  //       return Row(
  //         children: [
  //           SizedBox(width: 80, child: Text(stat.category)),
  //           Expanded(
  //             child: LinearProgressIndicator(
  //               value: stat.percentage / 100,
  //               minHeight: 8,
  //               borderRadius: BorderRadius.circular(4),
  //               backgroundColor: Colors.grey.shade300,
  //               color: Colors.amber,
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Text("${stat.count}"),
  //         ],
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _buildStars(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index == fullStars && halfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return const Icon(Icons.star_border, color: Colors.grey, size: 18);
        }
      }),
    );
  }

  Widget _buildCommentTile(Comment comment, int index) {
    final replyController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              comment.patientNamme[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name + Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        capitalizeEachWord(comment.patientNamme),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStars(comment.doctorRating),
                  ],
                ),
                Text(
                  timeago.format(comment.parsedDateTime),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(comment.feedback),

                Obx(() {
                  if (commentController.replyingIndex.value == index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: replyController,
                        decoration: const InputDecoration(
                          hintText: "Write a reply...",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(8),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Patients Feedback',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'No ratings or comments available.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
