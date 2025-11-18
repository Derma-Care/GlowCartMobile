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
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            Image.asset(
              'assets/ic_launcher.png', // Ensure this path is correct
              width: 150,

              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 30,
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
                      controller: siginSignUpController.nameController,
                      labelText: 'Enter Customer Id',
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      inputFormatters: [
                        UpperCaseTextFormatter(), // 👈 add this custom formatter
                      ],
                      validator: (value) => siginSignUpController.validatedata(
                          value, "Customer Id"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      controller: siginSignUpController.mobileController,
                      labelText: 'Enter Mobile Number',
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) =>
                          siginSignUpController.validateMobileNumber(value),
                      onChanged: (_) {
                        // Revalidate the form when typing
                        siginSignUpController.formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Row(
                        children: [
                          Checkbox(
                            fillColor:
                                MaterialStateProperty.all(secondaryColor),
                            value: siginSignUpController.agreeToTerms,
                            onChanged: (bool? newValue) {
                              setState(() {
                                siginSignUpController.agreeToTerms =
                                    newValue ?? false;
                                siginSignUpController.errorMessage.value =
                                    ""; // Clear error when checkbox is checked
                              });
                            },
                          ),
                          const Text('I Agree to '),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed('/termsandcondition');
                            },
                            child: const Text(
                              'Terms & Conditions',
                              style: TextStyle(color: mainColor),
                            ),
                          ),
                        ],
                      ),
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
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/manualscreen');
              },
              child: const Text(
                'App User Manual',
                style: TextStyle(color: mainColor),
              ),
            ),
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
