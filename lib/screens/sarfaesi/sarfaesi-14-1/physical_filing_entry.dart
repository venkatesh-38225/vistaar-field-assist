import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_confirm_dialog.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import 'physical_filing_logs_tab.dart';

class PhysicalFilingEntryScreen extends StatefulWidget {
  const PhysicalFilingEntryScreen({
    super.key,
    required this.caseId,
    required this.updatedBy,
  });

  final int caseId;
  final String updatedBy;

  @override
  State<PhysicalFilingEntryScreen> createState() =>
      _PhysicalFilingEntryScreenState();
}

class _PhysicalFilingEntryScreenState extends State<PhysicalFilingEntryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _physicalFilingDateController = TextEditingController();
  final _physicalFilingCaseNumberController = TextEditingController();

  PhysicalFilingCase? _details;
  DateTime? _physicalFilingDate;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isSubmittingRequirement = false;

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
    _loadDetails();
  }

  @override
  void dispose() {
    _alertAnimationController.dispose();
    _physicalFilingDateController.dispose();
    _physicalFilingCaseNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient().getPhysicalFilingById(widget.caseId);
      if (!mounted) return;
      if (response?.success == true && response?.data != null) {
        final PhysicalFilingCase details = response!.data!;
        setState(() {
          _details = details;
          if (_physicalFilingDate == null && details.physicalFilingDate != null) {
            _physicalFilingDate = details.physicalFilingDate;
            _physicalFilingDateController.text =
                DateFormat('dd-MM-yyyy').format(details.physicalFilingDate!);
          }
          if (_physicalFilingCaseNumberController.text.trim().isEmpty &&
              details.physicalFilingCaseNumber.trim().isNotEmpty) {
            _physicalFilingCaseNumberController.text =
                details.physicalFilingCaseNumber.trim();
          }
        });
        if (_showDocumentRequirementsBanner) {
          _alertAnimationController.forward(from: 0.0);
        }
      } else {
        setState(() {
          _details = null;
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to fetch filing details';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _details = null;
        _errorMessage = 'Unable to load filing details';
      });
      GlobalSnackbar.showError('Unable to load filing details');
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

  Future<void> _pickPhysicalFilingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _physicalFilingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _physicalFilingDate = picked;
      _physicalFilingDateController.text =
          DateFormat('dd-MM-yyyy').format(picked);
    });
  }

  String _toApiDate(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) {
      GlobalSnackbar.showError('Please complete all required filing details');
      return;
    }

    final details = _details;
    final physicalFilingDate = _physicalFilingDate;
    final updatedBy = widget.updatedBy.trim();
    if (details == null || details.caseId == 0) {
      GlobalSnackbar.showError('Case ID is unavailable');
      return;
    }
    if (physicalFilingDate == null) return;
    if (updatedBy.isEmpty) {
      GlobalSnackbar.showError('Updated user ID is unavailable');
      return;
    }

    final confirmed = await CustomConfirmDialog.show(
      context: context,
      title: 'Submit Physical Filing Details',
      highlightItems: {
        'LAN': details.lan,
        if (details.courtName.trim().isNotEmpty)
          'Court Name': details.courtName,
        'Physical Filing Date':
            DateFormat('dd-MMM-yyyy').format(physicalFilingDate),
        'Case Number': _physicalFilingCaseNumberController.text.trim(),
      },
      message:
          'Are you sure you want to submit Physical Filing details for LAN ${details.lan}?',
      confirmText: 'Submit Filing',
      icon: Icons.assignment_turned_in_outlined,
      iconColor: Constant.mediumBlueColor,
      iconBackgroundColor: const Color(0xFFE3F2FD),
    );
    if (confirmed != true || !mounted) return;

    final payload = <String, dynamic>{
      'caseId': details.caseId,
      'filingType': 'Physical Filing',
      'courtName': details.courtName,
      if (details.eFilingDate != null)
        'eFilingDate': _toApiDate(details.eFilingDate!),
      if (details.eFilingCaseNumber.trim().isNotEmpty)
        'eFilingCaseNumber': details.eFilingCaseNumber.trim(),
      'physicalFilingDate': _toApiDate(physicalFilingDate),
      'physicalFilingCaseNumber':
          _physicalFilingCaseNumberController.text.trim(),
      'updatedBy': updatedBy,
    };

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient().submitPhysicalFiling(payload);
      if (!mounted) return;
      if (response?['success'] == true) {
        GlobalSnackbar.showSuccess(
          response?['message']?.toString() ??
              'Physical filing details submitted successfully',
        );
        Get.back(result: true);
      } else {
        GlobalSnackbar.showError(
          response?['message']?.toString() ??
              'Failed to submit physical filing details',
        );
      }
    } catch (_) {
      if (mounted) {
        GlobalSnackbar.showError('Unable to submit physical filing details');
      }
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
            text: 'Physical Filing',
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
              onRefresh: _loadDetails,
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
        onRefresh: _loadDetails,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 130),
            const Icon(Icons.cloud_off_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            CustomText(
              text: _errorMessage ?? 'No filing details available',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: _loadDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        child: Form(
          key: _formKey,
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
                text: 'Physical Filing Details',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102F54),
              ),
              const SizedBox(height: 14),
              _buildLabel('Date of Physical Filing *'),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildLabel('Physical Filing Case Number *'),
              TextFormField(
                controller: _physicalFilingCaseNumberController,
                decoration:
                    _inputDecoration('Enter Physical Filing Case Number'),
                validator: _requiredValidator('Physical filing case number'),
              ),
              const SizedBox(height: 26),
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
                      : const Icon(Icons.send_outlined, color: Colors.white),
                  label: CustomText(
                    text: _isSubmitting
                        ? 'Submitting...'
                        : 'Submit Physical Filing',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
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
                            text: 'Document Requirements Alert',
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
                _detailRow(
                  Icons.location_city_outlined,
                  'Court Name',
                  details.courtName,
                ),
                _detailRow(
                  Icons.calendar_today_outlined,
                  'E-Filing Date',
                  details.eFilingDate == null
                      ? 'N/A'
                      : DateFormat('dd-MMM-yyyy').format(details.eFilingDate!),
                ),
                _detailRow(
                  Icons.numbers_outlined,
                  'E-Filing Case No.',
                  details.eFilingCaseNumber,
                ),
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
              width: 120,
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

  Widget _buildDateField() {
    return TextFormField(
      controller: _physicalFilingDateController,
      readOnly: true,
      onTap: _pickPhysicalFilingDate,
      decoration: _inputDecoration('Select Date of Physical Filing').copyWith(
        suffixIcon: const Icon(
          Icons.calendar_today,
          color: Constant.mediumBlueColor,
        ),
      ),
      validator: (value) =>
          value?.trim().isEmpty ?? true ? 'Please select a date' : null,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Constant.mediumBlueColor),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String fieldName) {
    return (value) =>
        value?.trim().isEmpty ?? true ? '$fieldName is required' : null;
  }
}
