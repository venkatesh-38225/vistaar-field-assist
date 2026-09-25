import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/legal_masters.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_confirm_dialog.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import 'physical_filing_logs_tab.dart';

class AssignAdvocateScreen extends StatefulWidget {
  const AssignAdvocateScreen({
    super.key,
    required this.caseId,
    required this.updatedBy,
  });

  final int caseId;
  final String updatedBy;

  @override
  State<AssignAdvocateScreen> createState() => _AssignAdvocateScreenState();
}

class _AssignAdvocateScreenState extends State<AssignAdvocateScreen>
    with SingleTickerProviderStateMixin {
  PhysicalFilingCase? _details;
  List<Advocate> _advocates = [];
  Advocate? _selectedAdvocate;
  DateTime? _assignmentDate;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isSubmittingRequirement = false;
  bool _showAdvocateError = false;
  bool _showDateError = false;

  late AnimationController _alertAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool get _showDocumentRequirementsBanner => _details != null;

  @override
  void initState() {
    super.initState();
    _alertAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _alertAnimationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _alertAnimationController,
      curve: Curves.easeOutBack,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.93,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _alertAnimationController,
      curve: Curves.easeOutBack,
    ));
    _loadData();
  }

  @override
  void dispose() {
    _alertAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        ApiClient().getPhysicalFilingById(widget.caseId),
        ApiClient().getAllAdvocates(),
      ]);
      if (!mounted) return;

      final detailsResponse = results[0] as PhysicalFilingDetailsResponse?;
      final advocates = results[1] as List<Advocate>?;
      if (detailsResponse?.success == true && detailsResponse?.data != null) {
        final PhysicalFilingCase details = detailsResponse!.data!;
        final advocatesList = advocates ?? [];

        Advocate? matchedAdvocate;
        if (details.advocateId > 0) {
          try {
            matchedAdvocate = advocatesList.firstWhere(
              (a) => a.id == details.advocateId,
            );
          } catch (_) {
            if (details.advocateName.trim().isNotEmpty) {
              matchedAdvocate = Advocate(
                id: details.advocateId,
                advocateName: details.advocateName.trim(),
              );
            }
          }
        } else if (details.advocateName.trim().isNotEmpty) {
          try {
            matchedAdvocate = advocatesList.firstWhere(
              (a) =>
                  a.advocateName.trim().toLowerCase() ==
                  details.advocateName.trim().toLowerCase(),
            );
          } catch (_) {
            matchedAdvocate = Advocate(
              id: 0,
              advocateName: details.advocateName.trim(),
            );
          }
        }

        setState(() {
          _details = details;
          _advocates = advocatesList;
          if (_selectedAdvocate == null && matchedAdvocate != null) {
            _selectedAdvocate = matchedAdvocate;
          }
          if (_assignmentDate == null && details.advocateAssignmentDate != null) {
            _assignmentDate = details.advocateAssignmentDate;
          }
          _errorMessage =
              advocates == null ? 'Unable to load advocate masters' : null;
        });
        if (_showDocumentRequirementsBanner) {
          _alertAnimationController.forward(from: 0.0);
        }
      } else {
        setState(() {
          _details = null;
          _advocates = advocates ?? [];
          _errorMessage = detailsResponse?.message.isNotEmpty == true
              ? detailsResponse!.message
              : 'Failed to fetch physical filing details';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _details = null;
        _advocates = [];
        _errorMessage = 'Unable to load advocate assignment details';
      });
      GlobalSnackbar.showError('Unable to load advocate assignment details');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAndSubmitRequirement({
    required String questionType,
    required bool isYes,
  }) async {
    final details = _details;
    if (details == null || details.caseId == 0 || !mounted) return;
    final updatedBy = widget.updatedBy.trim();
    if (updatedBy.isEmpty) {
      GlobalSnackbar.showError('Updated user ID is unavailable');
      return;
    }

    final bool isPhysicalDocs = questionType == 'Physical Documents';
    final TextEditingController commentsController = TextEditingController();

    try {
      final confirmed = await CustomConfirmDialog.show(
        context: context,
        title: 'Confirm Requirement',
        highlightItems: {
          'Question': '$questionType Required?',
          'Selected': isYes ? 'Yes' : 'No',
        },
        message: 'This will save your choice and return to the case list.',
        confirmText: 'Submit',
        showInputField: !isPhysicalDocs,
        inputLabel: 'Comments',
        inputHint: isYes
            ? 'Enter reason for additional documents...'
            : 'Enter comments (optional)...',
        isInputRequired: !isPhysicalDocs && isYes,
        inputController: commentsController,
        inputValidationErrorMessage:
            'Please enter reason for additional documents',
      );

      if (confirmed != true || !mounted) return;

      final comments = commentsController.text.trim();

      setState(() => _isSubmittingRequirement = true);
      try {
        final payload = <String, dynamic>{
          'caseId': details.caseId,
          if (isPhysicalDocs) 'requiresPhysicalDocuments': isYes,
          if (!isPhysicalDocs) ...{
            'requiresAdditionalDocuments': isYes,
            if (comments.isNotEmpty) 'comments': comments,
          },
          'updatedBy': updatedBy,
        };

        final response = isPhysicalDocs
            ? await ApiClient().submitPhysicalDocumentRequirement(payload)
            : await ApiClient().submitAdditionalDocumentRequirement(payload);

        if (!mounted) return;
        if (response?['success'] == true) {
          GlobalSnackbar.showSuccess(
            response?['message']?.toString() ??
                '$questionType requirement submitted successfully',
          );
          Get.back(result: true);
        } else {
          GlobalSnackbar.showError(
            response?['message']?.toString() ?? 'Failed to submit requirement',
          );
        }
      } catch (_) {
        if (mounted) {
          GlobalSnackbar.showError('Unable to submit requirement');
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmittingRequirement = false);
        }
      }
    } finally {
      commentsController.dispose();
    }
  }

  Future<void> _pickAssignmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assignmentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _assignmentDate = picked;
        _showDateError = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final details = _details;
    final advocate = _selectedAdvocate;
    final assignmentDate = _assignmentDate;
    final updatedBy = widget.updatedBy.trim();

    setState(() {
      _showAdvocateError = advocate == null;
      _showDateError = assignmentDate == null;
    });
    if (advocate == null || assignmentDate == null) {
      GlobalSnackbar.showError('Please select advocate and assignment date');
      return;
    }

    if (details == null || details.caseId == 0) {
      GlobalSnackbar.showError('Case ID is unavailable');
      return;
    }
    if (updatedBy.isEmpty) {
      GlobalSnackbar.showError('Updated user ID is unavailable');
      return;
    }

    final confirmed = await CustomConfirmDialog.show(
      context: context,
      title: 'Assign Advocate',
      highlightItems: {
        'LAN': details.lan,
        'Advocate': advocate.advocateName,
        'Assignment Date': DateFormat('dd-MMM-yyyy').format(assignmentDate),
      },
      message:
          'Are you sure you want to assign ${advocate.advocateName} to LAN ${details.lan}?',
      confirmText: 'Assign Advocate',
      icon: Icons.person_add_alt_1_outlined,
      iconColor: Constant.mediumBlueColor,
      iconBackgroundColor: const Color(0xFFE3F2FD),
    );
    if (confirmed != true || !mounted) return;

    final assignmentDateForApi = DateTime(
      assignmentDate.year,
      assignmentDate.month,
      assignmentDate.day,
    );
    final payload = <String, dynamic>{
      'caseId': details.caseId,
      'advocateId': advocate.id,
      'assignmentDate': assignmentDateForApi.toIso8601String(),
      'updatedBy': updatedBy,
    };

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient().assignPhysicalFilingAdvocate(payload);
      if (!mounted) return;
      if (response?['success'] == true) {
        GlobalSnackbar.showSuccess(
          response?['message']?.toString() ?? 'Advocate assigned successfully',
        );
        Get.back(result: true);
      } else {
        GlobalSnackbar.showError(
          response?['message']?.toString() ?? 'Failed to assign advocate',
        );
      }
    } catch (_) {
      if (mounted) GlobalSnackbar.showError('Unable to assign advocate');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Constant.mediumBlueColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const CustomText(
            text: 'Assign Advocate',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Constant.mediumYellowColor,
            tabs: [
              Tab(text: 'DETAILS'),
              Tab(text: 'LOGS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBody(),
            PhysicalFilingLogsTab(
              details: _details,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              onRefresh: _loadData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Constant.lightBlueColor),
      );
    }
    if (_errorMessage != null || _details == null) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 130),
            const Icon(Icons.cloud_off_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            CustomText(
              text: _errorMessage ?? 'No assignment details available',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showDocumentRequirementsBanner) ...[
              _buildDocumentRequirementsAlertBanner(),
              const SizedBox(height: 14),
            ],
            _buildCaseDetailsCard(_details!),
            const SizedBox(height: 18),
            const CustomText(
              text: 'Advocate Assignment',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102F54),
            ),
            const SizedBox(height: 14),
            _buildLabel('Select Advocate *'),
            _buildAdvocateSelector(),
            if (_showAdvocateError) _buildError('Please select an advocate'),
            const SizedBox(height: 16),
            _buildLabel('Date of Assignment *'),
            _buildDateSelector(),
            if (_showDateError) _buildError('Please select assignment date'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constant.mediumBlueColor,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: CustomText(
                  text: _isSubmitting ? 'Assigning...' : 'Assign Advocate',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentRequirementsAlertBanner() {
    final isScannedCopy =
        _details?.documentTransmissionType?.trim().toLowerCase() ==
            'scanned copy';
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB74D),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF57C00).withValues(alpha: 0.14),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA000).withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFE65100),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            text: 'Document Requirements',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBF360C),
                          ),
                          const SizedBox(height: 2),
                          CustomText(
                            text: isScannedCopy
                                ? 'Scanned transmission mode detected (Optional)'
                                : 'Document requirement confirmation (Optional)',
                            fontSize: 11,
                            color: const Color(0xFF8D4B00),
                          ),
                        ],
                      ),
                    ),
                    if (_isSubmittingRequirement)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE65100),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (isScannedCopy) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFE082),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: CustomText(
                            text: 'Physical Documents Required?',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceButton(
                          questionType: 'Physical Documents',
                          label: 'Yes',
                          isYes: true,
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceButton(
                          questionType: 'Physical Documents',
                          label: 'No',
                          isYes: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFE082),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: CustomText(
                          text: 'Additional Documents Required?',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildChoiceButton(
                        questionType: 'Additional Documents',
                        label: 'Yes',
                        isYes: true,
                      ),
                      const SizedBox(width: 8),
                      _buildChoiceButton(
                        questionType: 'Additional Documents',
                        label: 'No',
                        isYes: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String questionType,
    required String label,
    required bool isYes,
  }) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFE65100),
            width: 1.2,
          ),
          foregroundColor: const Color(0xFFE65100),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        onPressed: (_isLoading || _isSubmitting || _isSubmittingRequirement)
            ? null
            : () => _confirmAndSubmitRequirement(
                  questionType: questionType,
                  isYes: isYes,
                ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE65100),
          ),
        ),
      ),
    );
  }

  Widget _buildCaseDetailsCard(PhysicalFilingCase details) {
    final isScannedCopy =
        details.documentTransmissionType?.trim().toLowerCase() ==
            'scanned copy';
    final dispatchDate = details.dispatchDate == null
        ? 'N/A'
        : DateFormat('dd-MMM-yyyy').format(details.dispatchDate!);
    final emailDate = details.emailDate == null
        ? 'N/A'
        : DateFormat('dd-MMM-yyyy').format(details.emailDate!);
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              color: Constant.mediumBlueColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open, color: Colors.white),
                const SizedBox(width: 9),
                Expanded(
                  child: CustomText(
                    text: details.lan,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(Icons.info_outline, 'Status', details.status),
                if (isScannedCopy) ...[
                  _detailRow(
                    Icons.email_outlined,
                    'Email Date',
                    emailDate,
                  ),
                  _detailRow(
                    Icons.subject_outlined,
                    'Email Subject',
                    (details.emailSubject?.trim().isNotEmpty ?? false)
                        ? details.emailSubject!
                        : 'N/A',
                  ),
                ] else ...[
                  _detailRow(
                    Icons.calendar_today_outlined,
                    'Dispatch Date',
                    dispatchDate,
                  ),
                  _detailRow(
                    Icons.confirmation_number_outlined,
                    'POD Number',
                    details.podNumber,
                  ),
                  _detailRow(
                    Icons.local_shipping_outlined,
                    'Courier Name',
                    details.courierName,
                  ),
                ],
                _detailRow(
                  Icons.description_outlined,
                  'Transmission Mode',
                  (details.documentTransmissionType?.trim().isNotEmpty ?? false)
                      ? details.documentTransmissionType!
                      : 'N/A',
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Constant.lightBlueColor),
            const SizedBox(width: 9),
            SizedBox(
              width: 105,
              child: CustomText(
                text: label,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            Expanded(
              child: CustomText(
                text: value.trim().isEmpty ? 'N/A' : value,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        if (showDivider) const Divider(height: 20),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: CustomText(
        text: text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAdvocateSelector() {
    return InkWell(
      onTap: _advocates.isEmpty ? null : _showAdvocateSelection,
      child: _selectorContainer(
        value: _selectedAdvocate?.advocateName,
        hint: _advocates.isEmpty ? 'No advocates available' : 'Select Advocate',
        icon: Icons.search,
        hasError: _showAdvocateError,
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _pickAssignmentDate,
      child: _selectorContainer(
        value: _assignmentDate == null
            ? null
            : DateFormat('dd-MM-yyyy').format(_assignmentDate!),
        hint: 'Select Assignment Date',
        icon: Icons.calendar_today,
        hasError: _showDateError,
      ),
    );
  }

  Widget _selectorContainer({
    required String? value,
    required String hint,
    required IconData icon,
    required bool hasError,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: hasError ? Colors.red : Colors.black,
          width: hasError ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(1, 1),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              text: value ?? hint,
              color: value == null ? Colors.grey : Colors.black,
              fontSize: 16,
            ),
          ),
          Icon(icon, color: Constant.mediumBlueColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 12),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  void _showAdvocateSelection() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        var filtered = List<Advocate>.from(_advocates);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CustomText(
                      text: 'Select Advocate',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constant.mediumBlueColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        autofocus: true,
                        onChanged: (query) {
                          setModalState(() {
                            filtered = _advocates
                                .where((advocate) => advocate.advocateName
                                    .toLowerCase()
                                    .contains(query.trim().toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Advocate...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No advocates found'))
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final advocate = filtered[index];
                                return ListTile(
                                  title: CustomText(
                                    text: advocate.advocateName,
                                    fontSize: 16,
                                  ),
                                  trailing: _selectedAdvocate?.id == advocate.id
                                      ? const Icon(
                                          Icons.check,
                                          color: Constant.mediumBlueColor,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedAdvocate = advocate;
                                      _showAdvocateError = false;
                                    });
                                    Navigator.pop(sheetContext);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
