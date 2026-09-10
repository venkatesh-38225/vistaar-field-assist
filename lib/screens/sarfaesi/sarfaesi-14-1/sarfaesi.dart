import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/status_indicator.dart';

import 'lan_docs_checklist.dart';
import 'assign_advocate.dart';
import 'filing_details.dart';
import 'physical_filing_entry.dart';
import 'physical_filing_details.dart';
import 'submit_documents_return.dart';

class Sarfaesi14PhysicalFilingScreen extends StatefulWidget {
  const Sarfaesi14PhysicalFilingScreen({
    super.key,
    required this.profile,
    required this.access,
  });

  final ProfileResponse profile;
  final String access;

  @override
  State<Sarfaesi14PhysicalFilingScreen> createState() =>
      _Sarfaesi14PhysicalFilingScreenState();
}

class _Sarfaesi14PhysicalFilingScreenState
    extends State<Sarfaesi14PhysicalFilingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _statusOptions = const [
    'Pending',
    'In Progress',
    'Completed',
  ];

  List<PhysicalFilingCase> _records = [];
  List<PhysicalFilingCase> _filteredRecords = [];
  String _selectedStatus = 'Pending';
  String? _errorMessage;
  bool _isLoading = false;
  int _requestSerial = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRecords);
    _fetchRecords();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRecords);
    _searchController.dispose();
    super.dispose();
  }

  String get _apiStatus =>
      _selectedStatus == 'In Progress' ? 'inprogress' : _selectedStatus;

  void _filterRecords() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<PhysicalFilingCase>.from(_records)
        : _records.where((record) {
            return record.lan.toLowerCase().contains(query) ||
                record.podNumber.toLowerCase().contains(query) ||
                record.courierName.toLowerCase().contains(query) ||
                record.status.toLowerCase().contains(query);
          }).toList();

    if (mounted) {
      setState(() => _filteredRecords = filtered);
    }
  }

  Future<void> _fetchRecords() async {
    final requestSerial = ++_requestSerial;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final userId = widget.profile.data?.employeeId ?? '';
      if (userId.isEmpty) {
        throw StateError('Employee ID is unavailable');
      }
      if (widget.access.trim().isEmpty) {
        throw StateError('Physical Filing module access is unavailable');
      }

      final response = await ApiClient().getPhysicalFilingByUser(
        userId: userId,
        role: widget.access.trim(),
        status: _apiStatus,
      );
      if (!mounted || requestSerial != _requestSerial) return;

      if (response?.success == true) {
        _records = response!.data;
        _filterRecords();
      } else {
        setState(() {
          _records = [];
          _filteredRecords = [];
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to fetch physical filing records';
        });
      }
    } catch (error) {
      if (!mounted || requestSerial != _requestSerial) return;
      setState(() {
        _records = [];
        _filteredRecords = [];
        _errorMessage = 'Unable to load physical filing records';
      });
      GlobalSnackbar.showError('Unable to load physical filing records');
    } finally {
      if (mounted && requestSerial == _requestSerial) {
        setState(() => _isLoading = false);
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
          text: 'SARFAESI 14 - Physical Filing',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: Column(
          children: [
            _buildStatusTabs(),
            const SizedBox(height: 12),
            _buildSearchField(),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchRecords,
                child: _buildRecordList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Row(
      children: _statusOptions.map((status) {
        final isSelected = _selectedStatus == status;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (isSelected) return;
              setState(() => _selectedStatus = status);
              _fetchRecords();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Constant.mediumBlueColor : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? Constant.mediumBlueColor
                      : Colors.grey.shade300,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CustomText(
                text: status,
                textAlign: TextAlign.center,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchField() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search LAN, POD or courier...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Constant.lightBlueColor),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          CustomText(
            text: _errorMessage!,
            textAlign: TextAlign.center,
            fontSize: 15,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: _fetchRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (_filteredRecords.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 130),
          const Icon(Icons.inbox_outlined, size: 68, color: Colors.grey),
          const SizedBox(height: 12),
          CustomText(
            text: 'No $_selectedStatus Records Found',
            textAlign: TextAlign.center,
            fontSize: 16,
            color: Colors.grey,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 2, bottom: 18),
      itemCount: _filteredRecords.length,
      itemBuilder: (context, index) =>
          _buildRecordCard(_filteredRecords[index]),
    );
  }

  Widget _buildRecordCard(PhysicalFilingCase record) {
    final dispatchDate = record.dispatchDate == null
        ? 'N/A'
        : DateFormat('dd-MMM-yyyy').format(record.dispatchDate!);
    
    final hasWithdrawalRequest = record.withdrawalStatus != null &&
        record.withdrawalStatus!.trim().isNotEmpty;
    final isPendingWithdrawal = hasWithdrawalRequest && 
        record.withdrawalStatus!.trim().toLowerCase() == 'pending';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => _openRecord(record),
            child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0x1A104D89),
                    child: Icon(
                      Icons.account_balance_outlined,
                      color: Constant.mediumBlueColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: record.lan,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constant.mediumBlueColor,
                        ),
                        const SizedBox(height: 3),
                        _buildStatusDisplay(record.status),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Divider(height: 22),
              _infoRow(Icons.calendar_today_outlined, 'Dispatch', dispatchDate),
              _infoRow(Icons.local_shipping_outlined, 'Courier',
                  record.courierName.isEmpty ? 'N/A' : record.courierName),
              _infoRow(Icons.confirmation_number_outlined, 'POD Number',
                  record.podNumber.isEmpty ? 'N/A' : record.podNumber),
              // Show withdrawal request info if pending
              if (isPendingWithdrawal) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_outlined,
                            size: 18,
                            color: Color(0xFFF57C00),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: CustomText(
                              text: 'Withdrawal Request Pending',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF57C00),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        text: 'Reason: ${record.withdrawalReason ?? 'N/A'}',
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        text: 'Status: ${record.withdrawalStatus ?? 'N/A'}',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF57C00),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
                mainAxisAlignment: hasWithdrawalRequest ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
              children: [
                // Only show Withdraw button if no withdrawal request exists
                if (!hasWithdrawalRequest)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => _showWithdrawDialog(record),
                        icon: const Icon(Icons.undo_outlined, size: 18),
                        label: const Text('Withdraw'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!hasWithdrawalRequest) const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _openRecord(record),
                  icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  label: Text(
                    _isDocumentReturnPending(record) ||
                            _selectedStatus == 'Pending'
                        ? 'Action'
                        : 'Details',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.mediumBlueColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRecord(PhysicalFilingCase record) async {
    if (_isDocumentReturnPending(record)) {
      final result = await Get.to(() => SubmitDocumentsReturnScreen(
            caseId: record.id,
            submittedBy: widget.profile.data?.employeeId ?? '',
          ));
      if (result == true) _fetchRecords();
      return;
    }

    if (_requiresPhysicalFiling(record) && record.dashboardStatus == "Pending") {
      final result = await Get.to(() => PhysicalFilingEntryScreen(
            caseId: record.id,
            updatedBy: widget.profile.data?.employeeId ?? '',
          ));
      if (result == true) _fetchRecords();
    } else if (_isFilingDetails(record) && record.dashboardStatus == "Pending") {
      final result = await Get.to(() => FilingDetailsScreen(
            caseId: record.id,
            updatedBy: widget.profile.data?.employeeId ?? '',
          ));
      if (result == true) _fetchRecords();
    } else if (_isAdvocateAssignment(record) && record.dashboardStatus == "Pending") {
      final result = await Get.to(() => AssignAdvocateScreen(
            caseId: record.id,
            updatedBy: widget.profile.data?.employeeId ?? '',
          ));
      if (result == true) _fetchRecords();
    } else if (_selectedStatus == 'Pending' && record.dashboardStatus == "Pending") {
      final result = await Get.to(() => LanDocsChecklistScreen(
            caseId: record.id,
            submittedBy: widget.profile.data?.employeeId ?? '',
          ));
      if (result == true) _fetchRecords();
    } else {
      await Get.to(() => PhysicalFilingDetailsScreen(caseId: record.id));
    }
  }

  Future<void> _showWithdrawDialog(PhysicalFilingCase record) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WithdrawDialog(
        record: record,
        employeeId: widget.profile.data?.employeeId ?? 'EMP001',
      ),
    );

    if (result != null && mounted) {
      GlobalSnackbar.showSuccess(result);
      _fetchRecords();
    }
  }

  bool _isDocumentReturnPending(PhysicalFilingCase record) {
    final status = record.status.trim().toLowerCase();
    final documentReturnStatus =
        record.documentReturnStatus?.trim().toLowerCase() ?? '';
    return status == 'document return pending' && documentReturnStatus == 'pending';
  }

  bool _isAdvocateAssignment(PhysicalFilingCase record) {
    final status = record.status.trim().toLowerCase();
    return status.contains('advocate') && status.contains('assigned');
  }

  bool _isFilingDetails(PhysicalFilingCase record) {
    final status = record.status.trim().toLowerCase();
    return status.contains('filing details');
  }

  bool _requiresPhysicalFiling(PhysicalFilingCase record) {
    if (_selectedStatus != 'Pending') return false;

    final filingType = record.filingType.trim().toLowerCase();
    final hasEFilingDetails = filingType.contains('e-filing') ||
        record.eFilingDate != null ||
        record.eFilingCaseNumber.trim().isNotEmpty;
    final hasPhysicalFilingDetails = record.physicalFilingDate != null ||
        record.physicalFilingCaseNumber.trim().isNotEmpty;

    return hasEFilingDetails && !hasPhysicalFilingDetails;
  }

  Widget _buildStatusDisplay(String status) {
    final lowerStatus = status.toLowerCase();
    final isWithdrawalStatus = lowerStatus.contains('withdraw');
    
    if (isWithdrawalStatus) {
      return StatusIndicator.fromStatus(status);
    }
    
    return CustomText(
      text: status,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.black54,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 7),
          SizedBox(
            width: 100,
            child: CustomText(
              text: label,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawDialog extends StatefulWidget {
  const _WithdrawDialog({
    required this.record,
    required this.employeeId,
  });

  final PhysicalFilingCase record;
  final String employeeId;

  @override
  State<_WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<_WithdrawDialog> {
  final TextEditingController _remarksController = TextEditingController();
  String? _withdrawalReason;
  bool _isSubmitting = false;

  static const _withdrawalReasons = [
    'Out of NPA',
    'Closed/Settled',
    'Dismissed',
    'Re-initiation',
  ];

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdrawSubmit() async {
    if (_withdrawalReason == null || _withdrawalReason!.trim().isEmpty) {
      GlobalSnackbar.showError('Please select a withdrawal reason');
      return;
    }
    if (_remarksController.text.trim().isEmpty) {
      GlobalSnackbar.showError('Please enter withdrawal remarks');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = <String, dynamic>{
        'caseId': widget.record.caseId,
        'withdrawalReason': _withdrawalReason!.trim(),
        'withdrawalRemarks': _remarksController.text.trim(),
        'requestedBy': widget.employeeId,
      };

      final response = await ApiClient().requestWithdrawal(payload);
      if (!mounted) return;

      if (response?['success'] == true) {
        final message = response?['message']?.toString() ??
            'Withdrawal request submitted successfully';
        Navigator.of(context).pop(message);
      } else {
        setState(() => _isSubmitting = false);
        GlobalSnackbar.showError(
          response?['message']?.toString() ??
              'Failed to submit withdrawal request',
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      GlobalSnackbar.showError('Unable to submit withdrawal request');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width * 0.96,
          minWidth: 300,
        ),
        child: Container(
          width: width * 0.96,
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0x1AF44336),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.undo_outlined,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Withdraw Request',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'LAN: ${widget.record.lan}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Constant.mediumBlueColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Withdrawal Reason *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _withdrawalReason,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                hint: const Text('Select withdrawal reason'),
                items: _withdrawalReasons
                    .map(
                      (reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      ),
                    )
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _withdrawalReason = value),
              ),
              const SizedBox(height: 18),
              const Text(
                'Remarks *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _remarksController,
                enabled: !_isSubmitting,
                minLines: 4,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Enter withdrawal remarks',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleWithdrawSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isSubmitting)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (_isSubmitting)
                          const SizedBox(width: 8)
                        else
                          const SizedBox.shrink(),
                        Text(
                          _isSubmitting
                              ? 'Submitting...'
                              : 'Confirm Withdraw',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
