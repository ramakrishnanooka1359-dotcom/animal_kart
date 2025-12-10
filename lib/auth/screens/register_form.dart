import 'dart:io';
import 'package:animal_kart_demo2/auth/providers/auth_provider.dart';
import 'package:animal_kart_demo2/auth/providers/user_provider.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/auth/widgets/aadharvalidation_widget.dart';
import 'package:animal_kart_demo2/utils/save_user.dart';
import 'package:animal_kart_demo2/widgets/custom_widgets.dart';
import 'package:animal_kart_demo2/widgets/floating_toast.dart';
import 'package:animal_kart_demo2/auth/widgets/aadhar_upload_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


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
  Map<String, String> aadhaarUrls = {};

  String gender = "Male";
  DateTime? selectedDOB;

///age calculation
int calculateAge(DateTime birthDate) {
  final today = DateTime.now();
  int age = today.year - birthDate.year;

  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}




  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
 final isFrontUploading= ref.watch(userProfileProvider.select((val)=>val.frontUploadProgress));
 final isBackUploading= ref.watch(userProfileProvider.select((val)=>val.backUploadProgress));


    return Scaffold(
      backgroundColor: kFieldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Card(
                color: akWhiteColor,

                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
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
                      const Text(
                        "Email ID",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: emailCtrl,
                        decoration: fieldDeco("Email ID"),
                        validator: (v) =>
                            v!.contains("@") ? null : "Enter a valid email",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // PERSONAL SECTION
              const Text(
                "Personal Information",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Card(
                color: akWhiteColor,

                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "First Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: firstNameCtrl,
                        decoration: fieldDeco("First Name"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Family Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            label: "Others",
                            selectedGender: gender,
                            onChanged: (val) => setState(() => gender = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Occupation",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: occupationCtrl,
                        decoration: fieldDeco("Occupation"),
                      ),

                      const SizedBox(height: 15),
                      const Text(
                        "Date of Birth",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Address Information",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Card(
                color: akWhiteColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: addressCtrl,
                        maxLines: 3,
                        decoration: fieldDeco("Address"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),

                      const SizedBox(height: 20),
                      // const Text(
                      //   "Aadhaar Verfication (Optional)",
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.w400,
                      //   ),
                      // ),
                       const SizedBox(height: 8),
                      TextFormField(
                      controller: aadhaarCtrl,
                      decoration: fieldDeco("Aadhaar Number (Optional)"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // 👈 ALLOWS ONLY NUMBERS
                     ],
                      maxLength: 12,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null; // optional

                        if (!AadharValidator.validateAadhar(value)) {
                          return "Enter a valid Aadhaar number";
                        }
                        return null;
                      },
                    ),
                      // TextFormField(
                      //   controller: aadhaarCtrl,
                      //   decoration: fieldDeco("Aadhaar Number (Optional)"),
                      // ),

                      const SizedBox(height: 25),

                      // Aadhaar Front
                      AadhaarUploadWidget(
                        title: "Upload Aadhaar Front Image",
                        file: aadhaarFront,
                        isFrontImage: true,
                        onCamera: () async {
                          final file = await pickFromCamera();
                          if (file != null) {
                            setState(() => aadhaarFront = file);
                            // Start upload immediately after selection
                            await _uploadAadhaarFront();
                          }
                        },
                        onGallery: () async {
                          final file = await pickImage();
                          if (file != null) {
                            setState(() => aadhaarFront = file);
                            // Start upload immediately after selection
                            await _uploadAadhaarFront();
                          }
                        },
                        onRemove: () async {
                          // Delete from Firebase and update local state
                          await _deleteAadhaarFront();
                        },
                      uploadProgress:isFrontUploading
                      
                      ),

                      const SizedBox(height: 25),

                      AadhaarUploadWidget(
                        title: "Upload Aadhaar Back Image",
                        file: aadhaarBack,
                        isFrontImage: false,
                        onCamera: () async {
                          final file = await pickFromCamera();
                          if (file != null) {
                            setState(() => aadhaarBack = file);
                            // Start upload immediately after selection
                            await _uploadAadhaarBack();
                          }
                        },
                        onGallery: () async {
                          final file = await pickImage();
                          if (file != null) {
                            setState(() => aadhaarBack = file);
                            // Start upload immediately after selection
                            await _uploadAadhaarBack();
                          }
                        },
                        onRemove: () async {
                          // Delete from Firebase and update local state
                          await _deleteAadhaarBack();
                        },
                      uploadProgress: isBackUploading,
                      
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              ],
                  ),
                ),
              ),
            ),
            // Fixed register button at bottom
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kFieldBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    onPressed: isLoading ? null : submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAadhaarFront() async {
    if (aadhaarFront == null) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final frontUrl = await ref
          .read(userProfileProvider.notifier)
          .uploadAadhaarFront(file: aadhaarFront!, userId: userId);

      if (frontUrl != null) {
        aadhaarUrls['aadhaar_front_url'] = frontUrl;
      }
    } catch (e) {
      if (mounted) {
        FloatingToast.showSimpleToast('Failed to upload front image');
      }
    }
  }

  Future<void> _uploadAadhaarBack() async {
    if (aadhaarBack == null) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final backUrl = await ref
          .read(userProfileProvider.notifier)
          .uploadAadhaarBack(file: aadhaarBack!, userId: userId);

      if (backUrl != null) {
        aadhaarUrls['aadhaar_back_url'] = backUrl;
      }
    } catch (e) {
      if (mounted) {
        FloatingToast.showSimpleToast('Failed to upload back image');
      }
    }
  }

  Future<void> _deleteAadhaarFront() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final success = await ref
          .read(userProfileProvider.notifier)
          .deleteAadhaarFront(userId: userId);

      if (success) {
        setState(() {
          aadhaarFront = null;
        });
        // Remove from URLs map
        aadhaarUrls.remove('aadhaar_front_url');
      }
    } catch (e) {
      if (mounted) {
        FloatingToast.showSimpleToast('Failed to delete front image');
      }
    }
  }

  Future<void> _deleteAadhaarBack() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final success = await ref
          .read(userProfileProvider.notifier)
          .deleteAadhaarBack(userId: userId);

      if (success) {
        setState(() {
          aadhaarBack = null;
        });
        // Remove from URLs map
        aadhaarUrls.remove('aadhaar_back_url');
      }
    } catch (e) {
      if (mounted) {
        FloatingToast.showSimpleToast('Failed to delete back image');
      }
    }
  }

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
      initialDate: DateTime(now.year - 21),
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
      selectedDOB = picked;
      dobCtrl.text = "${picked.month}-${picked.day}-${picked.year}";
    }
  }

  // SUBMIT FORM ------
   void submitForm() async {
    if (!_formKey.currentState!.validate()) return;
       if (selectedDOB == null) 
         { FloatingToast.showSimpleToast("Please select your Date of Birth"); return; } 
            int age = calculateAge(selectedDOB!); 
              //if(age <=20){
    if (age < 21) { 
               FloatingToast.showSimpleToast("You must be at least 21 years old to register");
       return;
       }
  // AADHAAR VALIDATION in submit
       if (aadhaarCtrl.text.trim().isNotEmpty) {
         bool isValid = AadharValidator.validateAadhar(aadhaarCtrl.text.trim());

            if (!isValid) {
              FloatingToast.showSimpleToast("Invalid Aadhaar number");
        return;
      }
   }


    final auth = ref.read(authProvider.notifier);
    final userId = widget.phoneNumberFromLogin;

    final extraFields = <String, dynamic>{
      'name': '${firstNameCtrl.text} ${lastNameCtrl.text}'.trim(),
      'email': emailCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'occupation': occupationCtrl.text.trim(),
      'isFormFilled': true,
      'gender': gender,
      'dob': dobCtrl.text.trim(),
      'aadhar_number': aadhaarCtrl.text.trim(),
      'first_name': firstNameCtrl.text.trim(),
      "last_name": lastNameCtrl.text.trim(),
    };

    

    if (aadhaarUrls['aadhaar_front_url'] != null) {
      extraFields['aadhar_front_image_url'] = aadhaarUrls['aadhaar_front_url'];
    }
   
    if (aadhaarUrls['aadhaar_back_url'] != null) {
      extraFields['aadhar_back_image_url'] = aadhaarUrls['aadhaar_back_url'];
    }

    debugPrint(extraFields.toString());
    debugPrint(userId);

    final user = await auth.updateUserdata(
      userId: userId, 
      extraFields: extraFields, 
    );

    if (!mounted) return;
    if (user != null) {
        await saveUserToPrefs(user);
        Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
        FloatingToast.showSimpleToast(
          'Failed to update profile. Please try again.',
        );
    }

    
  }
}