import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/re_kyc_screens/otp_verification.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:uuid/uuid.dart';

class UpdateAadhaar extends StatefulWidget {
  const UpdateAadhaar({super.key});

  @override
  State<UpdateAadhaar> createState() => _UpdateAadhaarState();
}
TextEditingController aadhaarNumber = TextEditingController();
class _UpdateAadhaarState extends State<UpdateAadhaar> {
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.cyan.shade700,
        body: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              color: Colors.blue.shade900,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/user.png',
                          height: 30,
                          width: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const CustomText(
                        text: 'Aadhaar Update',
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  const CustomText(
                    text: 'Please enter your aadhaar number',
                    fontSize: 18,
                    //   fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: aadhaarNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.fingerprint_outlined, color: Colors.grey[600]),
                      hintText: 'Aadhaar no',
                      hintStyle: const TextStyle(fontSize: 17, color: Colors.grey),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: const TextStyle(fontSize: 18),
                    onSaved: (String? value){
                      aadhaarNumber.text = value!;
                    },
                  ),

                  const Spacer(),
                  CustomButton(
                    text: 'Enter',
                    letterSpacing: 2,
                    onPressed: () {
                      Get.to(()=>  OtpVerification(/*otpDetails: response*/));
                      // sentOtpApi();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

/*  Future sentOtpApi() async {
    var uuid = const Uuid();
    Map<String, dynamic> details = {
      "consent": true,
      "reference_id": uuid.v4(),
      "purpose": "For Aadhaar Verification",
      "aadhaar_number": aadhaarNumber.text
    };
    log('details - $details');
    var response = await ApiClient().getOTPDetails(json.encode(details));
    if(response != null){
      Get.to(()=>  OtpVerification(otpDetails: response));
    }
  }*/
}
