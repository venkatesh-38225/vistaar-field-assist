import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/dsa_customer_list_res.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/bank_details_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/business_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/doc_verification.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/e-sign_enable.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/vcp_application.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';

import '../onboard_vcp_screens/add_appraiser.dart';

class ConnectorsList extends StatefulWidget {
  const ConnectorsList({super.key, required this.employeeId});

  final String employeeId;
  @override
  State<ConnectorsList> createState() => _ConnectorsListState();
}

class _ConnectorsListState extends State<ConnectorsList> {
  TextEditingController searchController = TextEditingController();
  bool update = false;
  bool isLoading = false;
  TextEditingController remarkController = TextEditingController();
  List<Map<String, String>> aggregatorList = [
    {
      'title': 'G. Arun',
      'subTitle': 'Finished',
      'loanNo': '987654321',
      'email_id': 'arun@vistaarfinance.com'
    },
    {
      'title': 'S. Kumar',
      'subTitle': 'Pending',
      'loanNo': '876543219',
      'email_id': 'arun@vistaarfinance.com'
    },
    {
      'title': 'K. Ramesh',
      'subTitle': 'Pending',
      'loanNo': '765432198',
      'email_id': 'arun@vistaarfinance.com'
    },
    {
      'title': 'B. Mani',
      'subTitle': 'Finished',
      'loanNo': '765432198',
      'email_id': 'arun@vistaarfinance.com'
    },
    {
      'title': 'F. Ramya',
      'subTitle': 'Pending',
      'loanNo': '765432198',
      'email_id': 'arun@vistaarfinance.com'
    },
    {
      'title': 'D. Ramya',
      'subTitle': 'Pending',
      'loanNo': '765432198',
      'email_id': 'arun@vistaarfinance.com'
    },
    {
      'title': 'E. Ramya',
      'subTitle': 'Pending',
      'loanNo': '765432198',
      'email_id': 'arun@vistaarfinance.com'
    },
    {
      'title': 'S. Ramya',
      'subTitle': 'Pending',
      'loanNo': '765432198',
      'email_id': 'arun@vistaarfinance.com'
    },
    {
      'title': 'T. Ramya',
      'subTitle': 'Pending',
      'loanNo': '765432198',
      'email_id': 'arun@vistaarfinance.com'
    },
  ];
  List<Datum> dsaCustomers = [];
  String? customerId;

  @override
  void initState() {
    super.initState();
    dsaCustomerList();
  }

  String getRemarksForStatus(Datum aggregator) {
    final actions = aggregator.actions;
    final status = aggregator.status;

    if (aggregator.isSentBack != true || actions == null || status == null) return "";

    if (status.contains("RCU_SentBack")) {
      return actions.rcuRemarks ?? "";
    } else if (status.contains("RBHSentBack")) {
      return actions.rbhRemarks ?? "";
    } else if (status.contains("ZBHSentBack")) {
      return actions.zbhRemarks ?? "";
    } else if (status.contains("MZBHSentBack")) {
      return actions.mzbhRemarks ?? "";
    } else if (status.contains("COPS_SentBack")) {
      return actions.copsRemarks ?? "";
    } else if (status.contains("ChannelSpoc_SentBack")) {
      return actions.channelSpocRemarks ?? "";
    }

    return "";
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
              text: 'Pending Connectors',
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
                  CustomText(text: 'Scroll down to refresh the list', fontSize: 10,),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_downward_sharp, size: 10,)
                ],),
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
                  : dsaCustomers.isNotEmpty ? Expanded(
                child: ListView.builder(
                  itemCount: dsaCustomers.length,
                  itemBuilder: (context, index) {
                    var aggregator = dsaCustomers[index];
                    var basicDetails = aggregator.basicDetails;
                    var customerId = aggregator.id;
                    return InkWell(
                      onTap: (){
                        callPendingScreen(status: aggregator.status!, customerId: customerId!, companyType: basicDetails!.companyType!,isSentBack: aggregator.isSentBack ?? false);
                      },
                      child: Card(
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
                                text: dsaCustomers == []
                                    ? ""
                                    : basicDetails!.name!,
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
                                  'Status : ${dsaCustomers == [] ? "Status" : aggregator.status!}',
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
                                  'Onboard type :  ${dsaCustomers == [] ? "" : basicDetails!.vcpType!}',
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
                                  'email : ${dsaCustomers == [] ? "" : basicDetails!.email!}',
                                  // Loan No: '${aggregator['loanNo']}',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              if (aggregator.isSentBack == true)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, top: 2),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Remarks : ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        TextSpan(
                                          text: getRemarksForStatus(aggregator),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Colors.blue.shade800, size: 20),
                        ),
                      ),
                    );
                  },
                ),
              )   : const Center(
                child: CustomText(text: 'No pending data'),
              ),
            ],
          ),
        ),
      ),

    );
  }
  void callPendingScreen({required String status, required String customerId, required String companyType,required bool isSentBack}){

    final datum = dsaCustomers.firstWhere((d) => d.id == customerId, orElse: () => dsaCustomers.first);

    final onBoardType =datum.basicDetails?.vcpType;
    if (status.contains("SentBack")) {
      // Go to Step-1 with prefill
      if(onBoardType == "Appraiser"){
        Get.to(
              () => AddAppraiser(
            onboardType: datum.basicDetails?.vcpType ?? "",
            employeeId: widget.employeeId,
            branchCode: datum.basicDetails?.branchCode ?? "",
          ),
          arguments: {
            "id": datum.id,
            "isSentBack": isSentBack,
            "basicDetails": {
              "name": datum.basicDetails?.name,
              "branchCode": datum.basicDetails?.branchCode,
              "mobile": datum.basicDetails?.mobile,
              "mobileStatus": datum.basicDetails?.mobileStatus,
              "email": datum.basicDetails?.email,
              "emailStatus": datum.basicDetails?.emailStatus,
              "vcpType": datum.basicDetails?.vcpType,
              "companyType": datum.basicDetails?.companyType,
              "companyRegistrationNo": datum.basicDetails?.companyRegistrationNo,
              "designation": datum.basicDetails?.designation,
              "pincode": datum.basicDetails?.pincode,
              "city": datum.basicDetails?.city,
              "district": datum.basicDetails?.district,
              "stateName": datum.basicDetails?.stateName,
              "stateCode": datum.basicDetails?.stateCode,
              "cityCode": datum.basicDetails?.cityCode,
              "pinCodeId": datum.basicDetails?.pinCodeId,
              "address": datum.basicDetails?.address,
              "officeAddress": datum.basicDetails?.officeAddress,
              "telephoneNumber": datum.basicDetails?.telephoneNumber,
              "remarks": datum.basicDetails?.remarks,
              "pan": datum.basicDetails?.pan,
              "dobAsperPAN": datum.basicDetails?.dobAsperPan,
              "gender": datum.basicDetails?.gender,
              "fatherName": datum.basicDetails?.fatherName,
              "eduQualification": datum.basicDetails?.eduQualification,
              "agencyName": datum.basicDetails?.agencyName,
              "businessName": datum.basicDetails?.businessName,
            },
            "businessDetails": {
              "noOfYearsInBusiness": datum.businessDetails?.noOfYearsInBusiness,
              "nbfcBankParnters": datum.businessDetails?.nbfcBankParnters,
              "nbfcBankParnterDetails": (datum.businessDetails?.nbfcBankParnterDetails ?? []).map((e) => {
                "companyName": e.companyName,
                "product": e.product,
                "nameOfContact": e.nameOfContact,
                "mobileNo": e.mobileNo,
              }).toList(),
              "noOfOfficesInIndia": datum.businessDetails?.noOfOfficesInIndia,
              "listOfCities": datum.businessDetails?.listOfCities ?? [],
              "noOfEmployees": datum.businessDetails?.noOfEmployees,
              "useSubContractorsToService": datum.businessDetails?.useSubContractorsToService,
              "describeServicesOrDeliverables": datum.businessDetails?.describeServicesOrDeliverables,
              "relatedToEmployeeOfVistaar": datum.businessDetails?.relatedToEmployeeOfVistaar,
              "employeeRelation": (datum.businessDetails?.employeeRelation ?? []).map((e) => {
                // "id": e.id,
                "name": e.name,
                "relationship": e.relationship,
              }).toList(),
              "urcNo": datum.businessDetails?.urcNo,
              "willingnessToGoldAppraiser": datum.businessDetails?.willingnessToGoldAppraiser,
              "valuationCharges": datum.businessDetails?.valuationCharges,
            },
            "isSameIndividualAddress": datum.basicDetails?.isSameIndividualAddress,
            "documents": {
              "photo": datum.documents?.photo,
              "signature": datum.documents?.signature,
              "pan": datum.documents?.pan,
              "addressProof": datum.documents?.addressProof,
              "companyPAN": datum.documents?.companyPAN,
              "officeAddressProof": datum.documents?.officeAddressProof,
              "entityProof": datum.documents?.entityProof,
              "addressProofType": datum.documents?.addressProofType,
              "officeAddressProofType": datum.documents?.officeAddressProofType,
              "entityProofType": datum.documents?.entityProofType,
              "dsa": datum.documents?.dsa,
              "urc": datum.documents?.urc,
              "eSign": datum.documents?.eSign,
              "otherDoc": datum.documents?.otherDoc,
            },

            "bankDetails": {
              "bankAcDetails": {
                "bankAcNo": datum.bankDetails?.bankAcDetails?.bankAcNo,
                "acHolderName": datum.bankDetails?.bankAcDetails?.acHolderName,
                "ifscCode": datum.bankDetails?.bankAcDetails?.ifscCode,
                "bankName": datum.bankDetails?.bankAcDetails?.bankName,
                "branchName": datum.bankDetails?.bankAcDetails?.branchName,
                "bankBranchId": datum.bankDetails?.bankAcDetails?.bankBranchId,
              },

              // "fundAcValidationID": datum.bankDetails?.fundAcValidationID,
              "status": datum.bankDetails?.status,
              "utr": datum.bankDetails?.utr,
              "results": {
                "account_status": datum.bankDetails?.results?.accountStatus,
                "registered_name": datum.bankDetails?.results?.registeredName,
              }
            },

          },

        );
      } else{
        Get.to(
              () => VCPApplication(
            onboardType: datum.basicDetails?.vcpType ?? "",
            employeeId: widget.employeeId,
            branchCode: datum.basicDetails?.branchCode ?? "",
          ),
          arguments: {
            "id": datum.id,
            "isSentBack": isSentBack,
            "basicDetails": {
              "name": datum.basicDetails?.name,
              "branchCode": datum.basicDetails?.branchCode,
              "mobile": datum.basicDetails?.mobile,
              "mobileStatus": datum.basicDetails?.mobileStatus,
              "email": datum.basicDetails?.email,
              "emailStatus": datum.basicDetails?.emailStatus,
              "vcpType": datum.basicDetails?.vcpType,
              "companyType": datum.basicDetails?.companyType,
              "companyRegistrationNo": datum.basicDetails?.companyRegistrationNo,
              "designation": datum.basicDetails?.designation,
              "pincode": datum.basicDetails?.pincode,
              "city": datum.basicDetails?.city,
              "district": datum.basicDetails?.district,
              "stateName": datum.basicDetails?.stateName,
              "stateCode": datum.basicDetails?.stateCode,
              "cityCode": datum.basicDetails?.cityCode,
              "pinCodeId": datum.basicDetails?.pinCodeId,
              "address": datum.basicDetails?.address,
              "officeAddress": datum.basicDetails?.officeAddress,
              "telephoneNumber": datum.basicDetails?.telephoneNumber,
              "remarks": datum.basicDetails?.remarks,
              "pan": datum.basicDetails?.pan,
              "dobAsperPAN": datum.basicDetails?.dobAsperPan,
              "gender": datum.basicDetails?.gender,
              "fatherName": datum.basicDetails?.fatherName,
              "eduQualification": datum.basicDetails?.eduQualification,
              "agencyName": datum.basicDetails?.agencyName,
              "businessName": datum.basicDetails?.businessName,
            },
            "businessDetails": {
              "noOfYearsInBusiness": datum.businessDetails?.noOfYearsInBusiness,
              "nbfcBankParnters": datum.businessDetails?.nbfcBankParnters,
              "nbfcBankParnterDetails": (datum.businessDetails?.nbfcBankParnterDetails ?? []).map((e) => {
                "companyName": e.companyName,
                "product": e.product,
                "nameOfContact": e.nameOfContact,
                "mobileNo": e.mobileNo,
              }).toList(),
              "noOfOfficesInIndia": datum.businessDetails?.noOfOfficesInIndia,
              "listOfCities": datum.businessDetails?.listOfCities ?? [],
              "noOfEmployees": datum.businessDetails?.noOfEmployees,
              "useSubContractorsToService": datum.businessDetails?.useSubContractorsToService,
              "describeServicesOrDeliverables": datum.businessDetails?.describeServicesOrDeliverables,
              "relatedToEmployeeOfVistaar": datum.businessDetails?.relatedToEmployeeOfVistaar,
              "employeeRelation": (datum.businessDetails?.employeeRelation ?? []).map((e) => {
                // "id": e.id,
                "name": e.name,
                "relationship": e.relationship,
              }).toList(),
              "urcNo": datum.businessDetails?.urcNo,
              "willingnessToGoldAppraiser": datum.businessDetails?.willingnessToGoldAppraiser,
              "valuationCharges": datum.businessDetails?.valuationCharges,
            },
            "isSameIndividualAddress": datum.basicDetails?.isSameIndividualAddress,
            "documents": {
              "photo": datum.documents?.photo,
              "signature": datum.documents?.signature,
              "pan": datum.documents?.pan,
              "addressProof": datum.documents?.addressProof,
              "companyPAN": datum.documents?.companyPAN,
              "officeAddressProof": datum.documents?.officeAddressProof,
              "entityProof": datum.documents?.entityProof,
              "addressProofType": datum.documents?.addressProofType,
              "officeAddressProofType": datum.documents?.officeAddressProofType,
              "entityProofType": datum.documents?.entityProofType,
              "dsa": datum.documents?.dsa,
              "urc": datum.documents?.urc,
              "eSign": datum.documents?.eSign,
              "otherDoc": datum.documents?.otherDoc,
            },

            "bankDetails": {
              "bankAcDetails": {
                "bankAcNo": datum.bankDetails?.bankAcDetails?.bankAcNo,
                "acHolderName": datum.bankDetails?.bankAcDetails?.acHolderName,
                "ifscCode": datum.bankDetails?.bankAcDetails?.ifscCode,
                "bankName": datum.bankDetails?.bankAcDetails?.bankName,
                "branchName": datum.bankDetails?.bankAcDetails?.branchName,
                "bankBranchId": datum.bankDetails?.bankAcDetails?.bankBranchId,
              },

              // "fundAcValidationID": datum.bankDetails?.fundAcValidationID,
              "status": datum.bankDetails?.status,
              "utr": datum.bankDetails?.utr,
              "results": {
                "account_status": datum.bankDetails?.results?.accountStatus,
                "registered_name": datum.bankDetails?.results?.registeredName,
              }
            },

          },

        );
      }
      return;
    }
    if (isSentBack == true) {
      if (status == "BusinessDtls_Pending") {
        Get.to(
              () => BusinessApplication(
            id: customerId,
            employeeId: widget.employeeId,
            close: 4,
            companyType: companyType,
            isSentBack: isSentBack,
          ),
          arguments: {
            "isSentBack": isSentBack,
            "businessDetails": {
              "noOfYearsInBusiness": datum.businessDetails?.noOfYearsInBusiness,
              "nbfcBankParnters": datum.businessDetails?.nbfcBankParnters,
              "nbfcBankParnterDetails": (datum.businessDetails?.nbfcBankParnterDetails ?? []).map((e) => {
                "companyName": e.companyName,
                "product": e.product,
                "nameOfContact": e.nameOfContact,
                "mobileNo": e.mobileNo,
              }).toList(),
              "noOfOfficesInIndia": datum.businessDetails?.noOfOfficesInIndia,
              "listOfCities": datum.businessDetails?.listOfCities ?? [],
              "noOfEmployees": datum.businessDetails?.noOfEmployees,
              "useSubContractorsToService": datum.businessDetails?.useSubContractorsToService,
              "describeServicesOrDeliverables": datum.businessDetails?.describeServicesOrDeliverables,
              "relatedToEmployeeOfVistaar": datum.businessDetails?.relatedToEmployeeOfVistaar,
              "employeeRelation": (datum.businessDetails?.employeeRelation ?? []).map((e) => {
                // "id": e.id,
                "name": e.name,
                "relationship": e.relationship,
              }).toList(),
              "urcNo": datum.businessDetails?.urcNo,
              "willingnessToGoldAppraiser": datum.businessDetails?.willingnessToGoldAppraiser,
              "valuationCharges": datum.businessDetails?.valuationCharges,
            }
          },
        );
      } else if (status == "UploadDocument_Pending") {
        Get.to(
              () => DocVerification(
            id: customerId,
            employeeId: widget.employeeId,
            close: 3,
            companyType: companyType,
            isSentBack: isSentBack,
          ),
          arguments: {
            "isSentBack": isSentBack,
            "isSameIndividualAddress": datum.basicDetails?.isSameIndividualAddress,
            "documents": {
              "photo": datum.documents?.photo,
              "signature": datum.documents?.signature,
              "pan": datum.documents?.pan,
              "addressProof": datum.documents?.addressProof,
              "companyPAN": datum.documents?.companyPAN,
              "officeAddressProof": datum.documents?.officeAddressProof,
              "entityProof": datum.documents?.entityProof,
              "dsa": datum.documents?.dsa,
              "urc": datum.documents?.urc,
              "eSign": datum.documents?.eSign,
              "otherDoc": datum.documents?.otherDoc,
            },
            "bankDetails": {
              "bankAcDetails": {
                "bankAcNo": datum.bankDetails?.bankAcDetails?.bankAcNo,
                "acHolderName": datum.bankDetails?.bankAcDetails?.acHolderName,
                "ifscCode": datum.bankDetails?.bankAcDetails?.ifscCode,
                "bankName": datum.bankDetails?.bankAcDetails?.bankName,
                "branchName": datum.bankDetails?.bankAcDetails?.branchName,
                "bankBranchId": datum.bankDetails?.bankAcDetails?.bankBranchId,
              },

              // "fundAcValidationID": datum.bankDetails?.fundAcValidationID,
              "status": datum.bankDetails?.status,
              "utr": datum.bankDetails?.utr,
              "results": {
                "account_status": datum.bankDetails?.results?.accountStatus,
                "registered_name": datum.bankDetails?.results?.registeredName,
              }
            },
          },
        );
      } else if (status == "BankVerification_Pending") {
        Get.to(
              () => BankApplication(id: customerId, employeeId: widget.employeeId, close: 2),
          arguments: {
            "isSentBack": isSentBack,
            "bankDetails": {
              "bankAcDetails": {
                "bankAcNo": datum.bankDetails?.bankAcDetails?.bankAcNo,
                "acHolderName": datum.bankDetails?.bankAcDetails?.acHolderName,
                "ifscCode": datum.bankDetails?.bankAcDetails?.ifscCode,
                "bankName": datum.bankDetails?.bankAcDetails?.bankName,
                "branchName": datum.bankDetails?.bankAcDetails?.branchName,
                "bankBranchId": datum.bankDetails?.bankAcDetails?.bankBranchId,
              },

              // "fundAcValidationID": datum.bankDetails?.fundAcValidationID,
              "status": datum.bankDetails?.status,
              "utr": datum.bankDetails?.utr,
              "results": {
                "account_status": datum.bankDetails?.results?.accountStatus,
                "registered_name": datum.bankDetails?.results?.registeredName,
              }
            }
          },
        );
      } else if (status == "EsignInitiation_Pending") {
        Get.to(() => ESignEnable(id: customerId, employeeId: widget.employeeId, close: 1));
      } else {
        // default to business page if unknown
        Get.to(
              () => BusinessApplication(
            id: customerId,
            employeeId: widget.employeeId,
            close: 4,
            companyType: companyType,
            isSentBack: isSentBack,
          ),
        );
      }
      return;
    }

    switch (status) {
      case "BusinessDtls_Pending":
        Get.to(() =>  BusinessApplication(
            id: customerId,
            employeeId: widget.employeeId,
            close : 4,
          companyType: companyType,
          isSentBack:isSentBack,
        ));
        break;
      case "UploadDocument_Pending":
        Get.to(() => DocVerification(
            id: customerId,
            employeeId: widget.employeeId,
            close : 3,
          companyType: companyType,
          isSentBack: isSentBack,
        ));
        break;
      case "BankVerification_Pending":
        Get.to(() => BankApplication(
            id: customerId,
            employeeId: widget.employeeId,
            close : 2
        ),);
        break;
      case "EsignInitiation_Pending":
        Get.to(() =>  ESignEnable(
            id: customerId,
            employeeId: widget.employeeId,
            close : 1
        ));
        break;
      default:
      // Code to execute if none of the cases match
    }
  }

  void dsaCustomerList() async {
    setState(() {
      isLoading = true;
    });
    DsaCustomerList? response = await ApiClient().dsaCustomerListApi(json.encode(widget.employeeId));
    if (response != null) {
      if (response.success!) {
        setState(() {
          dsaCustomers = response.data!.where((item) {
            return item.basicDetails!.vcpType == "Connector" && item.status != 'Completed';
          }).toList();

          isLoading = false;
        });
      } else {
        // Get.snackbar("Failed", response.error,
        //     backgroundColor: Colors.redAccent, colorText: Colors.white);
        GlobalSnackbar.showError(response.error ?? "Failed to fetch connectors");
      }
    } else {
      // Get.snackbar("Failed", "Something went wrong",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }
}
