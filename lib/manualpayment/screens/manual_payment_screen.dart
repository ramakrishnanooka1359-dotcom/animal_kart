import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animal_kart_demo2/manualpayment/provider/ifsc_provider.dart';
import 'package:animal_kart_demo2/manualpayment/provider/manual_payment_provider.dart';
import 'package:animal_kart_demo2/manualpayment/widgets/bank_transfer_form.dart';
import 'package:animal_kart_demo2/manualpayment/widgets/cheque_payment_form.dart';
import 'package:animal_kart_demo2/manualpayment/widgets/common_widgets.dart';
import 'package:animal_kart_demo2/orders/widgets/custom_widgets.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/manualpayment/widgets/payment_mode_selector.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/utils/image_compressor_helper.dart';
import 'package:animal_kart_demo2/widgets/floating_toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


class ManualPaymentScreen extends ConsumerStatefulWidget {
  final double totalAmount;
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

  //bool _isUploading = false;
  bool _isDeleting = false;
  Timer? _ifscDebounceTimer;
  bool _isCompressing = false;

  // Bank Transfer Controllers
  final bankAmountCtrl = TextEditingController();
  final utrCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final ifscCodeCtrl = TextEditingController();
  final transactionDateCtrl = TextEditingController();
  String transferMode = 'NEFT';
  final List<String> transferModes = ['NEFT', 'RTGS', 'IMPS'];
  String? ifscErrorBankTransfer;
  String? bankScreenshotError;
  String? bankScreenshotUrl;
  String? bankScreenshotPath;
  double? bankScreenshotProgress;
  File? bankScreenshot;

  // Cheque Payment Controllers
  final chequeNoCtrl = TextEditingController();
  final chequeDateCtrl = TextEditingController();
  final chequeAmountCtrl = TextEditingController();
  final chequeBankNameCtrl = TextEditingController();
  final chequeIfscCodeCtrl = TextEditingController();
  final chequeUtrRefCtrl = TextEditingController();
  String? ifscErrorCheque;
  String? chequeFrontImageError;
  String? chequeBackImageError;
  String? chequeFrontUrl;
  String? chequeBackUrl;
  String? chequeFrontPath;
  String? chequeBackPath;
  double? chequeFrontProgress;
  double? chequeBackProgress;
  File? chequeFrontImage;
  File? chequeBackImage;

  @override
  void initState() {
    super.initState();
    bankAmountCtrl.text = FormatUtils.formatAmountWithCurrency(widget.totalAmount);
    chequeAmountCtrl.text = FormatUtils.formatAmountWithCurrency(widget.totalAmount);
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
    _ifscDebounceTimer?.cancel();
    super.dispose();
  }

  void _onIfscChanged(String value, {bool isBankTransfer = true}) {
    _ifscDebounceTimer?.cancel();
    
    if (isBankTransfer) {
      setState(() {
        ifscErrorBankTransfer = null;
      });
    } else {
      setState(() {
        ifscErrorCheque = null;
      });
    }

    if (value.isEmpty) {
      if (isBankTransfer) {
        bankNameCtrl.text = '';
      } else {
        chequeBankNameCtrl.text = '';
      }
      return;
    }

    _ifscDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.length == 11) {
        _fetchBankDetails(value, isBankTransfer: isBankTransfer);
      } else if (value.length > 11) {
        final errorMessage = 'IFSC code must be exactly 11 characters';
        if (isBankTransfer) {
          bankNameCtrl.text = '';
          ifscErrorBankTransfer = errorMessage;
        } else {
          chequeBankNameCtrl.text = '';
          ifscErrorCheque = errorMessage;
        }
      }
    });
  }

  Future<void> _fetchBankDetails(String ifscCode, {bool isBankTransfer = true}) async {
    try {
      final ifscData = await IfscService.fetchBankDetails(ifscCode);
      
      if (ifscData != null && mounted) {
        final bankInfo = '${ifscData.bank} - ${ifscData.branch}';
        
        if (isBankTransfer) {
          setState(() {
            bankNameCtrl.text = bankInfo;
            ifscErrorBankTransfer = null;
          });
        } else {
          setState(() {
            chequeBankNameCtrl.text = bankInfo;
            ifscErrorCheque = null;
          });
        }
      } else {
        final errorMessage = 'IFSC code not found. Please enter a valid IFSC code.';
        if (mounted) {
          if (isBankTransfer) {
            setState(() {
              bankNameCtrl.text = '';
              ifscErrorBankTransfer = errorMessage;
            });
          } else {
            setState(() {
              chequeBankNameCtrl.text = '';
              ifscErrorCheque = errorMessage;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching bank details: $e');
    }
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

  Future<File?> _pickAndCompressImage(bool isCamera) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85, 
        maxWidth: 1920, 
        maxHeight: 1920,
      );
      
      if (picked == null) return null;
      
      final originalFile = File(picked.path);
      
     
      final originalSize = await originalFile.length() / 1024;
     
      
      if (originalSize > 1024) {
        FloatingToast.showSimpleToast("Compressing large image...");
      }
      
     
      final compressedFile = await ImageCompressionHelper.getCompressedImageIfNeeded(
        originalFile,
        isDocument: true,
      );
      
      
    
      return compressedFile;
      
    } catch (e) {
     
      FloatingToast.showSimpleToast("Failed to process image");
      return null;
    }
  }

  Future<void> _handleImageUpload({
    required bool isCamera,
    required bool isBankScreenshot,
    required bool isChequeFront,
    required bool isChequeBack,
  }) async {
    // Show compression indicator
    if (mounted) {
      setState(() => _isCompressing = true);
    }
    
    final file = await _pickAndCompressImage(isCamera);
    
    if (mounted) {
      setState(() => _isCompressing = false);
    }
    
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
    final dateFolder = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    String pathPrefix = "userpics/manual_payments/$dateFolder";
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

  Future<void> _handleBankTransferSubmit() async {
    if (!_bankFormKey.currentState!.validate()) return;

    final screenshotError = BankTransferValidators.validatePaymentScreenshot(bankScreenshot);
    if (screenshotError != null) {
      setState(() => bankScreenshotError = screenshotError);
      return;
    }

    final dateError = _validateTransactionDate(transactionDateCtrl.text, transferMode);
    if (dateError != null) {
      FloatingToast.showSimpleToast(dateError);
      return;
    }

    if (_isCompressing) {
      FloatingToast.showSimpleToast("Please wait for image compression to complete");
      return;
    }

    if (bankScreenshotProgress != null) {
      FloatingToast.showSimpleToast("Please wait for image upload to complete");
      return;
    }

    final transactionData = {
      "transferMode": transferMode,
      "amount": double.tryParse(bankAmountCtrl.text) ?? widget.totalAmount.toDouble(),
      "utrNumber": utrCtrl.text.trim(),
      "payerBankName": bankNameCtrl.text.trim(),
      "transactionDate": transactionDateCtrl.text,
      "payerIFSC": ifscCodeCtrl.text.trim(),
      "paymentScreenshotUrl": bankScreenshotUrl,
    };

    

    final payload = {
      "orderId": widget.unitId,
      "paymentType": "BANK_TRANSFER",
      "userId": widget.userId,
      "breedId": widget.buffaloId,
      "transaction": transactionData,
    };
    debugPrint('Bank Transfer Payload: ${jsonEncode(payload)}');

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

  Future<void> _handleChequePaymentSubmit() async {
    if (!_chequeFormKey.currentState!.validate()) return;

    final frontError = ChequePaymentValidators.validateChequeFrontImage(chequeFrontImage);
    final backError = ChequePaymentValidators.validateChequeBackImage(chequeBackImage);

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

    if (_isCompressing) {
      FloatingToast.showSimpleToast("Please wait for image compression to complete");
      return;
    }

    if (chequeFrontProgress != null || chequeBackProgress != null) {
      FloatingToast.showSimpleToast("Please wait for image upload to complete");
      return;
    }

    if ((chequeFrontUrl == null && chequeFrontImage != null) ||
        (chequeBackUrl == null && chequeBackImage != null)) {
      FloatingToast.showSimpleToast("Image upload failed, please try again");
      return;
    }

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
      "orderId": widget.unitId,
      "paymentType": "CHEQUE",
      "userId": widget.userId,
      "breedId": widget.buffaloId,
      "transaction": transactionData,
    };

    debugPrint('Cheque Payload: ${jsonEncode(payload)}');
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
    final minDate = DateTime(today.year, today.month - 3, today.day);
    final maxDate = DateTime(today.year, today.month + 3, today.day);
    return (minDate, maxDate);
  }

  (DateTime, DateTime) _getDatePickerConstraints(String mode) {
    final (minDate, maxDate) = _getDateConstraints(mode);
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
      
      final minDate = DateTime(today.year, today.month - 3, today.day);
      final maxDate = DateTime(today.year, today.month + 3, today.day);

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

  Widget _buildSubmitButton({required bool isFormBank}) {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.watch(manualPaymentProvider);
        final bool isUploadInProgress = isFormBank
            ? bankScreenshotProgress != null
            : (chequeFrontProgress != null || chequeBackProgress != null);

        final bool shouldDisable = controller.isLoading || 
            isUploadInProgress || 
            _isDeleting || 
            _isCompressing;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: shouldDisable
                ? null
                : (isFormBank ? _handleBankTransferSubmit : _handleChequePaymentSubmit),
            style: ElevatedButton.styleFrom(
              backgroundColor: shouldDisable ? Colors.grey : kPrimaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: _isCompressing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.tr("compressing"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : controller.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.tr("submit"),
                        style: const TextStyle(
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

 

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                  "${context.tr("amountToPay")}: ${FormatUtils.formatAmountWithCurrency(widget.totalAmount)}",
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

                if (showBankForm)
                  BankTransferForm(
                    formKey: _bankFormKey,
                    bankAmountCtrl: bankAmountCtrl,
                    utrCtrl: utrCtrl,
                    bankNameCtrl: bankNameCtrl,
                    ifscCodeCtrl: ifscCodeCtrl,
                    transactionDateCtrl: transactionDateCtrl,
                    transferMode: transferMode,
                    transferModes: transferModes,
                    ifscError: ifscErrorBankTransfer,
                    bankScreenshot: bankScreenshot,
                    bankScreenshotError: bankScreenshotError,
                    bankScreenshotProgress: bankScreenshotProgress,
                    onIfscChanged: (value) => _onIfscChanged(value, isBankTransfer: true),
                    onTransferModeChanged: (newValue) => setState(() => transferMode = newValue),
                    onCameraPressed: () => _handleImageUpload(
                      isCamera: true,
                      isBankScreenshot: true,
                      isChequeFront: false,
                      isChequeBack: false,
                    ),
                    onGalleryPressed: () => _handleImageUpload(
                      isCamera: false,
                      isBankScreenshot: true,
                      isChequeFront: false,
                      isChequeBack: false,
                    ),
                    onRemoveImage: () {
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
                    validateTransactionDate: (value) => _validateTransactionDate(value, transferMode),
                    getDatePickerConstraints: _getDatePickerConstraints,
                    buildSubmitButton: () => _buildSubmitButton(isFormBank: true),
                  ),

                if (showChequeForm)
                  ChequePaymentForm(
                    formKey: _chequeFormKey,
                    chequeNoCtrl: chequeNoCtrl,
                    chequeDateCtrl: chequeDateCtrl,
                    chequeAmountCtrl: chequeAmountCtrl,
                    chequeBankNameCtrl: chequeBankNameCtrl,
                    chequeIfscCodeCtrl: chequeIfscCodeCtrl,
                    chequeUtrRefCtrl: chequeUtrRefCtrl,
                    ifscError: ifscErrorCheque,
                    chequeFrontImage: chequeFrontImage,
                    chequeBackImage: chequeBackImage,
                    chequeFrontImageError: chequeFrontImageError,
                    chequeBackImageError: chequeBackImageError,
                    chequeFrontProgress: chequeFrontProgress,
                    chequeBackProgress: chequeBackProgress,
                    onIfscChanged: (value) => _onIfscChanged(value, isBankTransfer: false),
                    onCameraFrontPressed: () => _handleImageUpload(
                      isCamera: true,
                      isBankScreenshot: false,
                      isChequeFront: true,
                      isChequeBack: false,
                    ),
                    onGalleryFrontPressed: () => _handleImageUpload(
                      isCamera: false,
                      isBankScreenshot: false,
                      isChequeFront: true,
                      isChequeBack: false,
                    ),
                    onCameraBackPressed: () => _handleImageUpload(
                      isCamera: true,
                      isBankScreenshot: false,
                      isChequeFront: false,
                      isChequeBack: true,
                    ),
                    onGalleryBackPressed: () => _handleImageUpload(
                      isCamera: false,
                      isBankScreenshot: false,
                      isChequeFront: false,
                      isChequeBack: true,
                    ),
                    onRemoveFrontImage: () {
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
                    onRemoveBackImage: () {
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
                    buildSubmitButton: () => _buildSubmitButton(isFormBank: false),
                  ),
              ],
            ),
          ),
        ),
        // _buildCompressionProgressOverlay(),
      ],
    );
  }
}