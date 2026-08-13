import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import 'lan_docs_checklist.dart';
import 'assign_advocate.dart';
import 'filing_details.dart';
import 'physical_filing_entry.dart';
import 'physical_filing_details.dart';

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

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (_requiresPhysicalFiling(record)) {
            final result = await Get.to(() => PhysicalFilingEntryScreen(
                  caseId: record.id,
                  updatedBy: widget.profile.data?.employeeId ?? '',
                ));
            if (result == true) {
              _fetchRecords();
            }
          } else if (_isFilingDetails(record)) {
            final result = await Get.to(() => FilingDetailsScreen(
                  caseId: record.id,
                  updatedBy: widget.profile.data?.employeeId ?? '',
                ));
            if (result == true) {
              _fetchRecords();
            }
          } else if (_isAdvocateAssignment(record)) {
            final result = await Get.to(() => AssignAdvocateScreen(
                  caseId: record.id,
                  updatedBy: widget.profile.data?.employeeId ?? '',
                ));
            if (result == true) {
              _fetchRecords();
            }
          } else if (_selectedStatus == 'Pending') {
            final result = await Get.to(() => LanDocsChecklistScreen(
                  caseId: record.id,
                  submittedBy: widget.profile.data?.employeeId ?? '',
                ));
            if (result == true) {
              _fetchRecords();
            }
          } else {
            await Get.to(() => PhysicalFilingDetailsScreen(
                  caseId: record.id,
                ));
          }
        },
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
                        CustomText(
                          text: record.status,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
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
            ],
          ),
        ),
      ),
    );
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
