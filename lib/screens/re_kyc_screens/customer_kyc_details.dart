import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/token_response_model.dart';
import 'package:re_kyc_mobile_app/screens/re_kyc_screens/update_aadhaar.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class CustomerKYCDetails extends StatefulWidget {
  const CustomerKYCDetails({super.key});

  @override
  State<CustomerKYCDetails> createState() => _CustomerKYCDetailsState();
}

class _CustomerKYCDetailsState extends State<CustomerKYCDetails> {
  @override
  Widget build(BuildContext context) {
    const tokenResponse =
        '{"statusCode":200,"body":{"access_token":"04dca606ec23944bdac852bc6f82bbbf54d57973","expires_in":3600,"token_type":"Bearer","scope":"picture email userdetails careof address profile issued/in.gov.uidai-ADHAR-a9978b6fb1b081d2d18f143e82ab9da0 files.issueddocs issued/in.gov.pan-PANCR-HLJPK5531H","consent_valid_till":"1731478650","digilockerid":"e844fe4c-b0c6-5a8c-8d58-154a7481a5e7","name":"Saeed Khan","dob":"07051986","gender":"M","eaadhaar":"Y","reference_key":"02b302ac1a2384be71349653dc4d5ca0371d10198d40ae98dfb5894cbc20d7d1","mobile":"","refresh_token":"","new_account":"N"},"headers":{"date":"Mon, 14 Oct 2024 06:17:44 GMT","content-type":"application/json","transfer-encoding":"chunked","connection":"close","server":"nginx","vary":"Accept-Encoding","cache-control":"max-age=10","pragma":"no-cache","expires":"Mon, 14 Oct 2024 06:17:54 GMT","access-control-allow-headers":"jtoken,device-security-id,Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With","x-xss-protection":"1; mode=block","x-content-type-options":"nosniff","referrer-policy":"no-referrer-when-downgrade","strict-transport-security":"max-age=31536000; includeSubDomains"},"request":{"uri":{"protocol":"https:","slashes":true,"auth":null,"host":"api.digitallocker.gov.in","port":443,"hostname":"api.digitallocker.gov.in","hash":null,"search":null,"query":null,"pathname":"/public/oauth2/1/token","path":"/public/oauth2/1/token","href":"https://api.digitallocker.gov.in/public/oauth2/1/token"},"method":"POST","headers":{"accept":"application/json","Content-Type":"application/json","content-length":311}}}';
    final responseStatus =
        TokenApiResponse.fromJson(json.decode(tokenResponse));

    final responseBody = responseStatus.body;

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
                        text: 'KYC Details',
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
              height: 630,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade200,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Name  ',
                              fontSize: 18,
                              //   fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  ${responseBody.name}',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Loan No  ',
                              fontSize: 18,
                              //   fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  12345678',
                              fontSize: 20,
                              //    fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'KYC Due  ',
                              fontSize: 18,
                              //   fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  10 Yr',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Aadhar No  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  9876 4567 8432',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Pan No  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  HG6I98',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Mobile No  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  9876543210',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Loan No  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  12345678',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'KYC Due  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  10 Yr',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Aadhaar No  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  ${responseBody.eaadhaar}',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Date of Birth  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  ${responseBody.dob}',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Mobile No  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  ${responseBody.mobile}',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Gender  ',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: ':  ${responseBody.gender}',
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CustomButton(
                    text: 'Update KYC',
                    onPressed: () {
                      Get.to(() => const UpdateAadhaar());
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

  Future tokenApi() async {
    Map<String, dynamic> details = {
      "grant_type": "authorization_code",
      "code": "544994aca033540162ce2555b4fb58c1c4f1ef6c",
      "redirect_uri":
          "https://vidyutlend.vistaarfinance.net.in/iaAPI/digilocker/callback",
      "code_verifier":
          "HI-cTqW8GnNPPUDdOnTzkVI0.2uIod6lOGCoV2_pa.IIUmPEORdS8DiNt43",
      "client_id": "FX420249E2",
      "client_secret": "c9935d2af2f980d13605"
    };
    var response = await ApiClient().getTokenApi(json.encode(details));
  }
}
