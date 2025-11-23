import 'dart:math';

import 'package:animal_kart_demo2/auth/providers/auth_provider.dart';
import 'package:animal_kart_demo2/auth/screens/otp_screen.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:animal_kart_demo2/widgets/floating_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  bool isButtonEnabled = false;
  bool _isSendingOtp = false;

  // ---------------- VALIDATION ----------------
  bool isValidPhone(String value) {
    return RegExp(r'^[0-9]{10}$').hasMatch(value);
  }

  void validatePhone() {
    final phone = phoneController.text.trim();
    setState(() {
      isButtonEnabled = isValidPhone(phone);
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ---------------- HEADER ----------------
              Center(
                child: const Text(
                  "Back to the Buffalo Cart\nworld!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: const Text(
                  "Enter your mobile number to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mobile number",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ---------------- PHONE INPUT ----------------
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),

                    // Country Code Selector
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            AppConstants.countryCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),

                    // Divider
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.shade500,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),

                    // Phone Input
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,

                        maxLength: 10,
                        onChanged: (_) => validatePhone(),
                        decoration: InputDecoration(
                          border: InputBorder.none,

                          counterText: "",
                          hintText: "Enter number",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ---------------- INFO TEXT ----------------
              Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "We'll send a 6-digit code.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// Generate OTP Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed:
                      isButtonEnabled && !auth.isLoading && !_isSendingOtp
                      ? () async {
                          setState(() {
                            _isSendingOtp = true;
                          });
                          try {
                            final bool isUserVerfiyed = await ref
                                .read(authProvider.notifier)
                                .verifyUser(phoneController.text.trim());
                            if (isUserVerfiyed) {
                              await FirebaseAuth.instance.verifyPhoneNumber(
                                phoneNumber:
                                    "+91${phoneController.text.trim()}",
                                verificationCompleted:
                                    (PhoneAuthCredential credential) async {
                                      // Auto-sign in for instant verification (rare)
                                      try {
                                        await FirebaseAuth.instance
                                            .signInWithCredential(credential);
                                        if (mounted) {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.home,
                                          );
                                        }
                                      } catch (e) {
                                        FloatingToast.showSimpleToast(
                                          'Auto verification failed',
                                        );
                                      }
                                    },
                                verificationFailed: (FirebaseAuthException ex) {
                                  print(
                                    'Verification failed: ${ex.code} - ${ex.message}',
                                  );
                                  FloatingToast.showSimpleToast(
                                    'OTP send failed. Please try again.',
                                  );
                                },
                                codeSent:
                                    (String verificationId, int? resendToken) {
                                      print(
                                        'OTP sent successfully to +91${phoneController.text.trim()}',
                                      );
                                      FloatingToast.showSimpleToast(
                                        'OTP sent successfully!',
                                      );
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.otp,
                                        arguments: {
                                          'verificationId': verificationId,
                                          'phoneNumber': phoneController.text
                                              .trim(),
                                        },
                                      );
                                    },
                                codeAutoRetrievalTimeout: (String verificationId) {
                                  print(
                                    'Auto retrieval timeout for verification: $verificationId',
                                  );
                                },
                                timeout: const Duration(seconds: 60),
                              );
                            } else {
                              FloatingToast.showSimpleToast(
                                "User not found ,Not a new referral",
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSendingOtp = false;
                              });
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? const Color(0xFF57BE82)
                        : const Color.fromARGB(255, 186, 236, 209),
                    disabledBackgroundColor: const Color(
                      0xFFBAECD1,
                    ), // your disabled color
                    disabledForegroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: (auth.isLoading || _isSendingOtp)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF57BE82),
                            ),
                          ),
                        )
                      : Text(
                          "Send OTP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isButtonEnabled
                                ? Colors.black
                                : Colors.grey.shade500,
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
}
