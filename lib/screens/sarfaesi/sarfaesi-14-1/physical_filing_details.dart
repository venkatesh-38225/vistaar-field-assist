import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class PhysicalFilingDetailsScreen extends StatefulWidget {
  const PhysicalFilingDetailsScreen({
    super.key,
    required this.caseId,
  });

  final int caseId;

  @override
  State<PhysicalFilingDetailsScreen> createState() =>
      _PhysicalFilingDetailsScreenState();
}

class _PhysicalFilingDetailsScreenState
    extends State<PhysicalFilingDetailsScreen> {
  PhysicalFilingCase? _details;
  String? _errorMessage;
  bool _isLoading = false;

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
        setState(() => _details = response!.data!);
      } else {
        setState(() {
          _details = null;
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to fetch physical filing details';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _details = null;
        _errorMessage = 'Unable to load physical filing details';
      });
      GlobalSnackbar.showError('Unable to load physical filing details');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
            text: 'Physical Filing Details',
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
            _buildLogsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsTab() {
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
              text: _errorMessage ?? 'No logs available',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    final logs = _details!.logs;
    if (logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchDetails,
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
      onRefresh: _fetchDetails,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) => _buildLogCard(logs[index]),
      ),
    );
  }

  Widget _buildLogCard(PhysicalFilingLog log) {
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
                  text: log.createdDt == null
                      ? ''
                      : DateFormat('dd-MMM-yyyy HH:mm').format(log.createdDt!),
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomText(
              text: 'Stage: ${_valueOrNA(log.stage)}',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            const SizedBox(height: 5),
            CustomText(
              text: 'User: ${_valueOrNA(log.createdBy)}',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            const SizedBox(height: 5),
            CustomText(
              text: 'Remarks: ${_valueOrNA(log.remarks ?? '')}',
              fontSize: 12,
              color: Colors.black87,
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
              text: _errorMessage ?? 'No physical filing details available',
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
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        children: [
          _buildCaseCard(details),
          const SizedBox(height: 14),
          _buildChecklistSection(details),
          const SizedBox(height: 14),
          _buildAdvocateCard(details),
          const SizedBox(height: 14),
          _buildFilingCard(details),
          // const SizedBox(height: 14),
          // _buildAuditCard(details),
        ],
      ),
    );
  }

  Widget _buildAdvocateCard(PhysicalFilingCase details) {
    return _buildSectionCard(
      icon: Icons.person_pin_outlined,
      title: 'Assigned Advocate',
      children: [
        _detailRow(
          Icons.person_outline,
          'Advocate Name',
          _valueOrNA(details.advocateName),
        ),
        _detailRow(
          Icons.calendar_today_outlined,
          'Assigned On',
          _formatDate(details.advocateAssignmentDate),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildFilingCard(PhysicalFilingCase details) {
    final showEFiling = details.filingType.toLowerCase().contains('e-filing') ||
        details.eFilingDate != null ||
        details.eFilingCaseNumber.trim().isNotEmpty;
    final showPhysicalFiling =
        details.filingType.toLowerCase().contains('physical') ||
            details.physicalFilingDate != null ||
            details.physicalFilingCaseNumber.trim().isNotEmpty;

    return _buildSectionCard(
      icon: Icons.account_balance_outlined,
      title: 'Filing Information',
      children: [
        _detailRow(
          Icons.description_outlined,
          'Filing Type',
          _valueOrNA(details.filingType),
        ),
        _detailRow(
          Icons.location_city_outlined,
          'Court Name',
          _valueOrNA(details.courtName),
          showDivider: showEFiling || showPhysicalFiling,
        ),
        if (showEFiling) ...[
          _subsectionLabel('E-Filing Details'),
          _detailRow(
            Icons.event_outlined,
            'E-Filing Date',
            _formatDate(details.eFilingDate),
          ),
          _detailRow(
            Icons.numbers_outlined,
            'E-Filing Case No.',
            _valueOrNA(details.eFilingCaseNumber),
            showDivider: showPhysicalFiling,
          ),
        ],
        if (showPhysicalFiling) ...[
          _subsectionLabel('Physical Filing Details'),
          _detailRow(
            Icons.event_available_outlined,
            'Physical Date',
            _formatDate(details.physicalFilingDate),
          ),
          _detailRow(
            Icons.confirmation_number_outlined,
            'Physical Case No.',
            _valueOrNA(details.physicalFilingCaseNumber),
            showDivider: false,
          ),
        ],
      ],
    );
  }

  Widget _buildAuditCard(PhysicalFilingCase details) {
    return _buildSectionCard(
      icon: Icons.history_outlined,
      title: 'Audit Information',
      children: [
        _detailRow(
          Icons.person_add_alt_outlined,
          'Created By',
          _valueOrNA(details.createdBy),
        ),
        _detailRow(
          Icons.schedule_outlined,
          'Created On',
          _formatDateTime(details.createdDt),
        ),
        _detailRow(
          Icons.manage_accounts_outlined,
          'Updated By',
          _valueOrNA(details.updatedBy),
        ),
        _detailRow(
          Icons.update_outlined,
          'Updated On',
          _formatDateTime(details.updatedDt),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
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
            child: Row(
              children: [
                Icon(icon, size: 20, color: Constant.mediumBlueColor),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: title,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF102F54),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _subsectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Constant.lightBlueColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: CustomText(
            text: text,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Constant.mediumBlueColor,
          ),
        ),
      ),
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
          text: 'Submitted Checklist (${details.checklist.length})',
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

  Widget _buildCaseCard(PhysicalFilingCase details) {
    final dispatchDate = details.dispatchDate == null
        ? 'N/A'
        : DateFormat('dd-MMM-yyyy').format(details.dispatchDate!);

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  Icons.calendar_today_outlined,
                  'Dispatch Date',
                  dispatchDate,
                ),
                _detailRow(
                  Icons.confirmation_number_outlined,
                  'POD Number',
                  _valueOrNA(details.podNumber),
                ),
                _detailRow(
                  Icons.local_shipping_outlined,
                  'Courier Name',
                  _valueOrNA(details.courierName),
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
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Expanded(
              child: CustomText(
                text: _valueOrNA(value),
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

  String _formatDate(DateTime? value) {
    return value == null ? 'N/A' : DateFormat('dd-MMM-yyyy').format(value);
  }

  String _formatDateTime(DateTime? value) {
    return value == null
        ? 'N/A'
        : DateFormat('dd-MMM-yyyy, hh:mm a').format(value);
  }

  String _valueOrNA(String value) => value.trim().isEmpty ? 'N/A' : value;
}
