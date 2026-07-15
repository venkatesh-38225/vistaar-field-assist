import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/pan_aadhaar_details.dart';
import 'package:re_kyc_mobile_app/utils/helper.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class UploadPanAadhaar extends StatefulWidget {
  const UploadPanAadhaar({super.key});

  @override
  State<UploadPanAadhaar> createState() => _UploadPanAadhaarState();
}

class _UploadPanAadhaarState extends State<UploadPanAadhaar> {
  String? selectedCategory;
  TextEditingController otherController = TextEditingController();

  String frontAadhaarImagePath = "";
  String backAadhaarImagePath = "";
  String frontPanImagePath = "";
  String backPanImagePath = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF145a95), Color(0xFF145a95)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CustomPaint(
                painter: WavePainter(),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Image.asset(
                            'assets/images/v_logo.png',
                            height: 25,
                            width: 25,
                            // color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const CustomText(
                          text: 'VCP Application',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          const CustomText(
                            text: 'Upload your aadhaar card*',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  CustomsHelper.cameraPermissionAlert(() async {
                                    String camera =
                                    await CustomsHelper().getCamera();
                                    setState(() {
                                      frontAadhaarImagePath = camera;
                                      Get.back();
                                    });
                                  }, () async {
                                    String gallery =
                                    await CustomsHelper().getGalleryFile();
                                    setState(() {
                                      frontAadhaarImagePath = gallery;
                                      Get.back();
                                    });
                                  });
                                },
                                child: frontAadhaarImagePath.isNotEmpty
                                    ? Align(
                                  alignment: Alignment.center,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    // Allows children to overflow
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(15),
                                        child: Container(
                                          height: 125,
                                          width: 125,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(15),
                                          ),
                                          child: Image.file(
                                            File(frontAadhaarImagePath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: -10,
                                        top: -10,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.redAccent.shade200,
                                          ),
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  frontAadhaarImagePath = "";
                                                });
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          // height: 125,
                                          // width: 125,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(15)),
                                          child: Icon(
                                            Icons.photo_camera,
                                            size: 70,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const CustomText(
                                          text: 'Front side photo',
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  CustomsHelper.cameraPermissionAlert(() async {
                                    String camera =
                                        await CustomsHelper().getCamera();
                                    setState(() {
                                      backAadhaarImagePath = camera;
                                      Get.back();
                                    });
                                  }, () async {
                                    String gallery =
                                        await CustomsHelper().getGalleryFile();
                                    setState(() {
                                      backAadhaarImagePath = gallery;
                                      Get.back();
                                    });
                                  });
                                },
                                child: backAadhaarImagePath.isNotEmpty
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Container(
                                                height: 125,
                                                width: 125,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Image.file(
                                                  File(backAadhaarImagePath),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: -10,
                                              top: -10,
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.redAccent.shade200,
                                                ),
                                                child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        backAadhaarImagePath = "";
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 18,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(15)),
                                                child: Icon(
                                                  Icons.photo_camera,
                                                  size: 70,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const CustomText(
                                                text: 'Back side photo',
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          const Divider(),
                          const SizedBox(height: 30),
                          const CustomText(
                            text: 'Upload your pan card*',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),

                          const SizedBox(height: 40),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  CustomsHelper.cameraPermissionAlert(() async {
                                    String camera =
                                    await CustomsHelper().getCamera();
                                    setState(() {
                                      frontPanImagePath = camera;
                                      Get.back();
                                    });
                                  }, () async {
                                    String gallery =
                                    await CustomsHelper().getGalleryFile();
                                    setState(() {
                                      frontPanImagePath = gallery;
                                      Get.back();
                                    });
                                  });
                                },
                                child: frontPanImagePath.isNotEmpty
                                    ? Align(
                                  alignment: Alignment.center,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(15),
                                        child: Container(
                                          height: 125,
                                          width: 125,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(15),
                                          ),
                                          child: Image.file(
                                            File(frontPanImagePath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: -10,
                                        top: -10,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.redAccent.shade200,
                                          ),
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  frontPanImagePath = "";
                                                });
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(15)),
                                          child: Icon(
                                            Icons.photo_camera,
                                            size: 70,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const CustomText(
                                          text: 'Front side photo',
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  CustomsHelper.cameraPermissionAlert(() async {
                                    String camera =
                                    await CustomsHelper().getCamera();
                                    setState(() {
                                      backPanImagePath = camera;
                                      Get.back();
                                    });
                                  }, () async {
                                    String gallery =
                                    await CustomsHelper().getGalleryFile();
                                    setState(() {
                                      backPanImagePath = gallery;
                                      Get.back();
                                    });
                                  });
                                },
                                child: backPanImagePath.isNotEmpty
                                    ? Align(
                                  alignment: Alignment.center,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(15),
                                        child: Container(
                                          height: 125,
                                          width: 125,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(15),
                                          ),
                                          child: Image.file(
                                            File(backPanImagePath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: -10,
                                        top: -10,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.redAccent.shade200,
                                          ),
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  backPanImagePath = "";
                                                });
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(15)),
                                          child: Icon(
                                            Icons.photo_camera,
                                            size: 70,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const CustomText(
                                          text: 'Back side photo',
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          Center(
                            child: CustomButton(
                              text: 'Save',
                              onPressed: () {
                                Get.to(()=> const PanAadhaarDetails());
                              },
                              backgroundColor: const Color(0xFFfaa61a),
                            ),
                          ),
                          const SizedBox(height: 30),

                        ],
                      ),
                    ),

                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.8, size.width, size.height * 0.6);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawPath(path, paint);

    Path path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
        size.width * 0.5, size.height * 0.9, size.width, size.height * 0.7);
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
