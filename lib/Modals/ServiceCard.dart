import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Services/OnlySUbServiceView.dart';
import '../TreatmentAndServices/ServiceSelectionScreen.dart';
import '../Services/serviceb.dart';

class ServiceCard extends StatefulWidget {
  final Serviceb service;
  final String mobileNumber;
  final String username;

  const ServiceCard({
    super.key,
    required this.service,
    required this.mobileNumber,
    required this.username,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Get.to(() => SelectServicesPage(
        //       categoryId: widget.service.categoryId,
        //       categoryName: widget.service.categoryName,
        //       mobileNumber: widget.mobileNumber,
        //       username: widget.username,
        //     ));

        Get.to(() => Onlysubserviceview(
              categoryId: widget.service.categoryId,
              categoryName: widget.service.categoryName,
              mobileNumber: widget.mobileNumber,
              username: widget.username,
            ));

        print('Tapped on ${widget.service.categoryId}');
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          width: double
              .infinity, // Ensure the card takes the full width of its parent
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: double.infinity, // Full width of the container

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(5.0),
                      ),
                    ),
                    child: widget.service.categoryImage != null
                        ? Image.memory(
                            widget.service.categoryImage,
                            width: double.infinity, // Full width

                            fit: BoxFit
                                .cover, // Covers the container proportionally
                          )
                        : Image.asset(
                            'assets/default_image.png',
                            width: double.infinity, // Full width
                            fit: BoxFit
                                .contain, // Covers the container proportionally
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 7.0),
                child: Text(
                  widget.service.categoryName,

                  // Null check
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      height: 1.2,
                      wordSpacing: 0),

                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
