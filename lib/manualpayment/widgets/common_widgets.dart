import 'dart:io';

import 'package:animal_kart_demo2/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class FieldTitle extends StatelessWidget {
  final String title;

  const FieldTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}



// Validators for Bank Transfer Form
class BankTransferValidators {
  static String? validateUTR(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "UTR number is required";
    }

    final utrRegex = RegExp(r'^[A-Za-z0-9]{12,22}$');

    if (!utrRegex.hasMatch(value.trim())) {
      return "Enter a valid UTR number (12-22 alphanumeric characters)";
    }

    return null;
  }

  static String? validateBankName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Bank name is required";
    }

    final bankRegex = RegExp(r'^[A-Za-z ]{3,}$');

    if (!bankRegex.hasMatch(value.trim())) {
      return "Enter a valid bank name (minimum 3 characters)";
    }

    return null;
  }

  static String? validateIFSC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "IFSC code is required";
    }

    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

    if (!ifscRegex.hasMatch(value.trim().toUpperCase())) {
      return "Enter a valid IFSC code (Format: ABCD0123456)";
    }

    return null;
  }

  static String? validateTransactionDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Transaction date is required";
    }

    // Additional validation for future date
    try {
      final parts = value.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final selectedDate = DateTime(year, month, day);
        final now = DateTime.now();
        
        if (selectedDate.isAfter(now)) {
          return "Transaction date cannot be in the future";
        }
      }
    } catch (e) {
      return "Invalid date format. Use DD-MM-YYYY";
    }

    return null;
  }

  static String? validatePaymentScreenshot(File? file) {
    if (file == null) {
      return "Payment screenshot is required";
    }
    return null;
  }
}

// Validators for Cheque Payment Form
class ChequePaymentValidators {
  static String? validateChequeNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Cheque number is required";
    }

    final chequeRegex = RegExp(r'^[0-9]{6,10}$');

    if (!chequeRegex.hasMatch(value.trim())) {
      return "Enter a valid cheque number (6-10 digits)";
    }

    return null;
  }

  static String? validateChequeDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Cheque date is required";
    }

    try {
      final parts = value.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final chequeDate = DateTime(year, month, day);
        final now = DateTime.now();
        
        // Check if cheque date is in the future
        if (chequeDate.isAfter(now)) {
          return "Cheque date cannot be in the future";
        }
        
        // Check if cheque is older than 3 months (90 days)
        final difference = now.difference(chequeDate).inDays;
        if (difference > 90) {
          return "Cheque date cannot be older than 3 months";
        }
      }
    } catch (e) {
      return "Invalid date format. Use DD-MM-YYYY";
    }

    return null;
  }

  static String? validateChequeBankName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Bank name is required";
    }

    final bankRegex = RegExp(r'^[A-Za-z ]{3,}$');

    if (!bankRegex.hasMatch(value.trim())) {
      return "Enter a valid bank name (minimum 3 characters)";
    }

    return null;
  }

  static String? validateChequeIFSC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "IFSC code is required";
    }

    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

    if (!ifscRegex.hasMatch(value.trim().toUpperCase())) {
      return "Enter a valid IFSC code (Format: ABCD0123456)";
    }

    return null;
  }

  static String? validateChequeUTRRef(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "UTR/Reference number is required";
    }

    final utrRefRegex = RegExp(r'^[A-Za-z0-9]{6,30}$');

    if (!utrRefRegex.hasMatch(value.trim())) {
      return "Enter a valid UTR/Reference number (6-30 alphanumeric characters)";
    }

    return null;
  }

  static String? validateChequeFrontImage(File? file) {
    if (file == null) {
      return "Cheque front image is required";
    }
    return null;
  }

  static String? validateChequeBackImage(File? file) {
    if (file == null) {
      return "Cheque back image is required";
    }
    return null;
  }
}

// Custom Validated Text Field Widget
class ValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;

  const ValidatedTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.validator,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType,
    this.maxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldTitle(label),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: fieldDeco("").copyWith(
            suffixIcon: suffixIcon,
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}