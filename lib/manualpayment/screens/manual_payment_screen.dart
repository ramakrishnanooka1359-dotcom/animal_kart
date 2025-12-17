// lib/manualpayment/manual_payment_screen.dart
import 'dart:io';
import 'package:animal_kart_demo2/manualpayment/model/manual_payment_form_model.dart';
import 'package:animal_kart_demo2/manualpayment/provider/manual_payment_provider.dart';
import 'package:animal_kart_demo2/manualpayment/widgets/capital_convert_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/manualpayment/widgets/common_widgets.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/widgets/floating_toast.dart';

import '../widgets/payment_mode_selector.dart';



class ManualPaymentScreen  extends ConsumerStatefulWidget  {
  final int totalAmount;
  final String unitId;
  final String userId;
  final String buffaloId;

  const ManualPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.unitId,
    required this.userId,
    required this.buffaloId,
  });

  @override
  ConsumerState<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends ConsumerState<ManualPaymentScreen> {
  bool showBankForm = true;
  bool showChequeForm = false;

  final GlobalKey<FormState> _bankFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _chequeFormKey = GlobalKey<FormState>();

  bool _isUploading = false;
  bool _isDeleting = false;

  final bankAmountCtrl = TextEditingController();
  final utrCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final ifscCodeCtrl = TextEditingController();
  final transactionDateCtrl = TextEditingController();
  String transferMode = 'NEFT';
  final List<String> transferModes = ['NEFT', 'RTGS', 'IMPS'];

  File? bankScreenshot;
  String? bankScreenshotError;
  String? bankScreenshotUrl;
  String? bankScreenshotPath;
  double? bankScreenshotProgress;

  final chequeNoCtrl = TextEditingController();
  final chequeDateCtrl = TextEditingController();
  final chequeAmountCtrl = TextEditingController();
  final chequeBankNameCtrl = TextEditingController();
  final chequeIfscCodeCtrl = TextEditingController();
  final chequeUtrRefCtrl = TextEditingController();

  File? chequeFrontImage;
  File? chequeBackImage;
  String? chequeFrontImageError;
  String? chequeBackImageError;
  String? chequeFrontUrl;
  String? chequeBackUrl;
  String? chequeFrontPath;
  String? chequeBackPath;
  double? chequeFrontProgress;
  double? chequeBackProgress;

  @override
  void initState() {
    super.initState();
    bankAmountCtrl.text = widget.totalAmount.toString();
    chequeAmountCtrl.text = widget.totalAmount.toString();
  }

  @override
  void dispose() {
    bankAmountCtrl.dispose();
    utrCtrl.dispose();
    bankNameCtrl.dispose();
    ifscCodeCtrl.dispose();
    transactionDateCtrl.dispose();
    chequeNoCtrl.dispose();
    chequeDateCtrl.dispose();
    chequeAmountCtrl.dispose();
    chequeBankNameCtrl.dispose();
    chequeIfscCodeCtrl.dispose();
    chequeUtrRefCtrl.dispose();
    super.dispose();
  }

  Future<String?> _uploadFile(
    File file,
    String path,
    Function(double) onProgress,
  ) async {
    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );
      final ref = storage.ref().child(path);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: "image/jpeg"),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      setState(() => _isDeleting = true);

      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );
      final ref = storage.ref().child(path);
      await ref.delete();

      if (mounted) {
        FloatingToast.showSimpleToast("Image deleted successfully");
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _handleImageUpload({
    required bool isCamera,
    required bool isBankScreenshot,
    required bool isChequeFront,
    required bool isChequeBack,
  }) async {
    final file = await pickImage(isCamera);
    if (file == null) return;

    if (isBankScreenshot) {
      setState(() {
        bankScreenshot = file;
        bankScreenshotError = null;
        bankScreenshotProgress = 0.0;
      });
    } else if (isChequeFront) {
      setState(() {
        chequeFrontImage = file;
        chequeFrontImageError = null;
        chequeFrontProgress = 0.0;
      });
    } else if (isChequeBack) {
      setState(() {
        chequeBackImage = file;
        chequeBackImageError = null;
        chequeBackProgress = 0.0;
      });
    }

    final now = DateTime.now();
    final dateFolder =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    String pathPrefix = "manual_payment/$dateFolder";
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

    if (isBankScreenshot) fileName = "bank_transfer_$fileName";
    if (isChequeFront) fileName = "cheque_front_$fileName";
    if (isChequeBack) fileName = "cheque_back_$fileName";

    final url = await _uploadFile(file, "$pathPrefix/$fileName", (progress) {
      if (mounted) {
        setState(() {
          if (isBankScreenshot) bankScreenshotProgress = progress;
          if (isChequeFront) chequeFrontProgress = progress;
          if (isChequeBack) chequeBackProgress = progress;
        });
      }
    });

    if (mounted) {
      setState(() {
        if (isBankScreenshot) {
          bankScreenshotUrl = url;
          bankScreenshotPath = url != null ? "$pathPrefix/$fileName" : null;
          bankScreenshotProgress = null;
        }
        if (isChequeFront) {
          chequeFrontUrl = url;
          chequeFrontPath = url != null ? "$pathPrefix/$fileName" : null;
          chequeFrontProgress = null;
        }
        if (isChequeBack) {
          chequeBackUrl = url;
          chequeBackPath = url != null ? "$pathPrefix/$fileName" : null;
          chequeBackProgress = null;
        }
      });

      if (url == null) {
        FloatingToast.showSimpleToast("Image upload failed");
      }
    }
  }

  Future<File?> pickImage(bool isCamera) async {
    final picked = await ImagePicker().pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    return picked != null ? File(picked.path) : null;
  }

  



Future<void> _handleBankTransferSubmit() async {
    if (!_bankFormKey.currentState!.validate()) return;

    final screenshotError =
        BankTransferValidators.validatePaymentScreenshot(bankScreenshot);
    if (screenshotError != null) {
      setState(() => bankScreenshotError = screenshotError);
      return;
    }

     final dateError =
        _validateTransactionDate(transactionDateCtrl.text, transferMode);
    if (dateError != null) {
      FloatingToast.showSimpleToast(dateError);
      return;
    }


    if (bankScreenshotProgress != null) {
      FloatingToast.showSimpleToast(
          "Please wait for image upload to complete");
      return;
    }

    final transactionData = {
      "transferMode": transferMode,
      "amount":
          double.tryParse(bankAmountCtrl.text) ??
              widget.totalAmount.toDouble(),
      "utrNumber": utrCtrl.text.trim(),
      "payerBankName": bankNameCtrl.text.trim(),
      "transactionDate": transactionDateCtrl.text,
      "payerIFSC": ifscCodeCtrl.text.trim(),
      "paymentScreenshotUrl": bankScreenshotUrl,
    };

    final payload = {
      "unitId": widget.unitId,
      "paymentType": "BANK_TRANSFER",
      "userId": widget.userId,
      "buffaloId": widget.buffaloId,
      "transaction": transactionData,
    };

   
    final controller = ref.read(manualPaymentProvider.notifier);

    final success = await controller.submitManualPayment(payload);

    if (success) {
      FloatingToast.showSimpleToast(
        controller.successMessage ?? "Submitted successfully",
      );
      Navigator.pushReplacementNamed(
          context, AppRouter.PaymentPending);
    } else {
      FloatingToast.showSimpleToast(
        controller.errorMessage ?? "Submission failed",
      );
    }
  }

  Future<void> _handleChequePaymentSubmit() async {
    if (!_chequeFormKey.currentState!.validate()) return;

    final frontError = ChequePaymentValidators.validateChequeFrontImage(
      chequeFrontImage,
    );
    final backError = ChequePaymentValidators.validateChequeBackImage(
      chequeBackImage,
    );

    bool hasError = false;
    if (frontError != null) {
      setState(() => chequeFrontImageError = frontError);
      hasError = true;
    }
    if (backError != null) {
      setState(() => chequeBackImageError = backError);
      hasError = true;
    }
    if (hasError) return;

    if (chequeFrontProgress != null || chequeBackProgress != null) {
      FloatingToast.showSimpleToast(
        "Please wait for image upload to complete",
      );
      return;
    }

    if ((chequeFrontUrl == null && chequeFrontImage != null) ||
        (chequeBackUrl == null && chequeBackImage != null)) {
      FloatingToast.showSimpleToast(
        "Image upload failed, please try again",
      );
      return;
    }

    // Build cheque transaction data
    final transactionData = {
      "chequeNumber": chequeNoCtrl.text.trim(),
      "chequeDate": chequeDateCtrl.text.trim(),
      "amount": double.tryParse(chequeAmountCtrl.text) ?? widget.totalAmount.toDouble(),
      "bankName": chequeBankNameCtrl.text.trim(),
      "ifscCode": chequeIfscCodeCtrl.text.trim(),
      "utrReference": chequeUtrRefCtrl.text.trim(),
      "frontImageUrl": chequeFrontUrl,
      "backImageUrl": chequeBackUrl,
    };

    final payload = {
      "unitId": widget.unitId,
      "paymentType": "CHEQUE",
      "userId": widget.userId,
      "buffaloId": widget.buffaloId,
      "transaction": transactionData,
    };

    // Use the same provider for cheque payment
    final controller = ref.read(manualPaymentProvider.notifier);
    final success = await controller.submitManualPayment(payload);

    if (success) {
      FloatingToast.showSimpleToast(
        controller.successMessage ?? "Submitted successfully",
      );
      Navigator.pushReplacementNamed(context, AppRouter.PaymentPending);
    } else {
      FloatingToast.showSimpleToast(
        controller.errorMessage ?? "Submission failed",
      );
    }
  }

   (DateTime, DateTime) _getDateConstraints(String mode) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // For all modes: 3 months before to 3 months after today
  final minDate = DateTime(today.year, today.month - 3, today.day);
  final maxDate = DateTime(today.year, today.month + 3, today.day);
  
  return (minDate, maxDate);
}
   (DateTime, DateTime) _getDatePickerConstraints(String mode) {
  final (minDate, maxDate) = _getDateConstraints(mode);
  // For date picker, we need DateTime objects with time component
  return (
    DateTime(minDate.year, minDate.month, minDate.day),
    DateTime(maxDate.year, maxDate.month, maxDate.day, 23, 59, 59)
  );
  }

  String? _validateTransactionDate(String? value, String mode) {
  if (value == null || value.trim().isEmpty) {
    return "Transaction date is required";
  }

  try {
    final parts = value.split('-');
    if (parts.length != 3) {
      return "Invalid date format. Use YYYY-MM-DD";
    }

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    final selectedDate = DateTime(year, month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate 3 months before and after today
    final minDate = DateTime(today.year, today.month - 3, today.day);
    final maxDate = DateTime(today.year, today.month + 3, today.day);

    // Validate against the 3-month range for all modes
    if (selectedDate.isBefore(minDate) || selectedDate.isAfter(maxDate)) {
      final minDateStr = "${minDate.year}-${minDate.month.toString().padLeft(2, '0')}-${minDate.day.toString().padLeft(2, '0')}";
      final maxDateStr = "${maxDate.year}-${maxDate.month.toString().padLeft(2, '0')}-${maxDate.day.toString().padLeft(2, '0')}";
      return "Transaction date must be between $minDateStr and $maxDateStr";
    }
    
  } catch (e) {
    return "Invalid date format. Use YYYY-MM-DD";
  }

  return null;
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFieldBg,
      appBar: AppBar(
        title: Text(context.tr("manualPayment")),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${context.tr("amountToPay")}: ₹${widget.totalAmount}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            PaymentModeSelector(
              isBankSelected: showBankForm,
              isChequeSelected: showChequeForm,
              onBankSelected: () => setState(() {
                showBankForm = true;
                showChequeForm = false;
              }),
              onChequeSelected: () => setState(() {
                showChequeForm = true;
                showBankForm = false;
              }),
            ),
            const SizedBox(height: 20),

            if (showBankForm) _buildBankTransferForm(),
            if (showChequeForm) _buildChequePaymentForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTransferForm() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _bankFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bank Transfer Details",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              ValidatedTextField(
                controller: bankAmountCtrl,
                label: "Amount Paid",
                readOnly: true,
              ),
              const SizedBox(height: 15),

              ValidatedTextField(
                controller: utrCtrl,
                label: "UTR Number",
                validator: BankTransferValidators.validateUTR,
                keyboardType: TextInputType.text,
                maxLength: 22,
                inputFormatters: [
    UpperCaseTextFormatter(), 
  ],

              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: bankNameCtrl,
                label: "Bank Name",
                validator: BankTransferValidators.validateBankName,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: ifscCodeCtrl,
                label: "IFSC Code",
                validator: BankTransferValidators.validateIFSC,
                keyboardType: TextInputType.text,
                maxLength: 11,
                inputFormatters: [
    UpperCaseTextFormatter(), 
  ],
              ),
              const SizedBox(height: 8),

                            ValidatedTextField(
                controller: transactionDateCtrl,
                label: "Transaction Date",
                readOnly: true,
                validator: (value) =>
                    _validateTransactionDate(value, transferMode),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final (firstDate, lastDate) =
                        _getDatePickerConstraints(transferMode);
                    
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: firstDate,
                      lastDate: lastDate,
                    );
                    if (picked != null) {
                      setState(() {
                        transactionDateCtrl.text =
                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldTitle("Transfer Mode"),
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
                        setState(() => transferMode = newValue!);
                      },
                      items: transferModes.map<DropdownMenuItem<String>>((
                        value,
                      ) {
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
                    title: "Upload Payment Screenshot",
                    file: bankScreenshot,
                    uploadProgress: bankScreenshotProgress,
                    onCamera: () => _handleImageUpload(
                      isCamera: true,
                      isBankScreenshot: true,
                      isChequeFront: false,
                      isChequeBack: false,
                    ),
                    onGallery: () => _handleImageUpload(
                      isCamera: false,
                      isBankScreenshot: true,
                      isChequeFront: false,
                      isChequeBack: false,
                    ),
                    onRemove: () {
                      if (bankScreenshotPath != null) {
                        _deleteFile(bankScreenshotPath!);
                      }
                      setState(() {
                        bankScreenshot = null;
                        bankScreenshotError = null;
                        bankScreenshotUrl = null;
                        bankScreenshotPath = null;
                        bankScreenshotProgress = null;
                      });
                    },
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

              _buildSubmitButton(
                isFormBank: true,
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChequePaymentForm() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _chequeFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cheque Payment Details",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              ValidatedTextField(
                controller: chequeNoCtrl,
                label: "Cheque Number",
                validator: ChequePaymentValidators.validateChequeNumber,
                keyboardType: TextInputType.number,
                maxLength: 10,
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: chequeDateCtrl,
                label: "Cheque Date",
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
                label: "Cheque Amount",
                readOnly: true,
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: chequeBankNameCtrl,
                label: "Bank Name",
                validator: ChequePaymentValidators.validateChequeBankName,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: chequeIfscCodeCtrl,
                label: "IFSC Code",
                validator: ChequePaymentValidators.validateChequeIFSC,
                keyboardType: TextInputType.text,
                maxLength: 11,
                inputFormatters: [
    UpperCaseTextFormatter(), 
  ],

              ),
              const SizedBox(height: 8),

              ValidatedTextField(
                controller: chequeUtrRefCtrl,
                label: "UTR/Reference Number",
                validator: ChequePaymentValidators.validateChequeUTRRef,
                keyboardType: TextInputType.text,
                maxLength: 30,
                inputFormatters: [
    UpperCaseTextFormatter(), 
  ],

              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAadhaarUploadWidget(
                    title: "Upload Cheque Front Image",
                    file: chequeFrontImage,
                    uploadProgress: chequeFrontProgress,
                    onCamera: () => _handleImageUpload(
                      isCamera: true,
                      isBankScreenshot: false,
                      isChequeFront: true,
                      isChequeBack: false,
                    ),
                    onGallery: () => _handleImageUpload(
                      isCamera: false,
                      isBankScreenshot: false,
                      isChequeFront: true,
                      isChequeBack: false,
                    ),
                    onRemove: () {
                      if (chequeFrontPath != null) {
                        _deleteFile(chequeFrontPath!);
                      }
                      setState(() {
                        chequeFrontImage = null;
                        chequeFrontImageError = null;
                        chequeFrontUrl = null;
                        chequeFrontPath = null;
                        chequeFrontProgress = null;
                      });
                    },
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
                    title: "Upload Cheque Back Image",
                    file: chequeBackImage,
                    uploadProgress: chequeBackProgress,
                    onCamera: () => _handleImageUpload(
                      isCamera: true,
                      isBankScreenshot: false,
                      isChequeFront: false,
                      isChequeBack: true,
                    ),
                    onGallery: () => _handleImageUpload(
                      isCamera: false,
                      isBankScreenshot: false,
                      isChequeFront: false,
                      isChequeBack: true,
                    ),
                    onRemove: () {
                      if (chequeBackPath != null) {
                        _deleteFile(chequeBackPath!);
                      }
                      setState(() {
                        chequeBackImage = null;
                        chequeBackImageError = null;
                        chequeBackUrl = null;
                        chequeBackPath = null;
                        chequeBackProgress = null;
                      });
                    },
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

             _buildSubmitButton(
                isFormBank: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAadhaarUploadWidget({
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
          absorbing: uploadProgress != null || _isDeleting,
          child: Opacity(
            opacity: (uploadProgress != null || _isDeleting) ? 0.6 : 1.0,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 12),

                    if (file != null)
                      _buildFilePreview(file, uploadProgress, onRemove)
                    else
                      _buildUploadButtons(onGallery, onCamera),
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
                            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGreen),
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

  Widget _buildUploadButtons(VoidCallback onGallery, VoidCallback onCamera) {
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
            child: const Text(
              "Upload Image",
              style: TextStyle(fontSize: 18),
            ),
          ),
          const Text("Upload photos from gallery"),
          const Text("or"),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: onCamera,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text("Open Camera",
            style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),),
          ),
        ],
      ),
    );
  }

Widget _buildSubmitButton({
  required bool isFormBank, // true = bank, false = cheque
  bool isDisabled = false,
}) {
  return Consumer(
    builder: (context, ref, _) {
      final controller = ref.watch(manualPaymentProvider);

      final bool isUploadInProgress = isFormBank
          ? bankScreenshotProgress != null
          : (chequeFrontProgress != null || chequeBackProgress != null);

      final bool shouldDisable =
          isDisabled ||
          controller.isLoading ||
          isUploadInProgress ||
          _isDeleting;

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: shouldDisable
              ? null
              : (isFormBank
                  ? _handleBankTransferSubmit
                  : _handleChequePaymentSubmit),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                shouldDisable ? Colors.grey : kPrimaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: controller.isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    },
  );
}
}