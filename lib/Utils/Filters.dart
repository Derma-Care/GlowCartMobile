import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorController.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

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
