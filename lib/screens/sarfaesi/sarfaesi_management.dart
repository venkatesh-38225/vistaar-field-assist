import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/models/sarfaesi_details_res.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/custom_textform_field.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SarfaesiManagementScreen extends StatefulWidget {
  const SarfaesiManagementScreen({
    super.key,
    required this.billingId,
    required this.profile,
    required this.isAction,
  });

  final int billingId;
  final ProfileResponse profile;
  final bool isAction;

  @override
  State<SarfaesiManagementScreen> createState() =>
      SarfaesiManagementScreenState();
}

class SarfaesiManagementScreenState extends State<SarfaesiManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  bool isSubmitting = false;
  SarfaesiDetailsData? details;

  final TextEditingController remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> fetchDetails() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient().getSarfaesiById(widget.billingId);
      if (response != null && response.success) {
        setState(() {
          details = response.data;
          isLoading = false;
        });
      } else {
        GlobalSnackbar.showError("Failed to fetch details");
        Get.back();
      }
    } catch (e) {
      GlobalSnackbar.showError("Something went wrong");
      Get.back();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy  HH:mm').format(dt);
  }

  String _formatCurrency(double? value) {
    if (value == null) return '—';
    return NumberFormat("#,##0.00").format(value);
  }

  String _fileTypeLabel(String fileType) {
    switch (fileType) {
      case 'Notice134Affixture':
        return '13(4) Notice Affixture';
      case 'Notice134ScannedCopy':
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

  Color _fileTypeColor(String fileType) {
    switch (fileType) {
      case 'Notice134Affixture':
        return const Color(0xFF1565C0);
      case 'Notice134ScannedCopy':
      case 'Notice134Signed':
        return const Color(0xFF2E7D32);
      case 'Notice134ByHandToCustomer':
        return const Color(0xFF6A1B9A);
      case 'PropertyVideo':
        return const Color(0xFFBF360C);
      default:
        return Colors.blueGrey;
    }
  }

  IconData _fileTypeIcon(String fileType) {
    switch (fileType) {
      case 'PropertyVideo':
        return Icons.videocam_rounded;
      default:
        return Icons.picture_as_pdf_rounded;
    }
  }

  // ── Dialog helpers ────────────────────────────────────────────────────────

  Future<void> _showConfirmationDialog({
    required String title,
    required String message,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          text: title,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Constant.mediumBlueColor,
        ),
        content: CustomText(text: message, fontSize: 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText(text: "Cancel", color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: const CustomText(
                text: "Confirm",
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> handleUpdateStatus(String action) async {
    if (remarksController.text.trim().isEmpty) {
      GlobalSnackbar.showError("Please enter remarks");
      return;
    }
    _showConfirmationDialog(
      title: "Confirm ${action.toUpperCase()}",
      message: "Are you sure you want to $action this record?",
      confirmColor: action == "approved"
          ? Colors.green
          : (action == "rejected" ? Colors.red : Colors.orange),
      onConfirm: () async {
        setState(() => isSubmitting = true);
        try {
          final payload = {
            "id": widget.billingId,
            "action": action,
            "role": widget.profile.data?.role ?? "",
            "modifiedBy": widget.profile.data?.employeeId ?? "",
            "remarks": remarksController.text.trim()
          };
          final response =
          await ApiClient().updateLegalBillingStatus(json.encode(payload));
          if (response != null && response["success"] == true) {
            GlobalSnackbar.showSuccess(
                response["message"] ?? "Action successful");
            Get.back(result: true);
          } else {
            GlobalSnackbar.showError(
                response?["message"] ?? "Operation failed");
          }
        } catch (e) {
          GlobalSnackbar.showError("Something went wrong");
        } finally {
          setState(() => isSubmitting = false);
        }
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String currentRole =
        widget.profile.data?.role?.toUpperCase() ?? "";
    final bool isLegalRole = currentRole == "LEGAL";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: CustomText(
          text: widget.isAction ? 'Take Action' : 'SARFAESI Details',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Constant.mediumYellowColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "DETAILS"),
            Tab(text: "DOCUMENTS"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildDocumentsTab(),
              ],
            ),
          ),
          // if (widget.isAction) _buildActionPanel(isLegalRole),
        ],
      ),
    );
  }

  // ── DETAILS TAB ───────────────────────────────────────────────────────────

  Widget _buildDetailsTab() {
    if (details == null) return const SizedBox.shrink();
    final tx = details!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status banner ──────────────────────────────────────────
          _buildStatusBanner(tx),
          const SizedBox(height: 14),

          // ── Basic Information ──────────────────────────────────────
          _buildSection(
            title: 'Basic Information',
            icon: Icons.person_outline_rounded,
            children: [
              _buildRow('LAN', tx.lan ?? '—'),
              _buildRow('Customer Name', tx.customerName ?? '—'),
              _buildRow('Mobile', tx.mobile ?? '—'),
              if ((tx.alternateMobile ?? '').isNotEmpty)
                _buildRow('Alternate Mobile', tx.alternateMobile!),
              _buildRow('Branch',
                  '${tx.branchCode ?? ''} — ${tx.branchName ?? ''}'.trim()),
              _buildRow('Region', tx.region ?? '—'),
              _buildRow('Zone', tx.zone ?? '—'),
              _buildRow('Mega Zone', tx.megaZone ?? '—'),
            ],
          ),
          const SizedBox(height: 14),

          // ── Address ────────────────────────────────────────────────
          _buildSection(
            title: 'Address',
            icon: Icons.location_on_outlined,
            children: [
              _buildResidentialAddressSection(tx.residentialAddress ?? ''),
              _buildPropertyAddressSection(tx.propertyAddress ?? ''),
            ],
          ),
          const SizedBox(height: 14),

          // ── Financial Details ──────────────────────────────────────
          _buildSection(
            title: 'Financial Details',
            icon: Icons.account_balance_wallet_outlined,
            children: [
              _buildRow('POS',
                  '₹ ${_formatCurrency(tx.pos)}',
                  valueColor: const Color(0xFFB71C1C)),
              _buildRow('Total Outstanding (TOS)',
                  '₹ ${_formatCurrency(tx.tos)}',
                  valueColor: const Color(0xFFB71C1C)),
              _buildRow('DPD', '${tx.dpd ?? 0} days'),
              _buildRow('Estimated Property Value',
                  '₹ ${_formatCurrency(tx.estimatedPropertyValue)}'),
            ],
          ),
          const SizedBox(height: 14),

          // ── Possession Details (only if isPossessionTaken == true) ─
          if (tx.isPossessionTaken == true) ...[
            _buildSection(
              title: 'Possession Details',
              icon: Icons.home_work_outlined,
              children: [
                _buildRow('Possession Date',
                    _formatDate(tx?.possessionDate)),
                _buildRow('13(4) By Hand Service',
                    (tx.is134HandService == true) ? 'Yes' : 'No',
                    valueColor: (tx.is134HandService == true)
                        ? Colors.green.shade700
                        : Colors.red.shade700),
                _buildRow('Customer Profile', tx.customerProfile ?? '—'),
                _buildRow(
                    'Property Occupied By', tx.propertyOccupiedBy ?? '—'),
                _buildRow('Property Type', tx.propertyType ?? '—'),
                _buildRow(
                    'Property Condition', tx.propertyCondition ?? '—'),
                _buildRow('Customer Intent / Capability',
                    tx.customerIntentCapability ?? '—'),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // ── Non-Possession Reason (only if isPossessionTaken == false) ──
          if (tx.isPossessionTaken == false &&
              (tx.nonPossessionReason ?? '').isNotEmpty) ...[
            _buildSection(
              title: 'Non-Possession Reason',
              icon: Icons.info_outline_rounded,
              children: [
                _buildRowMultiline('Reason', tx.nonPossessionReason!),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // ── Audit Trail ────────────────────────────────────────────
          _buildSection(
            title: 'Audit',
            icon: Icons.history_rounded,
            children: [
              _buildRow('Created By', tx.createdBy ?? '—'),
              _buildRow(
                  'Created On', _formatDateTime(tx.createdDt)),
              _buildRow('Last Updated By', tx.updatedBy ?? '—'),
              _buildRow(
                  'Last Updated On', _formatDateTime(tx.updatedDt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(SarfaesiDetailsData tx) {
    final bool possessed = tx.isPossessionTaken == true;
    final Color bgColor =
    possessed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
    final Color borderColor =
    possessed ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
    final Color textColor =
    possessed ? const Color(0xFF1B5E20) : const Color(0xFFBF360C);
    final IconData icon = possessed
        ? Icons.check_circle_outline_rounded
        : Icons.cancel_outlined;
    final String label =
    possessed ? 'Possession Taken' : 'Possession Not Taken';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: CustomText(
              text: label,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          // Container(
          //   padding:
          //   const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: borderColor,
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: CustomText(
          //     text: 'ID: ${tx.id}',
          //     fontSize: 12,
          //     color: Colors.white,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ],
      ),
    );
  }

  // ── DOCUMENTS TAB ─────────────────────────────────────────────────────────

  Widget _buildDocumentsTab() {
    if (details == null) return const SizedBox.shrink();
    final files = details!.files ?? [];

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            CustomText(
              text: 'No documents uploaded',
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      );
    } else if(details?.isPossessionTaken == false){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            CustomText(
              text: 'No documents uploaded',
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      );
    }

    // Group files by fileType
    final Map<String, List<SarfaesiFile>> grouped = {};
    for (final f in files) {
      final key = f.fileType ?? 'Other';
      grouped.putIfAbsent(key, () => []).add(f);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary chip row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grouped.entries.map((e) {
              final color = _fileTypeColor(e.key);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_fileTypeIcon(e.key), color: color, size: 14),
                    const SizedBox(width: 6),
                    CustomText(
                      text:
                      '${_fileTypeLabel(e.key)}  ·  ${e.value.length}',
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Document cards grouped by type
          ...grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group header
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _fileTypeColor(entry.key),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        text: _fileTypeLabel(entry.key),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _fileTypeColor(entry.key),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _fileTypeColor(entry.key),
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
                ),
                ...entry.value.asMap().entries.map((e) {
                  final idx = e.key;
                  final file = e.value;
                  return _buildDocumentCard(file, idx + 1);
                }),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(SarfaesiFile file, int index) {
    final String fileName = file.fileName ?? 'Unknown file';
    final String ext = fileName.split('.').last.toLowerCase();
    final bool isVideo = ['mp4', 'mov', 'avi'].contains(ext);
    final bool isPdf = ext == 'pdf';
    final bool isImage = ['jpg', 'jpeg', 'png'].contains(ext);
    final Color typeColor = _fileTypeColor(file.fileType ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              isVideo
                  ? Icons.videocam_rounded
                  : isPdf
                  ? Icons.picture_as_pdf_rounded
                  : Icons.image_rounded,
              color: typeColor,
              size: 22,
            ),
          ),
        ),
        title: CustomText(
          text: 'File $index',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            CustomText(
              text: fileName,
              fontSize: 11,
              color: Colors.grey.shade600,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 11, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                CustomText(
                  text: file.uploadedBy ?? '—',
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 10),
                Icon(Icons.schedule,
                    size: 11, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                CustomText(
                  text: _formatDateTime(file.uploadedDt),
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ],
        ),
        trailing: (isPdf || isImage || isVideo)
            ? GestureDetector(
          onTap: () => _viewDocument(fileName),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.visibility_rounded,
                color: typeColor, size: 20),
          ),
        )
            : Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.file_present_rounded,
              color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }

  // ── Shared section / row widgets ─────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Constant.mediumBlueColor.withOpacity(0.06),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Constant.mediumBlueColor),
                const SizedBox(width: 8),
                CustomText(
                  text: title,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Constant.mediumBlueColor,
                ),
              ],
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 155,
            child: CustomText(
              text: label,
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const CustomText(text: ':', fontSize: 13, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: value.isEmpty ? '—' : value,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowMultiline(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 3),
          CustomText(
            text: value.isEmpty ? '—' : value,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          const Divider(height: 14),
        ],
      ),
    );
  }

  // ── Document viewer (kept from original) ─────────────────────────────────

  Future<void> _openVideoPlayer(String fileName, Uint8List fileBytes) async {
    // Save bytes to a temp file so video_player can read it
    final tempDir = await getTemporaryDirectory();
    final safeFileName = fileName.split('/').last;
    final tempFile = File('${tempDir.path}/$safeFileName');
    await tempFile.writeAsBytes(fileBytes);

    if (!mounted) return;

    // Push a dedicated full-screen video player page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SarfaesiVideoPlayerPage(
          filePath: tempFile.path,
          fileName: safeFileName,
        ),
      ),
    );
  }

  Future<void> _viewDocument(String fileName) async {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: CustomText(
          text: 'Loading Document',
          fontWeight: FontWeight.bold,
        ),
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final response = await ApiClient().downloadSarfaesiFile(fileName);
      if (!mounted) return;
      Navigator.pop(context);

      if (response != null) {
        final String ext = fileName.toLowerCase().split('.').last;
        final bool isPdf   = ext == 'pdf';
        final bool isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
        final bool isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(ext);

        if (isPdf) {
          await _openPdfInWebView(fileName, response.bodyBytes);
        } else if (isImage) {
          _showImageViewer(fileName, response.bodyBytes);
        } else if (isVideo) {
          await _openVideoPlayer(fileName, response.bodyBytes);
        } else {
          GlobalSnackbar.showError('Unsupported file type: $ext');
        }
      } else {
        GlobalSnackbar.showError('Failed to load document');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlobalSnackbar.showError('Error loading document');
      }
    }
  }
  void _showImageViewer(String fileName, Uint8List fileBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              color: Constant.mediumBlueColor,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: fileName,
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.memory(fileBytes, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdfInWebView(
      String fileName, Uint8List fileBytes) async {
    final tempDir = await getTemporaryDirectory();
    final safeFileName = fileName.split('/').last;
    final tempFile = File('${tempDir.path}/$safeFileName');
    await tempFile.writeAsBytes(fileBytes);

    if (!mounted) return;

    if (Platform.isIOS) {
      final uri = Uri.file(tempFile.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        GlobalSnackbar.showError('No PDF viewer found on this device');
      }
      return;
    }

    final base64Pdf = base64Encode(fileBytes);
    final htmlContent = '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes">
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      html, body { width: 100%; height: 100%; background: #525659; overflow: hidden; }
      canvas { display: block; margin: 0 auto; }
      #controls {
        position: fixed; bottom: 0; left: 0; right: 0;
        background: rgba(0,0,0,0.7); color: white;
        display: flex; justify-content: center; align-items: center;
        padding: 8px; gap: 16px; z-index: 999;
      }
      #controls button {
        background: #fff; border: none; border-radius: 4px;
        padding: 6px 16px; font-size: 14px; cursor: pointer;
        color: #333; font-weight: bold;
      }
      #controls button:disabled { opacity: 0.4; }
      #pageInfo { font-size: 14px; color: white; min-width: 80px; text-align: center; }
      #container {
        width: 100%; height: calc(100vh - 50px);
        overflow-y: auto; overflow-x: hidden;
        -webkit-overflow-scrolling: touch;
      }
      #loading { color: white; text-align: center; padding-top: 40%; font-size: 16px; }
      #error { color: #ff6b6b; text-align: center; padding: 20px; font-size: 14px; display: none; }
    </style>
  </head>
  <body>
    <div id="container">
      <div id="loading">Loading PDF...</div>
      <div id="error">Failed to load PDF. Please try again.</div>
    </div>
    <div id="controls">
      <button id="prevBtn" onclick="changePage(-1)" disabled>&#8592; Prev</button>
      <span id="pageInfo">Page 1 / 1</span>
      <button id="nextBtn" onclick="changePage(1)" disabled>Next &#8594;</button>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
    <script>
      pdfjsLib.GlobalWorkerOptions.workerSrc =
        'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';
      let pdfDoc = null, currentPage = 1, totalPages = 0, isRendering = false;
      const base64Data = '$base64Pdf';
      const raw = atob(base64Data);
      const arr = new Uint8Array(raw.length);
      for (let i = 0; i < raw.length; i++) arr[i] = raw.charCodeAt(i);
      pdfjsLib.getDocument({ data: arr }).promise.then(function(pdf) {
        pdfDoc = pdf; totalPages = pdf.numPages;
        document.getElementById('loading').style.display = 'none';
        document.getElementById('nextBtn').disabled = totalPages <= 1;
        renderPage(currentPage);
      }).catch(function(err) {
        document.getElementById('loading').style.display = 'none';
        document.getElementById('error').style.display = 'block';
      });
      function renderPage(num) {
        if (isRendering) return; isRendering = true;
        pdfDoc.getPage(num).then(function(page) {
          const container = document.getElementById('container');
          const existing = document.getElementById('pdfCanvas');
          if (existing) existing.remove();
          const canvas = document.createElement('canvas');
          canvas.id = 'pdfCanvas'; container.appendChild(canvas);
          const ctx = canvas.getContext('2d');
          const dpr = window.devicePixelRatio || 1;
          const vw = container.clientWidth;
          const uv = page.getViewport({ scale: 1 });
          const scale = (vw / uv.width) * dpr;
          const vp = page.getViewport({ scale });
          canvas.width = vp.width; canvas.height = vp.height;
          canvas.style.width = (vp.width / dpr) + 'px';
          canvas.style.height = (vp.height / dpr) + 'px';
          page.render({ canvasContext: ctx, viewport: vp }).promise.then(function() {
            isRendering = false; container.scrollTop = 0; updateControls();
          });
        });
      }
      function changePage(delta) {
        const np = currentPage + delta;
        if (np < 1 || np > totalPages) return;
        currentPage = np; renderPage(currentPage);
      }
      function updateControls() {
        document.getElementById('pageInfo').textContent = 'Page ' + currentPage + ' / ' + totalPages;
        document.getElementById('prevBtn').disabled = currentPage <= 1;
        document.getElementById('nextBtn').disabled = currentPage >= totalPages;
      }
    </script>
  </body>
</html>
''';

    if (!mounted) return;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF525659))
      ..loadHtmlString(htmlContent);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.92,
          child: Column(
            children: [
              Container(
                color: Constant.mediumBlueColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: safeFileName,
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon:
                      const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(child: WebViewWidget(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _parseCollateralString(String raw) {
    try {
      // Remove outer brackets
      final trimmed = raw.trim();
      if (!trimmed.startsWith('[')) return [];

      final inner = trimmed.substring(1, trimmed.lastIndexOf(']')).trim();

      // Split into individual objects by "},{"
      final objectStrings = inner.split('}, {');

      return objectStrings.map((obj) {
        // Remove leading/trailing braces
        final clean = obj.replaceAll(RegExp(r'^\{|\}$'), '').trim();

        // Extract fields using regex for each key
        String extract(String key) {
          final pattern = RegExp('$key: (.*?)(?=, ${'collateral'[0].toUpperCase()}|\\s*\$)');
          final match = pattern.firstMatch(clean);
          return match?.group(1)?.trim() ?? '';
        }

        // Parse known keys explicitly since values can contain commas
        final refMatch = RegExp(r'collateralRef: ([^,]+)').firstMatch(clean);
        final typeMatch = RegExp(r'collateralType: ([^,]+)').firstMatch(clean);
        // collateralAddress is everything after "collateralAddress: "
        final addrMatch = RegExp(r'collateralAddress: (.+)$').firstMatch(clean);

        return {
          'collateralRef': refMatch?.group(1)?.trim() ?? '',
          'collateralType': typeMatch?.group(1)?.trim() ?? '',
          'collateralAddress': addrMatch?.group(1)?.trim() ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('collateral parse error: $e');
      return [];
    }
  }
  Widget _buildPropertyAddressSection(String raw) {
    final collaterals = _parseCollateralString(raw);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Property Address',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 6),
          if (collaterals.isEmpty)
          // Fallback: show raw string if parsing fails
            _buildAddressCard(
              index: null,
              ref: null,
              address: raw.isEmpty ? '—' : raw,
            )
          else
            ...List.generate(collaterals.length, (i) {
              final c = collaterals[i];
              return _buildAddressCard(
                index: i + 1,
                ref: c['collateralRef'],
                address: c['collateralAddress'] ?? '—',
              );
            }),
          const Divider(height: 14),
        ],
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
  // ── Action panel (kept from original) ────────────────────────────────────

  Widget _buildActionPanel(bool isLegalRole) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLegalRole) ...[
            CustomTextFormField(
              controller: remarksController,
              hintText: "Enter Approval/Reject Remarks *",
              maxLines: 2,
              onSaved: (v) {},
              validator: (v) => null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => handleUpdateStatus("sentback"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const CustomText(
                        text: "Sent Back",
                        color: Colors.white,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => handleUpdateStatus("rejected"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    child: const CustomText(
                        text: "Reject",
                        color: Colors.white,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => handleUpdateStatus("approved"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: const CustomText(
                        text: "Approve",
                        color: Colors.white,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }


}

class _SarfaesiVideoPlayerPage extends StatefulWidget {
  const _SarfaesiVideoPlayerPage({
    required this.filePath,
    required this.fileName,
  });
  final String filePath;
  final String fileName;

  @override
  State<_SarfaesiVideoPlayerPage> createState() =>
      _SarfaesiVideoPlayerPageState();
}

class _SarfaesiVideoPlayerPageState extends State<_SarfaesiVideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.play();
        }
      }).catchError((e) {
        if (mounted) setState(() => _hasError = true);
      });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.fileName,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _hasError
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white54,
              size: 56,
            ),
            SizedBox(height: 8),
            Text(
              'Unable to play this video',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      )
          : !_isInitialized
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      )
          : SafeArea(
        child: Column(
          children: [

            // VIDEO PLAYER
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: 600,
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      // VIDEO
                      Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width:
                            _controller.value.size.width,
                            height:
                            _controller.value.size.height,
                            child: VideoPlayer(
                              _controller,
                            ),
                          ),
                        ),
                      ),

                      // PLAY / PAUSE BUTTON
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),

                      // FULLSCREEN BUTTON
                      // Positioned(
                      //   bottom: 10,
                      //   right: 10,
                      //   child: GestureDetector(
                      //     onTap: () async {
                      //
                      //       await Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (_) =>
                      //               _FullScreenVideoPage(
                      //                 controller: _controller,
                      //                 fileName:
                      //                 widget.fileName,
                      //               ),
                      //         ),
                      //       );
                      //
                      //       setState(() {});
                      //     },
                      //     child: Container(
                      //       padding:
                      //       const EdgeInsets.all(8),
                      //       decoration: BoxDecoration(
                      //         color: Colors.black54,
                      //         borderRadius:
                      //         BorderRadius.circular(8),
                      //       ),
                      //       child: const Icon(
                      //         Icons.fullscreen,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // PROGRESS BAR
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor:
                  Constant.mediumBlueColor,
                  bufferedColor: Colors.white30,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // TIME
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(
                      _controller.value.position,
                    ),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(
                      _controller.value.duration,
                    ),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FullScreenVideoPage extends StatefulWidget {

  final VideoPlayerController controller;
  final String fileName;

  const _FullScreenVideoPage({
    required this.controller,
    required this.fileName,
  });

  @override
  State<_FullScreenVideoPage> createState() =>
      _FullScreenVideoPageState();
}

class _FullScreenVideoPageState
    extends State<_FullScreenVideoPage> {

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [

            AspectRatio(
              aspectRatio:
              widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  widget.controller.value.isPlaying
                      ? widget.controller.pause()
                      : widget.controller.play();
                });
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            Positioned(
              top: 30,
              left: 20,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.fullscreen_exit,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
