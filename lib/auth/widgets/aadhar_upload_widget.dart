import 'dart:io';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/svg_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AadhaarUploadWidget extends ConsumerWidget {
  final File? file;
  final String title; // Now using localization key
  final VoidCallback onRemove;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final bool isFrontImage;
  final double? uploadProgress;

  const AadhaarUploadWidget({
    super.key,
    required this.file,
    required this.title,
    required this.onRemove,
    required this.onCamera,
    required this.onGallery,
    this.isFrontImage = true,
    this.uploadProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr(title), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            /// ✅ NO UPLOAD LOGIC, ONLY STATIC PREVIEW
            if (file != null)
              _buildFilePreview(context)
            else
              _buildUploadButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.file(
                file!,
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
                            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGreen),
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 8),
                          if (uploadProgress != null)
                            Text(
                              '${(uploadProgress! * 100).toStringAsFixed(0)}%',
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
              child: SvgPicture.string(
                SvgUtils().deleteIcon,
                color: akRedColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                child: Text(context.tr("openCamera")),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
