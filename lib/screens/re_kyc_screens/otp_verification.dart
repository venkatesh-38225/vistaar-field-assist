import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:uuid/uuid.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({super.key, /*required this.otpDetails*/});

  // final Map<String, dynamic> otpDetails;

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}
TextEditingController otpNumber = TextEditingController();
class _OtpVerificationState extends State<OtpVerification> {
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
                        text: 'OTP Verification',
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
                    text: 'Please enter your OTP',
                    fontSize: 18,
                    //   fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: otpNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.password_sharp, color: Colors.grey[600]),
                      hintText: 'Enter your otp',
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
                      otpNumber.text = value!;
                    },
                  ),

                  const Spacer(),
                  CustomButton(
                    text: 'Enter',
                    letterSpacing: 2,
                    onPressed: () {
                      // verifyOtpApi();
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

/*  Future verifyOtpApi() async {
    Map<String, dynamic> details = {
      "consent": true,
      "generate_pdf": false,
      "generate_xml": false,
      "reference_id": widget.otpDetails['reference_id'],
      "purpose": "For Aadhaar Verification",
      "initiation_transaction_id": widget.otpDetails['decentroTxnId'],
      "otp": otpNumber.text
    };
    log('details - $details');
    var response = await ApiClient().getAadhaarDetails(json.encode(details));
  }*/
}
