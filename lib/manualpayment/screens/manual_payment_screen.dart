import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/widgets/custom_widgets.dart';
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

  // Bank Transfer Controllers
  final bankAmountCtrl = TextEditingController();
  final utrCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final ifscCodeCtrl = TextEditingController();
  final transactionDateCtrl = TextEditingController();
  String transferMode = 'NEFT'; // Default value
  List<String> transferModes = ['NEFT', 'RTGS', 'IMPS'];
  File? bankScreenshot;

  // Cheque Payment Controllers
  final chequeNoCtrl = TextEditingController();
  final chequeDateCtrl = TextEditingController();
  final chequeAmountCtrl = TextEditingController();
  final chequeBankNameCtrl = TextEditingController();
  final chequeIfscCodeCtrl = TextEditingController();
  final chequeUtrRefCtrl = TextEditingController();
  File? chequeFrontImage;
  File? chequeBackImage;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bank Transfer Details (NEFT/RTGS/IMPS)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // Amount
            TextFormField(
              controller: bankAmountCtrl,
              readOnly: true,
              decoration: fieldDeco("Amount Paid"),
            ),
            const SizedBox(height: 15),

            // UTR Number
            TextFormField(
              controller: utrCtrl,
              decoration: fieldDeco("UTR Number"),
            ),
            const SizedBox(height: 15),

            // Bank Name
            TextFormField(
              controller: bankNameCtrl,
              decoration: fieldDeco("Bank Name"),
            ),
            const SizedBox(height: 15),

            // IFSC Code
            TextFormField(
              controller: ifscCodeCtrl,
              decoration: fieldDeco("IFSC Code"),
            ),
            const SizedBox(height: 15),

            // Transaction Date
            TextFormField(
              controller: transactionDateCtrl,
              readOnly: true,
              decoration: fieldDeco("Transaction Date").copyWith(
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
                          "${picked.day}-${picked.month}-${picked.year}";
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Transfer Mode Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transfer Mode",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
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

            // Payment Screenshot Upload
            AadhaarUploadWidget(
              title: "Upload Payment Screenshot",
              file: bankScreenshot,
              isFrontImage: true,
              onCamera: () async {
                final file = await pickImage(true);
                if (file != null) setState(() => bankScreenshot = file);
              },
              onGallery: () async {
                final file = await pickImage(false);
                if (file != null) setState(() => bankScreenshot = file);
              },
              onRemove: () {
                setState(() => bankScreenshot = null);
              },
            ),

            const SizedBox(height: 20),

            // Submit Button
            _submitButton(() {
              if (utrCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Enter UTR Number");
                return;
              }
              if (bankNameCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Enter Bank Name");
                return;
              }
              if (ifscCodeCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Enter IFSC Code");
                return;
              }
              if (transactionDateCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Select Transaction Date");
                return;
              }
              if (bankScreenshot == null) {
                FloatingToast.showSimpleToast("Upload Payment Screenshot");
                return;
              }
              FloatingToast.showSimpleToast("Bank Transfer Submitted");
            }),
          ],
        ),
      ),
    );
  }

  // Cheque Payment Form
  Widget _chequePaymentForm() {
    return Card(
      color: akWhiteColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cheque Payment Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // Cheque Number
            TextFormField(
              controller: chequeNoCtrl,
              decoration: fieldDeco("Cheque Number"),
            ),
            const SizedBox(height: 15),

            // Cheque Date
            TextFormField(
              controller: chequeDateCtrl,
              readOnly: true,
              decoration: fieldDeco("Cheque Date").copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      chequeDateCtrl.text =
                          "${picked.day}-${picked.month}-${picked.year}";
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Cheque Amount
            TextFormField(
              controller: chequeAmountCtrl,
              readOnly: true,
              decoration: fieldDeco("Cheque Amount"),
            ),
            const SizedBox(height: 15),

            // Bank Name
            TextFormField(
              controller: chequeBankNameCtrl,
              decoration: fieldDeco("Bank Name"),
            ),
            const SizedBox(height: 15),

            // IFSC Code
            TextFormField(
              controller: chequeIfscCodeCtrl,
              decoration: fieldDeco("IFSC Code"),
            ),
            const SizedBox(height: 15),

            // UTR/Reference Number
            TextFormField(
              controller: chequeUtrRefCtrl,
              decoration: fieldDeco("UTR/Reference Number"),
            ),

            const SizedBox(height: 20),

            // Cheque Front Image
            AadhaarUploadWidget(
              title: "Upload Cheque Front Image",
              file: chequeFrontImage,
              isFrontImage: true,
              onCamera: () async {
                final file = await pickImage(true);
                if (file != null) setState(() => chequeFrontImage = file);
              },
              onGallery: () async {
                final file = await pickImage(false);
                if (file != null) setState(() => chequeFrontImage = file);
              },
              onRemove: () {
                setState(() => chequeFrontImage = null);
              },
            ),

            const SizedBox(height: 20),

            // Cheque Back Image
            AadhaarUploadWidget(
              title: "Upload Cheque Back Image",
              file: chequeBackImage,
              isFrontImage: true,
              onCamera: () async {
                final file = await pickImage(true);
                if (file != null) setState(() => chequeBackImage = file);
              },
              onGallery: () async {
                final file = await pickImage(false);
                if (file != null) setState(() => chequeBackImage = file);
              },
              onRemove: () {
                setState(() => chequeBackImage = null);
              },
            ),

            const SizedBox(height: 20),

            // Submit Button
            _submitButton(() {
              if (chequeNoCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Enter Cheque Number");
                return;
              }
              if (chequeDateCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Select Cheque Date");
                return;
              }
              if (chequeBankNameCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Enter Bank Name");
                return;
              }
              if (chequeIfscCodeCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Enter IFSC Code");
                return;
              }
              if (chequeUtrRefCtrl.text.isEmpty) {
                FloatingToast.showSimpleToast("Enter UTR/Reference Number");
                return;
              }
              if (chequeFrontImage == null) {
                FloatingToast.showSimpleToast("Upload Cheque Front Image");
                return;
              }
              if (chequeBackImage == null) {
                FloatingToast.showSimpleToast("Upload Cheque Back Image");
                return;
              }
              FloatingToast.showSimpleToast("Cheque Details Submitted");
            }),
          ],
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