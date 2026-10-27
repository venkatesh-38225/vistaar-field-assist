import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/physical_filing_response.dart';
import 'package:re_kyc_mobile_app/models/legal_masters.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_confirm_dialog.dart';
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

class _FilingDetailsScreenState extends State<FilingDetailsScreen>
    with SingleTickerProviderStateMixin {
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
  bool _isSubmittingRequirement = false;
  bool _dismissPhysicalDocs = false;
  bool _dismissAdditionalDocs = false;

  late AnimationController _alertAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool get _showDocumentRequirementsBanner {
    if (_details == null) return false;
    final isScannedCopy =
        _details?.documentTransmissionType?.trim().toLowerCase() ==
            'scanned copy';
    final hasPhysicalDocs = isScannedCopy && !_dismissPhysicalDocs;
    final hasAdditionalDocs = !_dismissAdditionalDocs;
    return hasPhysicalDocs || hasAdditionalDocs;
  }

  bool get _isEFiling => _filingType == 'E-Filing';

  @override
  void initState() {
    super.initState();
    _alertAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _alertAnimationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _alertAnimationController,
      curve: Curves.easeOutBack,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.93,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _alertAnimationController,
      curve: Curves.easeOutBack,
    ));
    _loadData();
  }

  @override
  void dispose() {
    _alertAnimationController.dispose();
    _courtNameController.dispose();
    _eFilingDateController.dispose();
    _eFilingCaseNumberController.dispose();
    _physicalFilingDateController.dispose();
    _physicalFilingCaseNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isLoadingCourts = true;
      _errorMessage = null;
      _courtsErrorMessage = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        ApiClient().getPhysicalFilingById(widget.caseId),
        ApiClient().getActiveCourts(),
      ]);
      if (!mounted) return;

      final detailsResponse = results[0] as PhysicalFilingDetailsResponse?;
      final courts = results[1] as List<Court>?;

      if (detailsResponse?.success == true && detailsResponse?.data != null) {
        final PhysicalFilingCase details = detailsResponse!.data!;
        final courtsList = courts ?? [];

        _populateExistingDetails(details, courtsList);

        setState(() {
          _details = details;
          _courts = courtsList;
          if (courts == null) {
            _courtsErrorMessage = 'Unable to load courts. Please try again.';
          }
        });
        if (_showDocumentRequirementsBanner) {
          _alertAnimationController.forward(from: 0.0);
        }
      } else {
        setState(() {
          _details = null;
          _courts = courts ?? [];
          _errorMessage = detailsResponse?.message.isNotEmpty == true
              ? detailsResponse!.message
              : 'Failed to fetch filing details';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _details = null;
        _courts = [];
        _errorMessage = 'Unable to load filing details';
      });
      GlobalSnackbar.showError('Unable to load filing details');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingCourts = false;
        });
      }
    }
  }

  void _populateExistingDetails(
    PhysicalFilingCase details,
    List<Court> courtsList,
  ) {
    if (_filingType == null && details.filingType.trim().isNotEmpty) {
      final ftLower = details.filingType.trim().toLowerCase();
      if (ftLower.contains('e-filing')) {
        _filingType = 'E-Filing';
      } else if (ftLower.contains('physical')) {
        _filingType = 'Physical Filing';
      } else {
        _filingType = details.filingType.trim();
      }
    }

    if (_selectedCourt == null && details.courtName.trim().isNotEmpty) {
      final name = details.courtName.trim();
      Court? match;
      try {
        match = courtsList.firstWhere(
          (c) => c.courtName.trim().toLowerCase() == name.toLowerCase(),
        );
      } catch (_) {
        match = Court(id: 0, courtName: name);
        courtsList.insert(0, match);
      }
      _selectedCourt = match;
    }

    if (_eFilingDate == null && details.eFilingDate != null) {
      _eFilingDate = details.eFilingDate;
      _eFilingDateController.text =
          DateFormat('dd-MM-yyyy').format(details.eFilingDate!);
    }
    if (_eFilingCaseNumberController.text.trim().isEmpty &&
        details.eFilingCaseNumber.trim().isNotEmpty) {
      _eFilingCaseNumberController.text = details.eFilingCaseNumber.trim();
    }

    if (_physicalFilingDate == null && details.physicalFilingDate != null) {
      _physicalFilingDate = details.physicalFilingDate;
      _physicalFilingDateController.text =
          DateFormat('dd-MM-yyyy').format(details.physicalFilingDate!);
    }
    if (_physicalFilingCaseNumberController.text.trim().isEmpty &&
        details.physicalFilingCaseNumber.trim().isNotEmpty) {
      _physicalFilingCaseNumberController.text =
          details.physicalFilingCaseNumber.trim();
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

  Future<void> _confirmAndSubmitRequirement({
    required String questionType,
    required bool isYes,
  }) async {
    final details = _details;
    if (details == null || details.caseId == 0 || !mounted) return;
    final updatedBy = widget.updatedBy.trim();
    if (updatedBy.isEmpty) {
      GlobalSnackbar.showError('Updated user ID is unavailable');
      return;
    }

    final bool isPhysicalDocs = questionType == 'Physical Documents';
    final TextEditingController commentsController = TextEditingController();

    try {
      final confirmed = await CustomConfirmDialog.show(
        context: context,
        title: 'Confirm Requirement',
        highlightItems: {
          'Question': '$questionType Required?',
          'Selected': isYes ? 'Yes' : 'No',
        },
        message: isYes
            ? 'This will save your choice and return to the dashboard.'
            : 'This will save your choice and refresh the current page.',
        confirmText: 'Submit',
        showInputField: !isPhysicalDocs,
        inputLabel: 'Comments',
        inputHint: isYes
            ? 'Enter reason for additional documents...'
            : 'Enter comments (optional)...',
        isInputRequired: !isPhysicalDocs && isYes,
        inputController: commentsController,
        inputValidationErrorMessage:
            'Please enter reason for additional documents',
      );

      if (confirmed != true || !mounted) return;

      final comments = commentsController.text.trim();

      setState(() => _isSubmittingRequirement = true);
      try {
        final payload = <String, dynamic>{
          'caseId': details.caseId,
          if (isPhysicalDocs) 'requiresPhysicalDocuments': isYes,
          if (!isPhysicalDocs) ...{
            'requiresAdditionalDocuments': isYes,
            if (comments.isNotEmpty) 'comments': comments,
          },
          'updatedBy': updatedBy,
        };

        final response = isPhysicalDocs
            ? await ApiClient().submitPhysicalDocumentRequirement(payload)
            : await ApiClient().submitAdditionalDocumentRequirement(payload);

        if (!mounted) return;
        if (response?['success'] == true) {
          GlobalSnackbar.showSuccess(
            response?['message']?.toString() ??
                '$questionType requirement submitted successfully',
          );
          if (isYes) {
            Get.back(result: true);
          } else {
            await _loadData();
          }
        } else {
          GlobalSnackbar.showError(
            response?['message']?.toString() ?? 'Failed to submit requirement',
          );
        }
      } catch (_) {
        if (mounted) {
          GlobalSnackbar.showError('Unable to submit requirement');
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmittingRequirement = false);
        }
      }
    } finally {
      commentsController.dispose();
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting || _isSubmittingRequirement) return;
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

    final filingDateStr = _isEFiling
        ? DateFormat('dd-MMM-yyyy').format(_eFilingDate!)
        : DateFormat('dd-MMM-yyyy').format(_physicalFilingDate!);
    final caseNumber = _isEFiling
        ? _eFilingCaseNumberController.text.trim()
        : _physicalFilingCaseNumberController.text.trim();

    final confirmed = await CustomConfirmDialog.show(
      context: context,
      title: 'Submit Filing Details',
      highlightItems: {
        'LAN': details.lan,
        'Filing Type': filingType,
        'Court Name': _selectedCourt!.courtName,
        'Filing Date': filingDateStr,
        'Case Number': caseNumber,
      },
      message:
          'Are you sure you want to submit $filingType details for LAN ${details.lan}?',
      confirmText: 'Submit Filing',
      icon: Icons.assignment_turned_in_outlined,
      iconColor: Constant.mediumBlueColor,
      iconBackgroundColor: const Color(0xFFE3F2FD),
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
              text: _errorMessage ?? 'No filing details available',
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
                  onPressed: (_isSubmitting || _isSubmittingRequirement)
                      ? null
                      : _submit,
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
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 350),
                firstCurve: Curves.easeInOut,
                secondCurve: Curves.easeInOut,
                sizeCurve: Curves.easeInOut,
                crossFadeState: _showDocumentRequirementsBanner
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _buildDocumentRequirementsAlertBanner(),
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
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
          TextButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      );
    }

    return Autocomplete<Court>(
      initialValue: TextEditingValue(text: _selectedCourt?.courtName ?? ''),
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
        if (controller.text.isEmpty && _selectedCourt != null) {
          controller.text = _selectedCourt!.courtName;
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration('Search and select court name').copyWith(
            suffixIcon: const Icon(Icons.arrow_drop_down,
                color: Constant.mediumBlueColor),
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

  void _dismissQuestion(String questionType) {
    setState(() {
      if (questionType == 'Physical Documents') {
        _dismissPhysicalDocs = true;
      } else {
        _dismissAdditionalDocs = true;
      }
    });
  }

  Widget _buildAnimatedQuestionRow({
    required bool isVisible,
    required Widget child,
  }) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.easeInOut,
      secondCurve: Curves.easeInOut,
      sizeCurve: Curves.easeInOut,
      crossFadeState:
          isVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: child,
      secondChild: const SizedBox.shrink(),
    );
  }

  Widget _buildDocumentRequirementsAlertBanner() {
    final isScannedCopy =
        _details?.documentTransmissionType?.trim().toLowerCase() ==
            'scanned copy';
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: Constant.mediumBlueColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            text: 'Document Requirements',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF102F54),
                          ),
                          const SizedBox(height: 2),
                          CustomText(
                            text: isScannedCopy
                                ? 'Scanned transmission mode detected (Optional)'
                                : 'Document requirement confirmation (Optional)',
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                    if (_isSubmittingRequirement)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Constant.mediumBlueColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isScannedCopy) ...[
                  _buildAnimatedQuestionRow(
                    isVisible: !_dismissPhysicalDocs,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: CustomText(
                                text: 'Physical Documents Required?',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildChoiceButton(
                              questionType: 'Physical Documents',
                              label: 'Yes',
                              isYes: true,
                            ),
                            const SizedBox(width: 8),
                            _buildChoiceButton(
                              questionType: 'Physical Documents',
                              label: 'No',
                              isYes: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                _buildAnimatedQuestionRow(
                  isVisible: !_dismissAdditionalDocs,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: CustomText(
                            text: 'Additional Documents Required?',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceButton(
                          questionType: 'Additional Documents',
                          label: 'Yes',
                          isYes: true,
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceButton(
                          questionType: 'Additional Documents',
                          label: 'No',
                          isYes: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String questionType,
    required String label,
    required bool isYes,
  }) {
    final isYesButton = isYes;
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isYesButton ? Constant.mediumBlueColor : Colors.grey.shade400,
            width: 1.2,
          ),
          foregroundColor:
              isYesButton ? Constant.mediumBlueColor : Colors.grey.shade700,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        onPressed: (_isLoading || _isSubmitting || _isSubmittingRequirement)
            ? null
            : () {
                if (isYes) {
                  _confirmAndSubmitRequirement(
                    questionType: questionType,
                    isYes: true,
                  );
                } else {
                  _dismissQuestion(questionType);
                }
              },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isYesButton ? Constant.mediumBlueColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
