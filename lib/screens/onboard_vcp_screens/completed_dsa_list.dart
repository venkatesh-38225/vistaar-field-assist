import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/dsa_customer_list_res.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/bank_details_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/business_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/doc_verification.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/e-sign_enable.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class VcpCompletedList extends StatefulWidget {
  const VcpCompletedList({super.key, required this.employeeId});

  final String employeeId;

  @override
  State<VcpCompletedList> createState() => _VcpCompletedListState();
}

class _VcpCompletedListState extends State<VcpCompletedList> {
  TextEditingController searchController = TextEditingController();
  bool update = false;
  bool isLoading = false;
  List<Datum> dsaCustomers = [];

  @override
  void initState() {
    super.initState();
    dsaCustomerList();
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
              text: 'Completed DSA',
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
            dsaCustomerList();
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
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Constant.lightBlueColor,
                      ),
                    )
                  : dsaCustomers.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: dsaCustomers.length,
                            itemBuilder: (context, index) {
                              var aggregator = dsaCustomers[index];
                              var basicDetails = aggregator.basicDetails;
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
                                          AssetImage(
                                              'assets/icons/profile.png'),
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      CustomText(
                                        text: basicDetails?.name?.trim().isNotEmpty == true
                                            ? basicDetails!.name!
                                            : 'N/A',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: CustomText(
                                          text:
                                              'Status : ${aggregator.status ?? 'N/A'}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: CustomText(
                                          text:
                                              'Onboard type :  ${basicDetails?.vcpType ?? 'N/A'}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: CustomText(
                                          text:
                                              'email : ${basicDetails?.email ?? 'N/A'}',
                                          // Loan No: '${aggregator['loanNo']}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: CustomText(
                                          text:
                                          'VCP Code : ${aggregator.vcpCode ?? 'N/A'}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF37A20C),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios,
                                      color: Colors.blue.shade800, size: 20),
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: CustomText(text: 'No completed data'),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  void callPendingScreen(
      {required String status,
      required String customerId,
      required String companyType}) {
    switch (status) {
      case "BusinessDtls_Pending":
        Get.to(() => BusinessApplication(
            id: customerId, employeeId: widget.employeeId, close: 4));
        break;
      case "UploadDocument_Pending":
        Get.to(() => DocVerification(
              id: customerId,
              employeeId: widget.employeeId,
              close: 3,
              companyType: companyType,
            ));
        break;
      case "BankVerification_Pending":
        Get.to(
          () => BankApplication(
              id: customerId, employeeId: widget.employeeId, close: 2),
        );
        break;
      case "EsignInitiation_Pending":
        Get.to(() => ESignEnable(
            id: customerId, employeeId: widget.employeeId, close: 1));
        break;
      default:
    }
  }

  void dsaCustomerList() async {
    setState(() {
      isLoading = true;
    });
    DsaCustomerList? response =
        await ApiClient().dsaCustomerListApi(json.encode(widget.employeeId));
    if (response != null) {
      if (response.success == true) {
        setState(() {
          dsaCustomers = (response.data ?? []).where((item) {
            return (item.basicDetails?.vcpType ?? '') == 'DSA' &&
                (item.status ?? '') == 'Completed';
          }).toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        GlobalSnackbar.showError(response.error ?? "Failed to load customers");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      GlobalSnackbar.showError("Something went wrong");
    }
  }
}
