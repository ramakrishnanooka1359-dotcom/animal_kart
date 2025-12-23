import 'dart:io';

import 'package:animal_kart_demo2/manualpayment/widgets/capital_convert_widget.dart';
import 'package:animal_kart_demo2/manualpayment/widgets/common_widgets.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ChequePaymentForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController chequeNoCtrl;
  final TextEditingController chequeDateCtrl;
  final TextEditingController chequeAmountCtrl;
  final TextEditingController chequeBankNameCtrl;
  final TextEditingController chequeIfscCodeCtrl;
  final TextEditingController chequeUtrRefCtrl;
  final String? ifscError;
  final File? chequeFrontImage;
  final File? chequeBackImage;
  final String? chequeFrontImageError;
  final String? chequeBackImageError;
  final double? chequeFrontProgress;
  final double? chequeBackProgress;
  final Function(String) onIfscChanged;
  final VoidCallback onCameraFrontPressed;
  final VoidCallback onGalleryFrontPressed;
  final VoidCallback onCameraBackPressed;
  final VoidCallback onGalleryBackPressed;
  final VoidCallback onRemoveFrontImage;
  final VoidCallback onRemoveBackImage;
  final Widget Function() buildSubmitButton;

  const ChequePaymentForm({
    super.key,
    required this.formKey,
    required this.chequeNoCtrl,
    required this.chequeDateCtrl,
    required this.chequeAmountCtrl,
    required this.chequeBankNameCtrl,
    required this.chequeIfscCodeCtrl,
    required this.chequeUtrRefCtrl,
    required this.ifscError,
    required this.chequeFrontImage,
    required this.chequeBackImage,
    required this.chequeFrontImageError,
    required this.chequeBackImageError,
    required this.chequeFrontProgress,
    required this.chequeBackProgress,
    required this.onIfscChanged,
    required this.onCameraFrontPressed,
    required this.onGalleryFrontPressed,
    required this.onCameraBackPressed,
    required this.onGalleryBackPressed,
    required this.onRemoveFrontImage,
    required this.onRemoveBackImage,
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
                context.tr("chequePaymentDetails"),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              ValidatedTextField(
                controller: chequeNoCtrl,
                label: context.tr("chequeNumber"),
                validator: ChequePaymentValidators.validateChequeNumber,
                keyboardType: TextInputType.number,
                maxLength: 10,
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: chequeDateCtrl,
                label: context.tr("chequeDate"),
                readOnly: true,
                validator: ChequePaymentValidators.validateChequeDate,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final minDate = DateTime(today.year, today.month - 3, today.day);
                    final maxDate = DateTime(today.year, today.month + 3, today.day);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: minDate,
                      lastDate: maxDate,
                    );
                    if (picked != null) {
                      chequeDateCtrl.text =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: chequeAmountCtrl,
                label: context.tr("chequeAmount"),
                readOnly: true,
              ),
              const SizedBox(height: 8),
              ValidatedTextField(
                controller: chequeIfscCodeCtrl,
                label: context.tr("ifscCode"),
                validator: ChequePaymentValidators.validateChequeIFSC,
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
                controller: chequeBankNameCtrl,
                label: context.tr("bankName"),
                keyboardType: TextInputType.text,
                readOnly: true,
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: chequeUtrRefCtrl,
                label: context.tr("utrReferenceNumber"),
                validator: ChequePaymentValidators.validateChequeUTRRef,
                keyboardType: TextInputType.text,
                maxLength: 30,
                inputFormatters: [UpperCaseTextFormatter()],
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAadhaarUploadWidget(
                    context: context,
                    title: context.tr("uploadChequeFrontImage"),
                    file: chequeFrontImage,
                    uploadProgress: chequeFrontProgress,
                    onCamera: onCameraFrontPressed,
                    onGallery: onGalleryFrontPressed,
                    onRemove: onRemoveFrontImage,
                  ),
                  if (chequeFrontImageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        chequeFrontImageError!,
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAadhaarUploadWidget(
                    context: context, 
                    title: context.tr("uploadChequeBackImage"),
                    file: chequeBackImage,
                    uploadProgress: chequeBackProgress,
                    onCamera: onCameraBackPressed,
                    onGallery: onGalleryBackPressed,
                    onRemove: onRemoveBackImage,
                  ),
                  if (chequeBackImageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        chequeBackImageError!,
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

  Widget _buildUploadButtons(BuildContext context, onGallery, VoidCallback onCamera) {
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