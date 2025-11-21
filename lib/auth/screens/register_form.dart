import 'dart:io';
import 'package:animal_kart_demo2/auth/providers/auth_provider.dart';
import 'package:animal_kart_demo2/auth/providers/user_provider.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:animal_kart_demo2/widgets/custom_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String phoneNumberFromLogin;

  const RegisterScreen({super.key, required this.phoneNumberFromLogin});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();

  File? aadhaarFront;
  File? aadhaarBack;

  String gender = "Male";

  // PICK IMAGE ------
  Future<File?> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  Future<File?> pickFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    return picked != null ? File(picked.path) : null;
  }

  // SELECT DOB ------
  Future<void> selectDOB() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1960),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: kPrimaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dobCtrl.text = "${picked.month}-${picked.day}-${picked.year}";
    }
  }

  // SUBMIT FORM ------
  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    print("========= USER DATA =========");
    print("Phone Number: ${widget.phoneNumberFromLogin}");
    print("Email: ${emailCtrl.text}");
    print("First Name: ${firstNameCtrl.text}");
    print("Last Name: ${lastNameCtrl.text}");
    print("Gender: $gender");
    print("Occupation: ${occupationCtrl.text}");
    print("DOB: ${dobCtrl.text}");
    print("Address: ${addressCtrl.text}");
    print("Aadhaar: ${aadhaarCtrl.text}");
    print("Aadhaar Front: ${aadhaarFront?.path}");
    print("Aadhaar Back: ${aadhaarBack?.path}");
    print("==============================");

    final auth = ref.read(authProvider);
    final userId = auth.userProfile?.id ?? widget.phoneNumberFromLogin;

    // Upload Aadhaar images through userProfileProvider to get URLs
    Map<String, String> aadhaarUrls = {};
    if (aadhaarFront != null || aadhaarBack != null) {
      aadhaarUrls = await ref
          .read(userProfileProvider)
          .saveAdharDetailsToDb(
            aadhaarFront: aadhaarFront ?? aadhaarBack!,
            aadhaarBack: aadhaarBack,
            userId: userId,
          );
    }

    final extraFields = <String, dynamic>{
      'name': '${firstNameCtrl.text} ${lastNameCtrl.text}'.trim(),
      'email': emailCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'occupation': occupationCtrl.text.trim(),
      'custom_fields': {
        'gender': gender,
        'dob': dobCtrl.text.trim(),
        'aadhaar': aadhaarCtrl.text.trim(),
      },
    };

    if (aadhaarUrls['aadhaar_front_url'] != null) {
      extraFields['aadhaar_front_url'] = aadhaarUrls['aadhaar_front_url'];
    }
    if (aadhaarUrls['aadhaar_back_url'] != null) {
      extraFields['aadhaar_back_url'] = aadhaarUrls['aadhaar_back_url'];
    }

    // final success = await auth.updateUserdata(
    //   userId: userId,
    //   extraFields: extraFields,
    // );

    if (!mounted) return;
    // if (success) {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Register Your Account !",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Welcome, Please Enter Your Details.",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 25),

                // CONTACT SECTION
                const Text(
                  "Contact Information",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                // READ ONLY PHONE NUMBER
                Container(
                  height: 55,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: kFieldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "+91 ${widget.phoneNumberFromLogin}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: emailCtrl,
                  decoration: fieldDeco("Email ID"),
                  validator: (v) =>
                      v!.contains("@") ? null : "Enter a valid email",
                ),

                const SizedBox(height: 25),

                // PERSONAL SECTION
                const Text(
                  "Personal Information",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: firstNameCtrl,
                  decoration: fieldDeco("First Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: lastNameCtrl,
                  decoration: fieldDeco("Family Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 20),

                const Text("Gender"),
                Row(
                  children: [
                    genderButton(
                      label: "Male",
                      selectedGender: gender,
                      onChanged: (val) => setState(() => gender = val),
                    ),
                    genderButton(
                      label: "Female",
                      selectedGender: gender,
                      onChanged: (val) => setState(() => gender = val),
                    ),
                    genderButton(
                      label: "Transgender",
                      selectedGender: gender,
                      onChanged: (val) => setState(() => gender = val),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: occupationCtrl,
                  decoration: fieldDeco("Occupation"),
                ),

                const SizedBox(height: 15),

                // DOB PICKER
                TextFormField(
                  controller: dobCtrl,
                  readOnly: true,
                  decoration: fieldDeco("Date of Birth").copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: selectDOB,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Select DOB" : null,
                ),

                const SizedBox(height: 25),

                const Text(
                  "Address Information",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: addressCtrl,
                  maxLines: 3,
                  decoration: fieldDeco("Address"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: aadhaarCtrl,
                  decoration: fieldDeco("Aadhaar Number (Optional)"),
                ),

                const SizedBox(height: 25),

                // Aadhaar Front
                aadhaarUploadBox(
                  title: "Upload Aadhaar Front Image",
                  file: aadhaarFront,
                  onGallery: () async {
                    final f = await pickImage();
                    if (f != null) setState(() => aadhaarFront = f);
                  },
                  onCamera: () async {
                    final f = await pickFromCamera();
                    if (f != null) setState(() => aadhaarFront = f);
                  },
                  onRemove: () {
                    setState(() => aadhaarFront = null);
                  },
                ),

                const SizedBox(height: 25),

                aadhaarUploadBox(
                  title: "Upload Aadhaar Back Image",
                  file: aadhaarBack,
                  onGallery: () async {
                    final f = await pickImage();
                    if (f != null) setState(() => aadhaarBack = f);
                  },
                  onCamera: () async {
                    final f = await pickFromCamera();
                    if (f != null) setState(() => aadhaarBack = f);
                  },
                  onRemove: () {
                    setState(() => aadhaarBack = null);
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
