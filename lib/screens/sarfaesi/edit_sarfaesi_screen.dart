import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:re_kyc_mobile_app/screens/sarfaesi/sarfaesi.dart';
import 'package:video_player/video_player.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/custom_textform_field.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/utils/helper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

/// Formats an integer text field with comma grouping (e.g. 50000 → 50,000).
/// Strips commas before parsing so the raw numeric value stays clean.
class _CommaInputFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat('#,##0');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final formatted = _fmt.format(int.parse(digits));
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
class EditSarfaesiScreen extends StatefulWidget {
  const EditSarfaesiScreen({
    super.key,
    required this.employeeId,
    required this.reqId,
  });

  final String employeeId;
  final int reqId;

  @override
  State<EditSarfaesiScreen> createState() => _EditSarfaesiScreenState();
}

class _EditSarfaesiScreenState extends State<EditSarfaesiScreen> {
  VideoPlayerController? _videoController;
  final _formKey = GlobalKey<FormState>();

  // ── Loading state ──────────────────────────────────────────────────────────
  bool isLoadingDetails = true;

  // ── LAN Details (read-only, prefilled from API) ────────────────────────────
  String _lan = '';
  String _customerName = '';
  String _propertyAddress = ''; // kept for update payload (joined)
  List<Map<String, dynamic>> _collaterals = []; // from getCollateralsByLan
  String _residentialAddress = '';
  String _customerContact = '';
  String _alternateContact = '';
  String _pos = '';
  String _tos = '';
  String _dpd = '';
  String _branch = '';
  String _branchCode = '';
  String _region = '';
  String _zone = '';
  String _megaZone = '';

  // ── Possession Status dropdown ─────────────────────────────────────────────
  String? selectedPossessionStatus;
  final List<String> possessionStatusOptions = ['Yes', 'No'];

  // ── No-Possession reason ───────────────────────────────────────────────────
  String? selectedNoPossessionReason;
  final List<String> noPossessionReasonOptions = [
    'Customer Denied',
    'Property Not Found',
    'Death in the Family – Further Process Could Not Be Initiated',
    'Court Stay Order',
    'Community Dominated Area',
    'Customer made payment'
  ];

  // ── Step management (Yes-possession flow) ─────────────────────────────────
  int activeStep = 0; // 0 = Step 1 Form, 1 = Step 2 Uploads

  // ── Step 1 fields ──────────────────────────────────────────────────────────
  DateTime? selectedPossessionDate;
  final TextEditingController possessionDateController = TextEditingController();
  String? handServiceToCustomer; // 'Yes' | 'No'

  String? selectedCustomerProfile;
  final List<String> customerProfileOptions = [
    'Doing business',
    'doing labour job',
    'Expired',
    'Not doing anything',
    'Shifted',
    'Salaried',
  ];

  String? selectedPropertyOccupiedBy;
  final List<String> propertyOccupiedByOptions = [
    'Tenant',
    'Owner',
    'Relatives',
    'Vacant',
  ];

  String? selectedPropertyType;
  final List<String> propertyTypeOptions = [
    'Vacant Land',
    'Commercial',
    'Residential',
  ];

  String? selectedPropertyCondition;
  final List<String> propertyConditionOptions = ['Average', 'Poor', 'Good'];

  final TextEditingController estimatedValueController = TextEditingController();

  String? selectedIntentCapabilityIssue;
  final List<String> intentCapabilityIssueOptions = [
    'Intentional defaulter',
    'Capability issue',
    'Customer expired',
    'Co-applicant expired',
    'Customer & co-applicant expired',
  ];

  // Option dropdowns and inputs for Response Status
  String? selectedResponseStatus;
  final List<String> responseStatusOptions = [
    'Ready to pay',
    'Ready to do settlement',
    'Not Ready to pay'
  ];

  // ── Step 2 file paths (newly picked files only) ────────────────────────────
  List<String> noticeAffixturePaths = [];
  List<String> noticeScannedCopyPaths = [];
  String? propertyVideoPath;
  List<String> noticeByHandPaths = [];

  // ── Existing uploaded files (from getById) ─────────────────────────────────
  List<Map<String, dynamic>> existingFiles = [];

  // ── Misc state ─────────────────────────────────────────────────────────────
  bool isProcessingByHand = false;
  double videoTrimStart = 0.0;
  double videoTrimEnd = 30.0;
  double videoMaxDuration = 60.0;
  bool isVideoSelected = false;
  bool isSubmitting = false;
  bool isProcessingImage = false;
  bool isProcessingAffixture = false;
  bool isProcessingScanned = false;
  String? _gpsInfo;

  final EdgeInsets contentPadding =
  const EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchDetails().then((_) => _fetchCollateralsByLan());
  }

  @override
  void dispose() {
    possessionDateController.dispose();
    estimatedValueController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _fetchCollateralsByLan() async {
    if (_lan.isEmpty) return; // guard: don't call if lan not loaded yet
    try {
      final response = await ApiClient().getCollateralsByLan(_lan);
      if (response != null &&
          response['data'] != null &&
          response['data']['success'] == true) {
        final List<dynamic> dataList = response['data']['data'] ?? [];
        setState(() {
          _collaterals = dataList
              .map((item) => {
            'collateralRef': item['collateralRef'] ?? '',
            'collateralType': item['collateralType'] ?? '',
            'collateralAddress': item['collateralAddress'] ?? '',
          })
              .toList();
          // Also update _propertyAddress for the update payload
          _propertyAddress = _collaterals
              .map((c) => c['collateralAddress'] as String)
              .where((a) => a.isNotEmpty)
              .join('; ');
        });
      }
    } catch (e) {
      debugPrint('getCollateralsByLan error: $e');
      // Non-fatal: collaterals list will just be empty
    }
  }

  // ── Fetch getById and prefill ──────────────────────────────────────────────

  Future<void> _fetchDetails() async {
    setState(() => isLoadingDetails = true);
    try {
      final response = await ApiClient().getSarfaesiById(widget.reqId);
      if (response != null && response.success && response.data != null) {
        final d = response.data!;
        setState(() {
          // LAN details
          _lan = d.lan ?? '';
          _customerName = d.customerName ?? '';
          _propertyAddress = d.propertyAddress ?? '';
          _residentialAddress = d.residentialAddress ?? '';
          _customerContact = d.mobile ?? '';
          _alternateContact = d.alternateMobile ?? '';
          _pos = d.pos?.toString() ?? '';
          _tos = d.tos?.toString() ?? '';
          _dpd = d.dpd?.toString() ?? '';
          _branch = d.branchName ?? '';
          _branchCode = d.branchCode ?? '';
          _region = d.region ?? '';
          _zone = d.zone ?? '';
          _megaZone = d.megaZone ?? '';

          // Possession status
          if (d.isPossessionTaken == true) {
            selectedPossessionStatus = 'Yes';
          } else if (d.isPossessionTaken == false) {
            selectedPossessionStatus = 'No';
          }

          // No-possession reason
          if (d.nonPossessionReason != null &&
              d.nonPossessionReason!.isNotEmpty) {
            // Match against the known list (case-insensitive fallback)
            final match = noPossessionReasonOptions.firstWhere(
                  (o) =>
              o.toLowerCase() == d.nonPossessionReason!.toLowerCase(),
              orElse: () => d.nonPossessionReason!,
            );
            selectedNoPossessionReason = match;
          }

          // Step-1 fields (possession = Yes)
          if (d.possessionDate != null) {
            selectedPossessionDate = d.possessionDate;
            possessionDateController.text =
                DateFormat('dd-MM-yyyy').format(d.possessionDate!);
          }

          handServiceToCustomer =
          (d.is134HandService == true) ? 'Yes' : 'No';

          // Customer profile — match dropdown list
          if (d.customerProfile != null && d.customerProfile!.isNotEmpty) {
            final match = customerProfileOptions.firstWhere(
                  (o) =>
              o.toLowerCase() == d.customerProfile!.toLowerCase(),
              orElse: () => d.customerProfile!,
            );
            selectedCustomerProfile = match;
          }

          // Property occupied by
          if (d.propertyOccupiedBy != null &&
              d.propertyOccupiedBy!.isNotEmpty) {
            final match = propertyOccupiedByOptions.firstWhere(
                  (o) =>
              o.toLowerCase() == d.propertyOccupiedBy!.toLowerCase(),
              orElse: () => d.propertyOccupiedBy!,
            );
            selectedPropertyOccupiedBy = match;
          }

          // Property type
          if (d.propertyType != null && d.propertyType!.isNotEmpty) {
            final match = propertyTypeOptions.firstWhere(
                  (o) => o.toLowerCase() == d.propertyType!.toLowerCase(),
              orElse: () => d.propertyType!,
            );
            selectedPropertyType = match;
          }

          // Property condition
          if (d.propertyCondition != null &&
              d.propertyCondition!.isNotEmpty) {
            final match = propertyConditionOptions.firstWhere(
                  (o) =>
              o.toLowerCase() == d.propertyCondition!.toLowerCase(),
              orElse: () => d.propertyCondition!,
            );
            selectedPropertyCondition = match;
          }

          // Estimated value
          if (d.estimatedPropertyValue != null) {
            final _prefillFmt = NumberFormat('#,##0');
            estimatedValueController.text =
                _prefillFmt.format(d.estimatedPropertyValue!.toInt());
          }

          // Customer intent / capability
          if (d.customerIntentCapability != null &&
              d.customerIntentCapability!.isNotEmpty) {
            final match = intentCapabilityIssueOptions.firstWhere(
                  (o) =>
              o.toLowerCase() ==
                  d.customerIntentCapability!.toLowerCase(),
              orElse: () => d.customerIntentCapability!,
            );
            selectedIntentCapabilityIssue = match;
          }
          if (d.responseStatus != null &&
              d.responseStatus!.isNotEmpty) {
            final match = responseStatusOptions.firstWhere(
                  (o) =>
              o.toLowerCase() ==
                  d.responseStatus!.toLowerCase(),
              orElse: () => d.responseStatus!,
            );
            selectedResponseStatus = match;
          }

          // Existing files
          if (d.files != null) {
            existingFiles = d.files!
                .map((f) => {
              'id': f.id,
              'fileType': f.fileType ?? '',
              'fileName': f.fileName ?? '',
              'uploadedBy': f.uploadedBy ?? '',
              'uploadedDt': f.uploadedDt,
            })
                .toList();
          }

          isLoadingDetails = false;
        });
      } else {
        GlobalSnackbar.showError('Failed to fetch record details');
        Get.back();
      }
    } catch (e) {
      debugPrint('EditSarfaesi fetchDetails error: $e');
      GlobalSnackbar.showError('Something went wrong');
      Get.back();
    }
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool _validateStep1() {
    if (selectedPossessionDate == null) {
      GlobalSnackbar.showError('Please select possession date');
      return false;
    }
    if (handServiceToCustomer == null) {
      GlobalSnackbar.showError(
          'Please select 13(4) by hand service option');
      return false;
    }
    if (selectedCustomerProfile == null) {
      GlobalSnackbar.showError('Please select customer profile');
      return false;
    }
    if (selectedPropertyOccupiedBy == null) {
      GlobalSnackbar.showError('Please select property occupied by');
      return false;
    }
    if (selectedPropertyType == null) {
      GlobalSnackbar.showError('Please select property type');
      return false;
    }
    if (selectedPropertyCondition == null) {
      GlobalSnackbar.showError('Please select property condition');
      return false;
    }
    if (estimatedValueController.text.trim().isEmpty) {
      GlobalSnackbar.showError(
          'Please enter estimated value of property');
      return false;
    }
    if (selectedIntentCapabilityIssue == null) {
      GlobalSnackbar.showError(
          'Please select customer intent / capability issue');
      return false;
    }
    if (selectedResponseStatus == null) {
      GlobalSnackbar.showError(
          'Please select response status');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    // For each required document type, pass if either:
    //   • at least one existing file of that type is in existingFiles (from API), OR
    //   • the user has newly picked at least one file for that field.

    // ── 1. Notice Affixture ────────────────────────────────────────────────
    final hasExistingAffixture = existingFiles
        .any((f) => f['fileType'] == 'Notice134Affixture');
    if (!hasExistingAffixture && noticeAffixturePaths.isEmpty) {
      GlobalSnackbar.showError(
          'Please upload at least one 13(4) notice affixture file');
      return false;
    }

    // ── 2. Property Video ──────────────────────────────────────────────────
    final hasExistingVideo = existingFiles
        .any((f) => f['fileType'] == 'PropertyVideo');
    final hasNewVideo =
        propertyVideoPath != null && propertyVideoPath!.isNotEmpty;
    if (!hasExistingVideo && !hasNewVideo) {
      GlobalSnackbar.showError('Please upload the property video');
      return false;
    }

    // ── 3. Notice Scanned & Signed Copy ───────────────────────────────────
    final hasExistingScanned = existingFiles
        .any((f) => f['fileType'] == 'Notice134Signed');
    if (!hasExistingScanned && noticeScannedCopyPaths.isEmpty) {
      GlobalSnackbar.showError(
          'Please upload at least one 13(4) notice scanned and signed copy');
      return false;
    }

    // ── 4. By-Hand Service (only required when hand service = Yes) ─────────
    if (handServiceToCustomer == 'Yes') {
      final hasExistingByHand = existingFiles
          .any((f) => f['fileType'] == 'Notice134ByHandToCustomer');
      if (!hasExistingByHand && noticeByHandPaths.isEmpty) {
        GlobalSnackbar.showError(
            'Please upload at least one 13(4) notice by hand service document');
        return false;
      }
    }

    return true;
  }

  // ── Update API (Step 1 → calls updateSarfaesiStatus) ─────────────────────

  Future<void> updateRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedPossessionStatus == null) {
      GlobalSnackbar.showError('Please select possession status');
      return;
    }

    if (selectedPossessionStatus == 'No') {
      if (selectedNoPossessionReason == null) {
        GlobalSnackbar.showError(
            'Please select reason for no possession');
        return;
      }
    } else if (selectedPossessionStatus == 'Yes') {
      if (!_validateStep1()) return;
    }

    setState(() => isSubmitting = true);

    final payload = <String, dynamic>{
      'lan': _lan,
      'customerName': _customerName,
      'propertyAddress':
      _propertyAddress.isNotEmpty ? _propertyAddress : 'N/A',
      'residentialAddress': _residentialAddress,
      'mobile': _customerContact,
      'alternateMobile': _alternateContact,
      'pos': double.tryParse(_pos) ?? 0,
      'tos': double.tryParse(_tos) ?? 0,
      'dpd': int.tryParse(_dpd) ?? 0,
      'branchCode': _branchCode,
      'branchName': _branch,
      'region': _region,
      'zone': _zone,
      'megaZone': _megaZone,
      'isPossessionTaken': selectedPossessionStatus == 'Yes',
      'createdBy': widget.employeeId,
    };

    if (selectedPossessionStatus == 'No') {
      payload['nonPossessionReason'] = selectedNoPossessionReason;
    } else {
      payload['possessionDate'] = selectedPossessionDate?.toIso8601String();
      payload['is134HandService'] = handServiceToCustomer == 'Yes';
      payload['customerProfile'] = selectedCustomerProfile;
      payload['propertyOccupiedBy'] = selectedPropertyOccupiedBy;
      payload['propertyType'] = selectedPropertyType;
      payload['propertyCondition'] = selectedPropertyCondition;
      payload['estimatedPropertyValue'] =
          double.tryParse(estimatedValueController.text.replaceAll(',', '')) ?? 0.0;
      payload['customerIntentCapability'] = selectedIntentCapabilityIssue;
      payload['responseStatus'] = selectedResponseStatus;
    }

    debugPrint('SARFAESI update payload: ${jsonEncode(payload)}');

    // Call updateSarfaesiStatus with reqId appended to the URL
    final updateResponse = await ApiClient()
        .updateSarfaesiStatus(jsonEncode(payload), widget.reqId);

    setState(() => isSubmitting = false);

    if (updateResponse != null) {
      final bool success = updateResponse['success'] == true;
      if (success) {
        if (selectedPossessionStatus == 'Yes') {
          // Proceed to document upload step
          setState(() => activeStep = 1);
          GlobalSnackbar.showSuccess(
            updateResponse['message'] ?? 'Record updated successfully',
          );
        } else {
          // No-possession: done
          GlobalSnackbar.showSuccess(
            updateResponse['message'] ?? 'Record updated successfully',
          );
          Get.back(result: true);
        }
      } else {
        GlobalSnackbar.showError(
          updateResponse['message'] ?? 'Failed to update record',
        );
      }
    } else {
      GlobalSnackbar.showError('Something went wrong');
    }
  }

  // ── Submit (calls submitSarfaesi) ──────────────────────────────────────────

  Future<void> submitRequest() async {
    setState(() => isSubmitting = true);

    final payload = <String, dynamic>{
      'ReqId': widget.reqId,
      'updatedBy': widget.employeeId,
    };

    debugPrint('SARFAESI submit payload: ${jsonEncode(payload)}');

    final submitResponse = await ApiClient().submitSarfaesi(payload);
    setState(() => isSubmitting = false);

    if (submitResponse != null) {
      final statusCode = submitResponse['statusCode'];
      final data = submitResponse['data'];

      if (statusCode == 200 || statusCode == 201) {
        GlobalSnackbar.showSuccess(
          data['message'] ?? 'SARFAESI request submitted successfully',
        );
        Get.back(result: true);
      } else {
        String errorMessage = 'Failed to submit request';
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstKey = errors.keys.first;
            final firstErrorList = errors[firstKey];
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              errorMessage = firstErrorList.first.toString();
            }
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['title'] != null) {
          errorMessage = data['title'];
        }
        GlobalSnackbar.showError(errorMessage);
      }
    } else {
      GlobalSnackbar.showError('Something went wrong');
    }
  }

  // ── Document upload (same as create) ──────────────────────────────────────

  Future<void> submitDocuments() async {
    if (!_validateStep2()) return;

    setState(() => isSubmitting = true);

    try {
      final int reqId = widget.reqId;
      final String createdBy = widget.employeeId;
      bool allSuccess = true;

      // Upload newly-picked affixture images
      for (final path in noticeAffixturePaths) {
        final bool ok = await _uploadSarfaesiFile(
          reqId: reqId,
          fileType: 'Notice134Affixture',
          filePath: path,
          createdBy: createdBy,
        );
        if (!ok) {
          allSuccess = false;
          break;
        }
      }

      // Upload newly-picked scanned copies
      if (allSuccess) {
        for (final path in noticeScannedCopyPaths) {
          final bool ok = await _uploadSarfaesiFile(
            reqId: reqId,
            fileType: 'Notice134Signed',
            filePath: path,
            createdBy: createdBy,
          );
          if (!ok) {
            allSuccess = false;
            break;
          }
        }
      }

      // Upload newly-picked by-hand documents
      if (allSuccess && handServiceToCustomer == 'Yes') {
        for (final path in noticeByHandPaths) {
          final bool ok = await _uploadSarfaesiFile(
            reqId: reqId,
            fileType: 'Notice134ByHandToCustomer',
            filePath: path,
            createdBy: createdBy,
          );
          if (!ok) {
            allSuccess = false;
            break;
          }
        }
      }

      final compressedVideo =
      await _compressVideo(propertyVideoPath!);
      // Upload newly-picked property video
      if (allSuccess &&
          propertyVideoPath != null &&
          propertyVideoPath!.isNotEmpty) {
        final bool ok = await _uploadSarfaesiFile(
          reqId: reqId,
          fileType: 'PropertyVideo',
          filePath: compressedVideo,
          createdBy: createdBy,
        );
        if (!ok) allSuccess = false;
      }

      setState(() => isSubmitting = false);

      if (allSuccess) {
        GlobalSnackbar.showSuccess('Documents uploaded successfully');
        await submitRequest();
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      debugPrint('Document upload error: $e');
      GlobalSnackbar.showError(
          'Something went wrong while uploading documents.');
    }
  }

  Future<bool> _uploadSarfaesiFile({
    required int reqId,
    required String fileType,
    required String filePath,
    required String createdBy,
  }) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      GlobalSnackbar.showError(
          'File not found: ${filePath.split('/').last}');
      return false;
    }

    final Map<String, dynamic>? result = await ApiClient().uploadSarfaesiFile(
      reqId: reqId,
      fileType: fileType,
      file: file,
      createdBy: createdBy,
    );

    if (result == null) {
      GlobalSnackbar.showError(
          'Upload failed: ${filePath.split('/').last}');
      return false;
    }

    final int statusCode = result['statusCode'] as int;
    final dynamic data = result['data'];

    if (statusCode == 200 || statusCode == 201) return true;

    String errMsg = 'Failed to upload ${filePath.split('/').last}';
    if (data is Map<String, dynamic>) {
      errMsg = data['message']?.toString() ?? errMsg;
    }
    GlobalSnackbar.showError(errMsg);
    return false;
  }


  Future<String> _compressImageToLimit(String imagePath, {int maxBytes = 2 * 1024 * 1024}) async {
    final originalFile = File(imagePath);
    final originalSize = await originalFile.length();

    // Already within limit — return original path as-is
    if (originalSize <= maxBytes) return imagePath;

    final dir = await getTemporaryDirectory();
    final ext = p.extension(imagePath).toLowerCase();
    final isPng = ext == '.png';
    final outPath = p.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}${isPng ? '.png' : '.jpg'}');

    // Step down quality: 85 → 70 → 55 → 40 → 25
    for (final quality in [85, 70, 55, 40, 25]) {
      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        outPath,
        quality: quality,
        format: isPng ? CompressFormat.png : CompressFormat.jpeg,
      );
      if (result != null) {
        final compressedSize = await File(result.path).length();
        if (compressedSize <= maxBytes) {
          return result.path;
        }
      }
    }

    // Could not compress below limit even at quality 25 — block the upload
    throw Exception(
      'Image is too large and cannot be compressed to under 2MB. '
          'Please use a smaller or lower-resolution image.',
    );
  }

  Future<void> _pickDocument(String type) async {
    CustomsHelper.cameraPermissionAlert(
          () async {
        Get.back();
        String path = await CustomsHelper().getCamera();
        if (path.isNotEmpty) {
          // Camera always returns an image — validate size (max 2.5 MB)
          final fileSize = await File(path).length();
          final maxImageBytes = (2.5 * 1024 * 1024).toInt(); // 2.5 MB
          if (fileSize > maxImageBytes) {
            GlobalSnackbar.showError(
              'Image size exceeds 2.5MB (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
                  'Please capture a lower-resolution photo.',
            );
            return;
          }
          setState(() {
            isProcessingImage = true;
            if (type == 'affixture') isProcessingAffixture = true;
            else if (type == 'byhand') isProcessingByHand = true;
            else isProcessingScanned = true;
          });
          setState(() {
            if (type == 'affixture') {
              noticeAffixturePaths.add(path);
              isProcessingAffixture = false;
            } else if (type == 'byhand') {
              noticeByHandPaths.add(path);
              isProcessingByHand = false;
            } else {
              noticeScannedCopyPaths.add(path);
              isProcessingScanned = false;
            }
            isProcessingImage = false;
          });
        }
      },
          () async {
        Get.back();
        String path = await CustomsHelper().getGalleryFile();
        if (path.isNotEmpty) {
          setState(() {
            isProcessingImage = true;
            if (type == 'affixture') isProcessingAffixture = true;
            else if (type == 'byhand') isProcessingByHand = true;
            else isProcessingScanned = true;
          });

          final fileSize = await File(path).length();
          final ext = path.toLowerCase();
          final isPdf = ext.endsWith('.pdf');

          if (isPdf) {
            // PDF: block if > 5 MB
            const maxPdfBytes = 5 * 1024 * 1024; // 5 MB
            if (fileSize > maxPdfBytes) {
              GlobalSnackbar.showError(
                'PDF size exceeds 5MB (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
                    'Please use a smaller PDF.',
              );
              setState(() {
                isProcessingImage = false;
                isProcessingAffixture = false;
                isProcessingByHand = false;
                isProcessingScanned = false;
              });
              return;
            }
          } else {
            // Image: block if > 2.5 MB
            final maxImageBytes = (2.5 * 1024 * 1024).toInt(); // 2.5 MB
            if (fileSize > maxImageBytes) {
              GlobalSnackbar.showError(
                'Image size exceeds 2.5MB (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
                    'Please select a smaller image.',
              );
              setState(() {
                isProcessingImage = false;
                isProcessingAffixture = false;
                isProcessingByHand = false;
                isProcessingScanned = false;
              });
              return;
            }
          }

          setState(() {
            if (type == 'affixture') {
              noticeAffixturePaths.add(path);
              isProcessingAffixture = false;
            } else if (type == 'byhand') {
              noticeByHandPaths.add(path);
              isProcessingByHand = false;
            } else {
              noticeScannedCopyPaths.add(path);
              isProcessingScanned = false;
            }
            isProcessingImage = false;
          });
        }
      },
    );
  }

  Future<String> _compressVideo(String videoPath) async {
    try {
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (mediaInfo?.file == null) {
        return videoPath;
      }

      final compressedFile = mediaInfo!.file!;

      final sizeMB =
          await compressedFile.length() / (1024 * 1024);

      debugPrint("Compressed video size: ${sizeMB.toStringAsFixed(2)} MB");

      return compressedFile.path;
    } catch (e) {
      debugPrint("Video compression error: $e");
      return videoPath;
    }
  }
  Future<void> _pickVideo() async {
    CustomsHelper.cameraPermissionAlert(
          () async {
        Get.back();
        try {
          final XFile? file = await ImagePicker().pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(minutes: 5),
          );
          if (file != null && file.path.isNotEmpty) {
            final fileSize = await File(file.path).length();
            const maxVideoBytes = 100 * 1024 * 1024;
            if (fileSize > maxVideoBytes) {
              GlobalSnackbar.showError(
                'Video size exceeds 100MB (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
                    'Please record a shorter video.',
              );
              return;
            }
            await _initializeVideo(file.path);
            await _initializeVideo(file.path);
          }
        } catch (e) {
          GlobalSnackbar.showError('Error picking video');
        }
      },
          () async {
        Get.back();
        try {
          final XFile? file = await ImagePicker().pickVideo(
            source: ImageSource.gallery,
          );
          if (file != null && file.path.isNotEmpty) {
            final fileSize = await File(file.path).length();
            const maxVideoBytes = 100 * 1024 * 1024;
            if (fileSize > maxVideoBytes) {
              GlobalSnackbar.showError(
                'Video size exceeds 100MB (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
                    'Please select a shorter video.',
              );
              return;
            }
            await _initializeVideo(file.path);
          }
        } catch (e) {
          GlobalSnackbar.showError('Error picking video');
        }
      },
    );
  }


  Future<void> _initializeVideo(String path) async {
    await _videoController?.dispose();
    final file = File(path);
    _videoController = VideoPlayerController.file(file);
    try {
      await _videoController!.initialize();
      final duration =
      _videoController!.value.duration.inSeconds.toDouble();
      setState(() {
        propertyVideoPath = path;
        isVideoSelected = true;
        videoMaxDuration = duration;
        videoTrimStart = 0.0;
        videoTrimEnd = duration;
      });
      _videoController!.addListener(() {
        final position =
        _videoController!.value.position.inSeconds.toDouble();
        if (position >= videoTrimEnd) {
          _videoController!.pause();
          _videoController!
              .seekTo(Duration(seconds: videoTrimStart.toInt()));
        }
        setState(() {});
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
      GlobalSnackbar.showError('Error initializing video');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          text: 'Edit SARFAESI 13(4)',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LAN Details Card ────────────────────────────
              _buildSectionTitle('LAN Details'),
              const SizedBox(height: 10),
              _buildDetailsCard([
                _buildDetailRow('LAN', _lan),
                _buildDetailRow('Customer Name', _customerName),
                _buildDetailRow(
                    'Customer Contact', _customerContact),
                _buildDetailRow(
                    'Alternate Contact', _alternateContact),
                _buildDetailRow('POS', _pos),
                _buildDetailRow('TOS', _tos),
                _buildDetailRow('DPD', _dpd),
                _buildDetailRow('Branch', _branch),
                _buildDetailRow('Zone', _zone),
                _buildDetailRow('MegaZone', _megaZone),
                _buildResidentialAddressSection(_residentialAddress),
                _buildCollateralsRow(),
              ]),

              const SizedBox(height: 20),

              // ── Possession Status ───────────────────────────
              _buildSectionTitle('Possession Details'),
              const SizedBox(height: 12),

              _buildInputLabel('Possession Status *'),
              DropdownButtonFormField<String>(
                value: selectedPossessionStatus,
                isExpanded: true,
                decoration: _dropdownDecoration(
                    'Select Possession Status'),
                icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Constant.mediumBlueColor),
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please select possession status'
                    : null,
                onChanged: (val) {
                  setState(() {
                    selectedPossessionStatus = val;
                    activeStep = 0;
                  });
                },
                items: possessionStatusOptions
                    .map((o) => DropdownMenuItem(
                    value: o, child: Text(o)))
                    .toList(),
              ),

              // ── No-Possession flow ──────────────────────────
              if (selectedPossessionStatus == 'No') ...[
                const SizedBox(height: 16),
                _buildInputLabel(
                    'Reason for No Possession *'),
                _buildDropdownField(
                  value: selectedNoPossessionReason,
                  hintText: 'Select Reason',
                  options: noPossessionReasonOptions,
                  onChanged: (val) => setState(
                          () => selectedNoPossessionReason = val),
                ),
                const SizedBox(height: 30),
                _buildSubmitButton(
                  label: 'Update',
                  onPressed: updateRequest,
                ),
              ],

              // ── Yes-Possession flow ─────────────────────────
              if (selectedPossessionStatus == 'Yes') ...[
                const SizedBox(height: 20),

                // Step indicator
                _buildStepBar(),
                const Divider(height: 24),

                // Step 1: Form fields
                if (activeStep == 0) ...[
                  _buildInputLabel('Possession Date *'),
                  GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                        selectedPossessionDate ??
                            DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedPossessionDate = picked;
                          possessionDateController.text =
                              DateFormat('dd-MM-yyyy')
                                  .format(picked);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: CustomTextFormField(
                        controller: possessionDateController,
                        hintText: 'Select Possession Date',
                        contentPadding: contentPadding,
                        suffixIcon: IconButton(
                          icon: const Icon(
                              Icons.calendar_today,
                              color:
                              Constant.mediumBlueColor),
                          onPressed: () {},
                        ),
                        onSaved: (v) {},
                        validator: (v) => null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel(
                      '13(4) by hand service to the customer *'),
                  const SizedBox(height: 4),
                  _buildYesNoToggle(
                    value: handServiceToCustomer,
                    onChanged: (val) =>
                        setState(() => handServiceToCustomer = val),
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Customer Profile *'),
                  _buildDropdownField(
                    value: selectedCustomerProfile,
                    hintText: 'Select Customer Profile',
                    options: customerProfileOptions,
                    onChanged: (val) => setState(
                            () => selectedCustomerProfile = val),
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Property Occupied By *'),
                  _buildDropdownField(
                    value: selectedPropertyOccupiedBy,
                    hintText: 'Select Occupant Type',
                    options: propertyOccupiedByOptions,
                    onChanged: (val) => setState(
                            () => selectedPropertyOccupiedBy = val),
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Property Type *'),
                  _buildDropdownField(
                    value: selectedPropertyType,
                    hintText: 'Select Property Type',
                    options: propertyTypeOptions,
                    onChanged: (val) =>
                        setState(() => selectedPropertyType = val),
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Property Condition *'),
                  _buildDropdownField(
                    value: selectedPropertyCondition,
                    hintText: 'Select Property Condition',
                    options: propertyConditionOptions,
                    onChanged: (val) => setState(
                            () => selectedPropertyCondition = val),
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel(
                      'Estimated Value of Property *'),
                  CustomTextFormField(
                    controller: estimatedValueController,
                    hintText: 'Enter Estimated Value',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      _CommaInputFormatter()
                    ],
                    contentPadding: contentPadding,
                    onSaved: (v) {},
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel(
                      'Customer Intent / Capability Issue *'),
                  _buildDropdownField(
                    value: selectedIntentCapabilityIssue,
                    hintText: 'Select Intent / Capability',
                    options: intentCapabilityIssueOptions,
                    onChanged: (val) => setState(() =>
                    selectedIntentCapabilityIssue = val),
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel(
                      'Response Status *'),
                  _buildDropdownField(
                    value: selectedResponseStatus,
                    hintText: 'Select Response Status',
                    options: responseStatusOptions,
                    onChanged: (val) => setState(() =>
                    selectedResponseStatus = val),
                  ),
                  const SizedBox(height: 30),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                        if (_validateStep1()) {
                          updateRequest();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Constant.mediumBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const CustomText(
                        text: 'Next',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                // Step 2: Documents
                if (activeStep == 1) ...[
                  // Show existing uploaded files
                  if (existingFiles.isNotEmpty) ...[
                    _buildSectionTitle('Existing Documents'),
                    const SizedBox(height: 8),
                    _buildExistingFilesCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Add New Documents'),
                    const SizedBox(height: 8),
                    CustomText(
                      text:
                      'You can upload additional files below. Existing files will be kept.',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Affixture upload
                  _buildFileUploadListField(
                    label: '13(4) notice affixture',
                    filePaths: noticeAffixturePaths,
                    hint: 'Upload affixture notice image/PDF',
                    description: "Upload an image that clearly shows the notice affixed on the property, including the customer location’s latitude and longitude details.",
                    isLoading: isProcessingAffixture,
                    onTap: () => _pickDocument('affixture'),
                    onRemove: (index) => setState(() =>
                        noticeAffixturePaths.removeAt(index)),
                  ),
                  const SizedBox(height: 16),

                  // Video upload
                  _buildFileUploadField(
                    label: 'Property video',
                    filePath: propertyVideoPath,
                    hint: 'Upload/Record Property Video',
                    description:'Capture a clear video of the complete property. The video should contain the customer location’s latitude and longitude details',
                    icon: Icons.video_call_rounded,
                    onTap: _pickVideo,
                    onClear: () => setState(() {
                      propertyVideoPath = null;
                      isVideoSelected = false;
                    }),
                  ),

                  if (isVideoSelected && propertyVideoPath != null)
                    _buildVideoTrimmerPanel(),

                  const SizedBox(height: 16),

                  // By-hand documents
                  if (handServiceToCustomer == 'Yes') ...[
                    _buildFileUploadListField(
                      label:
                      '13(4) notice by hand service to customer',
                      filePaths: noticeByHandPaths,
                      hint:
                      'Upload by hand service document',
                      description: "Please attach customer signed copy of the 13(4) notice",
                      isLoading: isProcessingByHand,
                      onTap: () => _pickDocument('byhand'),
                      onRemove: (index) => setState(() =>
                          noticeByHandPaths.removeAt(index)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Scanned signed copy
                  _buildFileUploadListField(
                    label:
                    '13(4) notice scanned and signed copy',
                    filePaths: noticeScannedCopyPaths,
                    hint:
                    'Upload signed notice image/PDF',
                    description: 'Ensure a clear photo with seal and signature is uploaded for reference.',
                    isLoading: isProcessingScanned,
                    onTap: () => _pickDocument('scanned'),
                    onRemove: (index) => setState(() =>
                        noticeScannedCopyPaths.removeAt(index)),
                  ),
                  const SizedBox(height: 30),

                  // Navigation row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => setState(
                                    () => activeStep = 0),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color:
                                  Constant.mediumBlueColor,
                                  width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                            child: const CustomText(
                              text: 'Previous',
                              color: Constant.mediumBlueColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : submitDocuments,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Constant.mediumBlueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const CustomText(
                              text: 'Submit',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Existing files card ────────────────────────────────────────────────────

  Widget _buildExistingFilesCard() {
    // Group by fileType
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final f in existingFiles) {
      final key = f['fileType'] as String;
      grouped.putIfAbsent(key, () => []).add(f);
    }

    return Card(
      elevation: 2,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Constant.mediumBlueColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomText(
                        text: _fileTypeLabel(entry.key),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Constant.mediumBlueColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Constant.mediumBlueColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomText(
                        text: '${entry.value.length}',
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...entry.value.asMap().entries.map((e) {
                  final file = e.value;
                  final fileName = file['fileName'] as String;
                  final ext = fileName.split('.').last.toLowerCase();
                  final isVideo = ['mp4', 'mov', 'avi'].contains(ext);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.blue.shade100, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isVideo
                              ? Icons.videocam_rounded
                              : Icons.image_rounded,
                          color: Constant.mediumBlueColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            text: fileName.split('/').last,
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _fileTypeLabel(String fileType) {
    switch (fileType) {
      case 'Notice134Affixture':
        return '13(4) Notice Affixture';
      case 'Notice134Signed':
        return '13(4) Scanned & Signed';
      case 'Notice134ByHandToCustomer':
        return '13(4) By Hand to Customer';
      case 'PropertyVideo':
        return 'Property Video';
      default:
        return fileType;
    }
  }

  // ── Common widget helpers (mirrors create screen exactly) ─────────────────

  Widget _buildStepBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Step 1', 'Form Details'),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 2,
              color: activeStep >= 1
                  ? Constant.mediumBlueColor
                  : Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 8),
          _buildStepIndicator(1, 'Step 2', 'Documents'),
        ],
      ),
    );
  }

  Widget _buildYesNoToggle({
    required String? value,
    required void Function(String) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onChanged('Yes'),
            child: _toggleOption('Yes', value == 'Yes'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => onChanged('No'),
            child: _toggleOption('No', value == 'No'),
          ),
        ),
      ],
    );
  }

  Widget _toggleOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? Constant.mediumBlueColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
          isSelected ? Constant.mediumBlueColor : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            color: isSelected ? Constant.mediumBlueColor : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          CustomText(
              text: label,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Constant.mediumBlueColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: isSubmitting
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2),
        )
            : CustomText(
          text: label,
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(List<Widget> rows) {
    return Card(
      elevation: 2,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.white,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        child: Column(
          children: rows
              .asMap()
              .entries
              .map(
                (entry) => Column(
              children: [
                entry.value,
                if (entry.key < rows.length - 1)
                  Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey.shade200),
              ],
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    int? index,
    String? ref,
    required String address,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCDD8F6), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index != null) ...[
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Constant.mediumBlueColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ref != null && ref.isNotEmpty)
                  Text(
                    'Ref: $ref',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (ref != null && ref.isNotEmpty)
                  const SizedBox(height: 2),
                Text(
                  address.isEmpty ? '—' : address,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildResidentialAddressSection(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Residential Address',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 6),
          _buildAddressCard(
            index: null,   // no numbering — it's a single address
            ref: null,
            address: value.isEmpty ? '—' : value,
          ),
          const Divider(height: 14),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 165,
            child: CustomText(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          CustomText(
              text: ' : ',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500),
          Expanded(
            child: CustomText(
              text: value.isNotEmpty ? value : '—',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow2(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 165,
            height: value.isNotEmpty ? 50 : 20,
            child: CustomText(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          CustomText(
              text: ' : ',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500),
          Expanded(
            child: CustomText(
              text: value.isNotEmpty ? value : '—',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollateralsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Property Address',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 6),
          if (_collaterals.isEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: CustomText(
                text: _propertyAddress.isNotEmpty ? _propertyAddress : '—',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                textAlign: TextAlign.end,
              ),
            )
          else
            ...List.generate(_collaterals.length, (index) {
              final c = _collaterals[index];
              return Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCDD8F6), width: 0.8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Constant.mediumBlueColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((c['collateralRef'] as String).isNotEmpty)
                            Text(
                              'Ref: ${c['collateralRef']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            (c['collateralAddress'] as String).isNotEmpty
                                ? c['collateralAddress'] as String
                                : '—',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Constant.mediumBlueColor,
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            color: Constant.mediumYellowColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: CustomText(
        text: label,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInputDescription(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: CustomText(
        text: label,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildStepIndicator(int index, String stepNum, String title) {
    bool isActive = activeStep == index;
    bool isCompleted = activeStep > index;
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isCompleted
              ? Colors.green
              : isActive
              ? Constant.mediumBlueColor
              : Colors.grey.shade300,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
            (index + 1).toString(),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: stepNum,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Constant.mediumBlueColor
                  : Colors.grey.shade500,
            ),
            CustomText(
              text: title,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black87 : Colors.grey.shade600,
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
            color: Constant.mediumBlueColor, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hintText,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _dropdownDecoration(hintText),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Constant.mediumBlueColor),
      style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500),
      onChanged: onChanged,
      items: options
          .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
          .toList(),
    );
  }

  Widget _buildFilePlaceholder(String path) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file,
              color: Colors.blueGrey, size: 28),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              path.split('/').last,
              style: const TextStyle(fontSize: 9, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadListField({
    required String label,
    required List<String> filePaths,
    required VoidCallback onTap,
    required void Function(int) onRemove,
    IconData icon = Icons.upload_file,
    String hint = 'Upload files',
    bool isLoading = false,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label),
        _buildInputDescription("($description)" ?? ""),
        if (isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Constant.mediumBlueColor, width: 1.2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Constant.mediumBlueColor),
                ),
                const SizedBox(height: 10),
                const CustomText(
                  text: 'Processing...',
                  color: Constant.mediumBlueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),

        if (!isLoading && filePaths.isEmpty)
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.2,
                    style: BorderStyle.solid),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.grey.shade400, size: 32),
                  const SizedBox(height: 8),
                  CustomText(
                    text: hint,
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(height: 4),
                  const CustomText(
                    text: 'Tap to capture / select',
                    color: Constant.mediumBlueColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),

        if (!isLoading && filePaths.isNotEmpty) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 14),
                    const SizedBox(width: 4),
                    CustomText(
                      text:
                      '${filePaths.length} file${filePaths.length > 1 ? 's' : ''} selected',
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Constant.mediumBlueColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_a_photo_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      CustomText(
                        text: 'Add More',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: filePaths.length,
            itemBuilder: (context, i) {
              final path = filePaths[i];
              final isImage = path.toLowerCase().endsWith('.jpg') ||
                  path.toLowerCase().endsWith('.jpeg') ||
                  path.toLowerCase().endsWith('.png');
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _openImagePreview(path),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isImage
                          ? Image.file(
                        File(path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildFilePlaceholder(path),
                      )
                          : _buildFilePlaceholder(path),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFileUploadField({
    required String label,
    String? filePath,
    String? hint,
    IconData icon = Icons.upload_file,
    required VoidCallback onTap,
    required VoidCallback onClear,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label),
        _buildInputDescription("($description)" ?? ""),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: filePath == null || filePath.isEmpty
                    ? Colors.grey.shade300
                    : Constant.mediumBlueColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: filePath == null || filePath.isEmpty
                      ? Colors.grey
                      : Constant.mediumBlueColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: filePath != null && filePath.isNotEmpty
                      ? Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: filePath.split('/').last,
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel,
                            color: Colors.red, size: 20),
                        onPressed: onClear,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  )
                      : CustomText(
                    text: hint ?? 'Upload file',
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (filePath == null || filePath.isEmpty)
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.grey, size: 14)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _openImagePreview(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(imagePath: imagePath),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null) return const SizedBox.shrink();
    return Column(
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 48,
                  color: Colors.white,
                ),
                onPressed: () {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_videoController!.value.isInitialized) ...[
          Slider(
            min: 0.0,
            max: _videoController!.value.duration.inSeconds.toDouble(),
            value: _videoController!.value.position.inSeconds
                .toDouble()
                .clamp(
                0.0,
                _videoController!.value.duration.inSeconds
                    .toDouble()),
            onChanged: (value) {
              _videoController!
                  .seekTo(Duration(seconds: value.toInt()));
              setState(() {});
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_videoController!.value.position),
                  style: const TextStyle(fontSize: 12)),
              Text(_formatDuration(_videoController!.value.duration),
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes =
    d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
    d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildVideoTrimmerPanel() {
    return Card(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.video_settings_rounded,
                    color: Constant.mediumBlueColor),
                const SizedBox(width: 8),
                const CustomText(
                  text: 'Video Player',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Constant.mediumBlueColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomText(
                    text:
                    '${(videoTrimEnd - videoTrimStart).toStringAsFixed(0)}s Selected',
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isVideoSelected && _videoController != null)
              _buildVideoPlayer(),
            // const SizedBox(height: 10),
            // const CustomText(
            //   text: 'Drag the sliders below to trim the video length:',
            //   fontSize: 12,
            //   color: Colors.black54,
            // ),
            // const SizedBox(height: 10),
            // RangeSlider(
            //   values: RangeValues(videoTrimStart, videoTrimEnd),
            //   min: 0.0,
            //   max: videoMaxDuration,
            //   divisions:
            //   videoMaxDuration.toInt() > 0 ? videoMaxDuration.toInt() : 1,
            //   activeColor: Constant.mediumYellowColor,
            //   inactiveColor: Colors.grey.shade300,
            //   labels: RangeLabels(
            //     '${videoTrimStart.toStringAsFixed(0)}s',
            //     '${videoTrimEnd.toStringAsFixed(0)}s',
            //   ),
            //   onChanged: (RangeValues values) {
            //     if (values.end - values.start >= 0.5) {
            //       setState(() {
            //         videoTrimStart = values.start;
            //         videoTrimEnd = values.end;
            //         if (isVideoSelected && _videoController != null) {
            //           _videoController!.seekTo(
            //               Duration(seconds: videoTrimStart.toInt()));
            //         }
            //       });
            //     }
            //   },
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     CustomText(
            //       text: 'Start: ${videoTrimStart.toStringAsFixed(0)}s',
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black87,
            //     ),
            //     CustomText(
            //       text: 'End: ${videoTrimEnd.toStringAsFixed(0)}s',
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black87,
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 16),
            // const CustomText(
            //   text: 'Quick Trim Presets:',
            //   fontSize: 12,
            //   fontWeight: FontWeight.w600,
            //   color: Colors.black87,
            // ),
            // const SizedBox(height: 8),
            // Row(
            //   children: [
            //     _buildPresetButton('15s', 15.0),
            //     _buildPresetButton('30s', 30.0),
            //     _buildPresetButton('60s', 60.0),
            //     _buildPresetButton('Reset', videoMaxDuration),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, double duration) {
    if (label != 'Reset' && duration >= videoMaxDuration) {
      return const SizedBox.shrink();
    }
    bool isSelected = (label == 'Reset' &&
        videoTrimEnd == videoMaxDuration &&
        videoTrimStart == 0.0) ||
        (label != 'Reset' &&
            (videoTrimEnd - videoTrimStart) == duration);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (label == 'Reset') {
              videoTrimStart = 0.0;
              videoTrimEnd = videoMaxDuration;
            } else {
              if (videoTrimStart + duration <= videoMaxDuration) {
                videoTrimEnd = videoTrimStart + duration;
              } else {
                videoTrimStart = videoMaxDuration - duration;
                if (videoTrimStart < 0) videoTrimStart = 0.0;
                videoTrimEnd = videoMaxDuration;
              }
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isSelected ? Constant.mediumBlueColor : Colors.white,
          foregroundColor:
          isSelected ? Colors.white : Colors.black87,
          elevation: 0,
          side: BorderSide(
              color: isSelected
                  ? Constant.mediumBlueColor
                  : Colors.grey.shade300),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen image viewer
// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({required this.imagePath});
  final String imagePath;

  @override
  State<_FullScreenImageViewer> createState() =>
      _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final TransformationController _transformationController =
  TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Image Preview',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.file(
            File(widget.imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image,
                    color: Colors.white54, size: 64),
                SizedBox(height: 12),
                Text(
                  'Unable to load image',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}