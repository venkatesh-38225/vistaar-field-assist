import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/bank_details_resp.dart';
import 'package:re_kyc_mobile_app/models/peniping_acc_validate_res.dart';
import 'package:re_kyc_mobile_app/models/peniping_account_status.dart';
import 'package:re_kyc_mobile_app/models/peniping_create_cus_response.dart';
import 'package:re_kyc_mobile_app/models/peniping_create_fund.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/e-sign_enable.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/AnimatedStepCircle.dart';
import '../../widgets/customes_textformfield.dart';

class BankApplication extends StatefulWidget {
  const BankApplication(
      {super.key, required this.id, required this.employeeId, this.close});

  final String id;
  final String employeeId;
  final int? close;

  @override
  State<BankApplication> createState() => _BankApplicationState();
}

class _BankApplicationState extends State<BankApplication> {
  TextEditingController accountHolderName = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController confirmAccountNumber = TextEditingController();
  TextEditingController ifscCode = TextEditingController();
  final _bankFormKey = GlobalKey<FormState>();
  String? penipingContactID;
  String? penipingCustomerName;
  String? penipingFundID;
  String? penipingValidateID;
  String? bankName;
  String? branchName;
  String? bankBranchId;
  String? bankStatus;
  String? utrNo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _applyBankPrefillIfAny();
  }

  void _applyBankPrefillIfAny() {
    final args = Get.arguments;

    if (args is Map && args["bankDetails"] is Map) {
      final m = Map<String, dynamic>.from(args["bankDetails"]);
      final ac = Map<String, dynamic>.from(m["bankAcDetails"] ?? {});

      // Fill your actual controllers/fields
      accountNumber.text = (ac["bankAcNo"] ?? "").toString();
      confirmAccountNumber.text = (ac["bankAcNo"] ?? "").toString();
      accountHolderName.text = (ac["acHolderName"] ?? "").toString();
      ifscCode.text = (ac["ifscCode"] ?? "").toString();

      setState(() {
        bankName = (ac["bankName"] ?? "").toString();
        branchName = (ac["branchName"] ?? "").toString();
        bankBranchId = (ac["bankBranchId"] ?? m["bankBranchId"])?.toString();
      });

      // Optional: Prefill IDs/status if you show them
      penipingContactID = (m["contactID"] ?? "").toString();
      penipingFundID = (m["fundAcID"] ?? "").toString();
      penipingValidateID = (m["fundAcValidationID"] ?? "").toString();
      bankStatus = (m["status"] ?? "").toString();
      utrNo = (m["utr"] ?? "").toString();
    }
  }

  Widget stepCircle({
    required String text,
    required Color fillColor,
    required Color borderColor,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3.0),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget completedStepCircle() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
        border: Border.all(color: Colors.green[900]!, width: 3.0),
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget stepConnector(Color color) {
    return Expanded(
      child: Container(height: 4, color: color),
    );
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Form(
          key: _bankFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Step 1
                  completedStepCircle(),
                  stepConnector(Colors.green),

                  // Step 2
                  completedStepCircle(),
                  stepConnector(Colors.green),

                  // Step 3
                  completedStepCircle(),
                  stepConnector(Colors.green),

                  // Step 4
                  AnimatedStepCircle(
                    text: "4",
                    fillColor: Constant.mediumBlueColor,
                    borderColor: Colors.green,
                  ),
                  stepConnector(Colors.grey),

                  // Step 5
                  stepCircle(
                    text: "5",
                    fillColor: Colors.grey,
                    borderColor: Constant.mediumBlueColor,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const CustomText(
                text: 'Bank Details',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 9),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: TextFormField(
                          controller: ifscCode,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'IFSC Code',
                            hintStyle: TextStyle(color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.add_card_sharp,
                                color: Colors.blueGrey),
                          ),
                          onSaved: (String? value) {
                            setState(() {
                              ifscCode.text = value!;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Requried';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    bankName == null
                        ? InkWell(
                            onTap: () {
                              callBankDetails();
                            },
                            child: SizedBox(
                              width: 80,
                              height: 55,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CustomText(
                                    text: 'Verify*',
                                    fontSize: 14,
                                    color: Color(0XFF116bb6),
                                    letterSpace: 1.5,
                                  ),
                                  Container(
                                    height: 2,
                                    width: 55,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 50,
                            height: 55,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  bankName = null;
                                  branchName = null;
                                  ifscCode.clear();
                                });
                              },
                              icon: const ImageIcon(
                                AssetImage('assets/icons/close.png'),
                                color: Colors.red,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Visibility(
                // visible:true,
                visible: bankName != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 55),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_sharp,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                bankName ?? 'Bank name',
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 55),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_sharp,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                branchName ?? 'Branch name',
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 140),
              const SizedBox(height: 10),
              const CustomText(
                text: 'Account Details',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 9),
              BuildTextField(
                hint: 'Account holder name',
                label: 'Account holder name',
                icon: Icons.person,
                isMultiline: false,
                controller: accountHolderName,
                onSaved: (String? value) {
                  accountHolderName.text = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  } else {
                    return null;
                  }
                },
              ),
              BuildTextField(
                hint: 'Account No',
                label: 'Account No',
                obscureText: true,
                icon: Icons.visibility_off,
                isMultiline: false,
                controller: accountNumber,
                onSaved: (String? value) {
                  accountNumber.text = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  } else {
                    return null;
                  }
                },
              ),
              BuildTextField(
                hint: 'Confirm Account',
                label: 'Confirm Account',
                icon: Icons.password_sharp,
                isMultiline: false,
                controller: confirmAccountNumber,
                onSaved: (String? value) {
                  confirmAccountNumber.text = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  } else {
                    return null;
                  }
                },
              ),
              bankName != null
                  ? const SizedBox(height: 150)
                  : const SizedBox(height: 300),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: SizedBox(
                        width: 200,
                        child: CustomButton(
                          text: 'Save & Next',
                          onPressed: () {
                            var form = _bankFormKey.currentState;
                            if (form!.validate()) {
                              if (bankName == null) {
                                // Get.snackbar(
                                //     "Failed", "Please verify your IFSC code",
                                //     backgroundColor: Colors.redAccent.shade200,
                                //     colorText: Colors.white);
                                GlobalSnackbar.showError(
                                    "Please verify your IFSC code");
                              } else {
                                if (accountNumber.text ==
                                    confirmAccountNumber.text) {
                                  callCreateCustomer();
                                } else {
                                  // Get.snackbar("Failed",
                                  //     "Account No and Confirm account No is not matching.",
                                  //     backgroundColor:
                                  //         Colors.redAccent.shade200,
                                  //     colorText: Colors.white);
                                  GlobalSnackbar.showError(
                                      "Account No and Confirm account No is not matching.");
                                }
                              }
                            }
                          },
                          backgroundColor: const Color(0xFFfaa61a),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void callBankDetails() async {
    BankDetailsResp? response =
        await ApiClient().getBankDetails(ifscCode.text.toString());
    if (response != null) {
      if (response.success == true) {
        setState(() {
          bankName = response.data?.bankName;
          branchName = response.data?.branchName;
          bankBranchId = response.data?.bankBranchId;
        });
      } else {
        String errorMsg = "Please provide a valid IFSC code";

        if (response.message != null &&
            response.message.toString().isNotEmpty) {
          errorMsg = response.message.toString();
        }
        GlobalSnackbar.showError(errorMsg);
      }
    } else {
      GlobalSnackbar.showError("Something went wrong. Please try again later.");
    }
  }

  void callCreateCustomer() async {
    var uuid = const Uuid();
    Map<String, dynamic> body = {
      "name": accountHolderName.text,
      "email": '',
      "contact": '',
      "type": "customer",
      "reference_id": uuid.v4(),
      "notes": {"note_key": "VCP creation"}
    };
    PenipingCreateCustomer? response =
        await ApiClient().createPenipingContact(json.encode(body));
    // print("response: ${json.encode(body)}");
    if (response != null) {
      setState(() {
        penipingContactID = response.id;
        penipingCustomerName = response.name;
      });
      callFundAccount();
    }
  }

  void callFundAccount() async {
    Map<String, dynamic> body = {
      "contact_id": penipingContactID,
      "account_type": "bank_account",
      "bank_account": {
        "name": accountHolderName.text,
        "ifsc": ifscCode.text,
        "account_number": accountNumber.text,
      }
    };
    PenipingCreateFund? response =
        await ApiClient().createPenipingFund(json.encode(body));
    if (response != null) {
      setState(() {
        penipingFundID = response.id;
      });
      callAccountValidation();
    }
  }

  void callAccountValidation() async {
    Map<String, dynamic> body = {
      "account_number": "3434493398448674",
      "fund_account": {"id": penipingFundID},
      "amount": 100,
      "currency": "INR",
      "notes": {"random_key_1": "VCP creation"}
    };

    PenipingAccountValidate? response =
        await ApiClient().penipingAccountValidation(json.encode(body));
    if (response != null) {
      setState(() {
        penipingValidateID = response.id!;
      });

      if (response.status! == 'created') {
        setState(() {
          isLoading = true;
        });
        DateFormat('HH:mm:ss').format(DateTime.now());
        DateFormat('HH:mm:ss').format(DateTime.now());
        callAccountStatus(response.id);
      }
    }
  }

  void callAccountStatus(String? id) async {
    PenipingAccountStatus? response =
        await ApiClient().penipingAccountStatus(id!);
    if (response != null) {
      if (response.status == 'completed' || response.status == 'created') {
        setState(() {
          isLoading = false;
        });
        String? accountStatus = response.results!.accountStatus ?? "";
        String utr = response.results!.utr ?? "";
        String name = response.results!.registeredName ?? "";
        String status = response.status ?? "";

        if (accountStatus != 'invalid') {
          callVcpBankDetails(
            accountStatus: accountStatus,
            utr: utr,
            name: name,
            status: status,
          );
        } else {
          // Get.snackbar("Failed", "Your bank account is not active",
          //     backgroundColor: Colors.redAccent, colorText: Colors.white);
          GlobalSnackbar.showError("Your bank account is not active");
        }
      } else {
        // Get.snackbar(
        //   "Failed",
        //   "IFSC Code and state not matching",
        //   backgroundColor: Colors.redAccent,
        //   colorText: Colors.white,
        // );
        GlobalSnackbar.showError("IFSC Code and state not matching");
      }
    } else {
      // Get.snackbar("Failed", "Something went wrong",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }

  void callVcpBankDetails({
    String? accountStatus,
    String? utr,
    String? name,
    String? status,
  }) async {
    Map<String, dynamic> body = {
      "id": widget.id,
      "data": {
        "bankAcDetails": {
          "bankAcNo": accountNumber.text,
          "acHolderName": accountHolderName.text,
          "ifscCode": ifscCode.text,
          "bankName": bankName,
          "branchName": branchName,
          "bankBranchId": bankBranchId ?? ""
        },
        "bankBranchId": bankBranchId ?? "",
        "contactID": penipingContactID,
        "fundAcID": penipingFundID,
        "fundAcValidationID": penipingValidateID,
        "status": status,
        "utr": utr,
        "results": {"account_status": accountStatus, "registered_name": name}
      },
      "updatedBy": widget.employeeId
    };
    Map<String, dynamic>? response =
        await ApiClient().vcpBankDetails(json.encode(body));
    if (response != null) {
      if (response["success"]) {
        /*Get.snackbar("Success", "Your bank account is validated successfully",
            backgroundColor: Colors.green, colorText: Colors.white);*/
        GlobalSnackbar.showSuccess(
            "Your bank account is validated successfully");
        Get.to(() => ESignEnable(
              id: widget.id,
              employeeId: widget.employeeId,
              close: widget.close,
            ));
      } else {
        /*Get.snackbar("Failed", response["error"],
            backgroundColor: Colors.redAccent, colorText: Colors.white);*/
        GlobalSnackbar.showError(
            response["error"] ?? "Failed to validate bank account");
      }
    } else {
      // Get.snackbar("Failed", "Something went wrong",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }
}
