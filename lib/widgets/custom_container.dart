import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    required this.title,
    required this.kycYr,
    required this.loanNo,
  });

  final String title;
  final String kycYr;
  final String loanNo;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const CustomText(
                text: 'Name : ',
                fontSize: 16,
                //   fontWeight: FontWeight.w600,
              ),
              CustomText(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          //   const SizedBox(height: 3),
          Row(
            children: [
              const CustomText(
                text: "Loan No : ",
                fontSize: 14,
              ),
              CustomText(
                text: loanNo,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            children: [
              const CustomText(
                text: "KYC Due : ",
                fontSize: 14,
              ),
              CustomText(
                text: kycYr,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
