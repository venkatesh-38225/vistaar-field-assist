import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/loan_details_res.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/models/voice_of_team_models.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_confirm_dialog.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class CreateVoiceOfTeamScreen extends StatefulWidget {
  const CreateVoiceOfTeamScreen({
    super.key,
    required this.profile,
    this.initialLan,
  });

  final ProfileResponse profile;
  final VotLanItem? initialLan;

  @override
  State<CreateVoiceOfTeamScreen> createState() =>
      _CreateVoiceOfTeamScreenState();
}

class _CreateVoiceOfTeamScreenState extends State<CreateVoiceOfTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Top Search Controllers & State (No pre-selected values)
  final TextEditingController lanController = TextEditingController();
  String? selectedCaseType;
  final List<String> caseTypeOptions = ['Fresh Case', 'Flow Case'];

  bool isLanSearching = false;
  bool isDetailsFetched = false;

  // Fetched LAN Data (Ordered items)
  String custName = '';
  String branchCode = '';
  String branchName = '';
  String region = '';
  String zone = '';
  String megaZone = '';
  String state = '';
  String disbAmount = '';
  String disbDate = '';
  String maturityDate = '';
  String dpd = '';
  String loanAmount = '';
  String principalOutstanding = '';
  String custAddress = '';

  // Section - Discrepancy Information (No pre-selected values)
  String? selectedCustomerIssue;
  final List<String> customerIssueOptions = [
    'Customer has not received the full loan amount',
    'Funding of Money by Employee',
    'Funding of Money by DSA Team',
    'Business Impersonation',
    'Business Closed in 6 Months to 12 Months',
    'Property Mismatch',
    'Inflated Valuation',
  ];
  final TextEditingController cdsmRemarksController = TextEditingController();

  // Section - Property Assessment (No pre-selected values)
  String? selectedPropertyCondition;
  final List<String> propertyConditionOptions = [
    'Average',
    'Good',
    'Bad',
    'Poor',
  ];

  String? selectedLoanRecoverable;
  final List<String> loanRecoverableOptions = ['Yes', 'No'];
  String? selectedNonRecoveryReason;
  final List<String> nonRecoveryReasonOptions = [
    'Community Dominated Area',
    'Low Resale Value',
    'Standalone Land',
    'Inflated Valuation',
    'Multi-funded Property',
    'Disputed Property',
  ];

  // Section - Photograph Attachments (max 3 each, max 5MB each)
  final List<File> propertyPhotos = [];
  final List<File> businessPhotos = [];
  final List<File> residencePhotos = [];

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLan != null) {
      lanController.text = widget.initialLan!.lan.toUpperCase();
      selectedCaseType = 'Fresh Case';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchLanDetails();
        }
      });
    }
  }

  @override
  void dispose() {
    lanController.dispose();
    cdsmRemarksController.dispose();
    super.dispose();
  }

  Future<void> _searchLanDetails() async {
    final lan = lanController.text.trim().toUpperCase();
    if (lan.isEmpty) {
      GlobalSnackbar.showError('Please enter LAN number');
      return;
    }
    if (selectedCaseType == null || selectedCaseType!.isEmpty) {
      GlobalSnackbar.showError('Please select Case Type');
      return;
    }

    setState(() {
      isLanSearching = true;
      isDetailsFetched = false;
    });

    try {
      final response = await ApiClient().getLanNoticeDetails(lan);
      final foreClosureResponse = await ApiClient().getForeClosureDetails(lan);

      if (!mounted) return;

      if (response is LoanDetailsResponse && response.fullName != null) {
        setState(() {
          custName = response.fullName ?? '';
          branchCode = response.branch?.branchCode ?? '';
          branchName = response.branch?.branchName ?? '';
          region = response.branch?.region ?? '';
          zone = response.branch?.zone ?? '';
          megaZone = response.branch?.megaZone ?? '';
          state = response.state ?? "";
          disbAmount = response.disbursementAmount ?? '';
          disbDate = response.disbursementDate ?? "";
          maturityDate = response.maturityDate ?? "";
          dpd = response.dpd ?? '';
          loanAmount = response.loanAmount ?? '';
          principalOutstanding = foreClosureResponse?.pos?.toString() ??
              response.principalOutstanding ??
              response.pos?.toString() ??
              '';
          custAddress =
              response.residentialAddress ?? response.propertyAddress ?? '';

          isDetailsFetched = true;
          isLanSearching = false;
        });
      } else if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response;
        setState(() {
          custName = data['custName']?.toString() ??
              data['fullName']?.toString() ??
              '';
          branchCode = data['branchCode']?.toString() ??
              data['branch']?['branchCode']?.toString() ??
              '';
          branchName = data['branchName']?.toString() ??
              data['branch']?['branchName']?.toString() ??
              '';
          region = data['region']?.toString() ??
              data['branch']?['region']?.toString() ??
              '';
          zone = data['zone']?.toString() ??
              data['branch']?['zone']?.toString() ??
              '';
          megaZone = data['megaZone']?.toString() ??
              data['branch']?['megaZone']?.toString() ??
              '';
          state = data['state']?.toString() ??
              data['branch']?['state']?.toString() ??
              '';
          disbAmount = data['disbAmount']?.toString() ??
              data['totalOutstanding']?.toString() ??
              '';
          disbDate = data['disbDate']?.toString() ??
              data['disbursementDate']?.toString() ??
              '';
          maturityDate = data['maturityDate']?.toString() ?? '';
          dpd = data['dpd']?.toString() ?? '';
          loanAmount = data['loanAmount']?.toString() ??
              data['disbAmount']?.toString() ??
              data['totalOutstanding']?.toString() ??
              '';
          principalOutstanding = data['principalOutstanding']?.toString() ??
              data['pos']?.toString() ??
              '';
          custAddress = data['residentialAddress']?.toString() ??
              data['custAddress']?.toString() ??
              data['propertyAddress']?.toString() ??
              '';

          isDetailsFetched = true;
          isLanSearching = false;
        });
      } else {
        setState(() {
          isLanSearching = false;
          isDetailsFetched = false;
        });
        GlobalSnackbar.showError('No details found for the entered LAN');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLanSearching = false;
          isDetailsFetched = false;
        });
        GlobalSnackbar.showError('Failed to fetch LAN details: $e');
      }
    }
  }

  Future<void> _pickPhoto(List<File> targetList, String photoType) async {
    if (targetList.length >= 3) {
      GlobalSnackbar.showError('Maximum 3 photos allowed for $photoType');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'Upload $photoType',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF102F54),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEBF3FF),
                    child:
                        Icon(Icons.camera_alt, color: Constant.mediumBlueColor),
                  ),
                  title: const CustomText(text: 'Take Photo from Camera'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    _handlePickedFile(photo, targetList);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEBF3FF),
                    child: Icon(Icons.photo_library,
                        color: Constant.mediumBlueColor),
                  ),
                  title: const CustomText(text: 'Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    _handlePickedFile(photo, targetList);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePickedFile(XFile? photo, List<File> targetList) {
    if (photo == null) return;
    final file = File(photo.path);
    final int sizeInBytes = file.lengthSync();
    final double sizeInMB = sizeInBytes / (1024 * 1024);

    if (sizeInMB > 5.0) {
      GlobalSnackbar.showError('File size exceeds 5MB limit');
      return;
    }

    setState(() {
      targetList.add(file);
    });
  }

  Future<void> _submitVoiceOfTeam() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isDetailsFetched) {
      GlobalSnackbar.showError('Please search and load LAN details first');
      return;
    }

    if (selectedCustomerIssue == null || selectedCustomerIssue!.isEmpty) {
      GlobalSnackbar.showError('Please select Customer Issue');
      return;
    }

    if (selectedPropertyCondition == null ||
        selectedPropertyCondition!.isEmpty) {
      GlobalSnackbar.showError('Please select Property Condition');
      return;
    }

    if (selectedLoanRecoverable == null || selectedLoanRecoverable!.isEmpty) {
      GlobalSnackbar.showError(
          'Please select whether loan can be recovered by sale');
      return;
    }

    if (selectedLoanRecoverable == 'No' &&
        (selectedNonRecoveryReason == null ||
            selectedNonRecoveryReason!.isEmpty)) {
      GlobalSnackbar.showError('Please select Reason for Non Recovery');
      return;
    }

    final confirmed = await CustomConfirmDialog.show(
      context: context,
      title: 'Submit Voice of Team',
      message:
          'Are you sure you want to submit Voice of Team for LAN: ${lanController.text.trim().toUpperCase()}?',
      confirmText: 'Submit Case',
      cancelText: 'Cancel',
      confirmIcon: Icons.send_outlined,
      highlightItems: {
        'LAN': lanController.text.trim().toUpperCase(),
        'Case Type': selectedCaseType ?? 'N/A',
        'Customer Name': custName.isNotEmpty ? custName : 'N/A',
        'Customer Issue': selectedCustomerIssue ?? 'N/A',
      },
    );

    if (confirmed == true) {
      _executeSubmission();
    }
  }

  Future<void> _executeSubmission() async {
    setState(() => isSubmitting = true);

    final empId = widget.profile.data?.employeeId ?? '';

    final payload = <String, dynamic>{
      'lan': lanController.text.trim().toUpperCase(),
      'caseType': selectedCaseType ?? '',
      'custName': custName,
      'custAddress': custAddress,
      'disbAmount': _parseNum(disbAmount) ?? disbAmount,
      'disbDate': _formatPayloadDate(disbDate),
      'maturityDate': _formatPayloadDate(maturityDate),
      'principalOutstanding':
          _parseNum(principalOutstanding) ?? principalOutstanding,
      'dpd': _parseInt(dpd) ?? dpd,
      'branchCode': branchCode.isNotEmpty
          ? branchCode
          : (widget.profile.data?.branchCode ?? ''),
      'branchName': branchName.isNotEmpty
          ? branchName
          : (widget.profile.data?.branchName ?? ''),
      'region': region,
      'zone': zone,
      'megaZone': megaZone,
      'customerIssue': selectedCustomerIssue ?? '',
      'cdsmRemarks': cdsmRemarksController.text.trim(),
      'propertyCondition': selectedPropertyCondition ?? '',
      'loanRecoverable': selectedLoanRecoverable == 'Yes',
      'nonRecoveryReason': selectedLoanRecoverable == 'No'
          ? (selectedNonRecoveryReason ?? '')
          : '',
      'createdBy': empId,
    };

    try {
      final response = await ApiClient().createVoiceOfTeamCase(payload);
      if (!mounted) return;

      final dynamic rawData = response?['data'];
      final bool isSuccess = response != null &&
          (response['statusCode'] == 200 ||
              response['statusCode'] == 201 ||
              (rawData is Map && rawData['success'] == true) ||
              response['success'] == true);

      if (isSuccess) {
        int? caseId;
        if (rawData is Map) {
          final dynamic innerData = rawData['data'];
          if (innerData is num) {
            caseId = innerData.toInt();
          } else if (innerData is Map) {
            caseId = (innerData['caseId'] as num?)?.toInt() ??
                (innerData['id'] as num?)?.toInt();
          }
          caseId ??= (rawData['caseId'] as num?)?.toInt() ??
              (rawData['id'] as num?)?.toInt();
        } else if (rawData is num) {
          caseId = rawData.toInt();
        } else if (response['caseId'] is num) {
          caseId = (response['caseId'] as num).toInt();
        }

        // Upload attachments if caseId is available and files exist
        if (caseId != null) {
          await _uploadAllAttachments(caseId, empId);
        }

        final successMsg = (rawData is Map ? rawData['message'] : null) ??
            response['message'] ??
            'Voice of Team case created successfully';
        GlobalSnackbar.showSuccess(successMsg.toString());
        Get.back(result: true);
      } else {
        final dynamic msg = (rawData is Map
                ? (rawData['message'] ?? rawData['error'])
                : null) ??
            response?['message'] ??
            'Failed to create Voice of Team case';
        GlobalSnackbar.showError(msg.toString());
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.showError('Something went wrong: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> _uploadAllAttachments(int caseId, String empId) async {
    for (var file in propertyPhotos) {
      try {
        await ApiClient().uploadVoiceOfTeamFile(
          caseId: caseId,
          fileType: 'PropertyPhoto',
          file: file,
          createdBy: empId,
        );
      } catch (e) {
        debugPrint('Error uploading PropertyPhoto: $e');
      }
    }

    for (var file in businessPhotos) {
      try {
        await ApiClient().uploadVoiceOfTeamFile(
          caseId: caseId,
          fileType: 'BusinessPhoto',
          file: file,
          createdBy: empId,
        );
      } catch (e) {
        debugPrint('Error uploading BusinessPhoto: $e');
      }
    }

    for (var file in residencePhotos) {
      try {
        await ApiClient().uploadVoiceOfTeamFile(
          caseId: caseId,
          fileType: 'ResidencePhoto',
          file: file,
          createdBy: empId,
        );
      } catch (e) {
        debugPrint('Error uploading ResidencePhoto: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          text: 'Create Voice of Team',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Constant.lightBlueColor),
                  SizedBox(height: 16),
                  CustomText(
                    text: 'Submitting case & uploading attachments...',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopSearchCard(),
                    if (isDetailsFetched) ...[
                      const SizedBox(height: 14),
                      _buildLanDetailsCard(),
                      const SizedBox(height: 14),
                      _buildDiscrepancySectionCard(),
                      const SizedBox(height: 14),
                      _buildPropertyAssessmentSectionCard(),
                      const SizedBox(height: 14),
                      _buildPhotographAttachmentsCard(),
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopSearchCard() {
    final bool isPrefilled = widget.initialLan != null;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Search LAN & Case Type',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102F54),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: lanController,
              readOnly: isPrefilled,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: InputDecoration(
                labelText: 'LAN Number *',
                hintText: 'Enter LAN number',
                labelStyle: const TextStyle(fontSize: 14),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                filled: isPrefilled,
                fillColor:
                    isPrefilled ? const Color(0xFFF0F4F8) : Colors.transparent,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: const Icon(Icons.pin, size: 20, color: Colors.grey),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Please enter LAN' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedCaseType,
              decoration: InputDecoration(
                labelText: 'Case Type *',
                hintText: 'Select Case Type',
                labelStyle: const TextStyle(fontSize: 14),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                filled: isPrefilled,
                fillColor:
                    isPrefilled ? const Color(0xFFF0F4F8) : Colors.transparent,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: const Icon(Icons.category_outlined,
                    size: 20, color: Colors.grey),
              ),
              items: caseTypeOptions.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: CustomText(
                    text: type,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return caseTypeOptions.map<Widget>((String item) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: item,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              onChanged: isPrefilled
                  ? null
                  : (val) => setState(() => selectedCaseType = val),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Please select Case Type' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLanSearching ? null : _searchLanDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constant.mediumBlueColor,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                icon: isLanSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.white, size: 18),
                label: CustomText(
                  text: isLanSearching ? 'Searching...' : 'SEARCH LAN DETAILS',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanDetailsCard() {
    final branch = [
      if (branchName.isNotEmpty) branchName,
      if (branchCode.isNotEmpty) '($branchCode)',
    ].join(' ');

    final rows = <Widget>[
      _detailRow(Icons.person_outline, 'Customer Name', custName),
      _detailRow(Icons.storefront_outlined, 'Branch', branch),
      _detailRow(Icons.map_outlined, 'Region', region),
      _detailRow(Icons.my_location_outlined, 'Zone', zone),
      _detailRow(Icons.public_outlined, 'MegaZone', megaZone),
      _detailRow(Icons.location_city_outlined, 'State', state),
      _detailRow(
        Icons.currency_rupee,
        'Disbursement Amount',
        _formatCurrency(disbAmount),
      ),
      _detailRow(
        Icons.calendar_today_outlined,
        'Disbursement Date',
        _formatDate(disbDate),
      ),
      _detailRow(
        Icons.event_outlined,
        'Maturity Date',
        _formatDate(maturityDate),
      ),
      _detailRow(
        Icons.timer_outlined,
        'DPD',
        dpd.isNotEmpty ? '$dpd days' : '',
      ),
      _detailRow(
        Icons.account_balance_wallet_outlined,
        'Loan Amount',
        _formatCurrency(loanAmount),
      ),
      _detailRow(
        Icons.monetization_on_outlined,
        'Principle Outstanding',
        _formatCurrency(principalOutstanding),
      ),
      _detailRow(
        Icons.home_outlined,
        'Residential Address',
        custAddress,
      ),
    ];

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Constant.mediumBlueColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 20, color: Constant.mediumBlueColor),
                SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: 'LAN Information',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102F54),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: _withDividers(rows),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscrepancySectionCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Discrepancy Details',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102F54),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedCustomerIssue,
              decoration: InputDecoration(
                labelText: 'Customer Issue *',
                hintText: 'Select Customer Issue',
                labelStyle: const TextStyle(fontSize: 14),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: customerIssueOptions.map((issue) {
                return DropdownMenuItem(
                  value: issue,
                  child: CustomText(
                    text: issue,
                    fontSize: 13,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return customerIssueOptions.map<Widget>((String item) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: item,
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              onChanged: (val) => setState(() => selectedCustomerIssue = val),
              validator: (val) => val == null || val.isEmpty
                  ? 'Please select Customer Issue'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: cdsmRemarksController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Detailed Remarks *',
                hintText: 'Enter detailed field observations and remarks...',
                labelStyle: const TextStyle(fontSize: 14),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Detailed remarks are required'
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyAssessmentSectionCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Field Observations',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102F54),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedPropertyCondition,
              decoration: InputDecoration(
                labelText: 'Property Condition *',
                hintText: 'Select Property Condition',
                labelStyle: const TextStyle(fontSize: 14),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: propertyConditionOptions.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: CustomText(
                    text: item,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return propertyConditionOptions.map<Widget>((String item) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: item,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              onChanged: (val) =>
                  setState(() => selectedPropertyCondition = val),
              validator: (val) => val == null || val.isEmpty
                  ? 'Please select Property Condition'
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedLoanRecoverable,
              decoration: InputDecoration(
                labelText: 'Whether Loan Can be recovered by Sale? *',
                hintText: 'Select Yes / No',
                labelStyle: const TextStyle(fontSize: 14),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: loanRecoverableOptions.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: CustomText(text: item, fontSize: 14),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return loanRecoverableOptions.map<Widget>((String item) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: CustomText(text: item, fontSize: 14),
                  );
                }).toList();
              },
              onChanged: (val) => setState(() {
                selectedLoanRecoverable = val;
                if (val != 'No') {
                  selectedNonRecoveryReason = null;
                }
              }),
              validator: (val) => val == null || val.isEmpty
                  ? 'Please select whether loan can be recovered'
                  : null,
            ),
            if (selectedLoanRecoverable == 'No') ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedNonRecoveryReason,
                decoration: InputDecoration(
                  labelText: 'Reason for Non Recovery *',
                  hintText: 'Select Reason for Non Recovery',
                  labelStyle: const TextStyle(fontSize: 14),
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: nonRecoveryReasonOptions.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: CustomText(
                      text: item,
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (BuildContext context) {
                  return nonRecoveryReasonOptions.map<Widget>((String item) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text: item,
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                onChanged: (val) =>
                    setState(() => selectedNonRecoveryReason = val),
                validator: (val) {
                  if (selectedLoanRecoverable == 'No' &&
                      (val == null || val.isEmpty)) {
                    return 'Please select Reason for Non Recovery';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotographAttachmentsCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Photograph Attachments',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102F54),
            ),
            const SizedBox(height: 4),
            const CustomText(
              text: 'Max 3 photos per type (Max 5MB each)',
              fontSize: 12,
              color: Colors.grey,
            ),
            const SizedBox(height: 14),
            _buildPhotoUploadSection(
              title: '1. Property Photo',
              photos: propertyPhotos,
              photoType: 'Property Photo',
            ),
            const Divider(height: 24),
            _buildPhotoUploadSection(
              title: '2. Business Photo',
              photos: businessPhotos,
              photoType: 'Business Photo',
            ),
            const Divider(height: 24),
            _buildPhotoUploadSection(
              title: '3. Residence Photo',
              photos: residencePhotos,
              photoType: 'Residence Photo',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploadSection({
    required String title,
    required List<File> photos,
    required String photoType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF102F54),
            ),
            CustomText(
              text: '(${photos.length}/3)',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: photos.length >= 3 ? Colors.green : Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (photos.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final file = photos[index];
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    PositionTileDeleteButton(
                      onTap: () {
                        setState(() {
                          photos.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        if (photos.length < 3) ...[
          if (photos.isNotEmpty) const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _pickPhoto(photos, photoType),
            style: OutlinedButton.styleFrom(
              foregroundColor: Constant.mediumBlueColor,
              side: const BorderSide(color: Constant.mediumBlueColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: const Icon(Icons.add_a_photo_outlined, size: 16),
            label: CustomText(
              text: 'Add $photoType',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Constant.mediumBlueColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : _submitVoiceOfTeam,
        style: ElevatedButton.styleFrom(
          backgroundColor: Constant.mediumBlueColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
        ),
        icon: const Icon(Icons.send_outlined, color: Colors.white, size: 20),
        label: const CustomText(
          text: 'SUBMIT VOICE OF TEAM',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Constant.lightBlueColor),
        const SizedBox(width: 9),
        SizedBox(
          width: 140,
          child: CustomText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const CustomText(
          text: ': ',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: CustomText(
            text: value.trim().isNotEmpty ? value.trim() : 'N/A',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const Divider(height: 14, thickness: 0.6));
      }
    }
    return result;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    try {
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return DateFormat('dd-MMM-yyyy').format(parsed);
      }
    } catch (_) {}

    final formats = [
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'dd-MMM-yyyy',
      'dd MMM yyyy',
      'yyyy/MM/dd',
    ];
    for (final fmt in formats) {
      try {
        final parsed = DateFormat(fmt).parseLoose(trimmed);
        return DateFormat('dd-MMM-yyyy').format(parsed);
      } catch (_) {}
    }

    return trimmed;
  }

  String _formatPayloadDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    try {
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return DateFormat('yyyy-MM-dd').format(parsed);
      }
    } catch (_) {}

    final formats = [
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'dd-MMM-yyyy',
      'dd MMM yyyy',
      'yyyy/MM/dd',
    ];
    for (final fmt in formats) {
      try {
        final parsed = DateFormat(fmt).parseLoose(trimmed);
        return DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {}
    }

    return trimmed;
  }

  String _formatCurrency(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final cleaned = raw.replaceAll('₹', '').replaceAll(',', '').trim();
    final numVal = double.tryParse(cleaned);
    if (numVal != null) {
      return '₹${NumberFormat('#,##,##0.00').format(numVal)}';
    }
    return raw.startsWith('₹') ? raw : '₹$raw';
  }

  num? _parseNum(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final cleaned = val.replaceAll('₹', '').replaceAll(',', '').trim();
    return num.tryParse(cleaned);
  }

  int? _parseInt(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final cleaned = val.replaceAll(RegExp(r'[^0-9\-]'), '').trim();
    return int.tryParse(cleaned);
  }
}

class PositionTileDeleteButton extends StatelessWidget {
  const PositionTileDeleteButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 2,
      right: 2,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 12, color: Colors.white),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
