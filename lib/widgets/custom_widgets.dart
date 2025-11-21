import 'dart:io';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// ------------------ TEXT FIELD DECORATION ------------------
InputDecoration fieldDeco(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: kFieldBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

/// ------------------ GENDER BUTTON ------------------
/// Now accepts a callback because setState cannot be used inside this file
Widget genderButton({
  required String label,
  required String selectedGender,
  required Function(String) onChanged,
}) {
  return Row(
    children: [
      Radio(
        value: label,
        groupValue: selectedGender,
        activeColor: kPrimaryGreen,
        onChanged: (value) => onChanged(value as String),
      ),
      Text(label),
    ],
  );
}

/// ------------------ AADHAAR FILE UPLOAD BOX ------------------
Widget aadhaarUploadBox({
  required String title,
  required File? file,
  required VoidCallback onGallery,
  required VoidCallback onCamera,
  required VoidCallback onRemove,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: file == null
            ? Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 55,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onGallery,
                    child: const Text("Upload Image"),
                  ),
                  const Text("or"),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: onCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // 👈 Reduced border radius
                      ),
                    ),
                    child: const Text("Open Camera"),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      file,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ],
  );
}
