/*
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/onboard_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/update_aggregator.dart';
import 'package:re_kyc_mobile_app/screens/re_kyc_screens/otp_verification.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/widgets/aggregator_container.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_container.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:uuid/uuid.dart';

class AggregatorList extends StatefulWidget {
  const AggregatorList({super.key});

  @override
  State<AggregatorList> createState() => _AggregatorListState();
}
TextEditingController aadhaarNumber = TextEditingController();
class _AggregatorListState extends State<AggregatorList> {
  @override
  Widget build(BuildContext context) {

     List<Map<String, String>> aggregatorList = [
    {'title': 'A. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    {'title': 'A. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    {'title': 'A. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    {'title': 'A. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    {'title': 'A. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    {'title': 'A. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    {'title': 'A. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    {'title': 'A. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.cyan.shade700,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: double.infinity,
                color: Colors.blue.shade900,
                child: Row(
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
                      text: 'Aggregators',
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                // height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey.shade200,
                ),
                child:Column(
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
                    ListView.builder(
                      shrinkWrap: true,
                      // scrollDirection: Axis.vertical,
                      itemCount: aggregatorList.length,
                      itemBuilder: (context, index) {
                        var low = aggregatorList[index];
                        return InkWell(
                          onTap: () {
                             Get.to(() => const UpdateAggregator());
                          },
                          child: AggregatorContainer(
                            title: low['title']!,
                            branchCode: low['subTitle']!,
                            mobileNo: low['loanNo']!,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
       floatingActionButton:  FloatingActionButton.extended(
          onPressed: () {
           Get.to(()=> const OnboardApplication());
          },
          label: const Text(
            'Add',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white, // Text color
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white), // Icon color
          backgroundColor: Colors.blue.shade900, // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Round border
          ),
          elevation: 6, // Shadow effect
        ),

      ),
    );


  }

}
*/

/// new UI
/*import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/onboard_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_aggregator_screens/update_aggregator.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class AggregatorList extends StatefulWidget {
  const AggregatorList({super.key});

  @override
  State<AggregatorList> createState() => _AggregatorListState();
}

class _AggregatorListState extends State<AggregatorList> {
  TextEditingController searchController = TextEditingController();

  List<Map<String, String>> aggregatorList = [
    {'title': 'H. Arun', 'subTitle': 'TRY001', 'loanNo': '987654321'},
    {'title': 'L. Kumar', 'subTitle': 'TRY002', 'loanNo': '876543219'},
    {'title': 'C. Ramesh', 'subTitle': 'TRY003', 'loanNo': '765432198'},
    {'title': 'G. Thaaranya', 'subTitle': 'TRY003', 'loanNo': '765432198'},
    {'title': 'M. Swathi', 'subTitle': 'TRY003', 'loanNo': '765432198'},
    {'title': 'P. Mani', 'subTitle': 'TRY003', 'loanNo': '765432198'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF116bb6), Color(0xFF116bb6)],
                   begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: const Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 10),
                      const CustomText(
                        text: 'Aggregators',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: aggregatorList.length,
                      itemBuilder: (context, index) {
                        var aggregator = aggregatorList[index];
                        return InkWell(
                          onTap: () {
                            Get.to(() => const UpdateAggregator());
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white.withOpacity(0.5),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade800,
                                child: Text(
                                  aggregator['title']![0],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: CustomText(
                                text: aggregator['title']!,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              subtitle: CustomText(
                                text: 'Branch: ${aggregator['subTitle']}\nLoan No: ${aggregator['loanNo']}',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue.shade800, size: 20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const OnboardApplication());
        },
        label: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'New Aggregator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,

import 'dart:developer';              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFfaa61a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 10,
        splashColor: Colors.white,
      ),
    );
  }
}*/

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/aggregator_list_res.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/vcp_application.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';

class AggregatorList extends StatefulWidget {
  const AggregatorList(
      {super.key, required this.employeeId, required this.branchCode});

  final String employeeId;
  final String branchCode;

  @override
  State<AggregatorList> createState() => _AggregatorListState();
}

class _AggregatorListState extends State<AggregatorList> {
  TextEditingController searchController = TextEditingController();

  int currentIndex = -1;
  List<Datum>? data = [];
  int? selectedIndex;
  TextEditingController remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    callAggregatorsList();
  }

  void toggleRemarkField(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = null;
      } else {
        selectedIndex = index;
        remarkController.clear();
      }
    });
  }

  void submitRemark({required int aggregatorID, required String mobileNo}) {
    String remark = remarkController.text.trim();

    if (remark.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a remark")),
      );
      return;
    }
    updateAggregators(
        aggregatorID: aggregatorID,
        mobileNo: mobileNo,
        remark: remarkController.text);
    setState(() {
      remarkController.clear();
      selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Image.asset(
                'assets/images/v_logo_white.png',
                height: 30,
                width: 30,
              ),
            ),
            const SizedBox(width: 10),
            const CustomText(
              text: 'Pending Visits',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: () async {
            callAggregatorsList();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Scroll down to refresh the list',
                    fontSize: 10,
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_downward_sharp,
                    size: 10,
                  )
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Card(
                  elevation: 5,
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        hintText: 'Search...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Constant.mediumBlueColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              data != []
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: data!.length,
                        itemBuilder: (context, index) {
                          var aggregator = data![index];
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade800,
                                    child: const ImageIcon(
                                      AssetImage('assets/icons/profile.png'),
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CustomText(
                                    text: data == []
                                        ? ""
                                        : aggregator.aggregatorName!,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: CustomText(
                                      text:
                                          'Status: ${data == [] ? "" : aggregator.officeAddress!}',
                                      // Loan No: '${aggregator['loanNo']}',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: CustomText(
                                      text:
                                          'Contact no: ${data == [] ? "" : aggregator.mobile!}',
                                      // Loan No: '${aggregator['loanNo']}',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: CustomText(
                                      text:
                                          'Email ID: ${data == [] ? "" : aggregator.email!}',
                                      // Loan No: '${aggregator['loanNo']}',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              toggleRemarkField(index),
                                          child: const Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.message_outlined,
                                                    color: Constant
                                                        .mediumYellowColor,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    'Update visit',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Constant
                                                            .mediumYellowColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 1),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(width: 8),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            Get.to(() => VCPApplication(
                                                  onboardType: 'Aggregator',
                                                  employeeId: widget.employeeId,
                                                  name: aggregator
                                                      .aggregatorName!,
                                                  email: aggregator.email,
                                                  mobileNo: aggregator.mobile,
                                                  branchCode: widget.branchCode,
                                                ));
                                          },
                                          child: const Column(
                                            children: [
                                              Row(
                                                children: [
                                                  ImageIcon(
                                                    AssetImage(
                                                        'assets/icons/tick_circle.png'),
                                                    color:
                                                        Constant.lightBlueColor,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    'Convert VCP',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Constant
                                                            .lightBlueColor,
                                                        // color: Colors.green.shade300,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 1),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (selectedIndex == index) ...[
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const CustomText(
                                          text: 'Please enter your remark',
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              remarkController
                                                  .clear(); // Clear text field
                                              selectedIndex = null;
                                            });
                                          },
                                          icon: const ImageIcon(
                                            AssetImage(
                                                'assets/icons/close.png'),
                                            size: 20,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: remarkController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter remark...',
                                          hintStyle: TextStyle(
                                              color: Colors.grey[600]),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 10),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF116bb6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          elevation: 3,
                                        ),
                                        onPressed: () => submitRemark(
                                            aggregatorID: aggregator.id!,
                                            mobileNo: aggregator.mobile!),
                                        child: const CustomText(
                                          text: 'Submit',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Constant.lightBlueColor,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void callAggregatorsList() async {
    String employeeId = widget.employeeId;
    AggregatorListRes? response =
        await ApiClient().aggregatorList(json.encode(employeeId));
    if (response != null) {
      if (response.success!) {
        setState(() {
          data = response.data;
        });
      } else {
        // Get.snackbar("Failed", response.error,
        //     backgroundColor: Colors.redAccent, colorText: Colors.white);
        GlobalSnackbar.showError(response.error ?? "Failed to fetch aggregators");
      }
    } else {
      // Get.snackbar("Failed", "Something went wrong",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }

  void updateAggregators(
      {required int aggregatorID,
      required String mobileNo,
      required String remark}) async {
    String employeeId = widget.employeeId;
    Map<String, dynamic> body = {
      "AggregatorID": aggregatorID,
      "mobile": mobileNo,
      "remarks": remark,
      "EmployeeID": employeeId
    };

    Map<String, dynamic>? response =
        await ApiClient().updateAggregatorAPi(json.encode(body));
    if (response != null) {
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Remark update successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Get.snackbar("Failed", response['error'],
        //     backgroundColor: Colors.redAccent, colorText: Colors.white);
        GlobalSnackbar.showError(response['error'] ?? "Failed to update aggregator");
      }
    } else {
      // Get.snackbar("Failed", "Something went wrong",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }
}
