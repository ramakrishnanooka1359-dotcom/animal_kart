import 'dart:io';

import 'package:animal_kart_demo2/manualpayment/widgets/capital_convert_widget.dart';
import 'package:animal_kart_demo2/manualpayment/widgets/common_widgets.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

class BankTransferForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController bankAmountCtrl;
  final TextEditingController utrCtrl;
  final TextEditingController bankNameCtrl;
  final TextEditingController ifscCodeCtrl;
  final TextEditingController transactionDateCtrl;
  final String transferMode;
  final List<String> transferModes;
  final String? ifscError;
  final File? bankScreenshot;
  final String? bankScreenshotError;
  final double? bankScreenshotProgress;
  final Function(String) onIfscChanged;
  final Function(String) onTransferModeChanged;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onRemoveImage;
  final String? Function(String? value)? validateTransactionDate;
  final (DateTime, DateTime) Function(String mode) getDatePickerConstraints;
  final Widget Function() buildSubmitButton;

  const BankTransferForm({
    super.key,
    required this.formKey,
    required this.bankAmountCtrl,
    required this.utrCtrl,
    required this.bankNameCtrl,
    required this.ifscCodeCtrl,
    required this.transactionDateCtrl,
    required this.transferMode,
    required this.transferModes,
    required this.ifscError,
    required this.bankScreenshot,
    required this.bankScreenshotError,
    required this.bankScreenshotProgress,
    required this.onIfscChanged,
    required this.onTransferModeChanged,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onRemoveImage,
    required this.validateTransactionDate,
    required this.getDatePickerConstraints,
    required this.buildSubmitButton,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr("bankTransferDetails"),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              ValidatedTextField(
                controller: bankAmountCtrl,
                label: context.tr("amountPaid"),
                readOnly: true,
              ),
              const SizedBox(height: 15),

              ValidatedTextField(
                controller: utrCtrl,
                label: context.tr("utrNumber"),
                validator: BankTransferValidators.validateUTR,
                keyboardType: TextInputType.text,
                maxLength: 22,
                inputFormatters: [UpperCaseTextFormatter()],
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: ifscCodeCtrl,
                label: context.tr("ifscCode"),
                validator: BankTransferValidators.validateIFSC,
                keyboardType: TextInputType.text,
                maxLength: 11,
                inputFormatters: [UpperCaseTextFormatter()],
                onChanged: onIfscChanged,
              ),
              if (ifscError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Text(
                    ifscError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 8),
              ValidatedTextField(
                controller: bankNameCtrl,
                label: context.tr("bankName"),
                keyboardType: TextInputType.text,
                readOnly: true,
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: transactionDateCtrl,
                label: context.tr("transactionDate"),
                readOnly: true,
                validator: validateTransactionDate,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final (firstDate, lastDate) = getDatePickerConstraints(transferMode);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: firstDate,
                      lastDate: lastDate,
                    );
                    if (picked != null) {
                      transactionDateCtrl.text =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldTitle(context.tr("transferMode")),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: transferMode,
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        onTransferModeChanged(newValue!);
                      },
                      items: transferModes.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAadhaarUploadWidget(
                     context: context,
                    title: context.tr("uploadPaymentScreenshot"),
                    file: bankScreenshot,
                    uploadProgress: bankScreenshotProgress,
                    onCamera: onCameraPressed,
                    onGallery: onGalleryPressed,
                    onRemove: onRemoveImage,
                  ),
                  if (bankScreenshotError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        bankScreenshotError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),
              buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAadhaarUploadWidget({
      required BuildContext context,
    required String title,
    required File? file,
    required double? uploadProgress,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AbsorbPointer(
          absorbing: uploadProgress != null,
          child: Opacity(
            opacity: uploadProgress != null ? 0.6 : 1.0,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 12),

                    if (file != null)
                      _buildFilePreview(file, uploadProgress, onRemove)
                    else
                      _buildUploadButtons(context,onGallery, onCamera),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview(File file, double? uploadProgress, VoidCallback onRemove) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.file(
                file,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              if (uploadProgress != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            value: uploadProgress,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryGreen),
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 8),
                          if (uploadProgress != null)
                            Text(
                              '${(uploadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButtons(BuildContext context,VoidCallback onGallery, VoidCallback onCamera) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 55,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onGallery,
            child: Text(
              context.tr("uploadImage"),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Text(context.tr("uploadPhotosNote")),
          Text(context.tr("or")),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: onCamera,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              context.tr("openCamera"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}