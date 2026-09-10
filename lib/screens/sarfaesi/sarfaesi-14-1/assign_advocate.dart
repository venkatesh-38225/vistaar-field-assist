import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/legal_masters.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import 'physical_filing_logs_tab.dart';

class AssignAdvocateScreen extends StatefulWidget {
  const AssignAdvocateScreen({
    super.key,
    required this.caseId,
    required this.updatedBy,
  });

  final int caseId;
  final String updatedBy;

  @override
  State<AssignAdvocateScreen> createState() => _AssignAdvocateScreenState();
}

class _AssignAdvocateScreenState extends State<AssignAdvocateScreen> {
  PhysicalFilingCase? _details;
  List<Advocate> _advocates = [];
  Advocate? _selectedAdvocate;
  DateTime? _assignmentDate;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _showAdvocateError = false;
  bool _showDateError = false;
  String? _physicalDocumentsRequired;

  bool get _showPhysicalDocumentsRequiredField {
    final transmissionType =
        _details?.documentTransmissionType?.trim().toLowerCase() ?? '';
    return transmissionType == 'scanned copy';
    // return true;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        ApiClient().getPhysicalFilingById(widget.caseId),
        ApiClient().getAllAdvocates(),
      ]);
      if (!mounted) return;

      final detailsResponse = results[0] as PhysicalFilingDetailsResponse?;
      final advocates = results[1] as List<Advocate>?;
      if (detailsResponse?.success == true && detailsResponse?.data != null) {
        setState(() {
          _details = detailsResponse!.data;
          _advocates = advocates ?? [];
          _errorMessage =
              advocates == null ? 'Unable to load advocate masters' : null;
        });
      } else {
        setState(() {
          _details = null;
          _advocates = advocates ?? [];
          _errorMessage = detailsResponse?.message.isNotEmpty == true
              ? detailsResponse!.message
              : 'Failed to fetch physical filing details';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _details = null;
        _advocates = [];
        _errorMessage = 'Unable to load advocate assignment details';
      });
      GlobalSnackbar.showError('Unable to load advocate assignment details');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAssignmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assignmentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _assignmentDate = picked;
        _showDateError = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final details = _details;
    final advocate = _selectedAdvocate;
    final assignmentDate = _assignmentDate;
    final updatedBy = widget.updatedBy.trim();

    setState(() {
      _showAdvocateError = advocate == null;
      _showDateError = assignmentDate == null;
    });
    if (advocate == null || assignmentDate == null) {
      GlobalSnackbar.showError('Please select advocate and assignment date');
      return;
    }

    // Validate physical documents required field if it's shown
    if (_showPhysicalDocumentsRequiredField && 
        (_physicalDocumentsRequired == null || _physicalDocumentsRequired!.trim().isEmpty)) {
      GlobalSnackbar.showError('Please select physical documents required option');
      return;
    }

    if (details == null || details.caseId == 0) {
      GlobalSnackbar.showError('Case ID is unavailable');
      return;
    }
    if (updatedBy.isEmpty) {
      GlobalSnackbar.showError('Updated user ID is unavailable');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Assign Advocate'),
        content: Text(
          'Assign ${advocate.advocateName} to LAN ${details.lan}?',
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
            child: const Text('Assign', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final assignmentDateForApi = DateTime(
      assignmentDate.year,
      assignmentDate.month,
      assignmentDate.day,
    );
    final payload = <String, dynamic>{
      'caseId': details.caseId,
      'advocateId': advocate.id,
      'assignmentDate': assignmentDateForApi.toIso8601String(),
      'updatedBy': updatedBy,
    };

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient().assignPhysicalFilingAdvocate(payload);
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
          print("Submitting physical document requirement payload: $documentRequirementPayload");
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
                'Physical document requirement submission failed, but advocate assigned',
              );
            }
          }
        }

        GlobalSnackbar.showSuccess(
          response?['message']?.toString() ?? 'Advocate assigned successfully',
        );
        Get.back(result: true);
      } else {
        GlobalSnackbar.showError(
          response?['message']?.toString() ?? 'Failed to assign advocate',
        );
      }
    } catch (_) {
      if (mounted) GlobalSnackbar.showError('Unable to assign advocate');
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
            text: 'Assign Advocate',
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
              onRefresh: _loadData,
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
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 130),
            const Icon(Icons.cloud_off_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            CustomText(
              text: _errorMessage ?? 'No assignment details available',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCaseDetailsCard(_details!),
            const SizedBox(height: 18),
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
            const CustomText(
              text: 'Advocate Assignment',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102F54),
            ),
            const SizedBox(height: 14),
           
            _buildLabel('Select Advocate *'),
            _buildAdvocateSelector(),
            if (_showAdvocateError) _buildError('Please select an advocate'),
            const SizedBox(height: 16),
            _buildLabel('Date of Assignment *'),
            _buildDateSelector(),
            if (_showDateError) _buildError('Please select assignment date'),
            const SizedBox(height: 24),
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
                    : const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: CustomText(
                  text: _isSubmitting ? 'Assigning...' : 'Assign Advocate',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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

  Widget _buildAdvocateSelector() {
    return InkWell(
      onTap: _advocates.isEmpty ? null : _showAdvocateSelection,
      child: _selectorContainer(
        value: _selectedAdvocate?.advocateName,
        hint: _advocates.isEmpty ? 'No advocates available' : 'Select Advocate',
        icon: Icons.search,
        hasError: _showAdvocateError,
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _pickAssignmentDate,
      child: _selectorContainer(
        value: _assignmentDate == null
            ? null
            : DateFormat('dd-MM-yyyy').format(_assignmentDate!),
        hint: 'Select Assignment Date',
        icon: Icons.calendar_today,
        hasError: _showDateError,
      ),
    );
  }

  Widget _selectorContainer({
    required String? value,
    required String hint,
    required IconData icon,
    required bool hasError,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: hasError ? Colors.red : Colors.black,
          width: hasError ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(1, 1),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              text: value ?? hint,
              color: value == null ? Colors.grey : Colors.black,
              fontSize: 16,
            ),
          ),
          Icon(icon, color: Constant.mediumBlueColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 12),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  void _showAdvocateSelection() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        var filtered = List<Advocate>.from(_advocates);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CustomText(
                      text: 'Select Advocate',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constant.mediumBlueColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        autofocus: true,
                        onChanged: (query) {
                          setModalState(() {
                            filtered = _advocates
                                .where((advocate) => advocate.advocateName
                                    .toLowerCase()
                                    .contains(query.trim().toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Advocate...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No advocates found'))
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final advocate = filtered[index];
                                return ListTile(
                                  title: CustomText(
                                    text: advocate.advocateName,
                                    fontSize: 16,
                                  ),
                                  trailing: _selectedAdvocate?.id == advocate.id
                                      ? const Icon(
                                          Icons.check,
                                          color: Constant.mediumBlueColor,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedAdvocate = advocate;
                                      _showAdvocateError = false;
                                    });
                                    Navigator.pop(sheetContext);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
