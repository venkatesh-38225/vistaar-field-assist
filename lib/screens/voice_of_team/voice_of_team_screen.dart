import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/models/voice_of_team_models.dart';
import 'package:re_kyc_mobile_app/screens/voice_of_team/create_voice_of_team.dart';
import 'package:re_kyc_mobile_app/screens/voice_of_team/voice_of_team_approval.dart';
import 'package:re_kyc_mobile_app/screens/voice_of_team/voice_of_team_details.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class VoiceOfTeamScreen extends StatefulWidget {
  const VoiceOfTeamScreen({
    super.key,
    required this.profile,
    required this.access,
  });

  final ProfileResponse profile;
  final String access;

  @override
  State<VoiceOfTeamScreen> createState() => _VoiceOfTeamScreenState();
}

class _VoiceOfTeamScreenState extends State<VoiceOfTeamScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  late List<String> statusOptions;
  late String selectedStatus;

  // New tab data (LANs)
  List<VotLanItem> lanRecords = [];
  List<VotLanItem> filteredLanRecords = [];

  // Other tabs data (Cases)
  List<VotCaseItem> caseRecords = [];
  List<VotCaseItem> filteredCaseRecords = [];

  bool get isCreateAccess => widget.access.trim().toUpperCase() == 'CREATE';

  @override
  void initState() {
    super.initState();
    if (isCreateAccess) {
      statusOptions = ['New', 'In Progress', 'Completed'];
      selectedStatus = 'New';
    } else {
      statusOptions = ['Pending', 'In Progress', 'Completed'];
      selectedStatus = 'Pending';
    }

    fetchRecords();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      if (selectedStatus == 'New') {
        filteredLanRecords = lanRecords.where((item) {
          return item.lan.toLowerCase().contains(query) ||
              item.custName.toLowerCase().contains(query) ||
              item.empId.toLowerCase().contains(query);
        }).toList();
      } else {
        filteredCaseRecords = caseRecords.where((item) {
          return item.lan.toLowerCase().contains(query) ||
              item.custName.toLowerCase().contains(query) ||
              (item.branchName?.toLowerCase().contains(query) ?? false) ||
              (item.branchCode?.toLowerCase().contains(query) ?? false) ||
              item.status.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchRecords() async {
    setState(() => isLoading = true);

    final String empId = widget.profile.data?.employeeId ?? '';
    final String role = widget.profile.data?.role ?? '';

    try {
      if (selectedStatus == 'New') {
        final response = await ApiClient().getVotLansByUser(empId);
        if (mounted) {
          setState(() {
            lanRecords = response?.data ?? [];
            _applyLanFilter();
            isLoading = false;
          });
          if (response == null || !response.success) {
            GlobalSnackbar.showError(
                response?.message ?? 'Failed to fetch New LANs');
          }
        }
      } else {
        // InProgress or Completed or Pending
        String apiStatus = selectedStatus;
        if (selectedStatus == 'In Progress') {
          apiStatus = 'InProgress';
        }

        final response = await ApiClient().getVotCasesByUser(
          empId: empId,
          role: role,
          status: apiStatus,
        );
        if (mounted) {
          setState(() {
            caseRecords = response?.data ?? [];
            _applyCaseFilter();
            isLoading = false;
          });
          if (response == null || !response.success) {
            GlobalSnackbar.showError(
                response?.message ?? 'Failed to fetch cases');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        GlobalSnackbar.showError('Something went wrong: $e');
      }
    }
  }

  void _applyLanFilter() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredLanRecords = List.from(lanRecords);
    } else {
      filteredLanRecords = lanRecords.where((item) {
        return item.lan.toLowerCase().contains(query) ||
            item.custName.toLowerCase().contains(query) ||
            item.empId.toLowerCase().contains(query);
      }).toList();
    }
  }

  void _applyCaseFilter() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredCaseRecords = List.from(caseRecords);
    } else {
      filteredCaseRecords = caseRecords.where((item) {
        return item.lan.toLowerCase().contains(query) ||
            item.custName.toLowerCase().contains(query) ||
            (item.branchName?.toLowerCase().contains(query) ?? false) ||
            (item.branchCode?.toLowerCase().contains(query) ?? false) ||
            item.status.toLowerCase().contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(Icons.record_voice_over,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const CustomText(
              text: 'Voice of Team',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchRecords,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusTabs(),
              const SizedBox(height: 12),
              _buildSearchBarRow(),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Scroll down to refresh',
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_downward_sharp,
                    size: 10,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Constant.lightBlueColor,
                        ),
                      )
                    : selectedStatus == 'New'
                        ? _buildNewLanList()
                        : _buildCaseList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Row(
      children: statusOptions.map((status) {
        final bool isSelected = selectedStatus == status;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (selectedStatus != status) {
                setState(() {
                  selectedStatus = status;
                });
                fetchRecords();
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: isSelected ? Constant.mediumBlueColor : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected
                      ? Constant.mediumBlueColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: CustomText(
                  text: status,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchBarRow() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 3,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: selectedStatus == 'New'
                    ? 'Search LAN, Customer...'
                    : 'Search LAN, Customer, Branch...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        if (isCreateAccess) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Get.to(() => CreateVoiceOfTeamScreen(
                    profile: widget.profile,
                  ));
              if (result == true) fetchRecords();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constant.mediumYellowColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const CustomText(
              text: 'Create',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNewLanList() {
    if (filteredLanRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 70, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            CustomText(
              text: searchController.text.isNotEmpty
                  ? 'No matching LANs found'
                  : 'No New LANs available',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredLanRecords.length,
      itemBuilder: (context, index) {
        final item = filteredLanRecords[index];
        return _buildLanCard(item);
      },
    );
  }

  Widget _buildLanCard(VotLanItem item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Constant.mediumBlueColor.withValues(alpha: 0.1),
                  radius: 18,
                  child: const Icon(Icons.account_balance,
                      color: Constant.mediumBlueColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: item.lan,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF102F54),
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        text: item.custName,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_outlined,
                        size: 15, color: Colors.grey),
                    const SizedBox(width: 5),
                    CustomText(
                      text: 'Emp ID: ${item.empId}',
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.to(() => CreateVoiceOfTeamScreen(
                          profile: widget.profile,
                          initialLan: item,
                        ));
                    if (result == true) fetchRecords();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.mediumBlueColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note,
                      color: Colors.white, size: 16),
                  label: const CustomText(
                    text: 'CREATE',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseList() {
    if (filteredCaseRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.record_voice_over_outlined,
                size: 70, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            CustomText(
              text: searchController.text.isNotEmpty
                  ? 'No matching records found'
                  : 'No $selectedStatus cases found',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredCaseRecords.length,
      itemBuilder: (context, index) {
        final item = filteredCaseRecords[index];
        return _buildCaseCard(item);
      },
    );
  }

  Widget _buildCaseCard(VotCaseItem record) {
    final bool canAct = !isCreateAccess && (selectedStatus == 'Pending');
    // final bool canAct = !isCreateAccess && (selectedStatus == 'Pending' ||record.status.toLowerCase().contains('pending'));

    final disbAmountFormatted = record.disbAmount != null
        ? '₹${NumberFormat('#,##,##0').format(record.disbAmount)}'
        : 'N/A';
    final posFormatted = record.principalOutstanding != null
        ? '₹${NumberFormat('#,##,##0').format(record.principalOutstanding)}'
        : 'N/A';

    final branchName = record.branchName?.trim() ?? '';
    final branchCode = record.branchCode?.trim() ?? '';
    final branch = [
      if (branchName.isNotEmpty) branchName,
      if (branchCode.isNotEmpty) '($branchCode)',
    ].join(' ');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: LAN and Status badge
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Constant.lightBlueColor.withValues(alpha: 0.1),
                      radius: 18,
                      child: const Icon(Icons.record_voice_over,
                          color: Constant.lightBlueColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: record.lan,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF102F54),
                          ),
                          CustomText(
                            text: record.custName,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(record.status),
                  ],
                ),
                const Divider(height: 16),

                // Info Rows
                if (branch.isNotEmpty)
                  _infoRow(Icons.storefront_outlined, 'Branch', branch),
                _infoRow(
                  Icons.currency_rupee,
                  'Disbursed',
                  '$disbAmountFormatted',
                ),
                _infoRow(
                  Icons.currency_rupee,
                  'POS',
                  '$posFormatted',
                ),
                if (record.dpd != null)
                  _infoRow(
                    Icons.timer_outlined,
                    'DPD',
                    '${record.dpd} days',
                  ),
                if (record.customerIssue?.trim().isNotEmpty == true)
                  _infoRow(
                    Icons.report_problem_outlined,
                    'Issue',
                    record.customerIssue!,
                  ),
                if (record.zdshDecision?.trim().isNotEmpty == true)
                  _infoRow(
                    Icons.gavel_outlined,
                    'ZDSH Decision',
                    record.zdshDecision!,
                  ),
                if (record.createdDt != null)
                  _infoRow(
                    Icons.schedule_outlined,
                    'Created Date',
                    DateFormat('dd-MMM-yyyy').format(record.createdDt!),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Action Buttons Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Get.to(() => VoiceOfTeamDetailsScreen(caseItem: record));
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  label: const Text('VIEW'),
                  style: TextButton.styleFrom(
                    foregroundColor: Constant.mediumBlueColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                if (canAct) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result =
                          await Get.to(() => VoiceOfTeamApprovalScreen(
                                caseItem: record,
                                profile: widget.profile,
                              ));
                      if (result == true) fetchRecords();
                    },
                    icon: const Icon(Icons.play_circle_outline,
                        size: 16, color: Colors.white),
                    label: const Text(
                      'ACTION',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constant.mediumYellowColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          SizedBox(
            width: 110,
            child: CustomText(
              text: '$label:',
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg = Colors.blue.shade50;
    Color fg = Colors.blue.shade700;

    if (s.contains('complete') ||
        s.contains('approved') ||
        s.contains('success')) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: CustomText(
        text: status,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: fg,
      ),
    );
  }
}
