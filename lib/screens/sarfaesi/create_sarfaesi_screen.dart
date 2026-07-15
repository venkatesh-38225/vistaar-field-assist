import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:re_kyc_mobile_app/models/loan_details_res.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:re_kyc_mobile_app/screens/legal_notice/legal_notice_screen.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/custom_textform_field.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/utils/helper.dart';
import 'package:video_compress/video_compress.dart';

/// Formats an integer text field with Indian/international comma grouping
/// (e.g. 50000 → 50,000) while the user types.
/// The raw numeric value (digits only) is what gets stored/submitted.
class _CommaInputFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat('#,##0');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Strip all non-digit characters to get the raw number
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

class CreateSarfaesiScreen extends StatefulWidget {
  const CreateSarfaesiScreen({
    super.key,
    required this.employeeId,
    required this.branchCode,
  });

  final String employeeId;
  final String branchCode;

  @override
  State<CreateSarfaesiScreen> createState() => _CreateSarfaesiScreenState();
}

class _CreateSarfaesiScreenState extends State<CreateSarfaesiScreen> {
  VideoPlayerController? _videoController;
  final _formKey = GlobalKey<FormState>();
  // video controller disposed in dispose
  late FocusNode lanFocusNode;

  // LAN Search
  final TextEditingController lanController = TextEditingController();

  // Data fields populated after LAN search (stored as strings for display)
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

  // Possession Status dropdown
  String? selectedPossessionStatus;
  final List<String> possessionStatusOptions = ['Yes', 'No'];

  // Option dropdowns and inputs for Possession Status = No
  String? selectedNoPossessionReason;
  final List<String> noPossessionReasonOptions = [
    'Customer Denied',
    'Property Not Found',
    'Death in the Family – Further Process Could Not Be Initiated',
    'Court Stay Order',
    'Community Dominated Area',
    'Customer made payment',
  ];

  // Option dropdowns and inputs for Response Status
  String? selectedResponseStatus;
  final List<String> responseStatusOptions = [
    'Ready to pay',
    'Ready to do settlement',
    'Not Ready to pay'
  ];

  // Steps / Form details when Possession Status = Yes
  int activeStep = 0; // 0 for Step 1 Form, 1 for Step 2 Uploads

  // Step 1: Form Fields
  DateTime? selectedPossessionDate;
  final TextEditingController possessionDateController =
      TextEditingController();
  String? handServiceToCustomer; // 'Yes' or 'No'

  String? selectedCustomerProfile;
  final List<String> customerProfileOptions = [
    'Doing business',
    'doing labour job',
    'Expired',
    'Not doing anything',
    'Shifted',
    'Salaried'
  ];

  String? selectedPropertyOccupiedBy;
  final List<String> propertyOccupiedByOptions = [
    'Tenant',
    'Owner',
    'Relatives',
    'Vacant'
  ];

  String? selectedPropertyType;
  final List<String> propertyTypeOptions = [
    'Vacant Land',
    'Commercial',
    'Residential'
  ];

  String? selectedPropertyCondition;
  final List<String> propertyConditionOptions = ['Average', 'Poor', 'Good'];

  final TextEditingController estimatedValueController =
      TextEditingController();

  String? selectedIntentCapabilityIssue;
  final List<String> intentCapabilityIssueOptions = [
    'Intentional defaulter',
    'Capability issue',
    'Customer expired',
    'Co-applicant expired',
    'Customer & co-applicant expired'
  ];

  // Step 2: Document / File paths
  List<String> noticeAffixturePaths = [];
  List<String> noticeScannedCopyPaths = [];
  String? propertyVideoPath;
  List<String> noticeByHandPaths = [];
  bool isProcessingByHand = false;
  // WhatsApp-style video trimming properties
  double videoTrimStart = 0.0;
  double videoTrimEnd = 30.0;
  double videoMaxDuration = 60.0;
  bool isVideoSelected = false;

  bool isSubmitting = false;
  bool isProcessingImage = false; // global GPS embedding flag (kept for compat)
  bool isProcessingAffixture = false; // loading indicator for affixture field
  bool isProcessingScanned = false; // loading indicator for scanned copy field
  bool isLanSearching = false;
  bool isDetailsFetched = false;
  bool isMappedLansLoading = false;

  List<String> mappedLans = [];
  int? _createdReqId;
  String? _gpsInfo; // Stores lat,lng display string

  final EdgeInsets contentPadding =
      const EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  @override
  void initState() {
    super.initState();
    lanFocusNode = FocusNode();
    fetchMappedLans();
  }

  Future<void> fetchMappedLans() async {
    setState(() => isMappedLansLoading = true);
    try {
      final lans = await ApiClient().getMappedLans(widget.employeeId);

      setState(() {
        mappedLans = lans ?? [];
        isMappedLansLoading = false;
      });
    } catch (e) {
      setState(() => isMappedLansLoading = false);
    }
  }

  @override
  void dispose() {
    lanFocusNode.dispose();
    lanController.dispose();
    possessionDateController.dispose();
    estimatedValueController.dispose();
    super.dispose();
  }

  void _clearDetails() {
    _lan = '';
    _customerName = '';
    _propertyAddress = '';
    _residentialAddress = '';
    _customerContact = '';
    _alternateContact = '';
    _pos = '';
    _tos = '';
    _dpd = '';
    _branch = '';
    _branchCode = '';
    _region = '';
    _zone = '';
    _megaZone = '';
    selectedPossessionStatus = null;
    isDetailsFetched = false;

    // Reset Possession Status fields
    selectedNoPossessionReason = null;
    activeStep = 0;
    selectedPossessionDate = null;
    possessionDateController.clear();
    handServiceToCustomer = null;
    selectedCustomerProfile = null;
    selectedPropertyOccupiedBy = null;
    selectedPropertyType = null;
    selectedPropertyCondition = null;
    estimatedValueController.clear();
    selectedIntentCapabilityIssue = null;

    // Reset Document Upload paths
    noticeAffixturePaths.clear();
    propertyVideoPath = null;
    noticeScannedCopyPaths.clear();
    videoTrimStart = 0.0;
    videoTrimEnd = 30.0;
    isVideoSelected = false;
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

  Future<void> searchLanDetails() async {
    lanFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    final lan = lanController.text.trim();
    if (lan.isEmpty) {
      GlobalSnackbar.showError('Please enter LAN number');
      return;
    }

    final bool isLanAvailable = mappedLans.any((availableLan) =>
        availableLan.trim().toUpperCase() == lan.toUpperCase());
    if (!isLanAvailable) {
      GlobalSnackbar.showError('This LAN is not in your available LANs list');

      setState(() {
        _clearDetails();
      });
      return;
    }

    setState(() {
      isLanSearching = true;
      _clearDetails();
    });

    try {
      final response = await ApiClient().getLanNoticeDetails(lan);
      final foreClosureResponse = await ApiClient().getForeClosureDetails(lan);

      if (response is LoanDetailsResponse && response.fullName != null) {
        setState(() {
          _lan = response.lan ?? '';
          _customerName = response.fullName ?? '';
          _pos = foreClosureResponse?.pos?.toString() ?? '';
          _tos = foreClosureResponse?.totalOutstanding ?? "" ?? '';
          _dpd = response.dpd ?? '';
          _branch = response.branch?.branchName ?? '';
          _branchCode = response.branch?.branchCode ?? '';
          _region = response.branch?.region ?? '';
          _zone = response.branch?.zone ?? '';
          _megaZone = response.branch?.megaZone ?? '';
          _residentialAddress = response.residentialAddress ?? '';
          _customerContact = response.mobile ?? '';
          _alternateContact = response.alternateMobile ?? '';

          isDetailsFetched = true;
          isLanSearching = false;
        });

        await _fetchCollateralsByLan();
        Future.delayed(const Duration(milliseconds: 100), () {
          lanFocusNode.unfocus();
          FocusScope.of(context).unfocus();
        });
      } else {
        String errMsg = 'No data found for this LAN';
        if (response is String) {
          errMsg = response;
        } else if (response is Map) {
          errMsg = response['message']?.toString() ?? errMsg;
        }
        setState(() {
          isLanSearching = false;
          isDetailsFetched = false;
        });
        GlobalSnackbar.showError(errMsg);
      }
    } catch (e) {
      setState(() {
        isLanSearching = false;
        isDetailsFetched = false;
      });

      GlobalSnackbar.showError('Error fetching LAN details');
    }
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
            if (type == 'affixture')
              isProcessingAffixture = true;
            else if (type == 'byhand')
              isProcessingByHand = true;
            else
              isProcessingScanned = true;
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
            if (type == 'affixture')
              isProcessingAffixture = true;
            else if (type == 'byhand')
              isProcessingByHand = true;
            else
              isProcessingScanned = true;
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

  List<String> _wrapText(
    String text,
    int maxCharsPerLine,
  ) {
    final words = text.split(' ');
    final List<String> lines = [];

    String currentLine = '';

    for (final word in words) {
      if ((currentLine + word).length <= maxCharsPerLine) {
        currentLine += currentLine.isEmpty ? word : ' $word';
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  Future<void> _embedGpsIntoImage(String imagePath) async {
    try {
      // ── 1. Location permission ──────────────────────────────────────
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        GlobalSnackbar.showError(
            'Location permission denied permanently. Please enable it in Settings.');
        return;
      }
      if (permission == LocationPermission.denied) {
        GlobalSnackbar.showError('Location permission denied.');
        return;
      }

      // ── 2. Current GPS position ─────────────────────────────────────
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final double lat = position.latitude;
      final double lng = position.longitude;

      // ── 3. Decode the photo ─────────────────────────────────────────
      final Uint8List originalBytes = await File(imagePath).readAsBytes();
      final img.Image? image = img.decodeImage(originalBytes);
      if (image == null) {
        GlobalSnackbar.showError('Unable to decode image for GPS stamp.');
        return;
      }

      // ── 4. Reverse geocode to get real address ──────────────────────
      String addressLine = '';
      try {
        final Uri geoUri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=$lat&lon=$lng&format=json',
        );
        final http.Response geoResp = await http.get(geoUri, headers: {
          'User-Agent': 'SarfaesiApp/1.0'
        }).timeout(const Duration(seconds: 6));
        if (geoResp.statusCode == 200) {
          final Map<String, dynamic> geoJson =
              jsonDecode(geoResp.body) as Map<String, dynamic>;
          // Use display_name but cap it at ~80 chars so it fits the banner
          final String full = (geoJson['display_name'] as String? ?? '').trim();
          addressLine = full;
        }
      } catch (_) {
        // Reverse geocode failed — fall back to coordinate string
        addressLine = '';
      }
      // ── 5. Build text strings ───────────────────────────────────────
      final String latDec =
          '${lat >= 0 ? "N" : "S"} ${lat.abs().toStringAsFixed(6)}';
      final String lngDec =
          '${lng >= 0 ? "E" : "W"} ${lng.abs().toStringAsFixed(6)}';

      String toDMS(double deg, bool isLat) {
        final d = deg.abs().floor();
        final mFull = (deg.abs() - d) * 60;
        final m = mFull.floor();
        final s = ((mFull - m) * 60).toStringAsFixed(1);
        final dir = isLat ? (deg >= 0 ? 'N' : 'S') : (deg >= 0 ? 'E' : 'W');
        return "$d deg ${m}' ${s}\" $dir";
      }

      final String latDMS = toDMS(lat, true);
      final String lngDMS = toDMS(lng, false);

      final DateTime now = DateTime.now();
      final String dateStr = DateFormat('EEEE, dd MMMM yyyy').format(now);
      final String timeStr = DateFormat('HH:mm:ss').format(now);
      final String lanLine = _lan.isNotEmpty ? 'LAN: $_lan' : 'SARFAESI 13(4)';

      final int stampW = image.width; // ← matches photo exactly, no h-stretch

      img.BitmapFont fontTitle = img.arial48; // ~52 px glyphs
      img.BitmapFont fontBody = img.arial24; // ~28 px glyphs

      final int titleH = (image.height * 0.016).round(); // ~1 large row
      final int bodyH = (image.height * 0.016).round(); // ~1 body row
      const int padV = 14; // top & bottom padding (photo pixels)
      const int padH = 20; // left padding (photo pixels)
      const int accentH = 6; // amber top bar (photo pixels)

      // Total rows: accentH + padV + title + body*4 + padV
      // (address, LAN, decimal coords, DMS coords, date+time)
      final int stampH =
          accentH + padV + titleH + bodyH + bodyH + bodyH + bodyH + padV + 60;

      // ── 7. Allocate stamp canvas ────────────────────────────────────
      final img.Image stamp = img.Image(width: stampW, height: stampH);
      img.fill(stamp, color: img.ColorRgba8(15, 20, 35, 245));

      // Amber top accent bar
      img.fillRect(stamp,
          x1: 0,
          y1: 0,
          x2: stampW,
          y2: accentH,
          color: img.ColorRgba8(255, 193, 7, 255));

      // ── 8. Text rows (no left panel — full width text) ──────────────
      final img.Color colWhite = img.ColorRgba8(255, 255, 255, 255);
      final img.Color colAmber = img.ColorRgba8(255, 210, 50, 255);
      final img.Color colGrey = img.ColorRgba8(185, 195, 210, 255);
      final img.Color colGreen = img.ColorRgba8(40, 190, 110, 255);

      int ty = accentH + padV;

      final String titleText =
          addressLine.isNotEmpty ? addressLine : 'LAN: $_lan';

      if (addressLine.isNotEmpty) {
        img.drawString(
          stamp,
          lanLine,
          font: fontBody,
          x: padH,
          y: ty,
          color: colAmber,
        );
      }

      ty += titleH;

// Wrap address into multiple lines
      final List<String> wrappedAddress = _wrapText(titleText, 99);

      for (final line in wrappedAddress) {
        img.drawString(
          stamp,
          line,
          font: fontBody,
          x: padH,
          y: ty,
          color: colWhite,
        );

        ty += bodyH;
      }

      img.drawString(stamp, 'Lat: $latDec     Lng: $lngDec',
          font: fontBody, x: padH, y: ty, color: colGrey);
      ty += bodyH;

      img.drawString(stamp, '$latDMS   $lngDMS',
          font: fontBody, x: padH, y: ty, color: colGrey);
      ty += bodyH;

      img.drawString(stamp, '$dateStr   $timeStr',
          font: fontBody, x: padH, y: ty, color: colWhite);

      ty += bodyH;
      // GPS Verified badge at right end of date row
      const int badgeW = 260;
      final int badgeX = stampW - badgeW - padH;
      img.fillRect(stamp,
          x1: badgeX,
          y1: ty,
          x2: badgeX + badgeW,
          y2: ty + bodyH - 4,
          color: colGreen);
      img.drawString(stamp, ' GPS Verified',
          font: fontBody, x: badgeX + 6, y: ty + 2, color: colWhite);

      // ── 9. Composite stamp directly — NO copyResize needed ──────────
      // stampW == image.width so width is already exact.
      // Only darken the strip behind the stamp.
      final int bannerY = image.height - stampH;
      for (int y = bannerY; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final img.Pixel p = image.getPixel(x, y);
          image.setPixelRgba(x, y, (p.r * 0.15).round(), (p.g * 0.15).round(),
              (p.b * 0.15).round(), 255);
        }
      }

      img.compositeImage(image, stamp,
          dstX: 0, dstY: bannerY, blend: img.BlendMode.alpha);

      // ── 10. Save & update UI ─────────────────────────────────────────
      final List<int> encoded = img.encodeJpg(image, quality: 90);
      await File(imagePath).writeAsBytes(encoded);

      setState(() {
        _gpsInfo =
            'Lat ${lat.toStringAsFixed(6)}, Lng ${lng.toStringAsFixed(6)}';
      });
    } catch (e) {
      debugPrint('GPS embed error: $e');
      GlobalSnackbar.showError('Failed to stamp GPS onto image.');
    }
  }

  Future<void> _initializeVideo(String path) async {
    // Dispose previous controller if any
    await _videoController?.dispose();
    final file = File(path);
    _videoController = VideoPlayerController.file(file);
    try {
      await _videoController!.initialize();
      // Set maximum duration based on video
      final duration = _videoController!.value.duration.inSeconds.toDouble();
      setState(() {
        propertyVideoPath = path;
        isVideoSelected = true;
        videoMaxDuration = duration;
        videoTrimStart = 0.0;
        videoTrimEnd = duration;
      });
      // Listener to enforce trimming bounds during playback
      _videoController!.addListener(() {
        final position = _videoController!.value.position.inSeconds.toDouble();
        if (position >= videoTrimEnd) {
          _videoController!.pause();
          _videoController!.seekTo(Duration(seconds: videoTrimStart.toInt()));
        }
        // Refresh UI for progress bar
        setState(() {});
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
      GlobalSnackbar.showError('Error initializing video');
    }
  }

  Future<double> _getVideoDuration(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return 30.0;

      final length = await file.length();
      final bytes = await file.open();

      final bufferSize = 65536;
      final headerBytes =
          await bytes.read(bufferSize > length ? length : bufferSize);
      await bytes.close();

      double? durationResult = _scanForMvhd(headerBytes);
      if (durationResult != null) {
        return double.parse(durationResult.toStringAsFixed(1));
      }

      if (length > bufferSize) {
        final lastBytes = await file.open();
        final startOffset = length > 131072 ? length - 131072 : 0;
        await lastBytes.setPosition(startOffset);
        final tailBytes = await lastBytes.read(length - startOffset);
        await lastBytes.close();

        durationResult = _scanForMvhd(tailBytes);
        if (durationResult != null) {
          return double.parse(durationResult.toStringAsFixed(1));
        }
      }

      // Fallback calculation based on size (typical 1080p compression is ~1.2MB/s)
      final double estimated = length / (1.2 * 1024 * 1024);
      if (estimated > 5.0 && estimated < 300.0) {
        return double.parse(estimated.toStringAsFixed(1));
      }
    } catch (e) {
      print("Error parsing video duration: $e");
    }
    return 30.0;
  }

  double? _scanForMvhd(List<int> bytes) {
    for (int i = 0; i < bytes.length - 28; i++) {
      if (bytes[i] == 109 && // 'm'
          bytes[i + 1] == 118 && // 'v'
          bytes[i + 2] == 104 && // 'h'
          bytes[i + 3] == 100) {
        // 'd'
        final int version = bytes[i + 4];
        int timescaleOffset = i + 12;
        int durationOffset = i + 16;

        if (version == 1) {
          timescaleOffset = i + 20;
          durationOffset = i + 24;
          final int timescale = _read64(bytes, timescaleOffset);
          final int duration = _read64(bytes, durationOffset);
          if (timescale > 0) return duration / timescale;
        } else {
          final int timescale = _read32(bytes, timescaleOffset);
          final int duration = _read32(bytes, durationOffset);
          if (timescale > 0) return duration / timescale;
        }
      }
    }
    return null;
  }

  int _read32(List<int> bytes, int offset) {
    if (offset + 3 >= bytes.length) return 0;
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  int _read64(List<int> bytes, int offset) {
    if (offset + 7 >= bytes.length) return 0;
    return (bytes[offset] << 56) |
        (bytes[offset + 1] << 48) |
        (bytes[offset + 2] << 40) |
        (bytes[offset + 3] << 32) |
        (bytes[offset + 4] << 24) |
        (bytes[offset + 5] << 16) |
        (bytes[offset + 6] << 8) |
        bytes[offset + 7];
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

      final sizeMB = await compressedFile.length() / (1024 * 1024);

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

  bool _validateStep1() {
    if (selectedPossessionDate == null) {
      GlobalSnackbar.showError('Please select possession date');
      return false;
    }
    if (handServiceToCustomer == null) {
      GlobalSnackbar.showError('Please select 13(4) by hand service option');
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
      GlobalSnackbar.showError('Please enter estimated value of property');
      return false;
    }
    if (selectedIntentCapabilityIssue == null) {
      GlobalSnackbar.showError(
          'Please select customer intent / capability issue');
      return false;
    }
    if (selectedResponseStatus == null) {
      GlobalSnackbar.showError('Please select response status');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (noticeAffixturePaths.isEmpty) {
      GlobalSnackbar.showError('Please upload 13(4) notice affixture file');
      return false;
    }
    if (propertyVideoPath == null || propertyVideoPath!.isEmpty) {
      GlobalSnackbar.showError('Please upload property video');
      return false;
    }
    if (noticeScannedCopyPaths.isEmpty) {
      GlobalSnackbar.showError(
          'Please upload 13(4) notice scanned and signed copy');
      return false;
    }
    if (handServiceToCustomer == 'Yes' && noticeByHandPaths.isEmpty) {
      GlobalSnackbar.showError(
          'Please upload 13(4) notice by hand service document');
      return false;
    }
    return true;
  }

  Future<void> updateRequest() async {
    if (_createdReqId == "" || _createdReqId == null) {
      GlobalSnackbar.showSuccess(
        'Invalid Req Id',
      );
      return;
    }
    setState(() => isSubmitting = true);

    final payload = <String, dynamic>{
      'lan': _lan,
      'customerName': _customerName,
      'propertyAddress': _propertyAddress.isNotEmpty ? _propertyAddress : 'N/A',
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
          double.tryParse(estimatedValueController.text.replaceAll(',', '')) ??
              0.0;
      payload['customerIntentCapability'] = selectedIntentCapabilityIssue;
      payload['responseStatus'] = selectedResponseStatus;
    }

    debugPrint('SARFAESI update payload: ${jsonEncode(payload)}');

    // Call updateSarfaesiStatus with reqId appended to the URL
    final updateResponse = await ApiClient()
        .updateSarfaesiStatus(jsonEncode(payload), _createdReqId);

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

  Future<void> createRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedPossessionStatus == null) {
      GlobalSnackbar.showError('Please select possession status');
      return;
    }

    if (selectedPossessionStatus == 'No') {
      if (selectedNoPossessionReason == null) {
        GlobalSnackbar.showError('Please select reason for no possession');
        return;
      }
    } else if (selectedPossessionStatus == 'Yes') {
      if (!_validateStep1()) return;
    }

    setState(() {
      isSubmitting = true;
    });

    if (_createdReqId != null) {
      print("Created ReqID: ${_createdReqId}");
      await updateRequest();
      return;
    }

    final payload = <String, dynamic>{
      'lan': _lan,
      'customerName': _customerName,
      'propertyAddress': _propertyAddress != "" ? "$_collaterals" : "N/A",
      'residentialAddress': _residentialAddress,
      'mobile': _customerContact,
      'alternateMobile': _alternateContact != "" ? _alternateContact : '0',
      'pos': double.tryParse(_pos) ?? 0,
      'tos': double.tryParse(_tos) ?? 0,
      'dpd': int.tryParse(_dpd) ?? 0,
      'branchCode': _branchCode,
      'branchName': _branch,
      'region': _region,
      'zone': _zone,
      'megaZone': _megaZone,
      'isPossessionTaken': selectedPossessionStatus == "Yes" ? true : false,
      'createdBy': widget.employeeId,
    };

    if (selectedPossessionStatus == 'No') {
      payload['nonPossessionReason'] = selectedNoPossessionReason;
    } else {
      payload['possessionDate'] = selectedPossessionDate?.toIso8601String();
      payload['is134HandService'] =
          handServiceToCustomer == "Yes" ? true : false;
      payload['customerProfile'] = selectedCustomerProfile;
      payload['propertyOccupiedBy'] = selectedPropertyOccupiedBy;
      payload['propertyType'] = selectedPropertyType;
      payload['propertyCondition'] = selectedPropertyCondition;
      payload['estimatedPropertyValue'] =
          double.tryParse(estimatedValueController.text.replaceAll(',', '')) ??
              0.0;
      payload['customerIntentCapability'] = selectedIntentCapabilityIssue;
      payload['responseStatus'] = selectedResponseStatus;
    }

    print('SARFAESI payload to create: ${jsonEncode(payload)}');

    final createResponse = await ApiClient().createSarfaesi(payload);
    setState(() {
      isSubmitting = false;
    });

    if (createResponse != null) {
      final statusCode = createResponse['statusCode'];
      final data = createResponse['data'];

      if (statusCode == 200 || statusCode == 201) {
        GlobalSnackbar.showSuccess(
          data['message'] ?? 'SARFAESI request created successfully',
        );

        final int reqId = (data['data'] as num).toInt();

        if (selectedPossessionStatus == 'Yes') {
          setState(() {
            _createdReqId = reqId;
            activeStep = 1;
          });
        } else {
          Get.back(result: true);
        }
      } else {
        String errorMessage = 'Failed to submit request';

        // ASP.NET validation errors
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;

          if (errors.isNotEmpty) {
            final firstKey = errors.keys.first;

            final firstErrorList = errors[firstKey];

            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              errorMessage = firstErrorList.first.toString();
            }
          }
        }

        // fallback message
        else if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['title'] != null) {
          errorMessage = data['title'];
        }

        GlobalSnackbar.showError(errorMessage);
      }
    } else {
      GlobalSnackbar.showError(
        'Something went wrong',
      );
    }
    // await _videoController?.dispose();
  }

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    final payload = <String, dynamic>{
      'ReqId': _createdReqId,
      'updatedBy': widget.employeeId,
    };

    print('SARFAESI payload to submit: ${jsonEncode(payload)}');

    final submitResponse = await ApiClient().submitSarfaesi(payload);
    setState(() {
      isSubmitting = false;
    });

    if (submitResponse != null) {
      final statusCode = submitResponse['statusCode'];
      final data = submitResponse['data'];

      if (statusCode == 200 || statusCode == 201) {
        GlobalSnackbar.showSuccess(
          data['message'] ?? 'SARFAESI request submitted successfully',
        );
        Get.back();
      } else {
        String errorMessage = 'Failed to submit request';

        // ASP.NET validation errors
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;

          if (errors.isNotEmpty) {
            final firstKey = errors.keys.first;

            final firstErrorList = errors[firstKey];

            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              errorMessage = firstErrorList.first.toString();
            }
          }
        }

        // fallback message
        else if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['title'] != null) {
          errorMessage = data['title'];
        }

        GlobalSnackbar.showError(errorMessage);
      }
    } else {
      GlobalSnackbar.showError(
        'Something went wrong',
      );
    }
    // await _videoController?.dispose();
  }

  Future<void> submitDocuments() async {
    if (!_validateStep2()) return;

    if (_createdReqId == null) {
      GlobalSnackbar.showError(
          'Request ID not found. Please go back and resubmit Step 1.');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final int reqId = _createdReqId!;
      final String createdBy = widget.employeeId;
      bool allSuccess = true;

      // ── Upload each affixture image ───────────────────────────────
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

      // ── Upload each scanned copy ──────────────────────────────────
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
// ── Upload by-hand service documents (only if Yes was selected) ──
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
      final compressedVideo = await _compressVideo(propertyVideoPath!);
      // ── Upload property video ─────────────────────────────────────
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
        submitRequest();
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
      GlobalSnackbar.showError('File not found: ${filePath.split('/').last}');
      return false;
    }

    final Map<String, dynamic>? result = await ApiClient().uploadSarfaesiFile(
      reqId: reqId,
      fileType: fileType,
      file: file,
      createdBy: createdBy,
    );

    if (result == null) {
      GlobalSnackbar.showError('Upload failed: ${filePath.split('/').last}');
      return false;
    }

    final int statusCode = result['statusCode'] as int;
    final dynamic data = result['data'];

    if (statusCode == 200 || statusCode == 201) {
      return true;
    }

    // Show the backend error message if available
    String errMsg = 'Failed to upload ${filePath.split('/').last}';
    if (data is Map<String, dynamic>) {
      errMsg = data['message']?.toString() ?? errMsg;
    }
    GlobalSnackbar.showError(errMsg);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          text: 'Create SARFAESI 13(4)',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── LAN SEARCH ──────────────────────────────────────────
              // ─── LAN SEARCH (Autocomplete) ───────────────────────────────
              _buildSectionTitle('LAN Search'),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RawAutocomplete<String>(
                      textEditingController: lanController,
                      focusNode: lanFocusNode,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return mappedLans;
                        }
                        return mappedLans.where((lan) => lan
                            .toUpperCase()
                            .contains(textEditingValue.text.toUpperCase()));
                      },
                      displayStringForOption: (option) => option,
                      fieldViewBuilder: (context, textController, focusNode,
                          onFieldSubmitted) {
                        return TextFormField(
                          controller: textController,
                          focusNode: focusNode,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: InputDecoration(
                            hintText: isMappedLansLoading
                                ? 'Loading LANs...'
                                : 'Enter LAN',
                            contentPadding: contentPadding,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 0.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Constant.mediumBlueColor, width: 1.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 1.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 1.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: isMappedLansLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : (textController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            size: 18, color: Colors.grey),
                                        onPressed: () {
                                          textController.clear();
                                          setState(() {
                                            _clearDetails();
                                          });
                                        },
                                      )
                                    : null),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'LAN is required' : null,
                          onChanged: (_) =>
                              setState(() {}), // refresh suffix icon state
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxHeight: 220, minWidth: 250),
                              child: options.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          Icon(
                                            mappedLans.isEmpty
                                                ? Icons.info_outline
                                                : Icons.search_off,
                                            size: 16,
                                            color: Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              mappedLans.isEmpty
                                                  ? 'No LANs available'
                                                  : 'No matching LAN found',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);
                                        return ListTile(
                                          dense: true,
                                          leading: const Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            size: 18,
                                            color: Constant.mediumBlueColor,
                                          ),
                                          title: Text(
                                            option,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        );
                      },
                      onSelected: (String selected) {
                        lanController.text = selected;
                        FocusScope.of(context).unfocus();
                        searchLanDetails();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isLanSearching ? null : searchLanDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constant.mediumYellowColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: isLanSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
              // ─── DETAILS CARD (shown after LAN search) ───────────────
              if (isDetailsFetched) ...[
                const SizedBox(height: 20),

                // Customer Details Card
                _buildSectionTitle('LAN Details'),
                const SizedBox(height: 10),
                _buildDetailsCard([
                  _buildDetailRow('LAN', _lan),
                  _buildDetailRow('Customer Name', _customerName),
                  _buildDetailRow('Customer Contact', _customerContact),
                  _buildDetailRow('Alternate Contact', _alternateContact),
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

                // ─── POSSESSION STATUS DROPDOWN ───────────────────────
                _buildSectionTitle('Possession Details'),
                const SizedBox(height: 12),

                _buildInputLabel('Possession Status *'),
                DropdownButtonFormField<String>(
                  value: selectedPossessionStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Select Possession Status',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 0.8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 0.8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Constant.mediumBlueColor, width: 1.2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.0),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Constant.mediumBlueColor),
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select possession status'
                      : null,
                  onChanged: (val) {
                    setState(() {
                      selectedPossessionStatus = val;
                      activeStep = 0; // reset active step
                    });
                  },
                  items: possessionStatusOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                ),

                if (selectedPossessionStatus == 'No') ...[
                  const SizedBox(height: 16),
                  _buildInputLabel('Reason for No Possession *'),
                  _buildDropdownField(
                    value: selectedNoPossessionReason,
                    hintText: 'Select Reason',
                    options: noPossessionReasonOptions,
                    onChanged: (val) {
                      setState(() {
                        selectedNoPossessionReason = val;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  // SUBMIT BUTTON (No Possession)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : createRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constant.mediumBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                              text: 'Submit',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                  ),
                ],

                if (selectedPossessionStatus == 'Yes') ...[
                  const SizedBox(height: 20),
                  // Step Indicator horizontal bar
                  Container(
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
                  ),
                  const Divider(height: 24),

                  if (activeStep == 0) ...[
                    // STEP 1 FIELDS
                    _buildInputLabel('Possession Date *'),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedPossessionDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedPossessionDate = picked;
                            possessionDateController.text =
                                DateFormat('dd-MM-yyyy').format(picked);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomTextFormField(
                          controller: possessionDateController,
                          hintText: 'Select Possession Date',
                          contentPadding: contentPadding,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today,
                                color: Constant.mediumBlueColor),
                            onPressed: () {},
                          ),
                          onSaved: (v) {},
                          validator: (v) => null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('13(4) by hand service to the customer *'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                handServiceToCustomer = 'Yes';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: handServiceToCustomer == 'Yes'
                                    ? Constant.mediumBlueColor.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: handServiceToCustomer == 'Yes'
                                      ? Constant.mediumBlueColor
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    handServiceToCustomer == 'Yes'
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: handServiceToCustomer == 'Yes'
                                        ? Constant.mediumBlueColor
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const CustomText(
                                    text: 'Yes',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                handServiceToCustomer = 'No';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: handServiceToCustomer == 'No'
                                    ? Constant.mediumBlueColor.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: handServiceToCustomer == 'No'
                                      ? Constant.mediumBlueColor
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    handServiceToCustomer == 'No'
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: handServiceToCustomer == 'No'
                                        ? Constant.mediumBlueColor
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const CustomText(
                                    text: 'No',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('Customer Profile *'),
                    _buildDropdownField(
                      value: selectedCustomerProfile,
                      hintText: 'Select Customer Profile',
                      options: customerProfileOptions,
                      onChanged: (val) {
                        setState(() {
                          selectedCustomerProfile = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('Property Occupied By *'),
                    _buildDropdownField(
                      value: selectedPropertyOccupiedBy,
                      hintText: 'Select Occupant Type',
                      options: propertyOccupiedByOptions,
                      onChanged: (val) {
                        setState(() {
                          selectedPropertyOccupiedBy = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('Property Type *'),
                    _buildDropdownField(
                      value: selectedPropertyType,
                      hintText: 'Select Property Type',
                      options: propertyTypeOptions,
                      onChanged: (val) {
                        setState(() {
                          selectedPropertyType = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('Property Condition *'),
                    _buildDropdownField(
                      value: selectedPropertyCondition,
                      hintText: 'Select Property Condition',
                      options: propertyConditionOptions,
                      onChanged: (val) {
                        setState(() {
                          selectedPropertyCondition = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('Estimated Value of Property *'),
                    CustomTextFormField(
                      controller: estimatedValueController,
                      hintText: 'Enter Estimated Value',
                      keyboardType: TextInputType.number,
                      inputFormatters: [_CommaInputFormatter()],
                      contentPadding: contentPadding,
                      onSaved: (v) {},
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('Customer Intent / Capability Issue *'),
                    _buildDropdownField(
                      value: selectedIntentCapabilityIssue,
                      hintText: 'Select Intent / Capability',
                      options: intentCapabilityIssueOptions,
                      onChanged: (val) {
                        setState(() {
                          selectedIntentCapabilityIssue = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputLabel('Response Status *'),
                    _buildDropdownField(
                      value: selectedResponseStatus,
                      hintText: 'Select Response Status',
                      options: responseStatusOptions,
                      onChanged: (val) {
                        setState(() {
                          selectedResponseStatus = val;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    // NEXT BUTTON (Step 1 -> Step 2)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_validateStep1()) {
                            createRequest();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.mediumBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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

                  if (activeStep == 1) ...[
                    // STEP 2 UPLOADS
                    _buildFileUploadListField(
                      label: '13(4) notice affixture *',
                      filePaths: noticeAffixturePaths,
                      hint: 'Upload affixture notice image/PDF',
                      description:
                          "Upload an image that clearly shows the notice affixed on the property, including the customer location’s latitude and longitude details.",
                      isLoading: isProcessingAffixture, // ← NEW
                      onTap: () => _pickDocument('affixture'),
                      onRemove: (index) {
                        setState(() {
                          noticeAffixturePaths.removeAt(index);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFileUploadField(
                      label: 'Property video *',
                      filePath: propertyVideoPath,
                      hint: 'Upload/Record Property Video',
                      description:
                          'Capture a clear video of the complete property. The video should contain the customer location’s latitude and longitude details',
                      icon: Icons.video_call_rounded,
                      onTap: _pickVideo,
                      onClear: () {
                        setState(() {
                          propertyVideoPath = null;
                          isVideoSelected = false;
                        });
                      },
                    ),

                    if (isVideoSelected && propertyVideoPath != null)
                      _buildVideoTrimmerPanel(),

                    const SizedBox(height: 16),
// Shown only when hand service to customer = Yes
                    if (handServiceToCustomer == 'Yes') ...[
                      _buildFileUploadListField(
                        label: '13(4) notice by hand service to customer *',
                        filePaths: noticeByHandPaths,
                        hint: 'Upload by hand service document',
                        description:
                            "Please attach customer signed copy of the 13(4) notice",
                        isLoading: isProcessingByHand,
                        onTap: () => _pickDocument('byhand'),
                        onRemove: (index) {
                          setState(() {
                            noticeByHandPaths.removeAt(index);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildFileUploadListField(
                      label: '13(4) notice scanned and signed copy *',
                      filePaths: noticeScannedCopyPaths,
                      hint: 'Upload signed notice image/PDF',
                      description:
                          'Ensure a clear photo with seal and signature is uploaded for reference.',
                      onTap: () => _pickDocument('scanned'),
                      onRemove: (index) {
                        setState(() {
                          noticeScannedCopyPaths.removeAt(index);
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                    // NAVIGATION ROW (Back / Submit)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  activeStep = 0;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Constant.mediumBlueColor,
                                    width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                                  : (activeStep == 0
                                      ? createRequest
                                      : submitDocuments),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constant.mediumBlueColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps a list of detail rows inside a styled white card.
  Widget _buildDetailsCard(List<Widget> rows) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
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
                if (ref != null && ref.isNotEmpty) const SizedBox(height: 2),
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
            index: null, // no numbering — it's a single address
            ref: null,
            address: value.isEmpty ? '—' : value,
          ),
          const Divider(height: 14),
        ],
      ),
    );
  }

  /// Builds a single `Label : Value` row.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          SizedBox(
            width: 165,
            child: CustomText(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          // Separator
          CustomText(
            text: ' : ',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
          // Value
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
          // Label
          SizedBox(
            width: 165,
            height: value != "" ? 50 : 20,
            child: CustomText(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          // Separator
          CustomText(
            text: ' : ',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
          // Value
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
                  border:
                      Border.all(color: const Color(0xFFCDD8F6), width: 0.8),
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
      padding: const EdgeInsets.only(bottom: 3),
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
              color: isActive ? Constant.mediumBlueColor : Colors.grey.shade500,
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

  Widget _buildDropdownField({
    required String? value,
    required String hintText,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
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
          borderSide:
              const BorderSide(color: Constant.mediumBlueColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Constant.mediumBlueColor),
      style: const TextStyle(
          color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
      onChanged: onChanged,
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ),
          )
          .toList(),
    );
  }

  /// Non-image file placeholder tile shown in the upload grid (PDF etc.)
  Widget _buildFilePlaceholder(String path) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.blueGrey, size: 28),
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

  /// Non-image file placeholder tile (PDF, etc.)
  Widget _buildFileUploadListField({
    required String label,
    required List<String> filePaths,
    required VoidCallback onTap,
    required void Function(int) onRemove,
    IconData icon = Icons.upload_file,
    String hint = 'Upload files',
    bool isLoading = false, // ← NEW
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label),
        _buildInputDescription("($description)" ?? ""),

        // ── Loading state ───────────────────────────────────────────────
        if (isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Constant.mediumBlueColor, width: 1.2),
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
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Constant.mediumBlueColor,
                  ),
                ),
                const SizedBox(height: 10),
                const CustomText(
                  text: 'Adding GPS stamp...',
                  color: Constant.mediumBlueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: 'Please wait, embedding location data',
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),

        // ── Empty state: tap to upload ──────────────────────────────────
        if (!isLoading && filePaths.isEmpty)
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
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
                  CustomText(
                    text: 'Tap to capture / select',
                    color: Constant.mediumBlueColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),

        // ── Uploaded state: image grid + add-more button ────────────────
        if (!isLoading && filePaths.isNotEmpty) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          '${filePaths.length} file${filePaths.length > 1 ? 's' : ''} uploaded',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  if (isImage)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.zoom_in,
                            color: Colors.white, size: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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

  /// Opens a full-screen image viewer so the user can see the GPS stamp.
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
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
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
            value: _videoController!.value.position.inSeconds.toDouble().clamp(
                0.0, _videoController!.value.duration.inSeconds.toDouble()),
            onChanged: (value) {
              _videoController!.seekTo(Duration(seconds: value.toInt()));
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
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${minutes}:${seconds}';
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            // // Range Slider
            // RangeSlider(
            //   values: RangeValues(videoTrimStart, videoTrimEnd),
            //   min: 0.0,
            //   max: videoMaxDuration,
            //   divisions:
            //       videoMaxDuration.toInt() > 0 ? videoMaxDuration.toInt() : 1,
            //   activeColor: Constant.mediumYellowColor,
            //   inactiveColor: Colors.grey.shade300,
            //   labels: RangeLabels(
            //     '${videoTrimStart.toStringAsFixed(0)}s',
            //     '${videoTrimEnd.toStringAsFixed(0)}s',
            //   ),
            //   onChanged: (RangeValues values) {
            //     setState(() {
            //       if (values.end - values.start >= 0.5) {
            //         videoTrimStart = values.start;
            //         videoTrimEnd = values.end;
            //         // Immediately seek to the new start position
            //         if (isVideoSelected && _videoController != null) {
            //           _videoController!
            //               .seekTo(Duration(seconds: videoTrimStart.toInt()));
            //           // Continue playing if it was already playing
            //           if (_videoController!.value.isPlaying) {
            //             _videoController!.play();
            //           }
            //         }
            //       }
            //     });
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
            //   mainAxisAlignment: MainAxisAlignment.start,
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
      return const SizedBox.shrink(); // hide presets larger than video duration
    }

    bool isSelected = (label == 'Reset' &&
            videoTrimEnd == videoMaxDuration &&
            videoTrimStart == 0.0) ||
        (label != 'Reset' && (videoTrimEnd - videoTrimStart) == duration);

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
          backgroundColor: isSelected ? Constant.mediumBlueColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: 0,
          side: BorderSide(
              color:
                  isSelected ? Constant.mediumBlueColor : Colors.grey.shade300),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen image viewer — shows the GPS-stamped image with pinch-to-zoom
// and a "GPS Stamp" info chip so the user knows the stamp is embedded.
// ─────────────────────────────────────────────────────────────────────────────
class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({required this.imagePath});
  final String imagePath;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
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
        // actions: [
        //   // GPS stamp indicator chip
        //   Container(
        //     margin: const EdgeInsets.only(right: 12),
        //     padding:
        //     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        //     decoration: BoxDecoration(
        //       color: Colors.amber.shade700,
        //       borderRadius: BorderRadius.circular(20),
        //     ),
        //     child: const Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(Icons.location_on, color: Colors.white, size: 13),
        //         SizedBox(width: 4),
        //         // Text(
        //         //   'GPS Stamped',
        //         //   style: TextStyle(
        //         //       color: Colors.white,
        //         //       fontSize: 11,
        //         //       fontWeight: FontWeight.bold),
        //         // ),
        //       ],
        //     ),
        //   ),
        // ],
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
                Icon(Icons.broken_image, color: Colors.white54, size: 64),
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
      // bottomNavigationBar: Container(
      //   color: Colors.black,
      //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      //   child: Row(
      //     children: [
      //       const Icon(Icons.info_outline, color: Colors.white54, size: 14),
      //       const SizedBox(width: 6),
      //       // const Expanded(
      //       //   child: Text(
      //       //     'GPS location & date are embedded in the bottom banner of this image.',
      //       //     style: TextStyle(color: Colors.white54, fontSize: 11),
      //       //   ),
      //       // ),
      //       // TextButton(
      //       //   onPressed: () {
      //       //     // Reset zoom
      //       //     _transformationController.value = Matrix4.identity();
      //       //   },
      //       //   child: const Text(
      //       //     'Reset Zoom',
      //       //     style: TextStyle(
      //       //         color: Colors.amber,
      //       //         fontSize: 11,
      //       //         fontWeight: FontWeight.bold),
      //       //   ),
      //       // ),
      //     ],
      //   ),
      // ),
    );
  }
}
