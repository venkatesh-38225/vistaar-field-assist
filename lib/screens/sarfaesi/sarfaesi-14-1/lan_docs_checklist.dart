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

class LanDocsChecklistScreen extends StatefulWidget {
  const LanDocsChecklistScreen({
    super.key,
    required this.caseId,
    required this.submittedBy,
  });

  final int caseId;
  final String submittedBy;

  @override
  State<LanDocsChecklistScreen> createState() => _LanDocsChecklistScreenState();
}

class _LanDocsChecklistScreenState extends State<LanDocsChecklistScreen> {
  PhysicalFilingCase? _details;
  final Map<int, bool?> _fieldSelections = {};
  final Map<int, String> _fieldComments = {};
  final Map<int, GlobalKey> _checklistItemKeys = {};
  int? _invalidChecklistItemId;
  int? _invalidCommentItemId;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
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
        final details = response!.data!;
        setState(() {
          _details = details;
          _fieldSelections
            ..clear()
            ..addEntries(
              details.checklist.map(
                (item) => MapEntry(item.id, item.fieldReceived),
              ),
            );
          _fieldComments
            ..clear()
            ..addEntries(
              details.checklist.where(_requiresFieldComment).map(
                    (item) => MapEntry(item.id, item.fieldComments ?? ''),
                  ),
            );
          _checklistItemKeys
            ..clear()
            ..addEntries(
              details.checklist.map(
                (item) => MapEntry(item.id, GlobalKey()),
              ),
            );
          _invalidChecklistItemId = null;
          _invalidCommentItemId = null;
        });
      } else {
        setState(() {
          _details = null;
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to fetch checklist details';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _details = null;
        _errorMessage = 'Unable to load checklist details';
      });
      GlobalSnackbar.showError('Unable to load checklist details');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setFieldSelection(int checklistItemId, bool value) {
    setState(() {
      _fieldSelections[checklistItemId] = value;
      if (_invalidChecklistItemId == checklistItemId) {
        _invalidChecklistItemId = null;
      }
    });
  }

  void _setFieldComment(int checklistItemId, String value) {
    _fieldComments[checklistItemId] = value;
    if (_invalidCommentItemId == checklistItemId && value.trim().isNotEmpty) {
      setState(() => _invalidCommentItemId = null);
    }
  }

  bool _requiresFieldComment(PhysicalFilingChecklistItem item) {
    return item.hasDiscrepancy;
  }

  bool _isChecklistItemEditable(PhysicalFilingChecklistItem item) {
    final hasActiveDiscrepancy = _details?.checklist
            .any((checklistItem) => checklistItem.hasDiscrepancy) ??
        false;

    // On a returned checklist, the backend's current hasDiscrepancy flag is
    // the only source of truth. Old legal comments may remain in the response
    // after a document is resolved and must not make it editable again.
    if (hasActiveDiscrepancy) return item.hasDiscrepancy;

    // Before the first submission there is no discrepancy yet, so unanswered
    // documents must remain selectable. Previously saved answers stay locked.
    return item.fieldReceived == null;
  }

  void _scrollToChecklistItem(int checklistItemId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      final itemContext = _checklistItemKeys[checklistItemId]?.currentContext;
      if (itemContext != null && itemContext.mounted) {
        Scrollable.ensureVisible(
          itemContext,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.08,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      }
    });
  }

  bool _validateSelections(PhysicalFilingCase details) {
    PhysicalFilingChecklistItem? firstUnselected;
    for (final item in details.checklist) {
      if (_isChecklistItemEditable(item) && _fieldSelections[item.id] == null) {
        firstUnselected = item;
        break;
      }
    }

    if (firstUnselected == null) return true;
    final missingItem = firstUnselected;

    setState(() => _invalidChecklistItemId = missingItem.id);
    GlobalSnackbar.showError(
      'Please select Yes or No for ${missingItem.documentName}',
    );
    _scrollToChecklistItem(missingItem.id);
    return false;
  }

  bool _validateDiscrepancyComments(PhysicalFilingCase details) {
    for (final item in details.checklist) {
      if (_requiresFieldComment(item) &&
          (_fieldComments[item.id]?.trim().isEmpty ?? true)) {
        setState(() => _invalidCommentItemId = item.id);
        GlobalSnackbar.showError(
          'Please enter comments for ${item.documentName}',
        );
        _scrollToChecklistItem(item.id);
        return false;
      }
    }
    return true;
  }

  Future<void> _submitChecklist() async {
    final details = _details;
    if (details == null || details.checklist.isEmpty || _isSubmitting) return;
    if (!_validateSelections(details)) return;
    if (!_validateDiscrepancyComments(details)) return;

    if (widget.submittedBy.trim().isEmpty) {
      GlobalSnackbar.showError('Submitted user ID is unavailable');
      return;
    }

    final confirmed = await CustomConfirmDialog.show(
      context: context,
      title: 'Submit Document Checklist',
      highlightItems: {
        'LAN': details.lan,
        'Status': details.status,
        'Total Documents': '${details.checklist.length}',
      },
      message:
          'Are you sure you want to submit this document checklist for LAN ${details.lan}?',
      confirmText: 'Submit Checklist',
      icon: Icons.checklist_rtl_rounded,
      iconColor: Constant.mediumBlueColor,
      iconBackgroundColor: const Color(0xFFE3F2FD),
    );
    if (confirmed != true || !mounted) return;

    final payload = <String, dynamic>{
      'caseId': details.id,
      'checklist': details.checklist
          .map(
            (item) => <String, dynamic>{
              'checklistItemId': item.id,
              'isReceived': _fieldSelections[item.id],
              'comments': _requiresFieldComment(item)
                  ? _fieldComments[item.id]?.trim()
                  : item.fieldComments,
            },
          )
          .toList(),
      'submittedBy': widget.submittedBy.trim(),
    };

    print('Submitting checklist payload: $payload');

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient().submitPhysicalFilingChecklist(payload);
      if (!mounted) return;

      print(
          'Checklist submission response: ${response?['success']}, ${response?['message']}');

      if (response?['success'] == true) {
        GlobalSnackbar.showSuccess(
          response?['message']?.toString() ??
              'Checklist submitted successfully',
        );
        Get.back(result: true);
      } else {
        GlobalSnackbar.showError(
          response?['message']?.toString() ?? 'Failed to submit checklist',
        );
      }
    } catch (error) {
      if (mounted) {
        GlobalSnackbar.showError('Unable to submit checklist');
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
            text: 'LAN Documents Checklist',
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
              text: _errorMessage ?? 'No checklist details available',
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
        child: Column(
          children: [
            _buildCaseDetailsCard(details),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(
                  Icons.fact_check_outlined,
                  color: Constant.mediumBlueColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: 'Document Checklist (${details.checklist.length})',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF102F54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: 'Compare Legal availability and record Field receipt.',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            if (details.checklist.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
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
            if (details.checklist.isNotEmpty) ...[
              const SizedBox(height: 8),
              const CustomText(
                text:
                    'All documents must have a Yes or No selection before submission.',
                textAlign: TextAlign.center,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitChecklist,
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
                    text: _isSubmitting ? 'Submitting...' : 'Submit Checklist',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
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
                    details.podNumber.isEmpty ? 'N/A' : details.podNumber,
                  ),
                  _detailRow(
                    Icons.local_shipping_outlined,
                    'Courier Name',
                    details.courierName.isEmpty ? 'N/A' : details.courierName,
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
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Expanded(
              child: CustomText(
                text: value.isEmpty ? 'N/A' : value,
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

  Widget _buildChecklistCard(PhysicalFilingChecklistItem item, int index) {
    final selection = _fieldSelections[item.id];
    final legalColor = item.legalAvailable ? Colors.green : Colors.red;
    final isMismatch = selection != null && selection != item.legalAvailable;
    final isEditable = _isChecklistItemEditable(item);
    final isCommentInvalid = _invalidCommentItemId == item.id;
    final isInvalid = _invalidChecklistItemId == item.id || isCommentInvalid;

    return Card(
      key: _checklistItemKeys[item.id],
      elevation: isMismatch ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 11),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMismatch
              ? Colors.orange.shade600
              : isInvalid
                  ? Colors.red
                  : Colors.transparent,
          width: isMismatch || isInvalid ? 1.8 : 0,
        ),
      ),
      child: Container(
        decoration: isMismatch
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.18),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
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
                  if (isMismatch)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Discrepancy',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: legalColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: CustomText(
                        text: 'Available with Legal user',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    Icon(
                      item.legalAvailable
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      size: 17,
                      color: legalColor,
                    ),
                    const SizedBox(width: 5),
                    CustomText(
                      text: item.legalAvailable ? 'Yes' : 'No',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: legalColor,
                    ),
                  ],
                ),
              ),
              if (item.legalComments?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        text: 'Legal Comments',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 3),
                      CustomText(
                        text: item.legalComments!.trim(),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 22),
              const CustomText(
                text: 'Received by Field user?',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              if (!isEditable) ...[
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.black45),
                    SizedBox(width: 5),
                    Expanded(
                      child: CustomText(
                        text:
                            'No discrepancy reported. Saved selection is read-only.',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _radioOption(
                      label: 'Yes',
                      value: true,
                      groupValue: selection,
                      activeColor: Colors.green,
                      onChanged: isEditable
                          ? (value) => _setFieldSelection(item.id, value)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _radioOption(
                      label: 'No',
                      value: false,
                      groupValue: selection,
                      activeColor: Colors.red,
                      onChanged: isEditable
                          ? (value) => _setFieldSelection(item.id, value)
                          : null,
                    ),
                  ),
                ],
              ),
              if (_requiresFieldComment(item)) ...[
                const SizedBox(height: 14),
                const CustomText(
                  text: 'Field Comments *',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  key: ValueKey('field-comment-${item.id}'),
                  initialValue: _fieldComments[item.id] ?? '',
                  enabled: isEditable,
                  onChanged: (value) => _setFieldComment(item.id, value),
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Enter comments for this discrepancy',
                    errorText:
                        isCommentInvalid ? 'Field comments are required' : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioOption({
    required String label,
    required bool value,
    required bool? groupValue,
    required Color activeColor,
    required ValueChanged<bool>? onChanged,
  }) {
    final isSelected = groupValue == value;
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color:
              isSelected ? activeColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onChanged == null
                ? Colors.grey.shade300
                : isSelected
                    ? activeColor
                    : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: onChanged == null
                  ? Colors.grey
                  : isSelected
                      ? activeColor
                      : Colors.grey,
            ),
            const SizedBox(width: 6),
            CustomText(
              text: label,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: onChanged == null
                  ? Colors.black38
                  : isSelected
                      ? activeColor
                      : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
