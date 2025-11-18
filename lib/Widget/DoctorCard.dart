import 'dart:convert';

import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../Doctors/ListOfDoctors/DoctorController.dart';
import '../Doctors/DoctorDetails/DoctorDetailsScreen.dart';
import '../Doctors/Schedules/Schedule.dart';
import '../Utils/GradintColor.dart';

Widget buildDoctorCard(
    BuildContext context,
    HospitalDoctorModel doctorModel,
    DoctorController controller,
    String mobileNumber,
    String username,
    String branchId) {
  final doctor = doctorModel.doctor;
  final hospital = doctorModel.hospital;
  String base64String = doctor.doctorPicture;
  final regex = RegExp(r'data:image/[^;]+;base64,');
  base64String = base64String.replaceAll(regex, '');
  final doctorController = Get.find<DoctorController>();
// Remove the prefix if present
  final prefix = 'data:image/jpeg;base64,';
  if (base64String.startsWith(prefix)) {
    base64String = base64String.substring(prefix.length);
  }

  print(" doctorModel.hospital.toString() ${doctorModel.hospital.branch}");
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      gradient:
          doctor.doctorAvailabilityStatus ? appGradient() : appGradientGrey(),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          // Row(
          //   children: [
          //     Expanded(
          //       child: RichText(
          //         text: TextSpan(
          //           children: [
          //             TextSpan(
          //               text: "${hospital.name} ",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.white,
          //                 fontSize: 16,
          //               ),
          //             ),
          //             TextSpan(
          //               text:
          //                   "(${(hospital.branch != null && hospital.branch!.isNotEmpty) ? hospital.branch : (hospital.city != null && hospital.city!.isNotEmpty) ? hospital.city : "Jubilee Hillss"})",
          //               style: const TextStyle(
          //                 color: Colors.white70,
          //                 fontSize: 14,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),

          //     Row(
          //       children: [
          //         const Icon(FontAwesomeIcons.hospital,
          //             size: 14, color: Colors.yellow),
          //         const SizedBox(width: 8),
          //         Text(
          //           hospital.hospitalOverallRating?.toStringAsFixed(1) ?? "0.0",
          //           style: const TextStyle(color: Colors.white),
          //         ),
          //       ],
          //     ),

          //     // IconButton( //TODO:implement pending
          //     //   icon: Icon(
          //     //     Icons.thumb_up,
          //     //     color: doctor.favorites ? Colors.yellow : Colors.white60,
          //     //   ),
          //     //   onPressed: () => controller.toggleFavorite(doctorModel),
          //     // ),
          //   ],
          // ),
          // const SizedBox(height: 8),

          // Doctor details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image with Verified + Availability
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            MemoryImage(base64Decode(base64String)),
                        onBackgroundImageError: (_, __) =>
                            const Icon(Icons.person, size: 35),
                      ),

                      // Verified icon bottom-right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 16,
                            color: mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  // Availability text
                  // Center(
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 6, vertical: 2),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white, // ✅ White background
                  //       borderRadius: BorderRadius.circular(6),
                  //     ),
                  //     child: Text(
                  //       doctor.doctorAvailabilityStatus
                  //           ? "Available Now"
                  //           : "Not Available",
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //         fontSize: 10,
                  //         fontWeight: FontWeight.bold,
                  //         color: doctor.doctorAvailabilityStatus
                  //             ? Colors.green // ✅ Green when available
                  //             : Colors.red, // ✅ Red when not available
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
              const SizedBox(width: 12),

              // Doctor name + qualification + specialization
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${doctor.doctorName}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: mainColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "(${doctor.qualification})",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${doctor.specialization} ",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rating & Comments & BOOK
          Row(
            children: [
              Row(
                children: [
                  const Icon(FontAwesomeIcons.userDoctor,
                      size: 14, color: Colors.white),

                  const SizedBox(width: 4),
                  // Text("${doctor.overallRating}", //TODO : imaplent pending
                  // Obx(() {
                  //   final rating =
                  //       doctorController.doctorRatings[doctor.doctorId] ?? 0.0;
                  //   return Text(
                  //     rating.toStringAsFixed(1),
                  //     style: TextStyle(color: Colors.white),
                  //   );
                  // })

                  Text("${doctor.doctorAverageRating}/5",
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Obx(() {
                    final comments =
                        doctorController.doctorCommentCounts[doctor.doctorId] ??
                            0;
                    return Text(
                      comments.toString(),
                      style: TextStyle(color: Colors.white),
                    );
                  })

                  // Text("${doctor.comments.length}", //TODO : imaplent pending
                  // Text("10", style: const TextStyle(color: Colors.white)),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => DoctorDetailScreen(doctorData: doctorModel));

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => ScheduleScreen(doctorData: item),
                      //   ),
                      // );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "ABOUT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () {
                      if (doctor.doctorAvailabilityStatus) {
                        // showSn
                        // showSnackbar();
                      }
                      doctor.doctorAvailabilityStatus
                          ? Get.to(() => ScheduleScreen(
                                doctorData: doctorModel,
                                mobileNumber: mobileNumber,
                                username: username,
                                branchId: branchId,
                              ))
                          : null;

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => DoctorDetailScreen(doctorData: item),
                      //   ),
                      // );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        doctor.doctorAvailabilityStatus
                            ? "Consult"
                            : "Unavailable",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: doctor.doctorAvailabilityStatus
                              ? mainColor
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Widget buildFilters(DoctorController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Text(
              "Sort by",
              style: TextStyle(
                  color: mainColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            FilterChip(
              label: Text(
                "A-Z",
                style: TextStyle(
                  color: controller.sortByAZ.value ? Colors.white : mainColor,
                ),
              ),
              selectedColor: mainColor,
              // color: Colors.red,
              selected: controller.sortByAZ.value,
              showCheckmark: false,
              onSelected: (val) {
                controller.sortByAZ.value = val;
                controller.applyFilters();
              },
            ),
            FilterChip(
              label: Icon(
                Icons.male,
                color: controller.selectedGender.value == "Male"
                    ? Colors.white
                    : mainColor,
              ),
              selectedColor: mainColor,
              showCheckmark: false,
              selected: controller.selectedGender.value == "Male",
              onSelected: (val) {
                controller.selectedGender.value = val ? "Male" : "All";
                controller.applyFilters();
              },
            ),
            FilterChip(
              label: Icon(
                Icons.female,
                color: controller.selectedGender.value == "Female"
                    ? Colors.white
                    : mainColor,
              ),
              selectedColor: mainColor,
              showCheckmark: false,
              selected: controller.selectedGender.value == "Female",
              onSelected: (val) {
                controller.selectedGender.value = val ? "Female" : "All";
                controller.applyFilters();
              },
            ),
            // FilterChip(
            //   label: Icon(
            //     Icons.favorite,
            //     color: controller.showFavoritesOnly.value
            //         ? Colors.white
            //         : mainColor,
            //   ),
            //   selectedColor: mainColor,
            //   showCheckmark: false,
            //   selected: controller.showFavoritesOnly.value,
            //   onSelected: (val) {
            //     controller.showFavoritesOnly.value = val;
            //     controller.applyFilters();
            //   },
            // ),
            FilterChip(
              label: Icon(
                Icons.star,
                color: controller.selectedRating.value >= 4.5
                    ? Colors.white
                    : mainColor,
              ),
              selectedColor: mainColor,
              showCheckmark: false,
              selected: controller.selectedRating.value >= 4.5,
              onSelected: (val) {
                controller.selectedRating.value = val ? 4.5 : 0.0;
                controller.applyFilters();
              },
            ),

            //search by city name
            // Row(
            //   children: [
            //     Expanded(
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 12),
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(8),
            //           border: Border.all(color: Colors.grey),
            //         ),
            //         child: DropdownButtonHideUnderline(
            //           child: DropdownButton<String>(
            //             isExpanded: true,
            //             value: controller.selectedCity.value,
            //             onChanged: (value) {
            //               controller.selectedCity.value = value!;
            //               controller.applyFilters();
            //             },
            //             items: controller.cityList
            //                 .map(
            //                   (city) => DropdownMenuItem<String>(
            //                     value: city,
            //                     child: Text(
            //                       // city.isEmpty ? city : "No city available",
            //                       city,
            //                       style: TextStyle(color: mainColor),
            //                     ),
            //                   ),
            //                 )
            //                 .toList(),
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(
            //       width: 10,
            //     ),
            //     // FilterChip(
            //     //   label: Padding(
            //     //     padding: const EdgeInsets.symmetric(vertical: 6.0),
            //     //     child: Text(
            //     //       "Our Recommended",
            //     //       style: TextStyle(
            //     //         color: controller.selectedRecommended.value
            //     //             ? Colors.white
            //     //             : mainColor,
            //     //       ),
            //     //     ),
            //     //   ),
            //     //   selectedColor: mainColor,
            //     //   showCheckmark: false,
            //     //   selected:
            //     //       controller.selectedRecommended.value, // expects a bool

            //     //   onSelected: (val) {
            //     //     controller.selectedRecommended.value = val;
            //     //     controller.applyFilters();
            //     //   },
            //     // ),
            //   ],
            // ),
          ],
        ),
      ],
    ),
  );
}
