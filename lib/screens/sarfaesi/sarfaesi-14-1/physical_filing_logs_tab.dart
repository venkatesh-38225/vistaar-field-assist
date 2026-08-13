import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class PhysicalFilingLogsTab extends StatelessWidget {
  const PhysicalFilingLogsTab({
    super.key,
    required this.details,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  final PhysicalFilingCase? details;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Constant.lightBlueColor),
      );
    }

    if (errorMessage != null || details == null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 130),
            const Icon(Icons.cloud_off_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            CustomText(
              text: errorMessage ?? 'No logs available',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    final logs = details!.logs;
    if (logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
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
      onRefresh: onRefresh,
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

  String _valueOrNA(String value) => value.trim().isEmpty ? 'N/A' : value;
}
