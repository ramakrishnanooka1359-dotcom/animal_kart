
import 'package:flutter/material.dart';


class PersonalInfoSection extends StatefulWidget {
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController occupationCtrl;
  final TextEditingController dobCtrl;
  final FocusNode? firstNameFocus;
  final Function() onSelectDOB;
  final String gender;
  final Function(String) onGenderChanged;

  const PersonalInfoSection({
    super.key,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.occupationCtrl,
    required this.dobCtrl,
    this.firstNameFocus,
    required this.onSelectDOB,
    required this.gender,
    required this.onGenderChanged,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Personal Information",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          color: Colors.white,
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
                  controller: widget.firstNameCtrl,
                  focusNode: widget.firstNameFocus,
                  decoration: _fieldDeco("First Name"),
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
                  controller: widget.lastNameCtrl,
                  decoration: _fieldDeco("Family Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 20),
                const Text("Gender"),
                Row(
                  children: [
                    _genderButton(
                      label: "Male",
                      selectedGender: widget.gender,
                      onChanged: widget.onGenderChanged,
                    ),
                    _genderButton(
                      label: "Female",
                      selectedGender: widget.gender,
                      onChanged: widget.onGenderChanged,
                    ),
                    _genderButton(
                      label: "Others",
                      selectedGender: widget.gender,
                      onChanged: widget.onGenderChanged,
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
                  controller: widget.occupationCtrl,
                  decoration: _fieldDeco("Occupation"),
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
                TextFormField(
                  controller: widget.dobCtrl,
                  readOnly: true,
                  decoration: _fieldDeco("Date of Birth").copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: widget.onSelectDOB,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Select DOB" : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _genderButton({
    required String label,
    required String selectedGender,
    required Function(String) onChanged,
  }) {
    return Expanded(
      child: RadioListTile(
        title: Text(label),
        value: label,
        groupValue: selectedGender,
        onChanged: (value) => onChanged(value.toString()),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  InputDecoration _fieldDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
    );
  }
}