import 'dart:async';
import 'dart:io';

import 'package:animal_kart_demo2/auth/providers/auth_provider.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/utils/save_user.dart';
import 'package:animal_kart_demo2/widgets/floating_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String otp;
  final bool isFormFilled;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
    required this.isFormFilled,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final otpController = TextEditingController();
final FocusNode otpFocusNode = FocusNode();
  String deviceId = "";
  String deviceModel = "";

  bool isOtpValid = false;
  bool _isVerifying = false;

  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    otpFocusNode.requestFocus();
  });

  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    super.dispose();
      otpFocusNode.dispose(); 
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendSeconds = 30;
      _canResendOtp = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
        setState(() {
          _canResendOtp = true;
        });
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
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
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(text: "Please enter the OTP sent to "),
                    TextSpan(
                      text: "(+91) ${widget.phoneNumber}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: Pinput(
                  controller: otpController,
                  focusNode: otpFocusNode, 
                  length: 6,
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  onChanged: (value) {
                    setState(() {
                      isOtpValid = value.length == 6;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// 🔁 RESEND OTP SECTION
              Center(
                child: _canResendOtp
                    ? TextButton(
                        onPressed: () async {
                        await ref.read(authProvider).sendWhatsappOtp(widget.phoneNumber);

                          FloatingToast.showSimpleToast(
                              "OTP resent successfully");
                          _startResendTimer();
                        },
                        child: const Text(
                          "Resend OTP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF57BE82),
                          ),
                        ),
                      )
                    : Text(
                        "Resend OTP in $_resendSeconds sec",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
              ),

              const Spacer(),

            
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isOtpValid && !_isVerifying
                      ? () async {
                          setState(() => _isVerifying = true);

                          final enteredOtp = otpController.text.trim();
                          final isValid = ref
                              .read(authProvider)
                              .verifyWhatsappOtpLocal(enteredOtp);

                          if (!mounted) return;

                          if (isValid) {
                            FloatingToast.showSimpleToast(
                                "OTP Verified Successfully");

                            final user =
                                ref.read(authProvider).userProfile;
                            final prefs =
                                await SharedPreferences.getInstance();

                            if (user != null) {
                              await saveUserToPrefs(user);
                            }
                            await prefs.setBool('isLoggedIn', true);

                            if (widget.isFormFilled) {
                              Navigator.pushReplacementNamed(
                                  context, AppRouter.home);
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRouter.profileForm,
                                arguments: {
                                  'phoneNumberFromLogin':
                                      widget.phoneNumber,
                                },
                              );
                            }
                          } else {
                            FloatingToast.showSimpleToast("Invalid OTP");
                          }

                          setState(() => _isVerifying = false);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOtpValid
                        ? const Color(0xFF57BE82)
                        : Colors.grey.shade300,
                    disabledBackgroundColor: const Color(0xFFBAECD1),
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
                              Color(0xFF57BE82),
                            ),
                          ),
                        )
                      : Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isOtpValid
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
