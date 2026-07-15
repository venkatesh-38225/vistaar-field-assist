import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/screens/risk_screens/high_risk.dart';
import 'package:re_kyc_mobile_app/screens/risk_screens/low_risk.dart';
import 'package:re_kyc_mobile_app/screens/risk_screens/medium_risk.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class KYCDashboard extends StatefulWidget {
  const KYCDashboard({super.key});

  @override
  State<KYCDashboard> createState() => _KYCDashboardState();
}

class _KYCDashboardState extends State<KYCDashboard>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade700,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            width: 1,
                            color: Colors.white,
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
                        text: 'G.Thaaranya',
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
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
                          'assets/images/location.png',
                          height: 30,
                          width: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const CustomText(
                        text: 'Bangalure',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(1, 1),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.white,
                  labelColor: Colors.black,
                  //    labelPadding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  indicator: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  unselectedLabelColor: Colors.black,
                  controller: tabController,
                  tabs: const [
                    CustomText(
                      text: 'Low Risk',
                      fontSize: 14,
                    ),
                    CustomText(
                      text: 'Medium Risk',
                      fontSize: 14,
                    ),
                    CustomText(
                      text: 'High Risk',
                      fontSize: 14,
                    ),
                  ]),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [
                  LowRiskScreen(),
                  MediumRiskScreen(),
                  HighRiskScreen(),
                ],
              ),
            ),

            // SizedBox(
            //   width: double.infinity,
            //   child: CustomSlidingSegmentedControl(
            //     //  innerPadding: EdgeInsets.symmetric(horizontal: 20),
            //     duration: const Duration(milliseconds: 300),
            //     curve: Curves.easeInToLinear,
            //     fromMax: true,
            //     decoration: BoxDecoration(
            //       color: CupertinoColors.lightBackgroundGray,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     thumbDecoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(6),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black.withOpacity(.3),
            //           blurRadius: 4.0,
            //           spreadRadius: 1.0,
            //           offset: const Offset(
            //             0.0,
            //             2.0,
            //           ),
            //         ),
            //       ],
            //     ),
            //     onValueChanged: (value) {
            //       setState(() {
            //         selectedValue = value;
            //       });
            //     },
            //     children: const {
            //       'Tab 1': Text('Tab 1'),
            //       'Tab 2': Text('Tab 2'),
            //       'Tab 3': Text('Tab 3'),
            //     },
            //   ),
            // ),
            // Expanded(
            //   child: Center(
            //     child: Text(
            //       'Selected: $selectedValue',
            //       style: const TextStyle(fontSize: 24),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
