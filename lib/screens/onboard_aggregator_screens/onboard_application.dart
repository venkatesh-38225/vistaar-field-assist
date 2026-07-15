import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/customes_textformfield.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';

class OnboardApplication extends StatefulWidget {
  const OnboardApplication(
      {super.key, required this.employeeId, required this.branchCode});

  final String employeeId;
  final String branchCode;

  @override
  State<OnboardApplication> createState() => _OnboardApplicationState();
}

class _OnboardApplicationState extends State<OnboardApplication> {
  TextEditingController name = TextEditingController();
  TextEditingController contactNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController officeAddress = TextEditingController();
  TextEditingController residenceAddress = TextEditingController();
  TextEditingController remark = TextEditingController();
  TextEditingController others = TextEditingController();

  final _aggregatorFormKey = GlobalKey<FormState>();
  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  String? selectedProfile;
  final List<String> profileList = [
    'Real Estate Agent',
    'Document Writer',
    'Material Supplier',
    'Architect',
    'Freelancer',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              text: 'Add Aggregators',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _aggregatorFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: 'Enter your details',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 15),
              BuildTextField(
                hint: 'Aggregator Name',
                icon: Icons.person,
                isMultiline: false,
                label: 'Aggregator Name',
                controller: name,
                onSaved: (String? value) {
                  setState(() {
                    name.text = value!;
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
                hint: 'Contact No',
                icon: Icons.phone,
                inputType: TextInputType.number,
                isMultiline: false,
                label: 'Contact No',
                controller: contactNo,
                maxLength: 10,
                counterText: "",
                onSaved: (String? value) {
                  setState(() {
                    contactNo.text = value!;
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
                hint: 'Email ID',
                icon: Icons.email,
                isMultiline: false,
                label: 'Email ID',
                controller: email,
                onSaved: (String? value) {
                  setState(() {
                    email.text = value!;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide valid email Id';
                  } else {
                    return null;
                  }
                },
              ),
              _buildDropdown(),
              Visibility(
                visible: selectedProfile == 'Others',
                child: BuildTextField(
                  hint: 'Mention your profile',
                  icon: Icons.person,
                  isMultiline: true,
                  label: 'Mention your profile',
                  controller: others,
                  onSaved: (String? value) {
                    setState(() {
                      others.text = value!;
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
              ),
              BuildTextField(
                hint: 'Office Address',
                icon: Icons.business,
                isMultiline: true,
                label: 'Office Address',
                controller: officeAddress,
                onSaved: (String? value) {
                  setState(() {
                    officeAddress.text = value!;
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
                hint: 'Residence Address',
                icon: Icons.home,
                isMultiline: true,
                label: 'Residence Address',
                controller: residenceAddress,
                onSaved: (String? value) {
                  setState(() {
                    residenceAddress.text = value!;
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
                hint: 'Remarks',
                icon: Icons.edit,
                isMultiline: false,
                label: 'Remarks',
                controller: remark,
                onSaved: (String? value) {
                  setState(() {
                    remark.text = value!;
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
              const SizedBox(height: 20),
              Center(
                child: CustomButton(
                  text: 'Save',
                  onPressed: () {
                    var form = _aggregatorFormKey.currentState;
                    if (form!.validate()) {
                      if (emailRegex.hasMatch(email.text.trim())) {
                        addAggregators();
                      } else {
                        // Get.snackbar(
                        //     "Failed", "Please Provide a valid email Id",
                        //     backgroundColor: Colors.redAccent,
                        //     colorText: Colors.white);
                        GlobalSnackbar.showError("Please Provide a valid email Id");
                      }
                    }
                  },
                  backgroundColor: const Color(0xFFfaa61a),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: selectedProfile,
          decoration: const InputDecoration(border: InputBorder.none),
          hint: Row(
            children: [
              const Icon(
                Icons.arrow_drop_down_circle_sharp,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 10),
              Text('Select Profile',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade200),
          items: profileList.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category,
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedProfile = newValue;
            });
          },
        ),
      ),
    );
  }

  void addAggregators() async {
    Map<String, dynamic> body = {
      "branchCode": widget.branchCode,
      "aggregatorName": name.text,
      "mobile": contactNo.text,
      "email": email.text,
      "profile": selectedProfile,
      "officeAddress": officeAddress.text,
      "residenceAddress": residenceAddress.text,
      "lat": others.text == '' ? 'lat' : others.text,
      "lng": "lng",
      "remarks": remark.text,
      "createdBy": widget.employeeId
    };
    Map<String, dynamic>? response =
        await ApiClient().addAggregatorApi(json.encode(body));
    if (response != null) {
      if (response['success']) {
        Get.close(1);
        // Get.snackbar("Success", "Aggregator details are saved successfully",
        //     backgroundColor: Colors.green, colorText: Colors.white);
        GlobalSnackbar.showSuccess("Aggregator details are saved successfully");
      } else {
        // Get.snackbar("Failed", response['error'],
        //     backgroundColor: Colors.redAccent, colorText: Colors.white);
        GlobalSnackbar.showError(response['error'] ?? "Failed to save aggregator");
      }
    } else {
      // Get.snackbar("Failed", "Something went wrong",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }
}
