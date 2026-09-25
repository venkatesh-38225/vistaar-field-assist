import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_confirm_dialog.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/status_indicator.dart';

import 'physical_filing_logs_tab.dart';

class SubmitDocumentsReturnScreen extends StatefulWidget {
  const SubmitDocumentsReturnScreen({
    super.key,
    required this.caseId,
    required this.submittedBy,
  });

  final int caseId;
  final String submittedBy;

  @override
  State<SubmitDocumentsReturnScreen> createState() =>
      _SubmitDocumentsReturnScreenState();
}

class _SubmitDocumentsReturnScreenState
    extends State<SubmitDocumentsReturnScreen> {
  static const _courierOptions = <String, String>{
    'Professional': 'Professional Courier',
    'DTDC': 'DTDC Courier',
  };

  final _formKey = GlobalKey<FormState>();
  final _dispatchDateController = TextEditingController();
  final _podNumberController = TextEditingController();
  final _remarksController = TextEditingController();

  PhysicalFilingCase? _details;
  DateTime? _dispatchDate;
  String? _courierApiValue;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _dispatchDateController.dispose();
    _podNumberController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiClient().getPhysicalFilingById(widget.caseId);
      if (!mounted) return;

      if (response?.success == true && response?.data != null) {
        setState(() => _details = response!.data!);
      } else {
        setState(() {
          _details = null;
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to fetch document return details';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _details = null;
        _errorMessage = 'Unable to load document return details';
      });
      GlobalSnackbar.showError('Unable to load document return details');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDispatchDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dispatchDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _dispatchDate = picked;
      _dispatchDateController.text = DateFormat('dd-MMM-yyyy').format(picked);
    });
  }

  String _toApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
      GlobalSnackbar.showError('Please complete all required fields');
      return;
    }

    final details = _details;
    final dispatchDate = _dispatchDate;
    final courierName = _courierApiValue;
    final submittedBy = widget.submittedBy.trim();

    if (details == null || details.caseId == 0) {
      GlobalSnackbar.showError('Case ID is unavailable');
      return;
    }
    if (dispatchDate == null || courierName == null) return;
    if (submittedBy.isEmpty) {
      GlobalSnackbar.showError('Submitted user ID is unavailable');
      return;
    }

    final confirmed = await CustomConfirmDialog.show(
      context: context,
      title: 'Submit Document Return',
      highlightItems: {
        'LAN': details.lan,
        'Dispatch Date': DateFormat('dd-MMM-yyyy').format(dispatchDate),
        'Courier Name': courierName,
        if (_podNumberController.text.trim().isNotEmpty)
          'POD Number': _podNumberController.text.trim(),
      },
      message:
          'Are you sure you want to submit document return details for LAN ${details.lan}?',
      confirmText: 'Confirm & Return',
      icon: Icons.local_shipping_outlined,
      iconColor: Constant.mediumBlueColor,
      iconBackgroundColor: const Color(0xFFE3F2FD),
    );
    if (confirmed != true || !mounted) return;

    final payload = <String, dynamic>{
      'caseId': details.caseId,
      'podNumber': _podNumberController.text.trim(),
      'dispatchDate': _toApiDate(dispatchDate),
      'courierName': courierName,
      'remarks': _remarksController.text.trim(),
      'submittedBy': submittedBy,
    };

    print("Document Return Payload: $payload");

    setState(() => _isSubmitting = true);
    try {
      final response =
          await ApiClient().submitPhysicalFilingDocumentReturn(payload);
      if (!mounted) return;

      if (response?['success'] == true) {
        GlobalSnackbar.showSuccess(
          response?['message']?.toString() ??
              'Document return submitted successfully',
        );
        Get.back(result: true);
      } else {
        GlobalSnackbar.showError(
          response?['message']?.toString() ??
              'Failed to submit document return',
        );
      }
    } catch (_) {
      if (mounted) {
        GlobalSnackbar.showError('Unable to submit document return');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
            text: 'Submit Document Return',
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
              onRefresh: _fetchDetails,
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
        onRefresh: _fetchDetails,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 130),
            const Icon(Icons.cloud_off_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            CustomText(
              text: _errorMessage ?? 'No document return details available',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: _fetchDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      );
    }

    final details = _details!;
    return RefreshIndicator(
      onRefresh: _fetchDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCaseDetailsCard(details),
              const SizedBox(height: 16),
              _buildReturnDetailsCard(),
              const SizedBox(height: 16),
              _buildChecklistSection(details),
              const SizedBox(height: 18),
              SizedBox(
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
                    text: _isSubmitting ? 'Submitting...' : 'Submit',
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

  Widget _buildReturnDetailsCard() {
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
              text: 'Document Return Details',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102F54),
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Dispatch Date *',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dispatchDateController,
              readOnly: true,
              onTap: _pickDispatchDate,
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please select dispatch date'
                      : null,
              decoration: _inputDecoration(
                hint: 'Select dispatch date',
                suffixIcon: Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Courier Name *',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _courierApiValue,
              isExpanded: true,
              decoration: _inputDecoration(hint: 'Select courier'),
              hint: const Text('Select courier'),
              items: _courierOptions.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _courierApiValue = value),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please select courier name'
                      : null,
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: 'POD Number *',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _podNumberController,
              textCapitalization: TextCapitalization.characters,
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter POD number'
                      : null,
              decoration: _inputDecoration(hint: 'Enter POD number'),
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Remarks *',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _remarksController,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter remarks'
                      : null,
              decoration: _inputDecoration(hint: 'Enter remarks'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      suffixIcon: suffixIcon == null ? null : Icon(suffixIcon, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Constant.mediumBlueColor),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                // _detailRow(Icons.info_outline, 'Status', details.status),
                _detailRow(
                  Icons.info_outline,
                  ' Status',
                  details.status,
                  valueWidget: _buildCaseStatus(
                    details.status,
                  ),
                ),
                _detailRow(
                  Icons.assignment_return_outlined,
                  'Document Return Status',
                  details.documentReturnStatus ?? '',
                  valueWidget: _buildDocumentReturnStatus(
                    details.documentReturnStatus,
                  ),
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
                  details.documentTransmissionType ?? '',
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentReturnStatus(String? status) {
    final value = status?.trim() ?? '';
    if (value.isEmpty) {
      return const CustomText(
        text: 'N/A',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusIndicator.fromStatus(value),
    );
  }

    Widget _buildCaseStatus(String? status) {
    final value = status?.trim() ?? '';
    if (value.isEmpty) {
      return const CustomText(
        text: 'N/A',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusIndicator.fromStatus(value),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool showDivider = true,
    Widget? valueWidget,
  }) {
    return Column(
      children: [
        Row(
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
            Expanded(
              child: valueWidget ??
                  CustomText(
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

  Widget _buildChecklistSection(PhysicalFilingCase details) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        initiallyExpanded: false,
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        leading: const Icon(
          Icons.fact_check_outlined,
          color: Constant.mediumBlueColor,
        ),
        title: CustomText(
          text: 'Document Checklist (${details.checklist.length})',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF102F54),
        ),
        subtitle: const CustomText(
          text: 'Tap to view the submitted documents',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
        children: [
          if (details.checklist.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: CustomText(
                  text: 'No checklist documents available',
                  color: Colors.grey,
                ),
              ),
            )
          else
            for (var index = 0; index < details.checklist.length; index++)
              _buildChecklistCard(details.checklist[index], index),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(PhysicalFilingChecklistItem item, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 11),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      Constant.mediumBlueColor.withValues(alpha: 0.1),
                  child: CustomText(
                    text: '${index + 1}',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Constant.mediumBlueColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    text: item.documentName,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF102F54),
                  ),
                ),
                if (item.hasDiscrepancy)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const CustomText(
                      text: 'Discrepancy',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statusBox(
                    label: 'With Legal',
                    value: item.legalAvailable ? 'Yes' : 'No',
                    color: item.legalAvailable ? Colors.green : Colors.red,
                    icon: item.legalAvailable
                        ? Icons.check_circle
                        : Icons.cancel_outlined,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _statusBox(
                    label: 'Received by Field',
                    value: item.fieldReceived == null
                        ? 'Pending'
                        : item.fieldReceived!
                            ? 'Yes'
                            : 'No',
                    color: item.fieldReceived == null
                        ? Colors.orange
                        : item.fieldReceived!
                            ? Colors.green
                            : Colors.red,
                    icon: item.fieldReceived == null
                        ? Icons.hourglass_empty
                        : item.fieldReceived!
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                  ),
                ),
              ],
            ),
            if (item.legalComments?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _commentBox(
                title: 'Legal Comments',
                value: item.legalComments!.trim(),
                color: Colors.amber,
                icon: Icons.gavel_outlined,
              ),
            ],
            if (item.fieldComments?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              _commentBox(
                title: 'Field Comments',
                value: item.fieldComments!.trim(),
                color: Colors.blue,
                icon: Icons.comment_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBox({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: CustomText(
                  text: value,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _commentBox({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                const SizedBox(height: 3),
                CustomText(
                  text: value,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
