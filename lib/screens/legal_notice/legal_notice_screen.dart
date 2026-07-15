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
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
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
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:re_kyc_mobile_app/models/aggregator_list_res.dart';
import 'package:re_kyc_mobile_app/models/legal_options.dart';
import 'package:re_kyc_mobile_app/models/notice_type_option.dart';
import 'package:re_kyc_mobile_app/models/loan_details_res.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:re_kyc_mobile_app/models/uploaded_notice_res.dart';
import 'package:re_kyc_mobile_app/models/download_notice_res.dart';
import '../../models/download_legal_notice_file.dart';
import '../../models/foreclosure_details_response.dart';
import '../../utils/helper.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

final MediaStore mediaStore = MediaStore();

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final upper = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upper,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

class LegalNoticeScreen extends StatefulWidget {
  const LegalNoticeScreen(
      {super.key, required this.employeeId, required this.branchCode});

  final String employeeId;
  final String branchCode;

  @override
  State<LegalNoticeScreen> createState() => _LegalNoticeScreenState();
}

class _LegalNoticeScreenState extends State<LegalNoticeScreen> {
  TextEditingController searchController = TextEditingController();

  int currentIndex = -1;
  List<Datum>? data = [];
  int? selectedIndex;
  TextEditingController remarkController = TextEditingController();

  String customerName = "VIGNESH M";
  LoanDetailsResponse? loanDetailsResponse = null;
  bool isLoading = false;
  List<LegalOption> downloadOptions = [];
  List<LegalOption> uploadOptions = [];
  LegalOption? selectedDownLoadLegalDocumentValue;
  LegalOption? selectedUploadLegalDocumentValue;
  //PlatformFile? selectedFile;
  String? base64File;
  String? fileName;
  String? fileType; // image or pdf
  String uploadOtherDocument = "";
  //bool uploadedOtherDocument = false;
  static const platform = MethodChannel('com.example.app/media_scanner');

  /// --- Notice Type API driven dropdowns ---
  List<NoticeTypeOption> noticeTypeOptions = [];
  String? selectedDownloadNoticeType;
  String? selectedDownloadSubType;
  String? selectedUploadNoticeType;
  String? selectedUploadSubType;

  List<UploadedNotice> uploadedNotices = [];

  @override
  void initState() {
    super.initState();
    // searchController.text = "0001SBML0469";
    _fetchNoticeTypes();
  }

  Future<void> _fetchNoticeTypes() async {
    try {
      final result = await ApiClient().getNoticeTypesOptions();
      print("Result");
      if (result != null && mounted) {
        setState(() {
          noticeTypeOptions = result;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notice types: $e');
    }
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
              text: 'Legal Notice',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: () async {
            // callAggregatorsList();
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
                    style: const TextStyle(color: Colors.black),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        callProfileApi(value.trim().toUpperCase());
                      }
                    },
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: 'Search LAN No...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Constant.mediumBlueColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Constant.lightBlueColor,
                      ),
                    )
                  : loanDetailsResponse != null
                      ? Column(
                          children: [
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              // color: Colors.blue.shade50,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name Section
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor:
                                              Constant.lightBlueColor,
                                          radius: 25,
                                          child: Icon(
                                            Icons.person,
                                            size: 32,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              loanDetailsResponse?.fullName ??
                                                  "",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            // const SizedBox(height: 3),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      height: 32,
                                      thickness: 1,
                                      color: Colors.grey,
                                    ),
                                    _buildProfileInfoRow(
                                        "Branch Code",
                                        loanDetailsResponse
                                                ?.branch?.branchCode ??
                                            ""),
                                    _buildProfileInfoRow(
                                        "Branch Name",
                                        loanDetailsResponse
                                                ?.branch?.branchName ??
                                            ""),
                                    _buildProfileInfoRow(
                                        "Region",
                                        loanDetailsResponse?.branch?.region ??
                                            ""),
                                    _buildProfileInfoRow(
                                        "Zone",
                                        loanDetailsResponse?.branch?.zone ??
                                            ""),
                                    _buildProfileInfoRow(
                                        "Mega Zone",
                                        loanDetailsResponse?.branch?.megaZone ??
                                            ""),
                                    _buildProfileInfoRow(
                                        "POS",
                                        loanDetailsResponse?.pos.toString() ??
                                            ""),
                                  ],
                                ),
                              ),
                            ),
                            if (uploadOptions.isNotEmpty)
                              _buildLegalFileWidget(uploadOptions, false),
                            if (uploadedNotices.isNotEmpty)
                              _buildLegalFileWidget(downloadOptions, true),
                          ],
                        )
                      : const Center(
                          child: Text(
                            'No Loan Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Notice Type dropdown using API data
  Widget _buildNoticeTypeDropDown(bool canDownLoad) {
    String? selectedValue =
        canDownLoad ? selectedDownloadNoticeType : selectedUploadNoticeType;

    // Filter available notice types for download
    List<NoticeTypeOption> filteredOptions = noticeTypeOptions;
    if (canDownLoad) {
      final availableTypes = uploadedNotices.map((n) => n.noticeType).toSet();
      filteredOptions = noticeTypeOptions
          .where((opt) => availableTypes.contains(opt.noticeType))
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Notice Type',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        value: selectedValue,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        items: filteredOptions.map((NoticeTypeOption option) {
          return DropdownMenuItem<String>(
            value: option.noticeType,
            child: Text(option.noticeType),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            if (canDownLoad) {
              selectedDownloadNoticeType = newValue;
              selectedDownloadSubType = null; // reset sub-type
              selectedDownLoadLegalDocumentValue = null;
            } else {
              selectedUploadNoticeType = newValue;
              selectedUploadSubType = null; // reset sub-type
              selectedUploadLegalDocumentValue = null;
              clearFile();
            }
          });
        },
      ),
    );
  }

  /// Builds the Sub-Type dropdown based on the selected Notice Type
  Widget _buildSubTypeDropDown(bool canDownLoad) {
    String? selectedNoticeType =
        canDownLoad ? selectedDownloadNoticeType : selectedUploadNoticeType;
    String? selectedSubType =
        canDownLoad ? selectedDownloadSubType : selectedUploadSubType;

    // Find sub-types for the selected notice type
    List<String> subTypes = [];
    if (selectedNoticeType != null) {
      if (canDownLoad) {
        // For download, only show sub-types that have been uploaded
        subTypes = uploadedNotices
            .where((n) => n.noticeType == selectedNoticeType)
            .map((n) => n.subType)
            .toSet()
            .toList();
      } else {
        // For upload, show all available sub-types from the API
        final match = noticeTypeOptions.firstWhereOrNull(
          (opt) => opt.noticeType == selectedNoticeType,
        );
        if (match != null) {
          subTypes = match.subTypes;
        }
      }
    }

    if (subTypes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Sub Type',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        value: selectedSubType,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        items: subTypes.map((String subType) {
          return DropdownMenuItem<String>(
            value: subType,
            child: Text(subType),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            if (canDownLoad) {
              selectedDownloadSubType = newValue;
            } else {
              selectedUploadSubType = newValue;
              clearFile();
            }
          });
        },
      ),
    );
  }

  /// Keeps the old LegalOption-based dropdown (used for download file selection)
  Widget _buildDropDownWidget(List<LegalOption> options, bool canDownLoad) {
    LegalOption? selectedValue = canDownLoad
        ? selectedDownLoadLegalDocumentValue
        : selectedUploadLegalDocumentValue;

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: DropdownButtonFormField<LegalOption>(
        decoration: InputDecoration(
          labelText: 'Select Notice Type',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        value: selectedValue,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        items: options.map((LegalOption option) {
          return DropdownMenuItem<LegalOption>(
            value: option,
            child: Text(
              option.value == "Y" ? '${option.label} (uploaded)' : option.label,
            ),
          );
        }).toList(),
        onChanged: (LegalOption? newValue) {
          setState(() {
            if (canDownLoad) {
              selectedDownLoadLegalDocumentValue = newValue;
            } else {
              selectedUploadLegalDocumentValue = newValue;
              clearFile();
            }
          });
        },
      ),
    );
  }

  Widget _buildLegalFileWidget(List<LegalOption> options, bool canDownLoad) {
    // Determine if a notice type + sub-type are selected
    bool hasNoticeTypeSelected = canDownLoad
        ? selectedDownloadNoticeType != null
        : selectedUploadNoticeType != null;
    bool hasSubTypeSelected = canDownLoad
        ? selectedDownloadSubType != null
        : selectedUploadSubType != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canDownLoad ? " Download Notice:-" : "  Upload Notice:-",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                // Notice Type dropdown (from API)
                _buildNoticeTypeDropDown(canDownLoad),
                // Sub-Type dropdown (shown when notice type is selected)
                if (hasNoticeTypeSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildSubTypeDropDown(canDownLoad),
                  ),
                // Show actions directly after sub-type selection
                if (hasSubTypeSelected)
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                if (hasSubTypeSelected)
                  canDownLoad
                      ? InkWell(
                          child: _buildNoticeDownloadOption(),
                          onTap: () {
                            downloadDocument();
                          },
                        )
                      : _buildNoticeUploadOption(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeDownloadOption() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.download,
          size: 32,
          color: Constant.lightBlueColor,
        ),
        Text(
          "Download",
          style: TextStyle(
            color: Constant.lightBlueColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeUploadOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Choose File
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text("Choose File"),
              ),
              const SizedBox(height: 8),
              Text(
                fileName ?? "  No file chosen",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // Right: Upload
        ElevatedButton(
          onPressed: uploadFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: const Text("Upload"),
        ),
      ],
    );
  }

  void uploadFile() {
    if (base64File == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected to upload")),
      );
      return;
    }

    callUploadNoticeApi();
  }

  // Future<void> pickFile() async {
  //   /* FilePickerResult? result = await FilePicker.platform.pickFiles();
  //
  //   if (result != null && result.files.isNotEmpty) {
  //     PlatformFile file = result.files.first;
  //
  //     html.File actualFile = html.File(file.path!);
  //     List<int> fileBytes = await actualFile.readAsBytes();
  //     String base64Str = base64Encode(fileBytes);
  //
  //     setState(() {
  //       selectedFile = file;
  //       fileName = file.name;
  //       base64File = base64Str;
  //     });
  //   }*/
  //   CustomsHelper.cameraPermissionAlert(() async {
  //     String camera = await CustomsHelper().getCamera();
  //     setState(() {
  //       uploadOtherDocument = camera;
  //       if (uploadOtherDocument != '') {
  //         storeFile();
  //       }
  //       Get.back();
  //     });
  //   }, () async {
  //     String gallery = await CustomsHelper().getGallery();
  //     setState(() {
  //       uploadOtherDocument = gallery;
  //       if (uploadOtherDocument != '') {
  //         storeFile();
  //       }
  //       Get.back();
  //     });
  //   });
  // }

  Future<void> pickFile() async {
    // Show file type selection dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Select File Type'),
        content: const Text('Choose the type of file you want to upload'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close 'Select File Type' dialog
              _pickImageFile();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image, color: Colors.blue),
                SizedBox(width: 8),
                Text('Image'),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close 'Select File Type' dialog
              _pickDocumentFile();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red),
                SizedBox(width: 8),
                Text('PDF Document'),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Pick image files (existing functionality)
  Future<void> _pickImageFile() async {
    CustomsHelper.cameraPermissionAlert(() async {
      String camera = await CustomsHelper().getCamera();
      if (camera != '') {
        setState(() {
          uploadOtherDocument = camera;
          fileType = getFileNameExtension(camera).replaceAll('.', '');
        });
        storeFile();
      }
      if (mounted) Navigator.of(context).pop(); // Close permission dialog
    }, () async {
      String gallery = await CustomsHelper().getGalleryFile();
      if (gallery != '') {
        setState(() {
          uploadOtherDocument = gallery;
          fileType = getFileNameExtension(gallery).replaceAll('.', '');
        });
        storeFile();
      }
      if (mounted) Navigator.of(context).pop(); // Close permission dialog
    });
  }

// Pick PDF files (new functionality)
  Future<void> _pickDocumentFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        setState(() {
          uploadOtherDocument = file.path!;
          fileName = file.name;
          fileType = getFileNameExtension(file.name).replaceAll('.', '');
          base64File = null; // Will be set in storeFile()
        });

        // Close any open selection dialogs (using native Navigator for stability)
        if (mounted) {
          // If we came from pickFile dialog, we have already popped.
          // But if Get.dialog was used and somehow still there, we pop standard navigation.
        }

        if (uploadOtherDocument != '') {
          storeFile();
        }
      }
    } catch (e) {
      print("Error picking PDF file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to pick PDF file"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // storeFile() async{
  //   // uploadedOtherDocument = true;
  //   //selectedFile =
  //
  //   fileName = getLastSegment(uploadOtherDocument as String?);
  //   base64File = await CustomsHelper().fileToBase64(uploadOtherDocument);
  // }

  storeFile() async {
    try {
      if (uploadOtherDocument.isNotEmpty) {
        fileName = getLastSegment(uploadOtherDocument);
        base64File = await CustomsHelper().fileToBase64(uploadOtherDocument);

        // Show success message using ScaffoldMessenger for stability
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("File selected: $fileName"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print("Error storing file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to process file"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String getLastSegment(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    List<String> parts = input.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }

  clearFile() {
    setState(() {
      // selectedFile = null;
      fileName = null;
      base64File = null;
    });
  }

  Widget _buildProfileInfoRow(String label, String data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2, // Adjust this to control label width
            child: Text(
              "$label:",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 3, // Adjust this to control value width
            child: Text(
              data,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  void callProfileApi(String loanNumber) async {
    setState(() {
      isLoading = true;
    });

    try {
      print("Testing");
      // Call both APIs
      final profileResponse = await ApiClient().getLanNoticeDetails(loanNumber);
      final foreClosureResponse =
          await ApiClient().getForeClosureDetails(loanNumber);
      final noticesResponse = await ApiClient().getUploadedNotices(loanNumber);

      setState(() {
        isLoading = false;
      });

      if (profileResponse != null) {
        if (profileResponse.fullName != null) {
          setState(() {
            _fillLegalOptionsData(profileResponse.legal);
            loanDetailsResponse = LoanDetailsResponse(
              lan: profileResponse.lan,
              fullName: profileResponse.fullName,
              branch: profileResponse.branch,
              pos: foreClosureResponse?.pos ?? 0,
              legal: profileResponse.legal,
              custId: profileResponse.custId,
              dpd: profileResponse.dpd,
              totalOutstanding: foreClosureResponse?.totalOutstanding ?? "",
              principalOutstanding: profileResponse.principalOutstanding,
              mobile: profileResponse.mobile,
              alternateMobile: profileResponse.alternateMobile,
              propertyAddress: profileResponse.propertyAddress,
              residentialAddress: profileResponse.residentialAddress,
            );

            // Handle uploaded notices
            if (noticesResponse != null && noticesResponse.success) {
              uploadedNotices = noticesResponse.data ?? [];
              // Sort by date descending to easily pick the latest
              uploadedNotices.sort((a, b) {
                if (a.uploadedAt == null) return 1;
                if (b.uploadedAt == null) return -1;
                return b.uploadedAt!.compareTo(a.uploadedAt!);
              });
            } else {
              uploadedNotices = [];
            }
          });
        } else {
          // Get.snackbar("Failed", "No Loan Details Found",
          //     backgroundColor: Colors.redAccent, colorText: Colors.white);
          GlobalSnackbar.showError("No Loan Details Found");
        }
      } else {
        // Get.snackbar("Failed", 'Something went wrong',
        //     duration: const Duration(seconds: 3),
        //     backgroundColor: Colors.redAccent,
        //     colorText: Colors.white);
        GlobalSnackbar.showError("Something went wrong");
      }
    } catch (e) {
      debugPrint("Error in callProfileApi: $e");
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Error", 'Something went wrong while fetching details',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  String getFileNameExtension(String filename) {
    String extension = filename.contains('.')
        ? '.${filename.split('.').last.toLowerCase()}'
        : '.pdf';
    return extension;
  }

  /// Builds a unique, backend-safe file name to avoid overwriting older uploads.
  /// Example: LAN_Sec138_20260309_112523_314.pdf
  String _uniqueServerFileName({
    required String lan,
    required String key,
    required String originalName,
  }) {
    final ext =
        getFileNameExtension(originalName); // you already have this helper
    final now = DateTime.now();
    // yyyyMMdd_HHmmss_SSS (no colon/dot to keep it FS-safe)
    final ts =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}_'
        '${now.millisecond.toString().padLeft(3, '0')}';
    return '${lan}_${key}_$ts$ext';
  }

  void callUploadNoticeApi() async {
    setState(() {
      isLoading = true;
    });

    if (selectedUploadNoticeType == null || selectedUploadSubType == null) {
      // Get.snackbar("Required", "Please select notice type and sub type",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Please select notice type and sub type");
      setState(() => isLoading = false);
      return;
    }
    if (loanDetailsResponse == null ||
        (loanDetailsResponse?.lan ?? '').isEmpty) {
      // Get.snackbar("Required", "Please load a valid LAN before uploading",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Please load a valid LAN before uploading");
      setState(() => isLoading = false);
      return;
    }
    if (base64File == null) {
      // Get.snackbar("Required", "Please choose a file to upload",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Please choose a file to upload");
      setState(() => isLoading = false);
      return;
    }

    final postData = {
      "lan": loanDetailsResponse?.lan.toString() ?? "",
      "customerName": customerName.toString() ?? "",
      "branchCode": loanDetailsResponse?.branch?.branchCode.toString() ?? "",
      "branchName": loanDetailsResponse?.branch?.branchName.toString() ?? "",
      "region": loanDetailsResponse?.branch?.region.toString() ?? "",
      "zone": loanDetailsResponse?.branch?.zone.toString() ?? "",
      "megaZone": loanDetailsResponse?.branch?.megaZone.toString() ?? "",
      "pos": loanDetailsResponse?.pos?.toString() ?? "",
      "noticeType": selectedUploadNoticeType.toString() ?? "",
      "subType": selectedUploadSubType.toString() ?? "0000",
      "fileType": fileType ?? "",
      "source": "Mobile",
      "base64": base64File,
      "uploadedBy": widget.employeeId.toString() ?? ""
    };

    final Map<String, dynamic>? response =
        await ApiClient().uploadLegalNotice(json.encode(postData));

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Document Uploaded Successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Optional: clear selection for the next upload
        clearFile();
        // Reload loan data; keep upload dropdown intact
        callProfileApi(searchController.text.toString().trim().toUpperCase());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Upload failed'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong during upload"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // void callUploadNoticeApi() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   // debugPrint("Selected Upload Document: ${selectedUploadLegalDocumentValue?.label}");
  //   // debugPrint("Selected Upload Document Key: ${selectedUploadLegalDocumentValue?.key}");
  //
  //   var postData = {
  //     "landtls": {
  //       "lan": loanDetailsResponse?.lan ?? "",
  //       "fullName": loanDetailsResponse?.fullName ?? "",
  //       "branch": {
  //         "branchCode": loanDetailsResponse?.branch?.branchCode ?? "",
  //         "branchName": loanDetailsResponse?.branch?.branchName ?? "",
  //         "region": loanDetailsResponse?.branch?.region ?? "",
  //         "zone": loanDetailsResponse?.branch?.zone ?? "",
  //         "megaZone": loanDetailsResponse?.branch?.megaZone ?? ""
  //       },
  //       "pos": loanDetailsResponse?.pos ?? 0000
  //     },
  //     "filedtls": {
  //       "category": selectedUploadLegalDocumentValue?.key ?? "",
  //       "fileName": "${loanDetailsResponse?.lan}_${selectedUploadLegalDocumentValue?.key}${getFileNameExtension(fileName ?? "")}",
  //       "base64": base64File
  //     },
  //     "userId": widget.employeeId
  //   };
  //
  //   Map<String, dynamic>? response =
  //   await ApiClient().uploadLegalNotice(json.encode(postData));
  //
  //   setState(() {
  //     isLoading = false;
  //   });
  //   if (response != null) {
  //     if (response['success']) {
  //       Get.snackbar("Success", "Document Uploaded",
  //           backgroundColor: Colors.green, colorText: Colors.white);
  //         callProfileApi(searchController.text.toString().trim().toUpperCase());
  //     } else {
  //       Get.snackbar("Failed", response['error'],
  //           duration: const Duration(seconds: 3),
  //           backgroundColor: Colors.redAccent,
  //           colorText: Colors.white);
  //     }
  //   } else {
  //     Get.snackbar("Failed", 'Something went wrong',
  //         duration: const Duration(seconds: 3),
  //         backgroundColor: Colors.redAccent,
  //         colorText: Colors.white);
  //   }
  // }
  void downloadDocument() async {
    if (selectedDownloadNoticeType == null || selectedDownloadSubType == null) {
      // Get.snackbar("Required", "Please select notice type and sub type",
      //     backgroundColor: Colors.redAccent, colorText: Colors.white);
      GlobalSnackbar.showError("Please select notice type and sub type");
      return;
    }

    // Find the latest notice for the selected type and subtype to get its details
    final latestNotice = uploadedNotices.firstWhereOrNull(
      (n) =>
          n.noticeType == selectedDownloadNoticeType &&
          n.subType == selectedDownloadSubType,
    );

    if (latestNotice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No file configuration found for this notice type"),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Use the new API to download the file
      final postData = {
        "lan": latestNotice.lan,
        "noticeType": latestNotice.noticeType,
        "subType": latestNotice.subType
      };

      final response =
          await ApiClient().postDownloadNotice(json.encode(postData));

      print("Res file : ${response}");
      if (response != null &&
          response.success &&
          response.data?.file?.base64 != null) {
        await convertBase64ToDocument(
          response.data!.file!.base64!,
          response.data!.file!.fileName ??
              "${latestNotice.lan}_${latestNotice.noticeType}_${latestNotice.subType}.pdf",
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?.message ?? 'Failed to download file'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error in downloadDocument: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong while downloading file"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> askStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      // print("✅ Storage permission granted.");
      downloadDocument();
      return;
    }

    if (status.isDenied) {
      // Ask again only once, then check if permanently denied
      status = await Permission.storage.request();

      if (status.isGranted) {
        downloadDocument();
        return;
      } else if (status.isPermanentlyDenied) {
        // Get.snackbar("Error", 'Storage permission permanently denied. Please enable it from settings.',
        //     duration: const Duration(seconds: 4),
        //     backgroundColor: Colors.redAccent,
        //     colorText: Colors.white);
        GlobalSnackbar.showError(
            "Storage permission permanently denied. Please enable it from settings.");
        await openAppSettings();
        return;
      }
      if (!await Permission.manageExternalStorage.isGranted) {
        await Permission.manageExternalStorage.request();
      }
      // Get.snackbar("Error", 'Storage permission denied.',
      //     duration: const Duration(seconds: 3),
      //     backgroundColor: Colors.redAccent,
      //     colorText: Colors.white);
      GlobalSnackbar.showError("Storage permission denied.");
    }

    if (status.isPermanentlyDenied) {
      // Get.snackbar("Error", 'Storage permission permanently denied. Please enable it from settings.',
      //     duration: const Duration(seconds: 4),
      //     backgroundColor: Colors.redAccent,
      //     colorText: Colors.white);
      GlobalSnackbar.showError(
          "Storage permission permanently denied. Please enable it from settings.");
      await openAppSettings();
    }
  }

  Future<void> _scanFile(String path) async {
    try {
      await platform.invokeMethod('scanFile', {'path': path});
    } on PlatformException catch (e) {
      print("Failed to scan file: ${e.message}");
    }
  }

  // Future<File?> convertBase64ToDocument(String base64String, String fileName) async {
  //   setState(() => isLoading = true);
  //
  //   try {
  //     // Get external storage directory
  //     Directory? externalDir = await getExternalStorageDirectory();
  //     if (externalDir == null) throw Exception("External storage not available");
  //
  //     // Build a custom path like /storage/emulated/0/vcp
  //     final rootPath = externalDir.path.split("Android").first; // to get root of shared storage
  //     final vcpFolder = Directory('$rootPath/Download/Legal Notice');
  //
  //     // Create the folder if it doesn't exist
  //     if (!(await vcpFolder.exists())) {
  //       await vcpFolder.create(recursive: true);
  //     }
  //
  //     // Create the file
  //     final file = File('${vcpFolder.path}/$fileName');
  //     final bytes = base64Decode(base64String);
  //     await file.writeAsBytes(bytes);
  //
  //     // print("File saved at: ${file.path}");
  //     await _scanFile(file.path);
  //
  //     Get.snackbar("Success", "Document saved!",
  //         backgroundColor: Colors.green, colorText: Colors.white);
  //
  //     return file;
  //   } catch (e) {
  //     print("Error writing file: $e");
  //     Get.snackbar("Failed", 'Error while saving document',
  //         duration: const Duration(seconds: 3),
  //         backgroundColor: Colors.redAccent,
  //         colorText: Colors.white);
  //     return null;
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  Future<void> convertBase64ToDocument(
      String base64String, String fileName) async {
    setState(() => isLoading = true);

    try {
      final bytes = base64Decode(base64String);
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$fileName';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(bytes, flush: true);

      setState(() => isLoading = false);

      // Show action sheet with status handling
      Get.bottomSheet(
        StatefulBuilder(
          builder: (context, setSheetState) {
            bool isProcessing = false;
            String? statusMessage;
            bool isSuccess = false;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 24),

                  // Conditional UI based on status
                  if (statusMessage != null) ...[
                    Icon(
                      isSuccess
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: isSuccess ? Colors.green : Colors.redAccent,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      text: statusMessage!,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.insert_drive_file_outlined,
                          color: Color(0xFF116bb6), size: 40),
                    ),
                    const SizedBox(height: 16),
                    const CustomText(
                        text: "Document Prepared",
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),
                    CustomText(
                        text: "Where should we save the notice?",
                        fontSize: 14,
                        color: Colors.grey.shade600),
                    const SizedBox(height: 24),
                    _buildModernActionTile(
                      icon: Icons.download_done_rounded,
                      title: "Quick Save to Downloads",
                      subtitle: "System /Downloads folder",
                      color: const Color(0xFF116bb6),
                      onTap: () async {
                        try {
                          await mediaStore.saveFile(
                            tempFilePath: tempFilePath,
                            dirName: DirName.download,
                            dirType: DirType.download,
                          );
                          // Close bottom sheet first
                          Navigator.of(context).pop();

                          // Show success snackbar
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Notice saved to Downloads!"),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          setSheetState(() {
                            isSuccess = false;
                            statusMessage = "Failed to Save";
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildModernActionTile(
                      icon: Icons.create_new_folder_outlined,
                      title: "Pick Custom Folder",
                      subtitle: "Open device folder manager",
                      color: Colors.amber.shade800,
                      onTap: () async {
                        try {
                          String? selectedPath =
                              await FilePicker.platform.getDirectoryPath();
                          if (selectedPath != null) {
                            final newFile = File('$selectedPath/$fileName');
                            await tempFile.copy(newFile.path);

                            // Close bottom sheet
                            Navigator.of(context).pop();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Notice saved successfully!"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          setSheetState(() {
                            isSuccess = false;
                            statusMessage = "Error picking folder";
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildModernActionTile(
                      icon: Icons.share_rounded,
                      title: "Share with Apps",
                      subtitle: "WhatsApp, Email, etc.",
                      color: Colors.green.shade600,
                      onTap: () async {
                        Navigator.of(context).pop();
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (await tempFile.exists()) {
                          Share.shareXFiles([XFile(tempFilePath)],
                              text: fileName, subject: 'Legal Notice');
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            );
          },
        ),
        isScrollControlled: true,
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error while processing document"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildModernActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _fillLegalOptionsData(Legal? legal) {
    final List<LegalOption> allLegalOptions = [
      LegalOption(
          id: "0",
          label: "SECTION 25 (PASSA)",
          value: legal?.sec25,
          key: "Sec25",
          fileName: legal?.sec25File ?? ""),
      LegalOption(
          id: "1",
          label: "SECTION 138 (NI Act)",
          value: legal?.sec138,
          key: "Sec138",
          fileName: legal?.sec138File ?? ""),
      LegalOption(
          id: "2",
          label: "Arbitration",
          value: legal?.arbitration,
          key: "Arb",
          fileName: legal?.arbitrationFile ?? ""),
      LegalOption(
          id: "3",
          label: "SARFAESI",
          value: legal?.sarfaesi,
          key: "sar",
          fileName: legal?.sarfaesiFile ?? ""),
      LegalOption(
          id: "4",
          label: "LRN",
          value: legal?.lrn,
          key: "LRN",
          fileName: legal?.lrnFile ?? ""),
    ];

    /// ⬇⬇⬇ CHANGE: Do NOT filter upload options by `value == null`.
    /// Allow uploading for any type, any number of times.
    uploadOptions = List<LegalOption>.from(allLegalOptions);

    /// Keep download behavior as-is (only show those available to download)
    downloadOptions =
        allLegalOptions.where((item) => item.value == "Y").toList();

    // Clear selected values if they no longer exist in the options
    if (uploadOptions.isNotEmpty &&
        !uploadOptions.contains(selectedUploadLegalDocumentValue)) {
      selectedUploadLegalDocumentValue = null;
    }
    if (downloadOptions.isNotEmpty &&
        !downloadOptions.contains(selectedDownLoadLegalDocumentValue)) {
      selectedDownLoadLegalDocumentValue = null;
    }
  }
  // _fillLegalOptionsData(Legal? legal) {
  //   List<LegalOption> allLegalOptions = [
  //     LegalOption(
  //         id: "0", label: "SECTION 25 (PASSA)", value: legal?.sec25, key: "Sec25",fileName:legal?.sec25File ?? "" ),
  //     LegalOption(
  //         id: "1", label: "SECTION 138 (NI Act)", value: legal?.sec138, key: "Sec138",fileName:legal?.sec138File ?? ""),
  //     LegalOption(
  //         id: "2", label: "Arbitration", value: legal?.arbitration, key: "Arb",fileName:legal?.arbitrationFile ?? ""),
  //     LegalOption(id: "3",label: "SARFAESI", value: legal?.sarfaesi, key: "sar",fileName:legal?.sarfaesiFile ?? ""),
  //     LegalOption(id: "4",label: "LRN", value: legal?.lrn, key: "LRN",fileName:legal?.lrnFile ?? ""),
  //   ];
  //   downloadOptions =
  //       allLegalOptions.where((item) => item.value == "Y").toList();
  //   uploadOptions =
  //       allLegalOptions.where((item) => item.value == null).toList();
  //
  //   // Clear selected values if they no longer exist in the options
  //   if (uploadOptions.isNotEmpty &&
  //       !uploadOptions.contains(selectedUploadLegalDocumentValue)) {
  //     selectedUploadLegalDocumentValue = null;
  //   }
  //
  //   if (downloadOptions.isNotEmpty &&
  //       !downloadOptions.contains(selectedDownLoadLegalDocumentValue)) {
  //     selectedDownLoadLegalDocumentValue = null;
  //   }
  //   /* if (uploadOptions.isNotEmpty &&
  //       !uploadOptions.contains(selectedUploadLeaglDocumentValue)) {
  //     selectedUploadLeaglDocumentValue = uploadOptions.first;
  //   }
  //
  //   if (downloadOptions.isNotEmpty &&
  //       !downloadOptions.contains(selectedDownLoadLeaglDocumentValue)) {
  //     selectedDownLoadLeaglDocumentValue = downloadOptions.first;
  //   }*/
  // }
}
