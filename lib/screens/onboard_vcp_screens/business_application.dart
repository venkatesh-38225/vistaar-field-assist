import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/branch_list_resp.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/doc_verification.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';

import '../../widgets/AnimatedStepCircle.dart';
import '../../widgets/customes_textformfield.dart';
import 'add_appraiser.dart';

class BusinessApplication extends StatefulWidget {
  const BusinessApplication({super.key,
    required this.id,
    required this.employeeId,
    this.close,
    this.companyType,
    this.onboardType,
    this.isSentBack});

  final String id;
  final String employeeId;
  final int? close;
  final String? companyType;
  final String? onboardType;
  final bool? isSentBack;


  @override
  State<BusinessApplication> createState() => _BusinessApplicationState();
}

List<String> contractorsProvide = [
  "Yes",
  "No",
];
String? subContractor;

String? bankPartners;
String? vistaarEmployee;
String? employeeAnswer;
List<String> selectedCity = [];
TextEditingController cityController = TextEditingController();

TextEditingController noOfBusiness = TextEditingController();
TextEditingController noOfOfficeIndia = TextEditingController();
TextEditingController noOfOfEmployee = TextEditingController();
TextEditingController feesValuationCharges = TextEditingController();
TextEditingController urcNo = TextEditingController();
TextEditingController describeSubContractor = TextEditingController();
TextEditingController subContractorController = TextEditingController();

final _businessFormKey = GlobalKey<FormState>();
List<D>? branchList;
List<String>? branchNames;
bool annex = false;
bool annex4 = false;
bool saveBankPartner = false;
bool saveRelatedEmployee = false;
List<Map<String, dynamic>> bankPartnerList = [];
List<Map<String, dynamic>> savedData = [];
List<Map<String, dynamic>> relatedEmployeeList = [];
List<Map<String, dynamic>> savedEmployee = [];
bool isSentBackValue = false ;
Map<String, dynamic>? documentDetails;
Map<String, dynamic>? bankDetails;
String? submittedId;
bool? isSameIndividualAddress = false;
String? feesValuationAnswer;

class _BusinessApplicationState extends State<BusinessApplication> {
  @override
  void initState() {
    super.initState();
    callBranchDetails();
    _applyPrefillIfAny();
  }

  void _applyPrefillIfAny() {
    final args = Get.arguments;

    if (args is Map && args["businessDetails"] is Map) {
      documentDetails = args["documents"];
      bankDetails = args["bankDetails"];
      submittedId = args["id"];
      isSameIndividualAddress = args["isSameIndividualAddress"] ?? false;
      isSentBackValue = args["isSentBack"] ? true : false;
      _bindBusinessPrefill(Map<String, dynamic>.from(args["businessDetails"]));
    }
  }

  void _bindBusinessPrefill(Map<String, dynamic> data) {
    setState(() {
      // Text fields
      noOfBusiness.text    = (data["noOfYearsInBusiness"] ?? "").toString();
      noOfOfficeIndia.text = (data["noOfOfficesInIndia"] ?? "").toString();
      noOfOfEmployee.text  = (data["noOfEmployees"] ?? "").toString();
      urcNo.text           = (data["urcNo"] ?? "").toString();

      // Dropdowns
      // bankPartners   = (data["nbfcBankParnters"] ?? data["nbfcBankPartners"])?.toString();
      // subContractor  = data["useSubContractorsToService"]?.toString();
      // employeeAnswer = data["relatedToEmployeeOfVistaar"]?.toString();
      final bankPartnersValue = (data["nbfcBankParnters"] ?? data["nbfcBankPartners"])?.toString();
      if (bankPartnersValue != null && contractorsProvide.contains(bankPartnersValue)) {
        bankPartners = bankPartnersValue;
      } else {
        bankPartners = null; // Reset to null if invalid
      }

      final subContractorValue = data["useSubContractorsToService"]?.toString();
      if (subContractorValue != null && contractorsProvide.contains(subContractorValue)) {
        subContractor = subContractorValue;
      } else {
        subContractor = null;
      }

      final employeeAnswerValue = data["relatedToEmployeeOfVistaar"]?.toString();
      if (employeeAnswerValue != null && contractorsProvide.contains(employeeAnswerValue)) {
        employeeAnswer = employeeAnswerValue;
      } else {
        employeeAnswer = null;
      }

      // Cities
      final citiesAny = data["listOfCities"];
      final cities = citiesAny is List
          ? citiesAny.map((e) => e?.toString() ?? "").where((e) => e.isNotEmpty).toList()
          : <String>[];
      selectedCity = cities;
      cityController.text = selectedCity.join(", ");

      // Description
      subContractorController.text = (data["describeServicesOrDeliverables"] ?? "").toString();

      // Bank partners list
      final partnersAny = data["nbfcBankParnterDetails"] ?? data["nbfcBankPartnerDetails"];
      final partnersList = partnersAny is List ? partnersAny : <dynamic>[];
      savedData = partnersList.map<Map<String, dynamic>>((e) {
        final m = (e is Map) ? e : <String, dynamic>{};
        return {
          "id": m["id"],
          "companyName": m["companyName"] ?? "",
          "product": (m["product"] ?? m["product/service"] ?? "").toString(),
          "nameOfContact": m["nameOfContact"] ?? "",
          "mobileNo": (m["mobileNo"] ?? "").toString(),
        };
      }).toList();

      bankPartnerList.clear();
      for (final e in savedData) {
        bankPartnerList.add({
          "id": e["id"],
          "companyName": TextEditingController(text: e["companyName"] ?? ""),
          "product/service": TextEditingController(text: e["product"] ?? ""),
          "personName": TextEditingController(text: e["nameOfContact"] ?? ""),
          "mobileNo": TextEditingController(text: e["mobileNo"] ?? ""),
        });
      }
      annex = bankPartnerList.isNotEmpty;
      saveBankPartner = bankPartnerList.isNotEmpty;

      // Employee relations
      final empAny = data["employeeRelation"];
      final empList = empAny is List ? empAny : <dynamic>[];
      savedEmployee = empList.map<Map<String, dynamic>>((e) {
        final m = (e is Map) ? e : <String, dynamic>{};
        return {
          "id": m["id"],
          "name": m["name"] ?? "",
          "relationship": m["relationship"] ?? "",
        };
      }).toList();

      relatedEmployeeList.clear();
      for (final e in savedEmployee) {
        relatedEmployeeList.add({
          "id": e["id"],
          "name": TextEditingController(text: e["name"] ?? ""),
          "relationship": TextEditingController(text: e["relationship"] ?? ""),
        });
      }
      annex4 = relatedEmployeeList.isNotEmpty;
      saveRelatedEmployee = relatedEmployeeList.isNotEmpty;
    });
  }
  void addEducation() {
    savedData.clear();
    setState(() {
      saveBankPartner = false;
      bankPartnerList.add({
        'id': bankPartnerList.length + 1, // Auto-increment number
        'companyName': TextEditingController(),
        'product/service': TextEditingController(),
        'personName': TextEditingController(),
        'mobileNo': TextEditingController(),
      });
    });
  }

  void removeEducation(int index) {
    setState(() {
      bankPartnerList.removeAt(index);
      savedData.clear();
    });
  }

  void saveEducation() {
    for (var item in bankPartnerList) {
      setState(() {
        savedData.add({
          'id': item['id'],
          'companyName': item['companyName'].text,
          'product': item['product/service'].text,
          'nameOfContact': item['personName'].text,
          'mobileNo': item['mobileNo'].text,
        });
      });
    }
  }

  void removeEmployee(int index) {
    setState(() {
      relatedEmployeeList.removeAt(index);
      savedEmployee.clear();
    });
  }

  void saveEmployeeList() {
    for (var item in relatedEmployeeList) {
      setState(() {
        savedEmployee.add({
          'id': item['id'],
          'name': item['name'].text,
          'relationship': item['relationship'].text,
        });
      });
    }
  }

  void addEmployee() {
    savedEmployee.clear();
    setState(() {
      saveRelatedEmployee = false;
      relatedEmployeeList.add({
        'id': relatedEmployeeList.length + 1,
        'name': TextEditingController(),
        'relationship': TextEditingController(),
      });
    });
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

  bool isBankDetailsCompleted() => widget.isSentBack == true;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Form(
            key: _businessFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    children: [
                    // Step 1
                    InkWell(
                  //     onTap: () {
                  //
                  //   Get.snackbar("Testing", "Test",
                  //       backgroundColor: Colors.redAccent,
                  //       colorText: Colors.white);
                  // },
                  //     onTap: () {
                  //       // if (widget.isSentBack == true) {
                  //       //   Get.to(() => AddAppraiser(
                  //       //     onboardType: widget.onboardType ?? "",
                  //       //     employeeId: widget.employeeId,
                  //       //     branchCode: "", // pass if you have it
                  //       //   ));
                  //       // } else {
                  //       //   Get.snackbar("Testing", "Test",
                  //       //       backgroundColor: Colors.redAccent,
                  //       //       colorText: Colors.white);
                  //       // }
                  //     },

                      child: completedStepCircle(),

                  ),
                  stepConnector(Colors.green),

                  // Step 2
                  AnimatedStepCircle(
                    text: "2",
                    fillColor: Constant.mediumBlueColor,
                    borderColor: Colors.lightGreen,
                  ),
                  stepConnector(Colors.grey),

                  // Step 3
                  stepCircle(
                    text: "3",
                    fillColor: Colors.grey,
                    borderColor: Constant.mediumBlueColor,
                  ),
                  stepConnector(Colors.grey),

                  // Step 4
                  isBankDetailsCompleted()
                      ? completedStepCircle()
                      : stepCircle(
                    text: "4",
                    fillColor: Colors.grey,
                    borderColor: Constant.mediumBlueColor,
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
              text: 'Business Details',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            BuildTextField(
              hint: 'No of years in business',
              label: 'No of years in business',
              inputType: TextInputType.number,
              icon: Icons.person,
              isMultiline: false,
              controller: noOfBusiness,
              onSaved: (String? value) {
                setState(() {
                  noOfBusiness.text = value!;
                });
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
              hint: 'No of offices in India',
              label: 'No of offices in India',
              icon: Icons.home_work_sharp,
              inputType: TextInputType.number,
              isMultiline: false,
              controller: noOfOfficeIndia,
              onSaved: (String? value) {
                setState(() {
                  noOfOfficeIndia.text = value!;
                });
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
              hint: 'No of employees',
              label: 'No of employees',
              inputType: TextInputType.number,
              icon: Icons.person,
              isMultiline: false,
              controller: noOfOfEmployee,
              onSaved: (String? value) {
                setState(() {
                  noOfOfEmployee.text = value!;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Required';
                } else {
                  return null;
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () async {
                  List<String>? results = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MultiSelectDialog(
                        items: (branchNames != null && branchNames!.isNotEmpty)
                            ? branchNames!
                            : [],
                        selectedItems: selectedCity,
                      );
                    },
                  );

                  if (results != null) {
                    setState(() {
                      selectedCity = results;
                      cityController.text =
                          selectedCity.join(", "); // Show in TextField
                    });
                  }
                },
                child: AbsorbPointer(
                  // Prevents manual input
                  child: TextField(
                    controller: cityController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Select Cities",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                          Icons.arrow_drop_down_circle_sharp,
                          color: Colors.blueGrey),
                    ),
                    readOnly: true, // Prevents user from typing
                  ),
                ),
              ),
            ),
            BuildTextField(
              hint: isAppraiser() ? 'URC No/GST No' : 'URC No',
              label: isAppraiser() ? 'URC No/GST No' : 'URC No',
              icon: Icons.app_registration,
              isMultiline: false,
              controller: urcNo,
              onSaved: (String? value) {
                setState(() {
                  urcNo.text = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const CustomText(
              text: 'Entity Information',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 10),

            /// bank partners
            CustomText(
              text: isAppraiser()
                  ? '1. Willingness to do as Gold/Jewel appraiser with Vistaar on a part time basis?'
                  : '1. Do you want to add bank partners?',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: bankPartners,
                  decoration:
                  const InputDecoration(border: InputBorder.none),
                  hint: Row(
                    children: [
                      const Icon(
                        Icons.arrow_drop_down_circle_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Yes / No',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  icon: Icon(
                    Icons.arrow_right,
                    color: Colors.grey[200],
                    size: 5,
                  ),
                  items: contractorsProvide.map((String partner) {
                    return DropdownMenuItem<String>(
                      value: partner,
                      child: Text(
                        partner,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black),
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      bankPartners = newValue;
                      bankPartnerList.clear();
                      savedData.clear();
                    });
                  },
                ),
              ),
            ),

            /// bank partners add list
            Visibility(
              visible: !isAppraiser() && bankPartners == 'Yes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: annex ? 430 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: bankPartnerList.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  color: Colors.grey[100],
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Bank partner ${bankPartnerList[index]['id']}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold)),
                                        TextFormField(
                                          controller: bankPartnerList[index]
                                          ['companyName'],
                                          decoration: const InputDecoration(
                                            labelText: 'Company name',
                                            focusedBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Required';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        TextFormField(
                                          controller: bankPartnerList[index]
                                          ['product/service'],
                                          decoration: const InputDecoration(
                                            labelText: 'Product/Service',
                                            focusedBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Required';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        TextFormField(
                                          cursorColor: Colors.black,
                                          controller: bankPartnerList[index]
                                          ['personName'],
                                          decoration: const InputDecoration(
                                            labelText: 'Person name',
                                            focusedBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Required';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        TextFormField(
                                          controller: bankPartnerList[index]
                                          ['mobileNo'],
                                          keyboardType:
                                          TextInputType.number,
                                          maxLength: 10,
                                          decoration: const InputDecoration(
                                            labelText: 'Mobile no',
                                            counterText: "",
                                            focusedBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Required';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 5),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                removeEducation(index);
                                                if (bankPartnerList
                                                    .isEmpty) {
                                                  setState(() {
                                                    annex = false;
                                                  });
                                                }
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          saveBankPartner
                              ? SizedBox(
                            width: 170,
                            height: 40,
                            child: CustomButton(
                              onPressed: () {},
                              text: 'Saved',
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          )
                              : SizedBox(
                            width: 170,
                            height: 40,
                            child: CustomButton(
                              onPressed: () {
                                saveBankPartner = true;
                                var form =
                                    _businessFormKey.currentState;
                                if (form!.validate()) {
                                  saveEducation();
                                }
                              },
                              text: 'Save bank partners',
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const CustomText(
                    text: 'Please add your bank partners',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        annex = true;
                      });
                      addEducation();
                    },
                    child: Container(
                      height: 57,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8.0),
                      child: Row(
                        children: [
                          const ImageIcon(
                            AssetImage('assets/icons/plus.png'),
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 10),
                          bankPartnerList.isEmpty
                              ? Text(
                            "Add bank partners",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16),
                          )
                              : Text(
                            "Add more bank partners",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /// sub - contractors
            const CustomText(
              text:
              '2. Do you use/ plan to use any sub - contractors in providing services or deliverables to Vistaar?',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: subContractor,
                  decoration:
                  const InputDecoration(border: InputBorder.none),
                  hint: Row(
                    children: [
                      const Icon(
                        Icons.arrow_drop_down_circle_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Yes / No',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  icon: Icon(
                    Icons.arrow_right,
                    color: Colors.grey[200],
                    size: 5,
                  ),
                  items: contractorsProvide.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black),
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      subContractor = newValue;
                    });
                  },
                ),
              ),
            ),

            /// add sub - contractors
            Visibility(
              visible: !isAppraiser() && subContractor == 'Yes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const CustomText(
                    text: 'Please provide details about sub - contractors',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 10),
                  BuildTextField(
                    hint: 'Sub - contractors',
                    label: 'Sub - contractors',
                    icon: Icons.person,
                    isMultiline: false,
                    controller: subContractorController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (String? value) {
                      setState(() {
                        subContractorController.text = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// employee
            const CustomText(
              text:
              '3. Are you (Proprietor / any Partner (s) /Director (s)) is / are related to any employee of Vistaar Finance?',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: employeeAnswer,
                  decoration:
                  const InputDecoration(border: InputBorder.none),
                  hint: Row(
                    children: [
                      const Icon(
                        Icons.arrow_drop_down_circle_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Yes / No',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  icon: Icon(
                    Icons.arrow_right,
                    color: Colors.grey[200],
                    size: 5,
                  ),
                  items: contractorsProvide.map((String partner) {
                    return DropdownMenuItem<String>(
                      value: partner,
                      child: Text(
                        partner,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black),
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      employeeAnswer = newValue;
                    });
                  },
                ),
              ),
            ),

            /// bank employee add list
            Visibility(
              visible: employeeAnswer == 'Yes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: annex4 ? 350 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: relatedEmployeeList.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  color: Colors.grey[100],
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Employee ${relatedEmployeeList[index]['id']}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold)),
                                        TextFormField(
                                          controller:
                                          relatedEmployeeList[index]
                                          ['name'],
                                          decoration: const InputDecoration(
                                            labelText: 'Name of employee',
                                            focusedBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Required';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        TextFormField(
                                          controller:
                                          relatedEmployeeList[index]
                                          ['relationship'],
                                          decoration: const InputDecoration(
                                            labelText: 'RelationShip',
                                            focusedBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Required';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 5),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                removeEmployee(index);
                                                if (relatedEmployeeList
                                                    .isEmpty) {
                                                  setState(() {
                                                    annex4 = false;
                                                  });
                                                }
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          saveRelatedEmployee
                              ? SizedBox(
                            width: 170,
                            height: 40,
                            child: CustomButton(
                              onPressed: () {},
                              text: 'Saved',
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          )
                              : SizedBox(
                            width: 170,
                            height: 40,
                            child: CustomButton(
                              onPressed: () {
                                saveRelatedEmployee = true;
                                var form =
                                    _businessFormKey.currentState;
                                if (form!.validate()) {
                                  saveEmployeeList();
                                }
                              },
                              text: 'Save employees',
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const CustomText(
                    text: 'Please add related employees',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        annex4 = true;
                      });
                      addEmployee();
                    },
                    child: Container(
                      height: 57,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8.0),
                      child: Row(
                        children: [
                          const ImageIcon(
                            AssetImage('assets/icons/plus.png'),
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 10),
                          relatedEmployeeList.isEmpty
                              ? Text(
                            "Add employees",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16),
                          )
                              : Text(
                            "Add more employees",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Visibility(
              visible: isAppraiser(),
              child: Column(
                children: [
                  const CustomText(
                    text:
                    '4. Fees/ Valuation Charges (Acceptable as per Vistaar\'s Guidelines)',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<String>(
                        value: feesValuationAnswer,
                        decoration: const InputDecoration(border: InputBorder.none),
                        hint: Row(
                          children: [
                            const Icon(
                              Icons.arrow_drop_down_circle_sharp,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Yes / No',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        icon: Icon(
                          Icons.arrow_right,
                          color: Colors.grey[200],
                          size: 5,
                        ),
                        items: contractorsProvide.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            feesValuationAnswer = newValue;
                          });
                        },
                        validator: (value) {
                          if (isAppraiser() && (value == null || value.isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// employee

            /// save button
            Center(
              child: SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Save & Next',
                  onPressed: () {
                    var form = _businessFormKey.currentState;
                    if (form!.validate()) {

                      if (!isAppraiser() && bankPartners == 'Yes' && bankPartners != null) {
                      // if (bankPartners == 'Yes' && bankPartners != null) {
                        if (savedData.isNotEmpty) {
                          if (employeeAnswer == "Yes" &&
                              employeeAnswer != null) {
                            log('employeeAnswer - $employeeAnswer');
                            if (savedEmployee.isNotEmpty) {
                              log('savedEmployee - $savedEmployee');
                              saveBusinessDetails();
                            } else {
                              // Get.snackbar("Failed",
                              //     'Please add/save related employee details',
                              //     backgroundColor: Colors.redAccent,
                              //     colorText: Colors.white);
                              GlobalSnackbar.showError("Please add/save related employee details");
                            }
                          } else {
                            saveBusinessDetails();
                          }
                        } else {
                          // Get.snackbar("Failed",
                          //     'Please add/save bank partner details',
                          //     backgroundColor: Colors.redAccent,
                          //     colorText: Colors.white);
                          GlobalSnackbar.showError("Please add/save bank partner details");
                        }
                      } else if (employeeAnswer == "Yes" &&
                          employeeAnswer != null) {
                        if (savedEmployee.isNotEmpty) {
                          saveBusinessDetails();
                        } else {
                          // Get.snackbar("Failed",
                          //     'Please add/save related employee details',
                          //     backgroundColor: Colors.redAccent,
                          //     colorText: Colors.white);
                          GlobalSnackbar.showError("Please add/save related employee details");
                        }
                      } else {
                        saveBusinessDetails();
                      }
                    }else{
                      print("Form is not valid");
                    }
                    /* Get.to(() => DocVerification(
                          id: widget.id,
                          employeeId: widget.employeeId,
                          close: widget.close,
                          companyType: widget.companyType,
                          onboardType:widget.onboardType,
                        ));*/
                  },
                  backgroundColor: const Color(0xFFfaa61a),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    ),
    );
    }

    bool isAppraiser() {
    final type = widget.onboardType ?? "";
    return type.isNotEmpty && type == "Appraiser";
    }

    void saveBusinessDetails() async {
    Map<String, dynamic> body = {
    "queryType": isSentBackValue ? "update":"add",
    "id": widget.id,
    "data": {
    "noOfYearsInBusiness": noOfBusiness.text,
    "nbfcBankParnters": bankPartners,
    "nbfcBankParnterDetails": savedData,
    "noOfOfficesInIndia": noOfOfficeIndia.text,
    "listOfCities": selectedCity,
    "noOfEmployees": noOfOfEmployee.text,
    "useSubContractorsToService": subContractor,
    "describeServicesOrDeliverables": subContractorController.text,
    "relatedToEmployeeOfVistaar": employeeAnswer,
    "employeeRelation": savedEmployee,
    "urcNo": urcNo.text,
    if (isAppraiser()) "willingnessToGoldAppraiser": bankPartners,
      if (isAppraiser()) "valuationCharges": feesValuationAnswer,
    },
    "updatedBy": widget.employeeId
    };
    log('saveBusinessDetails - ${json.encode(body)}');
log("isSame, #{isSameIndividualAddress");
    Map<String, dynamic>? response =
    await ApiClient().dsaBusinessDetApi(json.encode(body));
    if (response != null) {
    if (response["success"] == true) {
    // Get.snackbar("Success", "Business details are saved successfully",
    // backgroundColor: Colors.green, colorText: Colors.white);
    GlobalSnackbar.showSuccess("Business details are saved successfully");
    Get.to(() => DocVerification(
    id: widget.id,
    employeeId: widget.employeeId,
    close: widget.close,
    companyType: widget.companyType,
    onboardType:widget.onboardType,
    isSentBack: widget.isSentBack,
    ),
      arguments: {
      "id": submittedId, "isSentBack": isSentBackValue,
      "isSameIndividualAddress": isSameIndividualAddress,
      "documents":documentDetails,
        "bankDetails":bankDetails,
      }
    );
    } else {
    // Get.snackbar("Failed", response["error"],
    // backgroundColor: Colors.redAccent, colorText: Colors.white);
    GlobalSnackbar.showError(response["error"] ?? "Failed to save details");
    }
    }
    }

    void callBranchDetails() async {
    BranchListRes? response = await ApiClient().branchListApi();
    if (response != null) {
    if (response.d != []) {
    setState(() {
    branchList = response.d;
    branchNames =
    response.d!.map<String>((branch) => branch.branchname!).toList();
    });
    } else {
    // Get.snackbar("Failed", 'No available city',
    // backgroundColor: Colors.redAccent, colorText: Colors.white);
    GlobalSnackbar.showError("No available city");
    }
    } else {
    // Get.snackbar("Failed", 'Something went wrong',
    // backgroundColor: Colors.redAccent, colorText: Colors.white);
    GlobalSnackbar.showError("Something went wrong");
    }
    }
  }

// Multi-Select Dialog Widget
// Optimized Multi-Select Dialog Widget
  class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;

  const MultiSelectDialog({
  super.key,
  required this.items,
  required this.selectedItems,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
  }

  class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> tempSelectedItems;

  @override
  void initState() {
  super.initState();
  tempSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
  return AlertDialog(
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(7),
  ),
  title: const Text("Select Cities"),
  content: SizedBox(
  height: 400,
  width: double.maxFinite,
  child: Scrollbar(
  child: ListView.builder(
  itemCount: widget.items.length,
  itemBuilder: (context, index) {
  final item = widget.items[index];
  final isSelected = tempSelectedItems.contains(item);

  return CheckboxListTile(
  dense: true,
  contentPadding: EdgeInsets.zero,
  title: Text(
  item,
  style: const TextStyle(fontSize: 14),
  ),
  value: isSelected,
  onChanged: (bool? checked) {
  setState(() {
  if (checked == true) {
  tempSelectedItems.add(item);
  } else {
  tempSelectedItems.remove(item);
  }
  });
  },
  );
  },
  ),
  ),
  ),
  actions: [
  TextButton(
  onPressed: () {
  Navigator.pop(context); // Close without saving
  },
  child: const Text(
  "Cancel",
  style: TextStyle(color: Colors.black),
  ),
  ),
  ElevatedButton(
  style: ElevatedButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: Constant.mediumBlueColor,
  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 30),
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(3),
  ),
  ),
  onPressed: () {
  Navigator.pop(context, tempSelectedItems); // Return selected items
  },
  child: const Text("OK"),
  ),
  ],
  );
  }
  }

