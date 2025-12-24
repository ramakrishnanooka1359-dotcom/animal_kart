import 'package:animal_kart_demo2/manualpayment/widgets/common_widgets.dart';
import 'package:animal_kart_demo2/profile/providers/profile_provider.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddReferralDialog extends ConsumerStatefulWidget {
  final String referedByMobile;
  final String referedByName;
  final Function()? onSuccess;

  const AddReferralDialog({
    Key? key,
    required this.referedByMobile,
    required this.referedByName,
    this.onSuccess,
  }) : super(key: key);

  @override
  ConsumerState<AddReferralDialog> createState() => _AddReferralDialogState();
}

class _AddReferralDialogState extends ConsumerState<AddReferralDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _referralMobileController = TextEditingController();
  final _referralNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill referral details
    _referralMobileController.text = widget.referedByMobile;
    _referralNameController.text = widget.referedByName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _referralMobileController.dispose();
    _referralNameController.dispose();
    super.dispose();
  }

  // Validators
  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter first name';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter last name';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter mobile number';
    }
    if (value.length != 10) {
      return 'Please enter valid 10-digit mobile number';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Mobile number must contain only digits';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(profileProvider.notifier).createReferralUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        mobile: _mobileController.text.trim(),
        referedByMobile: widget.referedByMobile,
        referedByName: widget.referedByName,
        role: 'Investor',
      );

      final state = ref.watch(profileProvider);
      
      if (!state.isLoading) {
        if (state.createUserResponse != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.createUserResponse!.message),
              backgroundColor: kPrimaryGreen,
            ),
          );
          
          // Reset form
          _formKey.currentState!.reset();
          
          // Close dialog
          Navigator.of(context).pop();
          
          // Call success callback if provided
          widget.onSuccess?.call();
        } else if (state.error != null) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _referralMobileController.text = widget.referedByMobile;
    _referralNameController.text = widget.referedByName;
    ref.read(profileProvider.notifier).resetCreateUserState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    return AlertDialog(
      title: const Text('Add Referral'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
      content: SingleChildScrollView(
        child: Container(
           width: MediaQuery.of(context).size.width * 0.8,
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValidatedTextField(
                      controller: _firstNameController,
                      label: 'First Name *',
                      validator: _validateFirstName,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 8),
                    
                    ValidatedTextField(
                      controller: _lastNameController,
                      label: 'Last Name *',
                      validator: _validateLastName,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 8),
                    
                    ValidatedTextField(
                      controller: _mobileController,
                      label: 'Mobile Number *',
                      validator: _validateMobile,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // ValidatedTextField(
                    //   controller: _referralMobileController,
                    //   label: 'Referred By Mobile',
                    //   readOnly: true,
                    // ),
                    // const SizedBox(height: 8),
                    
                    // ValidatedTextField(
                    //   controller: _referralNameController,
                    //   label: 'Referred By Name',
                    //   readOnly: true,
                    // ),
                    // const SizedBox(height: 16),
                    
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          state.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.isLoading ? null : () {
            _resetForm();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: state.isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen, // Assuming kPrimaryGreen is defined in app_colors.dart
            foregroundColor: Colors.white,
          ),
          child: state.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}