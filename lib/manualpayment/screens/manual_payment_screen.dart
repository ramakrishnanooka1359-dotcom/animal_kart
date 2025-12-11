import 'dart:io';
import 'package:animal_kart_demo2/manualpayment/widgets/common_widgets.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/auth/widgets/aadhar_upload_widget.dart';
import 'package:animal_kart_demo2/widgets/floating_toast.dart';

class ManualPaymentScreen extends StatefulWidget {
  final int totalAmount;

  const ManualPaymentScreen({super.key, required this.totalAmount});

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  bool showBankForm = true;
  bool showChequeForm = false;
  final GlobalKey<FormState> _bankFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _chequeFormKey = GlobalKey<FormState>();


  // Bank Transfer Controllers

  final bankAmountCtrl = TextEditingController();
  final bankAccountNumber = TextEditingController();
  final bankAccountHolderName = TextEditingController();
  final utrCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final ifscCodeCtrl = TextEditingController();
  final transactionDateCtrl = TextEditingController();
  String transferMode = 'NEFT'; 
  List<String> transferModes = ['NEFT', 'RTGS', 'IMPS'];
  File? bankScreenshot;
  String? bankScreenshotError;


  // Cheque Payment Controllers
  
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

  Future<File?> pickImage(bool isCamera) async {
    final picked = await ImagePicker().pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    return picked != null ? File(picked.path) : null;
  }

  @override
  void initState() {
    super.initState();
    bankAmountCtrl.text = widget.totalAmount.toString();
    chequeAmountCtrl.text = widget.totalAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFieldBg,
      appBar: AppBar(
        title: const Text("Manual Payment"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Amount to Pay: ₹${widget.totalAmount}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Payment Mode Selection
            Row(
              children: [
                Expanded(
                  child: _paymentSelectButton(
                    title: "Bank Transfer",
                    isSelected: showBankForm,
                    color: Colors.green,
                    onTap: () {
                      setState(() {
                        showBankForm = true;
                        showChequeForm = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _paymentSelectButton(
                    title: "Cheque",
                    isSelected: showChequeForm,
                    color: Colors.orange,
                    onTap: () {
                      setState(() {
                        showChequeForm = true;
                        showBankForm = false;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Forms
            if (showBankForm) _bankTransferForm(),
            if (showChequeForm) _chequePaymentForm(),
          ],
        ),
      ),
    );
  }

  // Payment Mode Selection Button
  Widget _paymentSelectButton({
    required String title,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: isSelected ? color : akWhiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Bank Transfer Form
  Widget _bankTransferForm() {
    return Card(
      color: akWhiteColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _bankFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Bank Transfer Details (NEFT/RTGS/IMPS)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // Amount Field
              ValidatedTextField(
                controller: bankAmountCtrl,
                label: "Amount Paid",
                readOnly: true,
              ),
              const SizedBox(height: 15),

              // UTR Number Field
              ValidatedTextField(
                controller: utrCtrl,
                label: "UTR Number",
                validator: BankTransferValidators.validateUTR,
                keyboardType: TextInputType.text,
                maxLength: 22,
              ),
              const SizedBox(height: 8),

              // Bank Name Field
              ValidatedTextField(
                controller: bankNameCtrl,
                label: "Bank Name",
                validator: BankTransferValidators.validateBankName,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 8),

              // IFSC Code Field
              ValidatedTextField(
                controller: ifscCodeCtrl,
                label: "IFSC Code",
                validator: BankTransferValidators.validateIFSC,
                keyboardType: TextInputType.text,
                maxLength: 11,
              ),
              const SizedBox(height: 8),

              // Transaction Date Field
              ValidatedTextField(
                controller: transactionDateCtrl,
                label: "Transaction Date",
                readOnly: true,
                validator: BankTransferValidators.validateTransactionDate,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      transactionDateCtrl.text =
                          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Transfer Mode Dropdown
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
                        setState(() {
                          transferMode = newValue!;
                        });
                      },
                      items: transferModes
                          .map<DropdownMenuItem<String>>((String value) {
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

              // Payment Screenshot Upload with validation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AadhaarUploadWidget(
                    title: "Upload Payment Screenshot",
                    file: bankScreenshot,
                    isFrontImage: true,
                    onCamera: () async {
                      final file = await pickImage(true);
                      if (file != null) {
                        setState(() {
                          bankScreenshot = file;
                          bankScreenshotError = null;
                        });
                      }
                    },
                    onGallery: () async {
                      final file = await pickImage(false);
                      if (file != null) {
                        setState(() {
                          bankScreenshot = file;
                          bankScreenshotError = null;
                        });
                      }
                    },
                    onRemove: () {
                      setState(() {
                        bankScreenshot = null;
                        bankScreenshotError = null;
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
              _submitButton(() {
               
                if (_bankFormKey.currentState!.validate()) {
                  
                  final screenshotError =
                      BankTransferValidators.validatePaymentScreenshot(
                          bankScreenshot);
                  if (screenshotError != null) {
                    setState(() {
                      bankScreenshotError = screenshotError;
                    });
                    return;
                  }                  
                  FloatingToast.showSimpleToast("Bank Transfer Submitted");
                   Navigator.pushReplacementNamed(
                                context,
                                AppRouter.PaymentPending,
                    ); 
                  
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chequePaymentForm() {
    return Card(
      color: akWhiteColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _chequeFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Cheque Payment Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // Cheque Number
              ValidatedTextField(
                controller: chequeNoCtrl,
                label: "Cheque Number",
                validator: ChequePaymentValidators.validateChequeNumber,
                keyboardType: TextInputType.number,
                maxLength: 10,
              ),
              const SizedBox(height: 8),

              // Cheque Date
              ValidatedTextField(
                controller: chequeDateCtrl,
                label: "Cheque Date",
                readOnly: true,
                validator: ChequePaymentValidators.validateChequeDate,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      chequeDateCtrl.text =
                          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Cheque Amount
              ValidatedTextField(
                controller: chequeAmountCtrl,
                label: "Cheque Amount",
                readOnly: true,
              ),
              const SizedBox(height: 8),

              // Bank Name
              ValidatedTextField(
                controller: chequeBankNameCtrl,
                label: "Bank Name",
                validator: ChequePaymentValidators.validateChequeBankName,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 8),

              // IFSC Code
              ValidatedTextField(
                controller: chequeIfscCodeCtrl,
                label: "IFSC Code",
                validator: ChequePaymentValidators.validateChequeIFSC,
                keyboardType: TextInputType.text,
                maxLength: 11,
              ),
              const SizedBox(height: 8),

              // UTR/Reference Number
              ValidatedTextField(
                controller: chequeUtrRefCtrl,
                label: "UTR/Reference Number",
                validator: ChequePaymentValidators.validateChequeUTRRef,
                keyboardType: TextInputType.text,
                maxLength: 30,
              ),
              const SizedBox(height: 20),

              // Cheque Front Image with validation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AadhaarUploadWidget(
                    title: "Upload Cheque Front Image",
                    file: chequeFrontImage,
                    isFrontImage: true,
                    onCamera: () async {
                      final file = await pickImage(true);
                      if (file != null) {
                        setState(() {
                          chequeFrontImage = file;
                          chequeFrontImageError = null;
                        });
                      }
                    },
                    onGallery: () async {
                      final file = await pickImage(false);
                      if (file != null) {
                        setState(() {
                          chequeFrontImage = file;
                          chequeFrontImageError = null;
                        });
                      }
                    },
                    onRemove: () {
                      setState(() {
                        chequeFrontImage = null;
                        chequeFrontImageError = null;
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

              // Cheque Back Image with validation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AadhaarUploadWidget(
                    title: "Upload Cheque Back Image",
                    file: chequeBackImage,
                    isFrontImage: true,
                    onCamera: () async {
                      final file = await pickImage(true);
                      if (file != null) {
                        setState(() {
                          chequeBackImage = file;
                          chequeBackImageError = null;
                        });
                      }
                    },
                    onGallery: () async {
                      final file = await pickImage(false);
                      if (file != null) {
                        setState(() {
                          chequeBackImage = file;
                          chequeBackImageError = null;
                        });
                      }
                    },
                    onRemove: () {
                      setState(() {
                        chequeBackImage = null;
                        chequeBackImageError = null;
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

              // Submit Button with validation
              _submitButton(() {
                // Validate form fields
                if (_chequeFormKey.currentState!.validate()) {
                  // Validate images
                  final frontImageError =
                      ChequePaymentValidators.validateChequeFrontImage(
                          chequeFrontImage);
                  final backImageError =
                      ChequePaymentValidators.validateChequeBackImage(
                          chequeBackImage);

                  bool hasError = false;
                  
                  if (frontImageError != null) {
                    setState(() {
                      chequeFrontImageError = frontImageError;
                    });
                    hasError = true;
                  }
                  
                  if (backImageError != null) {
                    setState(() {
                      chequeBackImageError = backImageError;
                    });
                    hasError = true;
                  }
                  
                  if (hasError) return;
                    Navigator.pushReplacementNamed(
                        context,
                      AppRouter.PaymentPending,
                    ); 

                  // If all validations pass
                  FloatingToast.showSimpleToast("Cheque Details Submitted");
                  
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Submit Button
  Widget _submitButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryGreen,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
        ),
        child: const Text(
          "Submit",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
    );
  }
}