import 'dart:convert';
import 'dart:io';
import 'package:animal_kart_demo2/auth/providers/auth_provider.dart';
import 'package:animal_kart_demo2/auth/providers/user_provider.dart';
import 'package:animal_kart_demo2/auth/widgets/register_sections/contact_info_section.dart';
import 'package:animal_kart_demo2/auth/widgets/register_sections/personal_info_section.dart';
import 'package:animal_kart_demo2/auth/widgets/register_sections/address_documents_section.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/auth/widgets/aadharvalidation_widget.dart';
import 'package:animal_kart_demo2/utils/image_compressor_helper.dart';
import 'package:animal_kart_demo2/utils/save_user.dart';
import 'package:animal_kart_demo2/widgets/floating_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  final emailFocus = FocusNode();
  final firstNameFocus = FocusNode();

  File? aadhaarFront;
  File? aadhaarBack;
  File? panCard;
  String? panCardUrl;
  String gender = "Male";
  DateTime? selectedDOB;
  Map<String, String> aadhaarUrls = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final user = await loadUserFromPrefs();
  
    
    if (user != null && mounted) {
      setState(() {
        firstNameCtrl.text = user.firstName;
        lastNameCtrl.text = user.lastName;
      });
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    occupationCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    aadhaarCtrl.dispose();
    emailFocus.dispose();
    firstNameFocus.dispose();
    super.dispose();
  }

 
  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

 
  Future<File?> pickImage({bool compress = true, bool isDocument = true}) async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked == null) return null;
  
  final file = File(picked.path);
  
  // Compress image if needed
  if (compress) {
    try {
      final compressedFile = await ImageCompressionHelper.getCompressedImageIfNeeded(
        file,
        maxSizeKB: 250,
        isDocument: isDocument, // Pass this parameter
      );
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return file; 
    }
  }
  
  return file;
}
   

 Future<File?> pickFromCamera({bool compress = true, bool isDocument = true}) async {
  final picked = await ImagePicker().pickImage(source: ImageSource.camera);
  if (picked == null) return null;
  
  final file = File(picked.path);
  
  // Compress image if needed
  if (compress) {
    try {
      final compressedFile = await ImageCompressionHelper.getCompressedImageIfNeeded(
        file,
        maxSizeKB: 250,
        isDocument: isDocument, // Pass this parameter
      );
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return file; 
    }
  }
  
  return file;
}


  Future<void> pickAadhaarBackFromCamera() async {
    final file = await pickFromCamera(compress: true,isDocument: true);
    if (file != null && mounted) {
      setState(() => aadhaarBack = file);
      await _uploadAadhaarBack();
    }
  }

  Future<void> pickAadhaarFrontFromGallery() async {
    final file = await pickImage(compress: true,isDocument: true);
    if (file != null && mounted) {
      setState(() => aadhaarFront = file);
      await _uploadAadhaarFront();
    }
  }

Future<void> pickAadhaarFrontFromCamera() async {
    final file = await pickFromCamera(compress: true,isDocument: true);
    if (file != null && mounted) {
      setState(() => aadhaarFront = file);
      await _uploadAadhaarFront();
    }
  }
  Future<void> pickAadhaarBackFromGallery() async {
    final file = await pickImage(compress: true,isDocument: true);
    if (file != null && mounted) {
      setState(() => aadhaarBack = file);
      await _uploadAadhaarBack();
    }
  }


  Future<void> pickPanCardFromCamera() async {
    final file = await pickFromCamera(compress: true,isDocument: true);
    if (file != null && mounted) {
      setState(() => panCard = file);
      await _uploadPanCard();
    }
  }

  Future<void> pickPanCardFromGallery() async {
    final file = await pickImage(compress: true,isDocument: true);
    if (file != null && mounted) {
      setState(() => panCard = file);
      await _uploadPanCard();
    }
  }
 Future<void> selectDOB() async {
  final now = DateTime.now();
  final maxAllowedDOB = DateTime(now.year - 21, now.month, now.day);

  final picked = await showDatePicker(
    context: context,
    initialDate: maxAllowedDOB,
    firstDate: DateTime(1960),
    lastDate: maxAllowedDOB,
    builder: (context, child) {
      return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.light(
            primary: kPrimaryGreen,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          // Use DialogThemeData instead of DialogTheme
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    selectedDOB = picked;
    dobCtrl.text = "${picked.day}-${picked.month}-${picked.year}";
  }
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
      if (mounted) FloatingToast.showSimpleToast('Failed to upload front image');
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
      if (mounted) FloatingToast.showSimpleToast('Failed to upload back image');
    }
  }

  Future<void> _deleteAadhaarFront() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final success = await ref
          .read(userProfileProvider.notifier)
          .deleteAadhaarFront(userId: userId);
      if (success) {
        setState(() => aadhaarFront = null);
        aadhaarUrls.remove('aadhaar_front_url');
      }
    } catch (e) {
      if (mounted) FloatingToast.showSimpleToast('Failed to delete front image');
    }
  }

  Future<void> _deleteAadhaarBack() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final success = await ref
          .read(userProfileProvider.notifier)
          .deleteAadhaarBack(userId: userId);
      if (success) {
        setState(() => aadhaarBack = null);
        aadhaarUrls.remove('aadhaar_back_url');
      }
    } catch (e) {
      if (mounted) FloatingToast.showSimpleToast('Failed to delete back image');
    }
  }

  Future<void> _uploadPanCard() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final url = await ref
          .read(userProfileProvider.notifier)
          .uploadPanCard(file: panCard!, userId: userId);
      if (url != null && mounted) {
        setState(() => panCardUrl = url);
        FloatingToast.showSimpleToast('PAN card uploaded successfully');
      }
    } catch (e) {
      if (mounted) FloatingToast.showSimpleToast('Failed to upload PAN card');
    }
  }

  Future<void> _deletePanCard() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final success = await ref
          .read(userProfileProvider.notifier)
          .deletePanCard(userId: userId);
      if (success && mounted) {
        setState(() {
          panCard = null;
          panCardUrl = null;
        });
      }
    } catch (e) {
      if (mounted) FloatingToast.showSimpleToast('Failed to delete PAN card');
    }
  }


  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
   
    if (selectedDOB == null) {
      FloatingToast.showSimpleToast("Please select your Date of Birth");
      return;
    }
    
   
    int age = calculateAge(selectedDOB!);
    if (age < 21) {
      FloatingToast.showSimpleToast("You must be at least 21 years old to register");
      return;
    }
    
  
    if (aadhaarCtrl.text.trim().isNotEmpty) {
      bool isValid = AadharValidator.validateAadhar(aadhaarCtrl.text.trim());
      if (!isValid) {
        FloatingToast.showSimpleToast("Invalid Aadhaar number");
        return;
      }
    }
    
    
    if (panCardUrl == null) {
      FloatingToast.showSimpleToast("PAN card is mandatory. Please upload PAN card.");
      return;
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
      'panCardUrl': panCardUrl,
    };

    if (aadhaarUrls['aadhaar_front_url'] != null) {
      extraFields['aadhar_front_image_url'] = aadhaarUrls['aadhaar_front_url'];
    }
    if (aadhaarUrls['aadhaar_back_url'] != null) {
      extraFields['aadhar_back_image_url'] = aadhaarUrls['aadhaar_back_url'];
    }

    debugPrint("Extra fields: $extraFields");
    debugPrint("Registration Payload: ${jsonEncode(extraFields)}");
    debugPrint("User ID: $userId");

    // API Call
    final user = await auth.updateUserdata(
      userId: userId,
      extraFields: extraFields,
    );

    if (!mounted) return;
    if (user != null) {
      await saveUserToPrefs(user);
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
      FloatingToast.showSimpleToast('Failed to update profile. Please try again.');
    }
  }

  // ========== Build Method ==========
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final isUploadingDoc = ref.watch(
      userProfileProvider.select((val) => val.isUploading),
    );

    return Scaffold(
      backgroundColor: kFieldBg,
      body: SafeArea(
        child: Column(
          children: [
           
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
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Welcome, Please Enter Your Details.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 25),

                      
                      ContactInfoSection(
                        emailCtrl: emailCtrl,
                        emailFocus: emailFocus,
                        firstNameFocus: firstNameFocus,
                        formKey: _formKey,
                        phoneNumber: widget.phoneNumberFromLogin,
                      ),
                      const SizedBox(height: 25),

                     
                      PersonalInfoSection(
                        firstNameCtrl: firstNameCtrl,
                        lastNameCtrl: lastNameCtrl,
                        occupationCtrl: occupationCtrl,
                        dobCtrl: dobCtrl,
                        firstNameFocus: firstNameFocus,
                        onSelectDOB: selectDOB,
                        gender: gender,
                        onGenderChanged: (val) => setState(() => gender = val),
                      ),
                      const SizedBox(height: 25),

                   
                       AddressDocumentsSection(
                        addressCtrl: addressCtrl,
                        aadhaarCtrl: aadhaarCtrl,
                        aadhaarFront: aadhaarFront,
                        aadhaarBack: aadhaarBack,
                        panCard: panCard,
                       
                        onAadhaarFrontCamera: pickAadhaarFrontFromCamera,
                        onAadhaarFrontGallery: pickAadhaarFrontFromGallery,
                        onAadhaarBackCamera: pickAadhaarBackFromCamera,
                        onAadhaarBackGallery: pickAadhaarBackFromGallery,
                        onPanCardCamera: pickPanCardFromCamera,
                        onPanCardGallery: pickPanCardFromGallery,
                        onUploadAadhaarFront: _uploadAadhaarFront,
                        onUploadAadhaarBack: _uploadAadhaarBack,
                        onDeleteAadhaarFront: _deleteAadhaarFront,
                        onDeleteAadhaarBack: _deleteAadhaarBack,
                        onUploadPanCard: _uploadPanCard,
                        onDeletePanCard: _deletePanCard,
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
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (isLoading || isUploadingDoc) ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (isLoading || isUploadingDoc)
                        ? Colors.grey
                        : kPrimaryGreen,
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
}