// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cutomer_app/Doctors/Schedules/RelationModel.dart';
import 'package:cutomer_app/Inputs/CustomDropdownField.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Consultations/SymptomsController.dart';
import '../ConfirmBooking/ConsultationController.dart';
import '../Dashboard/GetCustomerData.dart';
import '../Inputs/CustomInputField.dart';
import '../Inputs/CustomTextAera.dart';
import '../Registration/RegisterController.dart';
import '../SigninSignUp/LoginController.dart';
import '../Utils/Constant.dart';
import 'PatientDetailsFormController.dart';

class PatientDetailsForm extends StatefulWidget {
  final String mobileNumber;
  final String username;
  const PatientDetailsForm({
    Key? key,
    required this.mobileNumber,
    required this.username,
  }) : super(key: key);

  @override
  State<PatientDetailsForm> createState() => _PatientDetailsFormState();
}

class _PatientDetailsFormState extends State<PatientDetailsForm> {
  final patientdetailsformcontroller = Get.put(Patientdetailsformcontroller());
  final SymptomsController controller = Get.put(SymptomsController());
  final registercontroller = Get.put(Registercontroller());
  final consultationController = Get.find<Consultationcontroller>();
  final SiginSignUpController siginSignUpController =
      Get.put(SiginSignUpController());
  final TextEditingController _durationController = TextEditingController();
  String? fullName;
  String? age;
  String? address;

  String? _selectedDurationType;
  final List<String> durationTypes = [
    "Hours",
    "Days",
    "Weeks",
    "Months",
    "Years"
  ];
  @override
  void initState() {
    super.initState();
    getUserData();
    fetchRelationData();
  }

  Future<void> fetchRelationData() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    if (customerId != null) {
      await patientdetailsformcontroller.fetchRelations();
    }
  }

  Future<void> getUserData() async {
    print("getUserData called");
    final prefs = await SharedPreferences.getInstance();

    final customerId = prefs.getString('customerId');

    // hospitalId = prefs.getString('hospitalId');

    final userData = await fetchUserData(customerId!);
    print("Fetched userData: $userData");

    if (userData != null && userData.dateOfBirth != null) {
      try {
        print("DOB exists: ${userData.dateOfBirth}");

        // Parse using custom format
        DateFormat formatter = DateFormat("dd-MM-yyyy");
        DateTime dob = formatter.parse(userData.dateOfBirth);

        int calculatedAge = _calculateAge(dob);
        print("Calculated Age: $calculatedAge");

        setState(() {
          fullName = userData.fullName;
          age = calculatedAge.toString();
          String formattedAddress = userData.address != null
              ? "${userData.address.houseNo}, ${userData.address.street}, ${userData.address.city}, ${userData.address.state}, ${userData.address.postalCode}"
              : "";

          patientdetailsformcontroller.addressController.text =
              formattedAddress;

          patientdetailsformcontroller.setAge(age ?? "0");
        });
      } catch (e) {
        print("Error parsing DOB: $e");
      }
    } else {
      print("No DOB available or userData is null");
    }
  }

  int _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickFile() async {
    int currentCount = controller.attachments.length;
    if (currentCount >= 6) {
      _showMessage(context, "You can only upload a maximum of 6 items.");
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          // Check total count
          if (controller.attachments.length >= 6) {
            _showMessage(
                context, "Limit reached (6 items). Extra files skipped.");
            break;
          }

          // ✅ Check file size (200 KB limit)
          final selectedFile = File(file.path!);
          final sizeKB = selectedFile.lengthSync() / 1024;
          if (sizeKB > 200) {
            _showMessage(context,
                "❌ ${file.name} is too large (${sizeKB.toStringAsFixed(2)} KB). Max allowed: 200 KB.");
            continue;
          }

          controller.addAttachment(selectedFile);
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    int currentCount = controller.attachments.length;
    if (currentCount >= 6) {
      _showMessage(context, "You can only upload a maximum of 6 items.");
      return;
    }

    final ImagePicker picker = ImagePicker();

    if (source == ImageSource.gallery) {
      final List<XFile>? pickedFiles = await picker.pickMultiImage();

      if (pickedFiles != null) {
        for (var pickedFile in pickedFiles) {
          if (controller.attachments.length >= 6) {
            _showMessage(
                context, "Limit reached (6 items). Extra images skipped.");
            break;
          }

          final file = File(pickedFile.path);
          print(
              "📷 Original Image Size: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB");

          final compressedFile = await _compressImage(file);
          controller.addAttachment(compressedFile);
        }
      }
    } else {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        if (controller.attachments.length >= 6) {
          _showMessage(context, "Limit reached (6 items). Cannot add more.");
          return;
        }

        final file = File(pickedFile.path);
        print(
            "📷 Original Image Size: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB");

        final compressedFile = await _compressImage(file);
        controller.addAttachment(compressedFile);
      }
    }
  }

  Future<File> _compressImage(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 800,
      minHeight: 800,
      quality: 80,
    );

    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(compressedBytes!);

    final compressedSizeKB = compressedFile.lengthSync() / 1024;
    print(
        "📷 Compressed Image Size: ${compressedSizeKB.toStringAsFixed(2)} KB");

    if (compressedFile.lengthSync() > 100 * 1024) {
      print("⚠️ Image still > 100KB, applying smaller compression...");
      return await _compressImageSmaller(compressedFile);
    }

    return compressedFile;
  }

  Future<File> _compressImageSmaller(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_small_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 600,
      minHeight: 600,
      quality: 60,
    );

    final smallerFile = File(targetPath);
    await smallerFile.writeAsBytes(compressedBytes!);

    final fileSizeKB = smallerFile.lengthSync() / 1024;
    print("📷 Final Small Image Size: ${fileSizeKB.toStringAsFixed(2)} KB");

    return smallerFile;
  }

  /// ✅ Show Snackbar message

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessageSnackbar.show(
      context: context,
      message: "${message}",
      type: SnackbarType.warning,
    );
  }

  void clearForm() {
    print("🧹 Clearing form for Someone...");

    // ✅ Reset controllers
    patientdetailsformcontroller.firstNameController.clear();
    patientdetailsformcontroller.lastNameController.clear();
    patientdetailsformcontroller.nameController.clear();
    patientdetailsformcontroller.relationController.clear();
    patientdetailsformcontroller.ageController.clear();
    patientdetailsformcontroller.addressController.clear();
    patientdetailsformcontroller.patientMobileNumberController.clear();
    patientdetailsformcontroller.selectedTitle = null;

    // ✅ Reset gender
    registercontroller.selectedGender = "Male";

    // ✅ Reset duration and symptoms
    _durationController.clear();
    _selectedDurationType = null;
    patientdetailsformcontroller.notesController.clear();
    controller.clearAttachments(); // Clear files/images in SymptomsController
    // Show the manual form again
    patientdetailsformcontroller.isManualFormVisible.value = true;
    patientdetailsformcontroller.patientId = null;
    // ✅ Trigger UI update
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Form(
      key: patientdetailsformcontroller.formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Patient Details",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          /// Self / Someone toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: ["Self", "Someone"].map((option) {
                  final isSelected =
                      patientdetailsformcontroller.selectedFor.value == option;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? patientdetailsformcontroller.activeColor
                            : patientdetailsformcontroller.inactiveColor,
                        side: BorderSide(
                            color: patientdetailsformcontroller.activeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          patientdetailsformcontroller.selectedFor.value =
                              option;
                        });

                        // ✅ If switching to "Someone", clear previous data
                        // if (option == "Someone") {
                        //   clearForm();
                        // }
                      },
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : patientdetailsformcontroller.activeColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (patientdetailsformcontroller.selectedFor.value == "Someone")
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: clearForm,
                      icon: Icon(Icons.clear, color: Colors.red),
                      label: Text("Clear", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 20),
          patientdetailsformcontroller.selectedFor.value != "Self"
              ? Obx(() {
                  bool isManual =
                      patientdetailsformcontroller.isManualFormVisible.value;

                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Obx(() {
                            if (patientdetailsformcontroller
                                .isLoadingRelations.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final filteredRelations =
                                patientdetailsformcontroller.relations
                                    .where((r) => r.relation != "Self")
                                    .toList();

                            if (filteredRelations.isEmpty) {
                              return DropdownButtonFormField<String>(
                                items: [],
                                onChanged: null,
                                decoration: InputDecoration(
                                  labelText: 'No Relations Found',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }

                            return DropdownButtonFormField<RelationModel>(
                              isExpanded: true,
                              hint: const Text('Select Patient from Relations'),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              items: filteredRelations.map((relation) {
                                return DropdownMenuItem<RelationModel>(
                                  value: relation,
                                  child: Text(
                                      "${relation.fullname} (${relation.relation})"),
                                );
                              }).toList(),
                              onChanged: (selected) {
                                if (selected != null) {
                                  patientdetailsformcontroller
                                      .selectRelation(selected);
                                  // Hide manual form since user picked a relation
                                  patientdetailsformcontroller
                                      .isManualFormVisible.value = true;
                                }
                              },
                              selectedItemBuilder: (context) {
                                return filteredRelations
                                    .map((relation) => Text(
                                        "${relation.fullname} (${relation.relation})"))
                                    .toList();
                              },
                            );
                          }),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // 🔘 Add / Remove Button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (isManual) {
                            // Remove -> go back to dropdown, keep previous values
                            patientdetailsformcontroller
                                .isManualFormVisible.value = false;
                            patientdetailsformcontroller.clearForm();
                            // Do NOT clearForm() here
                          } else {
                            // Add -> show manual form
                            patientdetailsformcontroller
                                .isManualFormVisible.value = true;
                            patientdetailsformcontroller.clearForm();
                            // Only clear if you want a fresh manual form
                          }
                        },
                        icon: Icon(
                          !isManual ? Icons.remove : Icons.add,
                          color: Colors.white,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            !isManual ? "Remove" : "Add",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  );
                })
              : const SizedBox.shrink(),

          SizedBox(
            height: 20,
          ),

          Obx(() {
            print(patientdetailsformcontroller.isManualFormVisible.value);
            if (patientdetailsformcontroller.selectedFor.value.toLowerCase() ==
                    "someone" &&
                patientdetailsformcontroller.isManualFormVisible.value) {
              return const SizedBox.shrink();
            }

            return Column(children: [
              /// Name Field
              patientdetailsformcontroller.selectedFor.value == "Self"
                  ? CustomTextField(
                      controller: TextEditingController(
                          text: fullName ?? widget.username),
                      labelText: 'Full Name (Self)',
                      readOnly: true,
                      enabled: false,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Dropdown for Title
                        DropdownButtonFormField<String>(
                          value: patientdetailsformcontroller.selectedTitle,
                          decoration: InputDecoration(
                            labelText: 'Select Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          items: [
                            "Mr.",
                            "Mrs.",
                            "Miss",
                            "Ms.",
                            "Mx.",
                            "Dr.",
                            "Prof.",
                            "Rev.",
                            "Sir",
                            "Dame",
                            "Lord",
                            "Lady",
                            "Capt.",
                            "Col.",
                            "Gen.",
                            "Hon.",
                          ]
                              .map((title) => DropdownMenuItem(
                                    value: title,
                                    child: Text(title),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            patientdetailsformcontroller.selectedTitle = value!;
                            patientdetailsformcontroller.updateFullName();
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Please select title"
                              : null,
                        ),
                        const SizedBox(height: 10),

                        // ✅ First Name (Required)

                        // ✅ Last Name (Optional)
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: patientdetailsformcontroller
                                    .firstNameController,
                                labelText: 'Enter First Name',
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onChanged: (value) =>
                                    patientdetailsformcontroller
                                        .updateFullName(),
                                validator: (value) => siginSignUpController
                                    .validatedata(value, "first name"),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: CustomTextField(
                                controller: patientdetailsformcontroller
                                    .lastNameController,
                                labelText: 'Enter Last Name (Optional)',
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onChanged: (value) =>
                                    patientdetailsformcontroller
                                        .updateFullName(),
                              ),
                            ),
                          ],
                        ),

                        // ✅ Final Full Name (Read Only)
                        CustomTextField(
                          controller:
                              patientdetailsformcontroller.nameController,
                          labelText: 'Full Name',
                          readOnly: true,
                          enabled: false,
                        ),
                      ],
                    ),

              /// Relation Field
              patientdetailsformcontroller.selectedFor.value == "Self"
                  ? CustomTextField(
                      controller: TextEditingController(text: "Self"),
                      labelText: 'Relation',
                      enabled: false,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: DropdownButtonFormField<String>(
                        value: patientdetailsformcontroller
                                .relationController.text.isNotEmpty
                            ? patientdetailsformcontroller
                                .relationController.text
                            : null,
                        items: [
                          'Father',
                          'Mother',
                          'Brother',
                          'Sister',
                          'Spouse',
                          'Child',
                        ].map((relation) {
                          return DropdownMenuItem<String>(
                            value: relation,
                            child: Text(
                              relation,
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          patientdetailsformcontroller.relationController.text =
                              value ?? '';
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Relation',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        validator: (value) => siginSignUpController
                            .validatedata(value, "Relation"),
                      ),
                    ),

              /// Mobile Number
              patientdetailsformcontroller.selectedFor.value == "Self"
                  ? CustomTextField(
                      controller:
                          TextEditingController(text: widget.mobileNumber),
                      labelText: 'Mobile Number (Self)',
                      readOnly: true,
                      enabled: false,
                    )
                  : CustomTextField(
                      controller: patientdetailsformcontroller
                          .patientMobileNumberController,
                      labelText: 'Enter Patient Mobile Number',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      // validator: (value) =>
                      //     siginSignUpController.validatePhone(value),
                    ),

              /// Age Field
              patientdetailsformcontroller.selectedFor.value == "Self"
                  ? CustomTextField(
                      suffixText: "Yrs",
                      controller: TextEditingController(text: age),
                      labelText: 'Age (Self)',
                      readOnly: true,
                      enabled: false,
                    )
                  : CustomTextField(
                      suffixText: "Yrs",
                      controller: patientdetailsformcontroller.ageController,
                      labelText: 'Enter Age',
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) =>
                          siginSignUpController.validateAge(value),
                    ),

              /// Address
              CustomTextField(
                controller: patientdetailsformcontroller.addressController,
                labelText: 'Enter Address',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter Address";
                  }
                  if (value.trim().length < 5) {
                    return "Address must be at least 5 characters";
                  }
                  return null;
                },
              ),

              /// Gender selection
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Gender",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Row(
                      children: registercontroller.genderOptions.map((gender) {
                        final isSelected =
                            registercontroller.selectedGender == gender;
                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                registercontroller.selectedGender = gender;
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? mainColor : Colors.white,
                                border: Border.all(
                                    color: isSelected
                                        ? mainColor
                                        : Colors.grey.shade400),
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
                                          : FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Divider(color: secondaryColor),
            ]);
          }),

          /// Problem Section
          if (consultationController.selectedConsultation.value != null &&
              consultationController
                      .selectedConsultation.value!.consultationType
                      .toLowerCase() ==
                  "services & treatments") ...[
            Text("Describe your problem / Symptoms",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            SizedBox(
              height: 15,
            ),
            CustomTextAera(
              controller: patientdetailsformcontroller.notesController,
              labelText: "Enter Symptoms",
              hintText:
                  "If you have any specific concerns to discuss before the procedure, please mention them here.",
              maxLines: 3,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),

            const SizedBox(height: 15),
            Text("Symptoms Duration",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              children: [
                // Duration Number
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: "Duration",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 16),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Duration Type Dropdown
                Expanded(
                  child: CustomDropdownField<String>(
                    value: _selectedDurationType,
                    labelText: "Select Type",
                    items: durationTypes
                        .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDurationType = val;
                        controller.updateDuration(
                            "${_durationController.text} ${_selectedDurationType}");
                      });
                    },
                  ),
                ),
              ],
            ),

            // CustomTextField(
            //   controller: patientdetailsformcontroller.durationController,
            //   labelText: 'Enter Duration (in days)',
            //   keyboardType: TextInputType.number,
            //   autovalidateMode: AutovalidateMode.onUserInteraction,
            //   inputFormatters: [
            //     LengthLimitingTextInputFormatter(3),
            //     FilteringTextInputFormatter.digitsOnly,
            //   ],
            // ),
            const SizedBox(height: 15),

            /// Attachments
            Text("Attach document (Previous reports if any)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text("PDF"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: secondaryColor),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text("Camera"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: secondaryColor),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library, color: Colors.white),
                  label: Text("Gallery"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: secondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Attachments Preview
            Obx(() {
              final files = controller.attachments;
              if (files.isEmpty) {
                return Center(child: Text("No attachments selected"));
              }
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(files.length, (index) {
                  final file = files[index];
                  final isPDF = file.path.toLowerCase().endsWith('.pdf');

                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (isPDF) {
                            await OpenFilex.open(file.path);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  appBar: CommonHeader(
                                    title: "Image Preview",
                                  ),
                                  body: Center(
                                    child: InteractiveViewer(
                                      child: Image.file(file),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: isPDF
                            ? Container(
                                width: 140,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[200],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf,
                                        color: Colors.red, size: 30),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        file.path.split('/').last,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(file, fit: BoxFit.cover),
                                ),
                              ),
                      ),
                      Positioned(
                        right: -5,
                        top: -5,
                        child: InkWell(
                          onTap: () => controller.removeAttachment(index),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              );
            }),
          ]
        ]),
      ),
    );
  }
}
