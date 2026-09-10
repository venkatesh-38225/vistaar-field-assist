import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
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

class _PhysicalFilingEntryScreenState extends State<PhysicalFilingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _physicalFilingDateController = TextEditingController();
  final _physicalFilingCaseNumberController = TextEditingController();

  PhysicalFilingCase? _details;
  DateTime? _physicalFilingDate;
  String? _physicalDocumentsRequired;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSubmitting = false;

  bool get _showPhysicalDocumentsRequiredField {
    final transmissionType =
        _details?.documentTransmissionType?.trim().toLowerCase() ?? '';
    return transmissionType == 'scanned copy';
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
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
        setState(() => _details = response!.data);
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

    // Validate physical documents required field if it's shown
    if (_showPhysicalDocumentsRequiredField && 
        (_physicalDocumentsRequired == null || _physicalDocumentsRequired!.trim().isEmpty)) {
      GlobalSnackbar.showError('Please select physical documents required option');
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit Physical Filing Details'),
        content: Text(
          'Submit Physical Filing details for LAN ${details.lan}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constant.mediumBlueColor,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
        // If document transmission type is "Scanned Copy", call physical document requirement API
        if (_showPhysicalDocumentsRequiredField) {
          final requiresPhysicalDocuments = _physicalDocumentsRequired == 'Yes';
          final documentRequirementPayload = <String, dynamic>{
            'caseId': details.caseId,
            'requiresPhysicalDocuments': requiresPhysicalDocuments,
            'updatedBy': updatedBy,
          };
          
          try {
            final docResponse = await ApiClient()
                .submitPhysicalDocumentRequirement(documentRequirementPayload);
            if (!mounted) return;
            if (docResponse?['success'] != true) {
              GlobalSnackbar.showError(
                docResponse?['message']?.toString() ??
                    'Physical document requirement API response unclear',
              );
            }
          } catch (_) {
            if (mounted) {
              GlobalSnackbar.showError(
                'Physical document requirement submission failed, but filing details submitted',
              );
            }
          }
        }

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
              _buildCaseDetailsCard(_details!),
              const SizedBox(height: 18),
              const CustomText(
                text: 'Physical Filing Details',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102F54),
              ),
              const SizedBox(height: 14),
              if (_showPhysicalDocumentsRequiredField) ...[
                _buildLabel('Physical Documents Required? *'),
                DropdownButtonFormField<String>(
                  value: _physicalDocumentsRequired,
                  isExpanded: true,
                  decoration: _inputDecoration('Select required option'),
                  items: const [
                    DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please select an option'
                          : null,
                  onChanged: (value) => setState(() => _physicalDocumentsRequired = value),
                ),
                const SizedBox(height: 16),
              ],
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

  Widget _buildCaseDetailsCard(PhysicalFilingCase details) {
    final dispatchDate = details.dispatchDate == null
        ? 'N/A'
        : DateFormat('dd-MMM-yyyy').format(details.dispatchDate!);
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
                _detailRow(
                  Icons.calendar_today_outlined,
                  'Dispatch Date',
                  dispatchDate,
                ),
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
