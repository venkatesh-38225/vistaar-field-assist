import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/models/voice_of_team_models.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_confirm_dialog.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class VoiceOfTeamApprovalScreen extends StatefulWidget {
  const VoiceOfTeamApprovalScreen({
    super.key,
    required this.caseItem,
    required this.profile,
  });

  final VotCaseItem caseItem;
  final ProfileResponse profile;

  @override
  State<VoiceOfTeamApprovalScreen> createState() =>
      _VoiceOfTeamApprovalScreenState();
}

class _VoiceOfTeamApprovalScreenState extends State<VoiceOfTeamApprovalScreen> {
  final _formKey = GlobalKey<FormState>();
  late VotCaseItem _caseItem;

  List<VotLogItem> _logs = [];
  List<VotUploadItem> _uploads = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Approval Form Fields
  String? selectedVisited;
  final List<String> visitedOptions = ['Yes', 'No'];

  String? selectedReviewed;
  final List<String> reviewedOptions = ['Yes', 'No'];

  String? selectedResolutionPlan;
  final List<String> resolutionPlanOptions = [
    'Settlement',
    'Legal Process',
    'Closure or BT out',
    'Senior Visit',
    'Group Visit',
    'High Intensity',
  ];

  String? selectedDecision;
  final List<String> decisionOptions = [
    'Recommended for Audit',
    'Reviewed – No Major Issue',
  ];

  final TextEditingController remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _caseItem = widget.caseItem;

    // Pre-populate if case item already has ZDSH review values
    if (widget.caseItem.zdshVisited != null) {
      selectedVisited = widget.caseItem.zdshVisited! ? 'Yes' : 'No';
    }
    if (widget.caseItem.zdshReviewed != null) {
      selectedReviewed = widget.caseItem.zdshReviewed! ? 'Yes' : 'No';
    }
    if (widget.caseItem.zdshResolutionPlan != null &&
        resolutionPlanOptions.contains(widget.caseItem.zdshResolutionPlan)) {
      selectedResolutionPlan = widget.caseItem.zdshResolutionPlan;
    }
    if (widget.caseItem.zdshDecision != null) {
      final matched = decisionOptions.firstWhereOrNull(
        (d) =>
            d.toLowerCase().replaceAll('–', '-').trim() ==
            widget.caseItem.zdshDecision!
                .toLowerCase()
                .replaceAll('–', '-')
                .trim(),
      );
      if (matched != null) {
        selectedDecision = matched;
      }
    }
    if (widget.caseItem.zdshRemarks?.trim().isNotEmpty == true) {
      remarksController.text = widget.caseItem.zdshRemarks!.trim();
    } else if (widget.caseItem.zdshComments?.trim().isNotEmpty == true) {
      remarksController.text = widget.caseItem.zdshComments!.trim();
    }

    _fetchCaseDetails();
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _fetchCaseDetails() async {
    final int targetId = _caseItem.id;
    if (targetId == 0) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiClient().getVoiceOfTeamCaseById(targetId);
      if (!mounted) return;

      if (response != null && response.success && response.data != null) {
        setState(() {
          if (response.data!.caseItem != null) {
            _caseItem = response.data!.caseItem!;
          }
          _logs = response.data!.logs;
          _uploads = response.data!.uploads;
        });
      } else {
        setState(() {
          _errorMessage = response?.message?.isNotEmpty == true
              ? response!.message
              : 'Failed to fetch case details';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load case details: $e';
      });
      GlobalSnackbar.showError('Unable to load case details');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitApproval() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await CustomConfirmDialog.show(
      context: context,
      title: 'Submit ZDSH Review',
      message:
          'Are you sure you want to submit approval review for LAN: ${_caseItem.lan}?',
      confirmText: 'Submit Approval',
      cancelText: 'Cancel',
      confirmIcon: Icons.send_outlined,
      highlightItems: {
        'LAN': _caseItem.lan,
        'Visited': selectedVisited ?? 'N/A',
        'Reviewed': selectedReviewed ?? 'N/A',
        'Resolution Plan': selectedResolutionPlan ?? 'N/A',
        'Decision': selectedDecision ?? 'N/A',
        if (remarksController.text.trim().isNotEmpty)
          'Remarks': remarksController.text.trim(),
      },
    );

    if (confirmed == true) {
      _executeSubmission();
    }
  }

  Future<void> _executeSubmission() async {
    setState(() => _isSubmitting = true);

    final String empId = widget.profile.data?.employeeId ?? '';

    final payload = <String, dynamic>{
      'caseId': _caseItem.id,
      'zdshVisited': selectedVisited == 'Yes',
      'zdshReviewed': selectedReviewed == 'Yes',
      'zdshComments': remarksController.text.trim(),
      'zdshResolutionPlan': selectedResolutionPlan ?? '',
      'zdshRemarks': remarksController.text.trim(),
      'zdshDecision': selectedDecision ?? '',
      'updatedBy': empId,
    };

    try {
      final response = await ApiClient().submitVoiceOfTeamZdshReview(payload);
      if (!mounted) return;

      final dynamic rawData = response?['data'];
      final bool isSuccess = response != null &&
          (response['statusCode'] == 200 ||
              response['statusCode'] == 201 ||
              (rawData is Map && rawData['success'] == true) ||
              response['success'] == true);

      if (isSuccess) {
        final successMsg = (rawData is Map ? rawData['message'] : null) ??
            response['message'] ??
            'ZDSH Review submitted successfully';
        GlobalSnackbar.showSuccess(successMsg.toString());
        Get.back(result: true);
      } else {
        final dynamic msg = (rawData is Map
                ? (rawData['message'] ?? rawData['error'])
                : null) ??
            response?['message'] ??
            'Failed to submit ZDSH review';
        GlobalSnackbar.showError(msg.toString());
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.showError('Something went wrong: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool get _hasZdshDetails =>
      _caseItem.zdshVisited != null ||
      _caseItem.zdshReviewed != null ||
      (_caseItem.zdshDecision?.trim().isNotEmpty == true) ||
      (_caseItem.zdshResolutionPlan?.trim().isNotEmpty == true) ||
      (_caseItem.zdshRemarks?.trim().isNotEmpty == true) ||
      (_caseItem.zdshComments?.trim().isNotEmpty == true);

  bool get _hasMzdshDetails =>
      _caseItem.mzdshVisited != null ||
      _caseItem.mzdshReviewed != null ||
      (_caseItem.mzdshDecision?.trim().isNotEmpty == true) ||
      (_caseItem.mzdshRemarks?.trim().isNotEmpty == true);

  bool get _hasAuditDetails =>
      (_caseItem.auditFinding?.trim().isNotEmpty == true) ||
      _caseItem.isSubstantiated != null ||
      (_caseItem.actionRecommended?.trim().isNotEmpty == true) ||
      (_caseItem.auditRemarks?.trim().isNotEmpty == true) ||
      _caseItem.canBeClosed != null;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Constant.mediumBlueColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const CustomText(
            text: 'Voice of Team Approval',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Constant.mediumYellowColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'DETAILS'),
              Tab(text: 'UPLOADS'),
              Tab(text: 'LOGS'),
            ],
          ),
        ),
        body: _isSubmitting
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Constant.lightBlueColor),
                    SizedBox(height: 16),
                    CustomText(
                      text: 'Submitting ZDSH review...',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              )
            : TabBarView(
                children: [
                  _buildDetailsAndApprovalTab(),
                  _buildUploadsTab(),
                  _buildLogsTab(),
                ],
              ),
      ),
    );
  }

  // ==========================================
  // DETAILS & APPROVAL TAB
  // ==========================================
  Widget _buildDetailsAndApprovalTab() {
    if (_isLoading && _logs.isEmpty && _uploads.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Constant.lightBlueColor),
      );
    }

    if (_errorMessage != null && _caseItem.lan.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchCaseDetails,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 130),
            const Icon(Icons.cloud_off_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            CustomText(
              text: _errorMessage!,
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _fetchCaseDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constant.mediumBlueColor,
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const CustomText(text: 'Retry', color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    final branchName = _caseItem.branchName?.trim() ?? '';
    final branchCode = _caseItem.branchCode?.trim() ?? '';
    final branch = [
      if (branchName.isNotEmpty) branchName,
      if (branchCode.isNotEmpty) '($branchCode)',
    ].join(' ');

    final disbAmountFormatted = _caseItem.disbAmount != null
        ? '₹${NumberFormat('#,##,##0.00').format(_caseItem.disbAmount)}'
        : 'N/A';
    final posFormatted = _caseItem.principalOutstanding != null
        ? '₹${NumberFormat('#,##,##0.00').format(_caseItem.principalOutstanding)}'
        : 'N/A';

    return RefreshIndicator(
      onRefresh: _fetchCaseDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unified Details Card (identical to Details screen)
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Constant.mediumBlueColor,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.record_voice_over,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: _caseItem.lan,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              if (_caseItem.caseType != null &&
                                  _caseItem.caseType!.isNotEmpty)
                                CustomText(
                                  text: _caseItem.caseType!,
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(_caseItem.status),
                      ],
                    ),
                  ),

                  // Inside unified box contents
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: LAN Information
                        _buildSectionTitle(
                          icon: Icons.info_outline,
                          title: 'LAN Information',
                        ),
                        const SizedBox(height: 8),
                        ..._withDividers([
                          _detailRow(
                            Icons.person_outline,
                            'Customer Name',
                            _caseItem.custName,
                          ),
                          if (_caseItem.custAddress?.trim().isNotEmpty == true)
                            _detailRow(
                              Icons.home_outlined,
                              'Residential Address',
                              _caseItem.custAddress!,
                            ),
                          if (branch.isNotEmpty)
                            _detailRow(
                              Icons.storefront_outlined,
                              'Branch',
                              branch,
                            ),
                          if (_caseItem.region?.trim().isNotEmpty == true)
                            _detailRow(
                              Icons.map_outlined,
                              'Region',
                              _caseItem.region!,
                            ),
                          if (_caseItem.zone?.trim().isNotEmpty == true)
                            _detailRow(
                              Icons.my_location_outlined,
                              'Zone',
                              _caseItem.zone!,
                            ),
                          if (_caseItem.megaZone?.trim().isNotEmpty == true)
                            _detailRow(
                              Icons.public_outlined,
                              'MegaZone',
                              _caseItem.megaZone!,
                            ),
                          _detailRow(
                            Icons.currency_rupee,
                            'Disbursement Amount',
                            disbAmountFormatted,
                          ),
                          _detailRow(
                            Icons.calendar_today_outlined,
                            'Disbursement Date',
                            _caseItem.formattedDisbDate,
                          ),
                          _detailRow(
                            Icons.event_outlined,
                            'Maturity Date',
                            _caseItem.formattedMaturityDate,
                          ),
                          _detailRow(
                            Icons.monetization_on_outlined,
                            'Principle Outstanding',
                            posFormatted,
                          ),
                          _detailRow(
                            Icons.timer_outlined,
                            'DPD',
                            _caseItem.dpd != null
                                ? '${_caseItem.dpd} days'
                                : 'N/A',
                          ),
                        ]),

                        const SizedBox(height: 16),

                        // Section 2: Discrepancy Details
                        _buildSectionTitle(
                          icon: Icons.assignment_late_outlined,
                          title: 'Discrepancy Details',
                        ),
                        const SizedBox(height: 8),
                        ..._withDividers([
                          _detailRow(
                            Icons.report_problem_outlined,
                            'Customer Issue',
                            _valueOrNA(_caseItem.customerIssue),
                          ),
                          _detailRow(
                            Icons.comment_outlined,
                            'CDSM Remarks',
                            _valueOrNA(_caseItem.cdsmRemarks),
                          ),
                        ]),

                        const SizedBox(height: 16),

                        // Section 3: Field Observations
                        _buildSectionTitle(
                          icon: Icons.fact_check_outlined,
                          title: 'Field Observations',
                        ),
                        const SizedBox(height: 8),
                        ..._withDividers([
                          _detailRow(
                            Icons.home_work_outlined,
                            'Property Condition',
                            _valueOrNA(_caseItem.propertyCondition),
                          ),
                          if (_caseItem.loanRecoverable != null)
                            _detailRow(
                              Icons.help_outline,
                              'Loan Recoverable',
                              _caseItem.loanRecoverable! ? 'Yes' : 'No',
                            ),
                          if (_caseItem.nonRecoveryReason?.trim().isNotEmpty ==
                              true)
                            _detailRow(
                              Icons.warning_amber_outlined,
                              'Reason for Non Recovery',
                              _caseItem.nonRecoveryReason!,
                            ),
                        ]),

                        // Previous ZDSH Review if already exists
                        if (_hasZdshDetails) ...[
                          const SizedBox(height: 16),
                          _buildSectionTitle(
                            icon: Icons.assignment_ind_outlined,
                            title: 'Previous ZDSH Review',
                          ),
                          const SizedBox(height: 8),
                          ..._withDividers([
                            if (_caseItem.zdshDecision?.trim().isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.gavel_outlined,
                                'Decision',
                                _caseItem.zdshDecision!,
                                valueWidget:
                                    _buildStatusBadge(_caseItem.zdshDecision!),
                              ),
                            if (_caseItem.zdshResolutionPlan
                                    ?.trim()
                                    .isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.next_plan_outlined,
                                'Resolution Plan',
                                _caseItem.zdshResolutionPlan!,
                              ),
                            if (_caseItem.zdshVisited != null)
                              _detailRow(
                                Icons.pin_drop_outlined,
                                'ZDSH Visited',
                                _caseItem.zdshVisited! ? 'Yes' : 'No',
                              ),
                            if (_caseItem.zdshReviewed != null)
                              _detailRow(
                                Icons.check_circle_outline,
                                'ZDSH Reviewed',
                                _caseItem.zdshReviewed! ? 'Yes' : 'No',
                              ),
                            if (_caseItem.zdshRemarks?.trim().isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.rate_review_outlined,
                                'Remarks',
                                _caseItem.zdshRemarks!,
                              ),
                            if (_caseItem.zdshComments?.trim().isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.notes_outlined,
                                'Comments',
                                _caseItem.zdshComments!,
                              ),
                          ]),
                        ],

                        // Previous MZDSH Review if already exists
                        if (_hasMzdshDetails) ...[
                          const SizedBox(height: 16),
                          _buildSectionTitle(
                            icon: Icons.supervisor_account_outlined,
                            title: 'MZDSH Review',
                          ),
                          const SizedBox(height: 8),
                          ..._withDividers([
                            if (_caseItem.mzdshDecision?.trim().isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.gavel_outlined,
                                'Decision',
                                _caseItem.mzdshDecision!,
                                valueWidget:
                                    _buildStatusBadge(_caseItem.mzdshDecision!),
                              ),
                            if (_caseItem.mzdshVisited != null)
                              _detailRow(
                                Icons.pin_drop_outlined,
                                'MZDSH Visited',
                                _caseItem.mzdshVisited! ? 'Yes' : 'No',
                              ),
                            if (_caseItem.mzdshReviewed != null)
                              _detailRow(
                                Icons.check_circle_outline,
                                'MZDSH Reviewed',
                                _caseItem.mzdshReviewed! ? 'Yes' : 'No',
                              ),
                            if (_caseItem.mzdshRemarks?.trim().isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.rate_review_outlined,
                                'Remarks',
                                _caseItem.mzdshRemarks!,
                              ),
                          ]),
                        ],

                        // Audit Review if exists
                        if (_hasAuditDetails) ...[
                          const SizedBox(height: 16),
                          _buildSectionTitle(
                            icon: Icons.verified_user_outlined,
                            title: 'Audit Review',
                          ),
                          const SizedBox(height: 8),
                          ..._withDividers([
                            if (_caseItem.auditFinding?.trim().isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.find_in_page_outlined,
                                'Audit Finding',
                                _caseItem.auditFinding!,
                              ),
                            if (_caseItem.isSubstantiated != null)
                              _detailRow(
                                Icons.task_alt,
                                'Is Substantiated',
                                _caseItem.isSubstantiated! ? 'Yes' : 'No',
                              ),
                            if (_caseItem.actionRecommended
                                    ?.trim()
                                    .isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.recommend_outlined,
                                'Action Recommended',
                                _caseItem.actionRecommended!,
                              ),
                            if (_caseItem.auditRemarks?.trim().isNotEmpty ==
                                true)
                              _detailRow(
                                Icons.comment_outlined,
                                'Audit Remarks',
                                _caseItem.auditRemarks!,
                              ),
                            if (_caseItem.canBeClosed != null)
                              _detailRow(
                                Icons.lock_clock_outlined,
                                'Can Be Closed',
                                _caseItem.canBeClosed! ? 'Yes' : 'No',
                              ),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Approval Action Form Card
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Constant.mediumBlueColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.rate_review_outlined,
                              color: Constant.mediumBlueColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const CustomText(
                            text: 'ZDSH Review & Action',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF102F54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 1. Visited Dropdown (Yes/No)
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedVisited,
                        decoration: InputDecoration(
                          labelText: 'Visited *',
                          hintText: 'Select Visited',
                          labelStyle: const TextStyle(fontSize: 14),
                          hintStyle:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          prefixIcon: const Icon(Icons.pin_drop_outlined,
                              size: 20, color: Colors.grey),
                        ),
                        items: visitedOptions.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: CustomText(text: item, fontSize: 14),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedVisited = val),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please select Visited'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // 2. Reviewed Dropdown (Yes/No)
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedReviewed,
                        decoration: InputDecoration(
                          labelText: 'Reviewed *',
                          hintText: 'Select Reviewed',
                          labelStyle: const TextStyle(fontSize: 14),
                          hintStyle:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          prefixIcon: const Icon(Icons.check_circle_outline,
                              size: 20, color: Colors.grey),
                        ),
                        items: reviewedOptions.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: CustomText(text: item, fontSize: 14),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedReviewed = val),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please select Reviewed'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // 3. Resolution Plan Dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedResolutionPlan,
                        decoration: InputDecoration(
                          labelText: 'Resolution Plan *',
                          hintText: 'Select Resolution Plan',
                          labelStyle: const TextStyle(fontSize: 14),
                          hintStyle:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          prefixIcon: const Icon(Icons.next_plan_outlined,
                              size: 20, color: Colors.grey),
                        ),
                        items: resolutionPlanOptions.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: CustomText(text: item, fontSize: 14),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedResolutionPlan = val),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please select Resolution Plan'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // 4. Decision Dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedDecision,
                        decoration: InputDecoration(
                          labelText: 'Decision *',
                          hintText: 'Select Decision',
                          labelStyle: const TextStyle(fontSize: 14),
                          hintStyle:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          prefixIcon: const Icon(Icons.gavel_outlined,
                              size: 20, color: Colors.grey),
                        ),
                        items: decisionOptions.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: CustomText(text: item, fontSize: 14),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedDecision = val),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please select Decision'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // 5. Remarks Textarea (Optional)
                      TextFormField(
                        controller: remarksController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          hintText: 'Enter review remarks...',
                          labelStyle: const TextStyle(fontSize: 14),
                          hintStyle:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 36),
                            child: Icon(Icons.comment_outlined,
                                size: 20, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _submitApproval,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constant.mediumBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.send_outlined,
                              color: Colors.white, size: 18),
                          label: const CustomText(
                            text: 'Submit Approval',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UPLOADS TAB (With View & Download Modal)
  // ==========================================
  Widget _buildUploadsTab() {
    if (_isLoading && _uploads.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Constant.lightBlueColor),
      );
    }

    if (_uploads.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchCaseDetails,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 150),
            Icon(Icons.photo_library_outlined, size: 68, color: Colors.grey),
            SizedBox(height: 12),
            CustomText(
              text: 'No uploads found',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCaseDetails,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        itemCount: _uploads.length,
        itemBuilder: (context, index) => _buildUploadCard(_uploads[index]),
      ),
    );
  }

  Widget _buildUploadCard(VotUploadItem upload) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Constant.mediumBlueColor.withValues(alpha: 0.1),
                  child: Icon(
                    _getFileTypeIcon(upload.fileType),
                    color: Constant.mediumBlueColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: _formatFileType(upload.fileType),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF102F54),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: CustomText(
                              text: upload.fileType ?? 'Attachment',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (upload.filePath?.trim().isNotEmpty == true) ...[
                        Row(
                          children: [
                            const Icon(Icons.attach_file,
                                size: 13, color: Colors.grey),
                            const SizedBox(width: 3),
                            Expanded(
                              child: CustomText(
                                text: upload.filePath!,
                                fontSize: 11,
                                color: Colors.black87,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'By: ${_valueOrNA(upload.createdBy)}',
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          CustomText(
                            text: upload.formattedCreatedDate,
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _handleViewFile(upload),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Constant.mediumBlueColor,
                    side: const BorderSide(color: Constant.mediumBlueColor),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  label: const CustomText(
                    text: 'View',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Constant.mediumBlueColor,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _handleDownloadFile(upload),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.mediumBlueColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.download_outlined,
                      size: 15, color: Colors.white),
                  label: const CustomText(
                    text: 'Download',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleViewFile(VotUploadItem upload) async {
    final fileName = upload.filePath?.trim() ?? '';
    if (fileName.isEmpty) {
      GlobalSnackbar.showError('File path is not available');
      return;
    }

    _showLoadingDialog('Opening file...');

    try {
      final response = await ApiClient().downloadVoiceOfTeamFile(fileName);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (response != null && response.bodyBytes.isNotEmpty) {
        final Uint8List bytes = response.bodyBytes;
        final String ext = fileName.split('.').last.toLowerCase();
        final bool isImage =
            ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);

        if (isImage) {
          _showImageModal(fileName, bytes);
        } else {
          final tempDir = await getTemporaryDirectory();
          final safeName = fileName.split('/').last;
          final file = File('${tempDir.path}/$safeName');
          await file.writeAsBytes(bytes);
          await Share.shareXFiles([XFile(file.path)], text: fileName);
        }
      } else {
        GlobalSnackbar.showError('Failed to load file');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        GlobalSnackbar.showError('Error loading file: $e');
      }
    }
  }

  Future<void> _handleDownloadFile(VotUploadItem upload) async {
    final fileName = upload.filePath?.trim() ?? '';
    if (fileName.isEmpty) {
      GlobalSnackbar.showError('File path is not available');
      return;
    }

    _showLoadingDialog('Downloading file...');

    try {
      final response = await ApiClient().downloadVoiceOfTeamFile(fileName);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (response != null && response.bodyBytes.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final safeName = fileName.split('/').last;
        final file = File('${tempDir.path}/$safeName');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          GlobalSnackbar.showSuccess('File downloaded successfully');
          await Share.shareXFiles([XFile(file.path)], text: fileName);
        }
      } else {
        GlobalSnackbar.showError('Failed to download file');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        GlobalSnackbar.showError('Error downloading file: $e');
      }
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Constant.lightBlueColor),
              const SizedBox(width: 16),
              CustomText(text: message, fontSize: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageModal(String fileName, Uint8List fileBytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Constant.mediumBlueColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: fileName.split('/').last,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: Colors.white, size: 20),
                    onPressed: () async {
                      final tempDir = await getTemporaryDirectory();
                      final safeName = fileName.split('/').last;
                      final file = File('${tempDir.path}/$safeName');
                      await file.writeAsBytes(fileBytes);
                      await Share.shareXFiles([XFile(file.path)],
                          text: fileName);
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                color: Colors.black87,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(
                      fileBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LOGS TAB
  // ==========================================
  Widget _buildLogsTab() {
    if (_isLoading && _logs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Constant.lightBlueColor),
      );
    }

    if (_logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchCaseDetails,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 150),
            Icon(Icons.history_outlined, size: 68, color: Colors.grey),
            SizedBox(height: 12),
            CustomText(
              text: 'No logs found',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCaseDetails,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        itemCount: _logs.length,
        itemBuilder: (context, index) => _buildLogCard(_logs[index]),
      ),
    );
  }

  Widget _buildLogCard(VotLogItem log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Constant.mediumBlueColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CustomText(
                      text: _valueOrNA(log.action),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Constant.mediumBlueColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CustomText(
                  text: log.formattedCreatedDt,
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (log.status?.trim().isNotEmpty == true) ...[
              _detailRow(Icons.flag_outlined, 'Status', log.status!),
              const SizedBox(height: 4),
            ],
            _detailRow(Icons.person_outline, 'User', _valueOrNA(log.createdBy)),
            if (log.remarks?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 4),
              _detailRow(Icons.comment_outlined, 'Remarks', log.remarks!),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Constant.mediumBlueColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Constant.mediumBlueColor),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: title,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF102F54),
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
    Widget? valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Constant.lightBlueColor),
        const SizedBox(width: 8),
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
          child: valueWidget ??
              CustomText(
                text: value.trim().isNotEmpty ? value.trim() : 'N/A',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg = Colors.blue.shade50;
    Color fg = Colors.blue.shade700;

    if (s.contains('complete') ||
        s.contains('approved') ||
        s.contains('success') ||
        s.contains('closed')) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    } else if (s.contains('reject') || s.contains('cancel')) {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
    } else if (s.contains('pending') ||
        s.contains('progress') ||
        s.contains('review') ||
        s.contains('audit')) {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: CustomText(
        text: status,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: fg,
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const Divider(height: 15, thickness: 0.6));
      }
    }
    return result;
  }

  IconData _getFileTypeIcon(String? fileType) {
    final type = fileType?.toLowerCase() ?? '';
    if (type.contains('property')) {
      return Icons.home_work_outlined;
    } else if (type.contains('business')) {
      return Icons.business_outlined;
    } else if (type.contains('residence')) {
      return Icons.home_outlined;
    }
    return Icons.image_outlined;
  }

  String _formatFileType(String? fileType) {
    if (fileType == null || fileType.isEmpty) return 'Attachment';
    if (fileType == 'PropertyPhoto') return 'Property Photo';
    if (fileType == 'BusinessPhoto') return 'Business Photo';
    if (fileType == 'ResidencePhoto') return 'Residence Photo';
    return fileType;
  }

  String _valueOrNA(String? value) =>
      value != null && value.trim().isNotEmpty ? value.trim() : 'N/A';
}
