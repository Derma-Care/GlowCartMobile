import 'dart:io';
import 'package:cutomer_app/Consultations/SymptomsController.dart';
import 'package:cutomer_app/Inputs/CustomDropdownField.dart';
import 'package:cutomer_app/Inputs/CustomInputField.dart';
import 'package:cutomer_app/Inputs/CustomTextAera.dart';
import 'package:cutomer_app/SigninSignUp/LoginController.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';

import '../ConfirmBooking/ConsultationPrice.dart';
import '../Doctors/ListOfDoctors/ConsuationDoctors.dart';

class SymptomsForm extends StatefulWidget {
  final String mobileNumber;
  final String username;
  final String consulationType;

  const SymptomsForm(
      {super.key,
      required this.mobileNumber,
      required this.username,
      required this.consulationType});
  @override
  State<SymptomsForm> createState() => _SymptomsFormState();
}

class _SymptomsFormState extends State<SymptomsForm> {
  final SymptomsController controller = Get.put(SymptomsController());
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String selectedType = "First Time"; // default value
  SiginSignUpController siginSignUpController = SiginSignUpController();
  String? errorText;
  int charCount = 0;
  String? _selectedDurationType;

  final List<String> durationTypes = [
    "Hours",
    "Days",
    "Weeks",
    "Months",
    "Years"
  ];

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

  void _onSubmit() {
    final text = _textController.text.trim();
    final duration = _durationController.text.trim();
    final length = text.length;

    if (length == 0) {
      setState(() => errorText = "Symptoms field is required.");
      return;
    }
    if (length < 10) {
      setState(() => errorText = "Minimum 10 characters required.");
      return;
    }
    if (length > 1000) {
      setState(() => errorText = "Maximum 1000 characters allowed.");
      return;
    }

    // Save and Clear
    controller.updateSymptoms(text);
    controller.updateDuration("${duration} ${_selectedDurationType}");
    controller.updateVisitType(selectedType);
    print("Symptoms: ${controller.symptoms.value}");
    print("updateDuration: ${controller.duration.value}");
    print("_selectedDurationType: ${"${duration} ${_selectedDurationType}"}");

    // controller.clearForm();

    setState(() {
      charCount = 0;
      errorText = null;
    });
    Get.to(ConsultationPrice(
      mobileNumber: widget.mobileNumber,
      username: widget.consulationType,
      consulationType: widget.consulationType,
      symptoms: controller.symptoms.value,
    ));
    // Get.snackbar("Submitted", "Appointment form submitted successfully");
  }

  @override
  void dispose() {
    Get.delete<SymptomsController>(); // This clears controller on back
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: "Symptoms & Attachment"),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F1F1), // light background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Selected Consultation Type",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.consulationType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       ChoiceChip(
            //         label: Text("First Time"),
            //         selected: selectedType == "First Time",
            //         onSelected: (selected) {
            //           setState(() => selectedType = "First Time");
            //         },
            //       ),
            //       const SizedBox(width: 10),
            //       ChoiceChip(
            //         label: Text("Follow Up"),
            //         selected: selectedType == "Follow Up",
            //         onSelected: (selected) {
            //           setState(() => selectedType = "Follow Up");
            //           // Navigate immediately to next screen for Follow Up
            //           // Get.to(ConsultationPrice(
            //           //   mobileNumber: widget.mobileNumber,
            //           //   username: widget.consulationType,
            //           //   consulationType: widget.consulationType,
            //           //   subserviceName: 'PRP Injection Procedure',
            //           //   subserviceid: '687b91e50ce982692fd1aeb2',
            //           //   serviceId: '687b91540ce982692fd1aeb0',
            //           //   categoryId: '687b90d80ce982692fd1aeae',
            //           //   serviceName: 'PRP Therapy',
            //           //   categoryName: 'Hair Treatments',
            //           // ));
            //         },
            //         //  enabled: false,
            //       ),
            //     ],
            //   ),
            // ),

            // Text("Selected Type: $selectedType",
            //     style: TextStyle(fontSize: 14)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enter your symptoms",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextAera(
                          controller: _textController,
                          labelText: "Symptoms",
                          hintText: "Describe your symptoms here...",
                          maxLines: 3,
                          onChanged: (val) {
                            setState(() {
                              charCount = val.length;
                              errorText = null;
                            });
                          },
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Please enter symptoms";
                            }
                            return null;
                          },
                        ),

                        // ✅ Show error below field if needed
                        if (errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              errorText!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),

                        // ✅ Show character counter
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "$charCount/1000 characters",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Symptoms Duration",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter duration";
                                  }
                                  return null;
                                },
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
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Select type";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text("Attach any document (if any)",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFile, // pick PDF
                          icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                          label: Text("PDF"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          label: Text("Camera"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: Icon(Icons.photo_library, color: Colors.white),
                          label: Text("Gallery"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

// Attachments Preview
                    Obx(() {
                      final files = controller.attachments;
                      if (files.isEmpty) {
                        return Center(child: Text("No attachments selected"));
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(files.length, (index) {
                          final file = files[index];
                          final isPDF =
                              file.path.toLowerCase().endsWith('.pdf');

                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (isPDF) {
                                    // Open PDF with external viewer
                                    await OpenFilex.open(file.path);
                                  } else {
                                    // Open Image in Preview Screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Scaffold(
                                          appBar: CommonHeader(
                                              title: "Image Preview"),
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
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(file,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                              ),
                              Positioned(
                                right: -5,
                                top: -5,
                                child: InkWell(
                                  onTap: () =>
                                      controller.removeAttachment(index),
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50), backgroundColor: mainColor
                    // backgroundColor: Theme.of(context).primaryColor,
                    ),
                child: Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
