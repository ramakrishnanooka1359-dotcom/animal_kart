import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// ------------------ TEXT FIELD DECORATION ------------------
// InputDecoration fieldDeco(String label) {
//   return InputDecoration(
//     labelText: label,
//     filled: true,
//     fillColor: kFieldBg,
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(12),
//       borderSide: BorderSide.none,
//     ),
//   );
// }

InputDecoration fieldDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      fillColor: kFieldBg,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
/// ------------------ GENDER BUTTON ------------------
/// Now accepts a callback because setState cannot be used inside this file
// Widget genderButton({
//   required String label,
//   required String selectedGender,
//   required Function(String) onChanged,
// }) {
//   return Row(
//     children: [
//       Radio(
//         value: label,
//         groupValue: selectedGender,
//         activeColor: kPrimaryGreen,
//         onChanged: (value) => onChanged(value as String),
//       ),
//       Text(label),
//     ],
//   );
// }


Widget genderButton({
  required String label,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Radio<String>(
        value: label,
        activeColor: kPrimaryGreen,
      ),
      Text(label),
    ],
  );
}
