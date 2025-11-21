import 'dart:io';
import 'package:animal_kart_demo2/auth/providers/auth_provider.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:device_info_plus/device_info_plus.dart';

class OtpScreen extends ConsumerStatefulWidget {
  String verficationId;
  final String phoneNumber;

  OtpScreen({
    super.key,
    required this.verficationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState
    extends ConsumerState<OtpScreen> /* with CodeAutoFill  */ {
  final otpController = TextEditingController();

  String deviceId = "";
  String deviceModel = "";
  bool isOtpValid = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    //listenForCode();
  }

  // @override
  // void codeUpdated() {
  //   if (code == null) return;
  //   setState(() {
  //     otpController.text = code!;
  //     isOtpValid = otpController.text.length == 6;
  //   });
  // }

  @override
  void dispose() {
    // cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    // final authViewController=ref.watch(authProvider);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- BACK BUTTON -----
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              // ---- TITLE ----
              Text(
                "Please enter the code we just sent to",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "(+91) ${widget.phoneNumber}",
                /* $phoneNumber */
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // ---- OTP INPUT ----
              Center(
                child: Pinput(
                  controller: otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  onChanged: (value) {
                    setState(() {
                      isOtpValid = value.length == 6;
                    });
                  },
                  onCompleted: (value) {
                    // ref
                    //     .read(authProvider.notifier)
                    //     .verifyOtp(value, deviceId, deviceModel);

                    // if (ref.read(authProvider).isVerified) {
                    //   // Get the phone number from the auth provider or pass it from login
                    //   final phoneNumber = ref.read(authProvider).phoneNumber;
                    //   Navigator.pushReplacementNamed(
                    //     context,
                    //     AppRoutes.profileForm,
                    //     arguments: phoneNumber,
                    //   );
                    // }
                  },
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        verificationCompleted: (PhoneAuthCredential cred) {},
                        verificationFailed: (FirebaseAuthException ex) {},
                        codeSent: (String verficationId, int? resendToken) {
                          // update the verificationId so the new OTP works
                          setState(() {
                            widget.verficationId = verficationId;
                          });
                        },
                        codeAutoRetrievalTimeout: (String verficationId) {
                          setState(() {
                            widget.verficationId = verficationId;
                          });
                        },
                        phoneNumber: "+91${widget.phoneNumber}",
                      );
                    } catch (e) {
                      // Optionally show a toast/snackbar here
                    }
                  },
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ---- CONTINUE BUTTON ----
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isOtpValid && !_isVerifying
                      ? () async {
                          setState(() {
                            _isVerifying = true;
                          });
                          try {
                            // 1) Create the credential synchronously (no await here)
                            final credential = PhoneAuthProvider.credential(
                              verificationId: widget.verficationId,
                              smsCode: otpController.text.trim(),
                            );

                            // 2) Await the sign‑in call (this is async)
                            await FirebaseAuth.instance.signInWithCredential(
                              credential,
                            );

                            // 3) Navigate after successful sign‑in
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.profileForm,
                              arguments: {
                                'phoneNumber': widget.phoneNumber.trim(),
                              },
                            );
                          } catch (e) {
                            print(e.toString());
                            // Optionally show a toast/snackbar for invalid OTP
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isVerifying = false;
                              });
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOtpValid
                        ? const Color(0xFF57BE82)
                        : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      setState(() {
        deviceId = android.id;
        deviceModel = android.model;
      });
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      setState(() {
        deviceId = ios.identifierForVendor ?? "";
        deviceModel = ios.utsname.machine;
      });
    }
  }
}
