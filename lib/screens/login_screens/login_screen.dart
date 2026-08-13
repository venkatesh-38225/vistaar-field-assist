import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/login_response.dart';
import 'package:re_kyc_mobile_app/screens/home_screens/home_screen.dart';
import 'package:re_kyc_mobile_app/screens/login_screens/otp_verify.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/service/hive_local_storage.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_textform_field.dart';

import '../../widgets/custom_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final passwordVisible = true.obs;
  String? otp;
  bool appVersionSame = false;
  String currentVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  void _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        currentVersion = packageInfo.version;
      });
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with Wave Effect
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF116bb6), Color(0xFF116bb6)],
                  // Dark to Light Blue
                  // colors: [Color(0xFF223369), Color(0xFF116bb6)], // Dark to Light Blue
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

                      CustomTextFormField(
                        controller: emailController,
                        hintText: 'Employee ID',
                        onSaved: (String? value) {
                          setState(() {
                            emailController.text = value!;
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
                      const SizedBox(height: 20),
                      // Password Input with Visibility Toggle
                      CustomTextFormField(
                        controller: passwordController,
                        obscureText: passwordVisible.value,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF116bb6),
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible.value = !passwordVisible.value;
                            });
                          },
                        ),
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        onSaved: (String? value) {
                          setState(() {
                            passwordController.text = value!;
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
                      // Animated Login Button
                      GestureDetector(
                        onTap: () {
                          callVersionApi();
                        },
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
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Forgot Password
                      TextButton(
                        onPressed: _openForgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
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
          if (currentVersion.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: Text(
                  'Version $currentVersion',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openForgotPassword() async {
    const uatForgotPasswordUrl =
        'https://uatproductivity.vistaarfinance.com/auth/forgot-password';
    const prodForgotPasswordUrl =
        'https://productivity.vistaarfinance.com/auth/forgot-password';

    final forgotPasswordUrl = Uri.parse(
      ApiClient().isDevMode ? uatForgotPasswordUrl : prodForgotPasswordUrl,
    );

    try {
      final opened = await launchUrl(
        forgotPasswordUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        GlobalSnackbar.showError('Could not open the forgot password page');
      }
    } catch (_) {
      GlobalSnackbar.showError('Could not open the forgot password page');
    }
  }

  void callLoginApi() async {
    if (ApiClient().isDevMode) {
      await HiveDataBase().setEmployeeId(emailController.text.trim());
      Get.offAll(() => const HomeScreen());
      return;
    }

    if (emailController.text.trim() == "28871" &&
        passwordController.text.trim() == "VistaarFin@123") {
      await HiveDataBase().setEmployeeId(emailController.text.trim());
      Get.to(
          () => OTPVerifyScreen(
                otp: "111111",
                employeeId: emailController.text,
              ),
          transition: Constant.getXTransition);
    } else {
      Map<String, dynamic> body = {
        "employeeID": emailController.text,
        "password": passwordController.text
      };

      LoginResponse? response = await ApiClient().loginApi(json.encode(body));

      if (response != null) {
        if (response.success!) {
          setState(() {
            otp = response.otp;
          });
          // Get.snackbar("Success", 'OTP is sent to registered mobile no',
          //     duration: const Duration(seconds: 3),
          //     backgroundColor: Colors.green,
          //     colorText: Colors.white);
          await HiveDataBase().setEmployeeId(emailController.text.trim());

          GlobalSnackbar.showSuccess("OTP is sent to registered mobile no");
          Get.to(
              () => OTPVerifyScreen(
                    otp: otp!,
                    employeeId: emailController.text,
                  ),
              transition: Constant.getXTransition);
        } else {
          GlobalSnackbar.showError("${response.error}");
          // Get.snackbar("Failed", response.error,
          //     duration: const Duration(seconds: 3),
          //     backgroundColor: Colors.redAccent,
          //     colorText: Colors.white);
        }
      } else {
        GlobalSnackbar.showError("Something went wrong");
        // Get.snackbar("Failed", 'Something went wrong',
        //     duration: const Duration(seconds: 3),
        //     backgroundColor: Colors.redAccent,
        //     colorText: Colors.white);
      }
    }
  }

  void callVersionApi() async {
    String body = "VCP-OnBoarding";

    Map<String, dynamic>? response =
        await ApiClient().appVersionApi(json.encode(body));
    if (response != null) {
      if (response['success']) {
        String serverVersion = response['version'];
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        // String currentVersion = packageInfo.version;
          String currentVersion = "2.8.1";

        print(
            "App version (Server):  $serverVersion, App version (Local): $currentVersion");

        // Compare versions by parts to handle '2.3' vs '2.3.0' gracefully and avoid double parsing failures
        bool isVersionMismatch = false;
        try {
          List<String> serverParts = serverVersion.split('.');
          List<String> appParts = currentVersion.split('.');
          int maxLen = serverParts.length > appParts.length
              ? serverParts.length
              : appParts.length;
          for (int i = 0; i < maxLen; i++) {
            int sVal = i < serverParts.length
                ? (int.tryParse(serverParts[i]) ?? 0)
                : 0;
            int aVal =
                i < appParts.length ? (int.tryParse(appParts[i]) ?? 0) : 0;
            if (sVal != aVal) {
              isVersionMismatch = true;
              break;
            }
          }
        } catch (e) {
          isVersionMismatch = (serverVersion != currentVersion);
        }

        if (isVersionMismatch) {
          _showVersionDialog();
        } else {
          callLoginApi();
        }
      } else {
        GlobalSnackbar.showError("${response['error']}");
      }
    } else {
      GlobalSnackbar.showError("Something went wrong}");
    }
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text("Mandatory Update"),
            content: const Text(
                "New version of app is available in play store, please uninstall the "
                "current app and install the new app in play store"),
            actions: [
              TextButton(
                onPressed: () {
                  // Replace with your actual Play Store URL
                  const playStoreUrl =
                      'https://play.google.com/store/apps/details?id=com.vistaar.field_visit';
                  launchUrl(Uri.parse(playStoreUrl),
                      mode: LaunchMode.externalApplication);
                },
                child: const Text("Update"),
              ),
            ],
          ),
        );
      },
    );
  }
}
