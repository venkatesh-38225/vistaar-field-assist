import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class KYCApplication extends StatefulWidget {
  const KYCApplication({super.key});

  @override
  State<KYCApplication> createState() => _KYCApplicationState();
}

class _KYCApplicationState extends State<KYCApplication> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 20,
        backgroundColor: Constant.mediumBlueColor,
        title: Row(
          children: [
            Image.asset(
              'assets/images/v_logo_white.png',
              height: 30,
              width: 35,
              // color: Colors.white,
            ),
            const SizedBox(width: 10),
            const CustomText(
              text: 'VCP Application',
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ImageIcon(
                  AssetImage('assets/icons/tick_circle_big.png'),
                  color: Colors.green,
                  size: 25,
                ),
                const SizedBox(width: 5),
                Container(
                  width: 40,
                  color: Colors.green,
                  height: 2,
                ),
                const SizedBox(width: 5),
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircleAvatar(
                    backgroundColor: Constant.mediumBlueColor,
                    child: CustomText(
                      text: '2',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 40,
                  color: Colors.grey,
                  height: 2,
                ),
                const SizedBox(width: 5),
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: CustomText(
                      text: '3',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 40,
                  color: Colors.grey,
                  height: 2,
                ),
                const SizedBox(width: 5),
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: CustomText(
                      text: '4',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 40,
                  color: Colors.grey,
                  height: 2,
                ),
                const SizedBox(width: 5),
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: CustomText(
                      text: '5',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 40,
                  color: Colors.grey,
                  height: 2,
                ),
                const SizedBox(width: 5),
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: CustomText(
                      text: '6',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const CustomText(
              text: 'KYC Details',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 9),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Save & Next',
                  onPressed: () {
                    // Get.to(() => const BusinessApplication());
                  },
                  backgroundColor: const Color(0xFFfaa61a),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
