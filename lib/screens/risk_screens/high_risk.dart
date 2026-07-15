import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/re_kyc_screens/customer_kyc_details.dart';
import 'package:re_kyc_mobile_app/widgets/custom_container.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class HighRiskScreen extends StatefulWidget {
  const HighRiskScreen({super.key});

  @override
  State<HighRiskScreen> createState() => _HighRiskScreenState();
}

class _HighRiskScreenState extends State<HighRiskScreen> {
  List<Map<String, String>> lowRisk = [
    {'title': 'A. Arun', 'subTitle': '10 yr', 'loanNo': '4325SBML9876'},
    {'title': 'B. Binthu', 'subTitle': '12 yr', 'loanNo': '4325SBML9876'},
    {'title': 'B. Binthu', 'subTitle': '12 yr', 'loanNo': '4325SBML9876'},
    {'title': 'B. Binthu', 'subTitle': '12 yr', 'loanNo': '4325SBML9876'},
    {'title': 'B. Binthu', 'subTitle': '12 yr', 'loanNo': '4325SBML9876'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5, left: 5, bottom: 5),
      padding: const EdgeInsets.all(5),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.black38),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ImageIcon(
                  AssetImage('assets/icons/search_empty.png'),
                  size: 25,
                ),
                SizedBox(width: 5),
                CustomText(
                  text: 'Search ...',
                  color: Colors.black45,
                  fontSize: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: lowRisk.length,
              itemBuilder: (context, index) {
                var low = lowRisk[index];
                return InkWell(
                  onTap: () {
                    Get.to(() => const CustomerKYCDetails());
                  },
                  child: CustomContainer(
                    title: low['title']!,
                    kycYr: low['subTitle']!,
                    loanNo: low['loanNo']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
