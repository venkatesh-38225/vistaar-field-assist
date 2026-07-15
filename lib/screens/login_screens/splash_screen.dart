import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/home_screens/home_screen.dart';
import 'package:re_kyc_mobile_app/screens/login_screens/login_screen.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/service/hive_local_storage.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    log('splash screen');
    super.initState();
    _checkDeveloperMode();
  }

  Future<void> _checkDeveloperMode() async {
    final bool isAppDevMode = ApiClient().isDevMode;
    if (!isAppDevMode) {
      try {
        const platform = MethodChannel('com.example.app/media_scanner');
        final bool isDevModeEnabled =
            await platform.invokeMethod('isDeveloperModeEnabled') ?? false;
        if (isDevModeEnabled) {
          _showDeveloperModeAlert();
          return; // Block execution
        }
      } catch (e) {
        log("Error checking developer mode: $e");
      }
    }

    _proceedToNextScreen();
  }

  void _proceedToNextScreen() {
    String? employeeId = HiveDataBase().getEmployeeId();
    HiveDataBase storeData = HiveDataBase();
    log('employeeId - $employeeId');
    Future.delayed(const Duration(seconds: 3), () {
      if (storeData.getEmployeeId() != null) {
        Get.offAll(
          () => const HomeScreen(),
          transition: Constant.getXTransition,
        );
      } else {
        Get.offAll(
          () => const LoginScreen(),
          transition: Constant.getXTransition,
        );
      }
    });
  }

  void _showDeveloperModeAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Developer Options Enabled',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            content: const Text(
              'For security reasons, this application cannot run while Developer Options are enabled. Please turn off Developer Options in your device settings and restart the app.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Exit App'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/Assist-logo.png',
          height: 100,
          width: 100,
        ),
      ),
    );
  }
}
