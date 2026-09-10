import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/home_screens/home_screen.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/widgets/custom_textform_field.dart';

import '../../utils/global_snackbar.dart';
import '../../widgets/custom_background.dart';

class OTPVerifyScreen extends StatefulWidget {
  const OTPVerifyScreen({
    super.key,
    required this.employeeId,
    this.localReviewerOtp,
  });

  final String employeeId;
  final String? localReviewerOtp;

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  final loginFormKey = GlobalKey<FormState>();
  final passwordVisible = true.obs;
  TextEditingController otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  Future<void> _verifyOtp() async {
    final enteredOtp = otpController.text.trim();
    if (enteredOtp.isEmpty) {
      GlobalSnackbar.showError('Please enter OTP');
      return;
    }
    if (_isVerifying) return;

    setState(() => _isVerifying = true);
    try {
      if (widget.localReviewerOtp != null) {
        if (enteredOtp == widget.localReviewerOtp) {
          Get.offAll(() => const HomeScreen());
        } else {
          GlobalSnackbar.showError('Invalid OTP');
        }
        return;
      }

      final response = await ApiClient().verifyLoginOtp(
        json.encode({
          'userId': widget.employeeId.trim(),
          'otp': enteredOtp,
          'source': 'Field Assist',
        }),
      );

      if (!mounted) return;
      if (response?['success'] == true) {
        Get.offAll(() => const HomeScreen());
      } else {
        GlobalSnackbar.showError(
          response?['message']?.toString() ?? 'Invalid OTP',
        );
      }
    } catch (_) {
      if (mounted) GlobalSnackbar.showError('Unable to verify OTP');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending) return;

    if (widget.localReviewerOtp != null) {
      GlobalSnackbar.showSuccess('Reviewer OTP is ready to use');
      return;
    }

    setState(() => _isResending = true);
    try {
      final response = await ApiClient().sendLoginOtp(
        json.encode({
          'userId': widget.employeeId.trim(),
          'source': 'Field Assist',
        }),
      );

      if (!mounted) return;
      if (response?['success'] == true) {
        GlobalSnackbar.showSuccess(
          response?['message']?.toString() ?? 'OTP resent successfully',
        );
      } else {
        GlobalSnackbar.showError(
          response?['message']?.toString() ?? 'Unable to resend OTP',
        );
      }
    } catch (_) {
      if (mounted) GlobalSnackbar.showError('Unable to resend OTP');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: _buildOtpViewContainerWidget(context),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

//  @override
  Widget _buildOtpViewContainerWidget(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF116bb6), Color(0xFF116bb6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CustomPaint(
                painter: WavePainter(),
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 370,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), // Glass effect
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/vistaar_logo_new.png',
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'OTP is sent to your mobile No',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        keyboardType: TextInputType.number,
                        controller: otpController,
                        obscureText: false,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        hintText: 'Enter OTP',
                        prefixIcon: Icons.lock_outline,
                        onSaved: (String? value) {
                          setState(() {
                            otpController.text = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'required';
                          } else {
                            return 'required';
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _isVerifying ? null : _verifyOtp,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFfaa61a),
                                Color(0xFFecb459)
                              ], // Yellow Gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Verify',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _isResending ? null : _resendOtp,
                        child: Text(
                          _isResending ? 'Sending...' : 'Re-Send OTP',
                          style: const TextStyle(
                            color: Colors.white70,
                            //  color: Color(0xFF116bb6),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
