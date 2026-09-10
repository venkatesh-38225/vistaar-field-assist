import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/models/legal_masters.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import 'physical_filing_logs_tab.dart';

class FilingDetailsScreen extends StatefulWidget {
  const FilingDetailsScreen({
    super.key,
    required this.caseId,
    required this.updatedBy,
  });

  final int caseId;
  final String updatedBy;

  @override
  State<FilingDetailsScreen> createState() => _FilingDetailsScreenState();
}

class _FilingDetailsScreenState extends State<FilingDetailsScreen> {
  static const _filingTypes = ['E-Filing', 'Physical Filing'];

  final _formKey = GlobalKey<FormState>();
  final _courtNameController = TextEditingController();
  final _eFilingDateController = TextEditingController();
  final _eFilingCaseNumberController = TextEditingController();
  final _physicalFilingDateController = TextEditingController();
  final _physicalFilingCaseNumberController = TextEditingController();

  PhysicalFilingCase? _details;
  List<Court> _courts = [];
  Court? _selectedCourt;
  String? _filingType;
  DateTime? _eFilingDate;
  DateTime? _physicalFilingDate;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isLoadingCourts = false;
  String? _courtsErrorMessage;
  bool _isSubmitting = false;

  bool get _isEFiling => _filingType == 'E-Filing';

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadCourts();
  }

  @override
  void dispose() {
    _courtNameController.dispose();
    _eFilingDateController.dispose();
    _eFilingCaseNumberController.dispose();
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

  Future<void> _loadCourts() async {
    setState(() {
      _isLoadingCourts = true;
      _courtsErrorMessage = null;
    });
    try {
      final courts = await ApiClient().getActiveCourts();
      if (!mounted) return;
      setState(() {
        _courts = courts ?? [];
        if (courts == null) {
          _courtsErrorMessage = 'Unable to load courts. Please try again.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _courtsErrorMessage = 'Unable to load courts. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoadingCourts = false);
    }
  }

  void _changeFilingType(String? value) {
    setState(() {
      _filingType = value;
      if (_isEFiling) {
        _physicalFilingDate = null;
        _physicalFilingDateController.clear();
        _physicalFilingCaseNumberController.clear();
      } else {
        _eFilingDate = null;
        _eFilingDateController.clear();
        _eFilingCaseNumberController.clear();
      }
    });
  }

  Future<void> _pickDate({required bool isEFilingDate}) async {
    final currentDate = isEFilingDate ? _eFilingDate : _physicalFilingDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isEFilingDate) {
        _eFilingDate = picked;
        _eFilingDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      } else {
        _physicalFilingDate = picked;
        _physicalFilingDateController.text =
            DateFormat('dd-MM-yyyy').format(picked);
      }
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

    final details = _details;
    final filingType = _filingType;
    final updatedBy = widget.updatedBy.trim();
    if (details == null || details.caseId == 0) {
      GlobalSnackbar.showError('Case ID is unavailable');
      return;
    }
    if (filingType == null) return;
    if (_isEFiling ? _eFilingDate == null : _physicalFilingDate == null) {
      return;
    }
    if (updatedBy.isEmpty) {
      GlobalSnackbar.showError('Updated user ID is unavailable');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit Filing Details'),
        content: Text(
          'Submit $filingType details for LAN ${details.lan}?',
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
      'filingType': filingType,
      'courtName': _selectedCourt!.courtName,
      if (_isEFiling) ...{
        'eFilingDate': _toApiDate(_eFilingDate!),
        'eFilingCaseNumber': _eFilingCaseNumberController.text.trim(),
      } else ...{
        'physicalFilingDate': _toApiDate(_physicalFilingDate!),
        'physicalFilingCaseNumber':
            _physicalFilingCaseNumberController.text.trim(),
      },
      'updatedBy': updatedBy,
    };

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient().submitPhysicalFiling(payload);
      if (!mounted) return;
      if (response?['success'] == true) {
        GlobalSnackbar.showSuccess(
          response?['message']?.toString() ??
              'Filing details submitted successfully',
        );
        Get.back(result: true);
      } else {
        GlobalSnackbar.showError(
          response?['message']?.toString() ?? 'Failed to submit filing details',
        );
      }
    } catch (_) {
      if (mounted) GlobalSnackbar.showError('Unable to submit filing details');
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
            text: 'Filing Details',
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
                text: 'Section 14 Filing',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102F54),
              ),
              const SizedBox(height: 14),
              _buildLabel('Type of Filing *'),
              DropdownButtonFormField<String>(
                initialValue: _filingType,
                isExpanded: true,
                decoration: _inputDecoration('Select Type of Filing'),
                items: _filingTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: _changeFilingType,
                validator: (value) =>
                    value == null ? 'Please select type of filing' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Court Name *'),
              _buildCourtAutocomplete(),
              if (_isEFiling) ...[
                const SizedBox(height: 20),
                _buildSectionHeader('E-Filing Details'),
                const SizedBox(height: 12),
                _buildLabel('Date of E-Filing *'),
                _buildDateField(
                  controller: _eFilingDateController,
                  hint: 'Select Date of E-Filing',
                  onTap: () => _pickDate(isEFilingDate: true),
                ),
                const SizedBox(height: 16),
                _buildLabel('E-Filing Case Number *'),
                TextFormField(
                  controller: _eFilingCaseNumberController,
                  decoration: _inputDecoration('Enter E-Filing Case Number'),
                  validator: _requiredValidator('E-Filing case number'),
                ),
              ],
              if (_filingType == 'Physical Filing') ...[
                const SizedBox(height: 20),
                _buildSectionHeader('Physical Filing Details'),
                const SizedBox(height: 12),
                _buildLabel('Date of Physical Filing *'),
                _buildDateField(
                  controller: _physicalFilingDateController,
                  hint: 'Select Date of Physical Filing',
                  onTap: () => _pickDate(isEFilingDate: false),
                ),
                const SizedBox(height: 16),
                _buildLabel('Physical Filing Case Number *'),
                TextFormField(
                  controller: _physicalFilingCaseNumberController,
                  decoration:
                      _inputDecoration('Enter Physical Filing Case Number'),
                  validator: _requiredValidator('Physical filing case number'),
                ),
              ],
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
                    text: _isSubmitting ? 'Submitting...' : 'Submit Filing',
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
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtAutocomplete() {
    if (_isLoadingCourts) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Constant.lightBlueColor,
          ),
        ),
      );
    }

    if (_courtsErrorMessage != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _courtsErrorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
          TextButton(onPressed: _loadCourts, child: const Text('Retry')),
        ],
      );
    }

    return Autocomplete<Court>(
      displayStringForOption: (court) => court.courtName,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return _courts;
        return _courts.where(
          (court) => court.courtName.toLowerCase().contains(query),
        );
      },
      onSelected: (court) {
        setState(() => _selectedCourt = court);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration('Search and select court name').copyWith(
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Constant.mediumBlueColor),
          ),
          onChanged: (value) {
            if (_selectedCourt?.courtName != value) {
              _selectedCourt = null;
            }
          },
          validator: (_) => _selectedCourt == null
              ? 'Please select a court name from the list'
              : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 500),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final court = options.elementAt(index);
                  return ListTile(
                    title: Text(court.courtName),
                    onTap: () => onSelected(court),
                  );
                },
              ),
            ),
          ),
        );
      },
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

  Widget _buildSectionHeader(String text) {
    return Row(
      children: [
        const Icon(Icons.description_outlined,
            size: 19, color: Constant.mediumBlueColor),
        const SizedBox(width: 7),
        CustomText(
          text: text,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF102F54),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: _inputDecoration(hint).copyWith(
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
