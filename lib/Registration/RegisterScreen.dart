import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../Inputs/CustomInputField.dart';
import '../Loading/FullScreeenLoader.dart';
import 'RegisterController.dart';
import '../Utils/CopyRigths.dart';
import '../Utils/DateInputFormat.dart';
import '../Utils/ElevatedButtonGredint.dart';

class RegisterScreen extends StatefulWidget {
  final String fullName;
  final String mobileNumber;

  const RegisterScreen({
    super.key,
    required this.fullName,
    required this.mobileNumber,
  });

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Registercontroller registercontroller = Registercontroller();

  @override
  void initState() {
    super.initState();
    if (widget.fullName.isNotEmpty) {
      registercontroller.nameController.text =
          capitalizeEachWord(widget.fullName);
    } else {
      registercontroller.nameController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: LoaderOverlay(
        overlayColor: const Color.fromARGB(149, 36, 35, 35),
        useDefaultLoading: false,
        overlayWidgetBuilder: (context) => const FullscreenLoader(
          message: "Your data is being sent securely.\nPlease wait...",
          logoPath: 'assets/DermaText.png',
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/ic_launcher.png',
                width: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'Basic Details',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: registercontroller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: registercontroller.nameController,
                          labelText: 'Full Name',
                          enabled: false,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextField(
                          controller: registercontroller.emailController,
                          labelText: 'Enter Email ID',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              registercontroller.validateEmail(value),
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextField(
                          controller: registercontroller.dateOfBirthController,
                          labelText: 'Date of Birth',
                          keyboardType: TextInputType.number,
                          hintText: "DD/MM/YYYY",
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                            DateInputFormatter(),
                          ],
                          validator: (value) =>
                              registercontroller.validateDOB(value),
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextField(
                          controller: registercontroller.referralController,
                          labelText: 'Referral Code (Optional)',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 20.0),
                        if (registercontroller.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              registercontroller.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              registercontroller.genderOptions.map((gender) {
                            final bool isSelected =
                                registercontroller.selectedGender == gender;
                            return Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    registercontroller.selectedGender = gender;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected ? mainColor : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? mainColor
                                          : Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      gender,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 110,
        color: Colors.white,
        child: Column(
          children: [
            GradientButton(
              text: "SUBMIT",
              onPressed: () => registercontroller.submitForm(
                context,
                widget.fullName,
                widget.mobileNumber,
              ),
            ),
            Copyrights(
              padding: const EdgeInsets.only(top: 10.0, bottom: 0.0),
            )
          ],
        ),
      ),
    );
  }
}
