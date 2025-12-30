import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/Utils/CommonCarouselAds.dart';
import 'package:cutomer_app/Utils/UpperCase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../Inputs/CustomInputField.dart';
import '../NetworkCheck/NetworkService.dart';
import '../Utils/Constant.dart';
import '../Utils/CopyRigths.dart';
import '../Utils/ElevatedButtonGredint.dart';
import 'LoginController.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  SiginSignUpController siginSignUpController = SiginSignUpController();
  final dashboardcontroller = Get.put(Dashboardcontroller());
  @override
  void dispose() {
    NetworkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: CommonCarouselAds(
                media: dashboardcontroller.carouselImages,
                height: MediaQuery.of(context).size.height * 0.5,
              ),
            ),

            // Image.asset(
            //   'assets/ic_launcher.png', // Ensure this path is correct
            //   width: 150,

            //   fit: BoxFit.cover,
            // ),
            SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Neha's Glow Kart",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Form(
                key: siginSignUpController.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'User Login',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    CustomTextField(
                      controller: siginSignUpController.mobileController,
                      labelText: 'Enter Mobile Number',
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) =>
                          siginSignUpController.validateMobileNumber(value),
                    ),
                    Obx(() =>
                        siginSignUpController.errorMessage.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  siginSignUpController.errorMessage.value,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : const SizedBox.shrink()),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: GradientButton(
                        text: siginSignUpController.getOTPButton.value,
                        onPressed: siginSignUpController.isLoading.value
                            ? null
                            : () {
                                siginSignUpController.submitForm(context);
                              },
                        child: Obx(() => Text(
                              siginSignUpController.getOTPButton.value,
                              style: const TextStyle(color: Colors.white),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.of(context).pushNamed('/manualscreen');
            //   },
            //   child: const Text(
            //     'App User Manual',
            //     style: TextStyle(color: mainColor),
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Copyrights(
            color: mainColor,
          )),
    );
  }
}
