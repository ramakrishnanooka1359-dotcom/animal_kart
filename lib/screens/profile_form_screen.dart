import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';

class ProfileFormScreen extends StatefulWidget {
  final String mobileNumber;
  const ProfileFormScreen({super.key, required this.mobileNumber});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final landmarkController = TextEditingController();
  final gpsController = TextEditingController();
  final aadharController = TextEditingController();

  String genderValue = 'Male';
  File? aadharFront;
  File? aadharBack;

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        if (isFront) {
          aadharFront = File(picked.path);
        } else {
          aadharBack = File(picked.path);
        }
      });
    }
  }

  // Future<void> _fetchLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) return;

  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   }
  //   if (permission == LocationPermission.deniedForever) return;

  //   final position = await Geolocator.getCurrentPosition();
  //   setState(() {
  //     gpsController.text =
  //         '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
  //   });
  // }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _sectionHeader(String title, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              // --- User Info Section ---
              _sectionHeader('User Information', Colors.blue, Icons.person),
              TextFormField(
                initialValue: widget.mobileNumber,
                enabled: false,
                decoration: _inputDecoration('Mobile Number'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                decoration: _inputDecoration('Full Name *'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: _inputDecoration('Email (Optional)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: genderValue,
                decoration: _inputDecoration('Gender *'),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => genderValue = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dobController,
                decoration: _inputDecoration(
                  'Date of Birth *',
                  hint: 'dd/mm/yyyy',
                ),
                validator: (v) => v!.isEmpty ? 'Enter date of birth' : null,
              ),
              const SizedBox(height: 8),
              // --- Aadhar Section ---
              _sectionHeader(
                'Aadhar Verification',
                Colors.orange,
                Icons.credit_card_rounded,
              ),
              TextFormField(
                controller: aadharController,
                validator: (v) => v!.isEmpty ? 'Enter Aadhar number' : null,
                decoration: _inputDecoration('Aadhar Number *'),
              ),
              const SizedBox(height: 12),
              _imageUploadBox(
                'Aadhar Front Image',
                aadharFront,
                () => _pickImage(true),
              ),
              const SizedBox(height: 12),
              _imageUploadBox(
                'Aadhar Back Image',
                aadharBack,
                () => _pickImage(false),
              ),
              const SizedBox(height: 8),

              // --- Address Section ---
              _sectionHeader(
                'Address Details',
                Colors.green,
                Icons.location_on,
              ),
              TextFormField(
                controller: address1Controller,
                validator: (v) => v!.isEmpty ? 'Enter address line 1' : null,
                decoration: _inputDecoration(
                  'Address Line 1 *',
                  hint: 'House/Flat No, Building',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: address2Controller,
                decoration: _inputDecoration(
                  'Address Line 2',
                  hint: 'Street, Area, Colony',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: cityController,
                      validator: (v) => v!.isEmpty ? 'Enter city' : null,
                      decoration: _inputDecoration('City *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: stateController,
                      validator: (v) => v!.isEmpty ? 'Enter state' : null,
                      decoration: _inputDecoration('State *'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: pincodeController,
                      validator: (v) => v!.isEmpty ? 'Enter pincode' : null,
                      decoration: _inputDecoration('Pincode *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: landmarkController,
                      decoration: _inputDecoration('Landmark'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row(
              //   children: [
              //     Expanded(
              //       child: TextFormField(
              //         controller: gpsController,
              //         decoration: _inputDecoration('GPS Location'),
              //       ),
              //     ),
              //     IconButton(
              //       icon: const Icon(Icons.my_location, color: Colors.blue),
              //       onPressed: _fetchLocation,
              //     ),
              //   ],
              // ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save & Continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageUploadBox(String label, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.grey,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Upload or capture Aadhar image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
