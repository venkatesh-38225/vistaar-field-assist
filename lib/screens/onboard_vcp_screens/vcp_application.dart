import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/controllers/vcp_application_controller.dart';
import 'package:re_kyc_mobile_app/models/dsa_bas_details_reqest.dart';
import 'package:re_kyc_mobile_app/models/email_otp_response.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/business_application.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import '../../widgets/AnimatedStepCircle.dart';
import '../../widgets/customes_textformfield.dart';
import '../../models/state_city_pincode_model.dart';
import '../../widgets/searchable_autocomplete_field.dart';

class VCPApplication extends StatefulWidget {
  const VCPApplication(
      {super.key,
      required this.onboardType,
      required this.employeeId,
      this.name,
      this.email,
      this.mobileNo,
      required this.branchCode});

  final String onboardType;
  final String employeeId;
  final String? name;
  final String? email;
  final String? mobileNo;
  final String branchCode;

  @override
  State<VCPApplication> createState() => _VCPApplicationState();
}

class _VCPApplicationState extends State<VCPApplication> {
  String? selectedCategory;
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController mobileOtpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emailOtpController = TextEditingController();
  TextEditingController panNoController = TextEditingController();
  TextEditingController companyRegNoController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController officeAddressController = TextEditingController();
  TextEditingController individualAddressController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController fathersNameController = TextEditingController();
  TextEditingController educationQualificationController =
      TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController agencyNameController = TextEditingController();
  String? selectedGender;
  List<String> genderList = ['Male', 'Female', 'Other'];

  String? mobileOtp;
  String? mobileValidation;
  bool mobileUpdate = false;
  String? emailOtp;
  String? emailValidation;
  bool emailUpdate = false;
  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  String? _dobPan;
  DateTime? dobAsPan;
  String? companyType;

  bool isSameIndividualAddress = false;
  Map<String, dynamic>? businessDetails;
  Map<String, dynamic>? documentDetails;
  Map<String, dynamic>? bankDetails;

  final VcpApplicationController vcpController = Get.find();
  final _basicDetailsFormKey = GlobalKey<FormState>();
  BasicDetails? basicDetails;
  DsaBasicDetailsRequest? bsaBasicDetailsRequest;
  final List<String> companyTypeList = [
    'Proprietorship',
    'Pvt ltd',
    'Partnership',
    'Individual',
  ];

  List<StateItem> _stateList = [];
  List<CityItem> _cityList = [];
  List<PinCodeItem> _pinCodeList = [];
  StateItem? _selectedState;
  CityItem? _selectedCity;
  PinCodeItem? _selectedPinCode;
  String? _stateCode;
  String? _cityCode;
  dynamic _pinCodeId;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  bool _isLoadingPinCodes = false;

  Future<void> _fetchStates() async {
    setState(() => _isLoadingStates = true);
    final states = await ApiClient().getStateList();
    if (mounted) {
      setState(() {
        _stateList = states;
        _isLoadingStates = false;
      });
      _matchPrefilledState();
    }
  }

  void _matchPrefilledState() {
    if (stateController.text.trim().isEmpty &&
        (_stateCode == null || _stateCode!.isEmpty)) {
      return;
    }
    try {
      final matched = _stateList.firstWhere(
        (s) =>
            (_stateCode != null &&
                _stateCode!.isNotEmpty &&
                s.cpProvince == _stateCode) ||
            s.cpProvinceName.trim().toLowerCase() ==
                stateController.text.trim().toLowerCase(),
      );
      _selectedState = matched;
      _stateCode = matched.cpProvince;
      final existingCity = cityController.text.trim();
      _fetchCities(matched.cpProvince,
          prefillCity: existingCity.isNotEmpty ? existingCity : null);
    } catch (_) {}
  }

  void _onStateSelected(StateItem state) {
    setState(() {
      _selectedState = state;
      _stateCode = state.cpProvince;
      stateController.text = state.cpProvinceName;
      _selectedCity = null;
      _cityCode = null;
      cityController.clear();
      _cityList = [];
      _selectedPinCode = null;
      _pinCodeId = null;
      pinCodeController.clear();
      _pinCodeList = [];
    });
    _fetchCities(state.cpProvince);
  }

  Future<void> _fetchCities(String stateCode, {String? prefillCity}) async {
    setState(() => _isLoadingCities = true);
    final cities = await ApiClient().getCitiesByState(stateCode);
    if (mounted) {
      setState(() {
        _cityList = cities;
        _isLoadingCities = false;
      });
      if ((prefillCity != null && prefillCity.isNotEmpty) ||
          (_cityCode != null && _cityCode!.isNotEmpty)) {
        _matchPrefilledCity(prefillCity ?? "");
      }
    }
  }

  void _matchPrefilledCity(String cityNameToMatch) {
    try {
      final matched = _cityList.firstWhere(
        (c) =>
            (_cityCode != null &&
                _cityCode!.isNotEmpty &&
                c.pcCity == _cityCode) ||
            c.pcCityName.trim().toLowerCase() ==
                cityNameToMatch.trim().toLowerCase(),
      );
      _selectedCity = matched;
      _cityCode = matched.pcCity;
      final existingPin = pinCodeController.text.trim();
      _fetchPinCodes(matched.pcCity,
          prefillPin: existingPin.isNotEmpty ? existingPin : null);
    } catch (_) {}
  }

  void _onCitySelected(CityItem city) {
    setState(() {
      _selectedCity = city;
      _cityCode = city.pcCity;
      cityController.text = city.pcCityName;
      _selectedPinCode = null;
      _pinCodeId = null;
      pinCodeController.clear();
      _pinCodeList = [];
    });
    _fetchPinCodes(city.pcCity);
  }

  Future<void> _fetchPinCodes(String cityCode, {String? prefillPin}) async {
    setState(() => _isLoadingPinCodes = true);
    final pinCodes = await ApiClient().getPinCodesByCity(cityCode);
    if (mounted) {
      setState(() {
        _pinCodeList = pinCodes;
        _isLoadingPinCodes = false;
      });
      if ((prefillPin != null && prefillPin.isNotEmpty) || _pinCodeId != null) {
        try {
          final matched = pinCodes.firstWhere(
            (p) =>
                (_pinCodeId != null &&
                    p.pincodeId?.toString() == _pinCodeId?.toString()) ||
                p.pincode.trim() == (prefillPin ?? "").trim(),
          );
          _selectedPinCode = matched;
          _pinCodeId = matched.pincodeId;
          pinCodeController.text = matched.pincode;
        } catch (_) {}
      }
    }
  }

  void _onPinCodeSelected(PinCodeItem pin) {
    setState(() {
      _selectedPinCode = pin;
      _pinCodeId = pin.pincodeId;
      pinCodeController.text = pin.pincode;
    });
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context, bool isAadhaar) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dobAsPan = pickedDate;

        String pan = DateFormat('dd-MM-yyyy').format(pickedDate);
        _dobPan = pan;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _applyBasicPrefillIfAny();
    _fetchStates();

    individualAddressController.addListener(() {
      // If checkbox is checked, automatically update office address
      if (isSameIndividualAddress) {
        setState(() {
          officeAddressController.text = individualAddressController.text;
        });
      }
    });
  }

  void _parseAndSetDOB(String? dobString) {
    if (dobString != null && dobString.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(dobString);
        setState(() {
          dobAsPan = parsedDate;
          _dobPan = DateFormat('dd-MM-yyyy').format(parsedDate);
        });
      } catch (e) {
        print('Error parsing DOB: $e');
        // Keep dobAsPan as null if parsing fails
      }
    }
  }

  String? _mapCompanyType(String? apiValue) {
    if (apiValue == null || apiValue == "") return null;
    switch (apiValue.toLowerCase()) {
      case 'partnership':
        return 'Partnership';
      case 'proprietorship':
        return 'Proprietorship';
      case 'pvt ltd':
        return 'Pvt ltd';
      case 'individual':
        return 'Individual';
      default:
        return apiValue; // return as-is if no match
    }
  }

  void _applyBasicPrefillIfAny() {
    final args = Get.arguments;

    if (args is Map && args["basicDetails"] is Map) {
      submittedId = args["id"];
      final isSentBack = args["isSentBack"];

      isSentBackValue = isSentBack ? true : false;
      final businessInfo = args["businessDetails"];
      businessDetails = businessInfo;
      documentDetails = args["documents"];
      isSameIndividualAddress = args["isSameIndividualAddress"] ?? false;
      bankDetails = args["bankDetails"];
      final m = Map<String, dynamic>.from(args["basicDetails"]);
      nameController.text = (m["name"] ?? "").toString();
      mobileNoController.text = (m["mobile"] ?? "").toString();
      emailController.text = (m["email"] ?? "").toString();
      companyRegNoController.text =
          (m["companyRegistrationNo"] ?? "").toString();
      designationController.text = (m["designation"] ?? "").toString();
      pinCodeController.text = (m["pincode"] ?? "").toString();
      cityController.text = (m["city"] ?? "").toString();
      districtController.text = (m["district"] ?? "").toString();
      stateController.text = (m["stateName"] ?? "").toString();
      _stateCode = m["stateCode"]?.toString();
      _cityCode = m["cityCode"]?.toString();
      _pinCodeId = m["pinCodeId"];
      individualAddressController.text = (m["address"] ?? "").toString();
      officeAddressController.text = (m["officeAddress"] ?? "").toString();
      telephoneController.text = (m["telephoneNumber"] ?? "").toString();
      remarkController.text = (m["remarks"] ?? "").toString();
      panNoController.text = (m["pan"] ?? "").toString();
      companyType = m["companyType"]?.toString();
      selectedGender = m["gender"]?.toString();
      fathersNameController.text = (m["fatherName"] ?? "").toString();
      educationQualificationController.text =
          (m["eduQualification"] ?? "").toString();
      agencyNameController.text = (m["agencyName"] ?? "").toString();
      businessNameController.text = (m["businessName"] ?? "").toString();
      // Map API company type to dropdown display value
      companyType = _mapCompanyType(m["companyType"]?.toString());

      selectedGender = m["gender"]?.toString();
      fathersNameController.text = (m["fatherName"] ?? "").toString();
      educationQualificationController.text =
          (m["eduQualification"] ?? "").toString();
      agencyNameController.text = (m["agencyName"] ?? "").toString();
      businessNameController.text = (m["businessName"] ?? "").toString();

      if (m["mobileStatus"] == "Validated" ||
          m["mobileStatus"] == "Y" ||
          isSentBackValue) {
        mobileValidation = "Validated";
      }

      // Check email status
      if (m["emailStatus"] == "Validated" ||
          m["emailStatus"] == "Y" ||
          isSentBackValue) {
        emailValidation = "Validated";
      }

      _parseAndSetDOB(m["dobAsperPAN"]?.toString());
    }
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
          key: _basicDetailsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Step 1
                  AnimatedStepCircle(
                    text: "1",
                    fillColor: Constant.mediumBlueColor,
                    borderColor: Colors.lightGreen,
                  ),
                  stepConnector(Colors.grey),

                  // Step 2
                  stepCircle(
                    text: "2",
                    fillColor: Colors.grey,
                    borderColor: Constant.mediumBlueColor,
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
                  stepCircle(
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
                text: 'Basic Details',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
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
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_note,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.onboardType,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              widget.name == null
                  ? BuildTextField(
                      hint: 'Name as per Pan',
                      label: 'Name as per Pan',
                      icon: Icons.person,
                      isMultiline: false,
                      controller: nameController,
                      onSaved: (String? value) {
                        setState(() {
                          nameController.text = value!;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        } else {
                          return null;
                        }
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.name!,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 9),
              widget.mobileNo == null
                  ? Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              enabled: !isSentBackValue,
                              controller: mobileNoController,
                              keyboardType: TextInputType.number,
                              maxLines: 1,
                              maxLength: 10,
                              decoration: InputDecoration(
                                hintText: 'Mobile Number',
                                hintStyle: TextStyle(color: Colors.grey[700]),
                                filled: true,
                                label: Text(
                                  'Mobile Number',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                fillColor: Colors.grey[200],
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.mobile_friendly,
                                    color: Colors.blueGrey),
                                counterText: "",
                              ),
                              onSaved: (String? value) {
                                setState(() {
                                  mobileNoController.text = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 5),
                          mobileValidation == "Validated"
                              ? SizedBox(
                                  width: 80,
                                  height: 55,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CustomText(
                                        text: 'Verified',
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
                                )
                              : InkWell(
                                  onTap: () {
                                    String mobileNo = widget.mobileNo ??
                                        mobileNoController.text;
                                    if (mobileNo.isNotEmpty &&
                                        mobileNoController.text.length == 10) {
                                      mobileOtpApi(
                                          mobileNo: mobileNoController.text);
                                    } else {
                                      // Get.snackbar("Failed",
                                      //     "Please enter your valid mobile no",
                                      //     backgroundColor: Colors.redAccent,
                                      //     colorText: Colors.white);
                                      GlobalSnackbar.showError(
                                          "Please enter your valid mobile no");
                                    }
                                  },
                                  child: SizedBox(
                                    width: 80,
                                    height: 55,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                ),
                        ],
                      ),
                    )
                  : Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mobile_friendly_rounded,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.mobileNo!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          mobileValidation == "Validated"
                              ? SizedBox(
                                  width: 80,
                                  height: 55,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CustomText(
                                        text: 'Verified',
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
                                )
                              : InkWell(
                                  onTap: () {
                                    if (widget.mobileNo!.isNotEmpty &&
                                        widget.mobileNo!.length == 10) {
                                      mobileOtpApi(mobileNo: widget.mobileNo!);
                                    } else {
                                      // Get.snackbar("Failed",
                                      //     "Please enter your valid mobile no",
                                      //     backgroundColor: Colors.redAccent,
                                      //     colorText: Colors.white);
                                      GlobalSnackbar.showError(
                                          "Please enter your valid mobile no");
                                    }
                                  },
                                  child: SizedBox(
                                    width: 80,
                                    height: 55,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                ),
                        ],
                      ),
                    ),
              if (mobileUpdate) ...[
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: 'OTP is sent to your mobile no',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => mobileUpdate = false);
                        mobileOtpController.clear();
                      },
                      icon: const ImageIcon(
                        AssetImage('assets/icons/close.png'),
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
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: mobileOtpController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter OTP...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (String? value) {
                      setState(() {
                        mobileOtpController.text = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (mobileOtp == mobileOtpController.text) {
                        setState(() {
                          mobileValidation = "Validated";
                          mobileOtpController.clear();
                          mobileUpdate = false;
                        });
                        // Get.snackbar(
                        //     "Success", "Mobile no is validated successfully",
                        //     backgroundColor: Colors.green,
                        //     colorText: Colors.white);
                        GlobalSnackbar.showSuccess(
                            "Mobile no is validated successfully");
                      } else {
                        // Get.snackbar("Failed", "OTP is not matching",
                        //     backgroundColor: Colors.redAccent,
                        //     colorText: Colors.white);
                        GlobalSnackbar.showError("OTP is not matching");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF116bb6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 15),
              widget.email == null
                  ? Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              enabled: !isSentBackValue,
                              controller: emailController,
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: 'Email ID',
                                hintStyle: TextStyle(color: Colors.grey[700]),
                                label: Text(
                                  'Email ID',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.email,
                                    color: Colors.blueGrey),
                              ),
                              onSaved: (String? value) {
                                setState(() {
                                  emailController.text = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 5),
                          emailValidation == "Validated"
                              ? SizedBox(
                                  width: 80,
                                  height: 55,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CustomText(
                                        text: 'Verified',
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
                                )
                              : InkWell(
                                  onTap: () {
                                    if (emailController.text.isNotEmpty) {
                                      if (emailRegex.hasMatch(
                                          emailController.text.trim())) {
                                        if (emailController.text
                                            .endsWith("@vistaarfinance.com")) {
                                          // Get.snackbar("Failed",
                                          //     "Email verification is not allowed for @vistaarfinance.com",
                                          //     backgroundColor: Colors.redAccent,
                                          //     colorText: Colors.white);
                                          GlobalSnackbar.showError(
                                              "Email verification is not allowed for @vistaarfinance.com");
                                        } else {
                                          emailOtpApi(
                                              email: emailController.text);
                                        }
                                      } else {
                                        GlobalSnackbar.showError(
                                            "Please Provide a valid email Id");
                                      }
                                    } else {
                                      GlobalSnackbar.showError(
                                          "Please enter your email Id");
                                    }
                                  },
                                  child: SizedBox(
                                    width: 80,
                                    height: 55,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                ),
                        ],
                      ),
                    )
                  : Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.email!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          emailValidation == "Validated"
                              ? SizedBox(
                                  width: 80,
                                  height: 55,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CustomText(
                                        text: 'Verified',
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
                                )
                              : InkWell(
                                  onTap: () {
                                    if (widget.email!.isNotEmpty) {
                                      if (emailRegex
                                          .hasMatch(widget.email!.trim())) {
                                        if (widget.email!
                                            .endsWith("@vistaarfinance.com")) {
                                          // Get.snackbar("Failed",
                                          //     "Email verification is not allowed for @vistaarfinance.com",
                                          //     backgroundColor: Colors.redAccent,
                                          //     colorText: Colors.white);
                                          GlobalSnackbar.showError(
                                              "Email verification is not allowed for @vistaarfinance.com");
                                        } else {
                                          emailOtpApi(email: widget.email!);
                                        }
                                      } else {
                                        // Get.snackbar("Failed",
                                        //     "Please Provide a valid email Id",
                                        //     backgroundColor: Colors.redAccent,
                                        //     colorText: Colors.white);
                                        GlobalSnackbar.showError(
                                            "Please Provide a valid email Id");
                                      }
                                    } else {
                                      // Get.snackbar("Failed",
                                      //     "Please enter your email Id",
                                      //     backgroundColor: Colors.redAccent,
                                      //     colorText: Colors.white);
                                      GlobalSnackbar.showError(
                                          "Please enter your email Id");
                                    }
                                  },
                                  child: SizedBox(
                                    width: 80,
                                    height: 55,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                ),
                        ],
                      ),
                    ),
              if (emailUpdate) ...[
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: 'OTP is sent to your email ID',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          emailUpdate = false;
                          emailOtpController.clear();
                        });
                      },
                      icon: const ImageIcon(
                        AssetImage('assets/icons/close.png'),
                        size: 20,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.grey.shade300,
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: emailOtpController,
                    decoration: InputDecoration(
                      hintText: 'Enter OTP...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (String? value) {
                      setState(() {
                        emailController.text = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (emailOtp == emailOtpController.text) {
                        setState(() {
                          emailValidation = "Validated";
                          emailOtpController.clear();
                          emailUpdate = false;
                        });
                        // Get.snackbar(
                        //     "Success", "Email is validated successfully",
                        //     backgroundColor: Colors.green,
                        //     colorText: Colors.white);
                        GlobalSnackbar.showSuccess(
                            "Email is validated successfully");
                      } else {
                        // Get.snackbar("Failed", "OTP is not matching",
                        //     backgroundColor: Colors.redAccent,
                        //     colorText: Colors.white);
                        GlobalSnackbar.showError("OTP is not matching");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF116bb6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 9),
              BuildTextField(
                isEnabled: !isSentBackValue,
                hint: 'Pan No',
                label: 'Pan No',
                icon: Icons.password_sharp,
                isMultiline: false,
                controller: panNoController,
                counterText: "",
                maxLength: 10,
                textCapitalization: TextCapitalization.characters,
                onSaved: (String? value) {
                  setState(() {
                    panNoController.text = value!;
                  });
                },
                validator: (value) {
                  String pattern =
                      r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$'; // PAN card format
                  RegExp regExp = RegExp(pattern);

                  if (value == null || value.isEmpty) {
                    return 'Required';
                  } else if (!regExp.hasMatch(value)) {
                    return 'Invalid PAN format (e.g., ABCDE1234F)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 9),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: _dobPan != null
                      ? Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                color: Colors.blueGrey),
                            const SizedBox(width: 10),
                            CustomText(text: _dobPan!, color: Colors.black87),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                color: Colors.blueGrey),
                            const SizedBox(width: 10),
                            CustomText(
                                text: 'DOB as per Pan',
                                color: Colors.grey.shade700),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 9),
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
                    value: companyType,
                    decoration: const InputDecoration(border: InputBorder.none),
                    hint: Row(
                      children: [
                        const Icon(
                          Icons.arrow_drop_down_circle_sharp,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 10),
                        Text('Company type',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.grey.shade200),
                    items: companyTypeList.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        companyType = newValue;
                        vcpController.companyType = newValue;
                      });
                    },
                  ),
                ),
              ),
              BuildTextField(
                hint: 'Company reg no',
                label: 'Company reg no',
                icon: Icons.app_registration_sharp,
                isMultiline: false,
                controller: companyRegNoController,
                onSaved: (String? value) {
                  setState(() {
                    companyRegNoController.text = value!;
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
              BuildTextField(
                hint: 'Designation',
                label: 'Designation',
                icon: Icons.email,
                isMultiline: false,
                controller: designationController,
                onSaved: (String? value) {
                  setState(() {
                    designationController.text = value!;
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
              SearchableAutocompleteField<StateItem>(
                label: 'State',
                hint: 'Select State',
                icon: Icons.pin_drop,
                controller: stateController,
                items: _stateList,
                isLoading: _isLoadingStates,
                itemLabel: (item) => item.cpProvinceName,
                onSelected: _onStateSelected,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              SearchableAutocompleteField<CityItem>(
                label: 'City',
                hint: 'Select City',
                icon: Icons.add_business,
                controller: cityController,
                items: _cityList,
                isEnabled:
                    _selectedState != null || stateController.text.isNotEmpty,
                isLoading: _isLoadingCities,
                disabledMessage: 'Please select State first',
                itemLabel: (item) => item.pcCityName,
                onSelected: _onCitySelected,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              SearchableAutocompleteField<PinCodeItem>(
                label: 'Pin code',
                hint: 'Select Pin code',
                icon: Icons.map_sharp,
                controller: pinCodeController,
                items: _pinCodeList,
                isEnabled:
                    _selectedCity != null || cityController.text.isNotEmpty,
                isLoading: _isLoadingPinCodes,
                disabledMessage: 'Please select City first',
                itemLabel: (item) => item.pincode,
                onSelected: _onPinCodeSelected,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              BuildTextField(
                hint: 'District',
                label: 'District',
                icon: Icons.real_estate_agent,
                isMultiline: false,
                controller: districtController,
                onSaved: (String? value) {
                  setState(() {
                    districtController.text = value!;
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
                hint: 'Individual Address',
                label: 'Individual Address',
                icon: Icons.business,
                isMultiline: true,
                // padding: 50,
                controller: individualAddressController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onSaved: (String? value) {
                  setState(() {
                    individualAddressController.text = value!;
                    if (isSameIndividualAddress) {
                      officeAddressController.text = value;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final addressRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
                  if (!addressRegex.hasMatch(value)) {
                    return 'Special characters are not allowed';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                value: isSameIndividualAddress,
                onChanged: (bool? value) {
                  setState(() {
                    isSameIndividualAddress = value ?? false;

                    // If checked, copy individual address to office address
                    if (isSameIndividualAddress) {
                      officeAddressController.text =
                          individualAddressController.text;
                    } else {
                      // If unchecked, clear office address
                      officeAddressController.text = '';
                    }
                  });
                },
                title: const Text(
                  'Office address same as individual address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor:
                    Constant.mediumBlueColor, // Use your app's primary color
              ),
              BuildTextField(
                hint: 'Office Address',
                label: 'Office Address',
                icon: Icons.business,
                isMultiline: true,
                // padding: 50,
                controller: officeAddressController,
                isEnabled: !isSameIndividualAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onSaved: (String? value) {
                  setState(() {
                    officeAddressController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final addressRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
                  if (!addressRegex.hasMatch(value)) {
                    return 'Special characters are not allowed';
                  }
                  return null;
                },
              ),
              BuildTextField(
                hint: 'Telephone Number',
                label: 'Telephone Number',
                icon: Icons.phone,
                inputType: TextInputType.number,
                isMultiline: false,
                counterText: "",
                maxLength: 10,
                controller: telephoneController,
                onSaved: (String? value) {
                  setState(() {
                    telephoneController.text = value!;
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
                label: 'Remarks',
                icon: Icons.edit,
                isMultiline: false,
                controller: remarkController,
                onSaved: (String? value) {
                  setState(() {
                    remarkController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 200,
                  child: CustomButton(
                    text: 'Save & Next',
                    onPressed: () {
                      var form = _basicDetailsFormKey.currentState;
                      if (form!.validate()) {
                        final addressRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
                        if (!addressRegex
                            .hasMatch(individualAddressController.text)) {
                          GlobalSnackbar.showError(
                              "Individual Address contains invalid special characters");
                          return;
                        }
                        if (!isSameIndividualAddress &&
                            !addressRegex
                                .hasMatch(officeAddressController.text)) {
                          GlobalSnackbar.showError(
                              "Office Address contains invalid special characters");
                          return;
                        }
                        if (emailValidation == 'Validated' &&
                            mobileValidation == 'Validated') {
                          saveBasicDetails();
                        } else {
                          // Get.snackbar("Failed",
                          //     'Please validate your email Id and mobile no',
                          //     backgroundColor: Colors.redAccent,
                          //     colorText: Colors.white);
                          GlobalSnackbar.showError(
                              "Please validate your email Id and mobile no");
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

  void mobileOtpApi({required String mobileNo}) async {
    EmailOtpRes? response =
        await ApiClient().mobileOtpSend(json.encode(mobileNo));
    if (response != null) {
      if (response.success!) {
        setState(() {
          mobileUpdate = true;
          mobileOtp = response.otp;
        });
        log('mobileOtp - $mobileOtp');
      } else {
        // Get.snackbar("Failed", response.error,
        //     backgroundColor: Colors.redAccent, colorText: Colors.white);
        GlobalSnackbar.showError(response.error ?? "Failed to send mobile OTP");
      }
    } else {
      // Get.snackbar("Failed", "Something went wrong",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }

  void emailOtpApi({required String email}) async {
    EmailOtpRes? response = await ApiClient().emailOtpSend(json.encode(email));
    if (response != null) {
      if (response.success!) {
        setState(() {
          emailUpdate = true;
          emailOtp = response.otp;
        });
        log('emailOtp - $emailOtp');
      } else {
        // Get.snackbar("Failed", response.error,
        //     backgroundColor: Colors.redAccent, colorText: Colors.white);
        GlobalSnackbar.showError(response.error ?? "Failed to send email OTP");
      }
    } else {
      // Get.snackbar("Failed", "Something went wrong",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Something went wrong");
    }
  }

  void saveBasicDetails() async {
    // DateTime now = dobAsPan!.toUtc();
    // log('dobAsPan - $dobAsPan');
    // log('now - $now');
    // String isoString = now.toIso8601String();
    // log('isoString - ${dobAsPan?.toIso8601String()}');

    // Keep local date without timezone shift
    DateTime localDate =
        DateTime(dobAsPan!.year, dobAsPan!.month, dobAsPan!.day);
    String isoString =
        localDate.toIso8601String(); // e.g., 2000-01-02T00:00:00.000

    log('dobAsPan - $dobAsPan');
    log('isoString - $isoString');

    Map<String, dynamic> body = {
      "queryType": isSentBackValue ? "update" : "add",
      "pan": panNoController.text,
      "data": {
        "BranchCode": widget.branchCode,
        "name": widget.name ?? nameController.text,
        "mobile": widget.mobileNo ?? mobileNoController.text,
        "mobileStatus": mobileValidation,
        "email": widget.email ?? emailController.text,
        "emailStatus": emailValidation,
        "vcpType": widget.onboardType,
        "companyType": companyType,
        "companyRegistrationNo": companyRegNoController.text,
        "designation": designationController.text,
        "pincode": pinCodeController.text,
        "city": cityController.text,
        "district": districtController.text,
        "stateName": stateController.text,
        "stateCode": _selectedState?.cpProvince ?? _stateCode ?? "",
        "cityCode": _selectedCity?.pcCity ?? _cityCode ?? "",
        "pinCodeId": _selectedPinCode?.pincodeId ?? _pinCodeId ?? "",
        "address": individualAddressController.text,
        "isSameIndividualAddress": isSameIndividualAddress,
        "officeAddress": officeAddressController.text,
        "telephoneNumber": telephoneController.text,
        "remarks": remarkController.text,
        "pan": panNoController.text,
        "dobAsperPAN": isoString.toString(),
      },
      "updatedby": widget.employeeId,
    };

    log('basic details - ${json.encode(body)}');
    Map<String, dynamic>? response =
        await ApiClient().dsaBasicDetApi(json.encode(body));
    if (response != null) {
      if (response["success"] == true) {
        // Get.snackbar("Success", "Basic details are saved successfully",
        //     backgroundColor: Colors.green, colorText: Colors.white);
        GlobalSnackbar.showSuccess("Basic details are saved successfully");

        String safeCompanyType =
            companyType ?? "Proprietorship"; // Default value
        String safeId =
            response["id"]?.toString() ?? ""; // Ensure id is not null

        Get.to(
            () => BusinessApplication(
                  id: isSentBackValue ? submittedId.toString() : safeId,
                  employeeId: widget.employeeId,
                  companyType: safeCompanyType,
                  onboardType: widget.onboardType,
                  isSentBack: isSentBackValue,
                ),
            arguments: {
              "id": submittedId,
              "isSentBack": isSentBackValue,
              "businessDetails": businessDetails,
              "documents": documentDetails,
              "isSameIndividualAddress": isSameIndividualAddress,
              "bankDetails": bankDetails
            });
      } else {
        // Get.snackbar("Failed", response["error"],
        //     backgroundColor: Colors.redAccent, colorText: Colors.white);
        GlobalSnackbar.showError(response["error"] ?? "Failed to save details");
      }
    }
  }
}
