import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_kyc_mobile_app/models/legal_billing_details_res.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/custom_textform_field.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalBillingManagementScreen extends StatefulWidget {
  const LegalBillingManagementScreen({
    super.key,
    required this.billingId,
    required this.profile,
    required this.isAction,
  });

  final int billingId;
  final ProfileResponse profile;
  final bool isAction;

  @override
  State<LegalBillingManagementScreen> createState() =>
      _LegalBillingManagementScreenState();
}

class _LegalBillingManagementScreenState
    extends State<LegalBillingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  bool isSubmitting = false;
  LegalBillingDetailsData? details;

  final TextEditingController remarksController = TextEditingController();
  final TextEditingController utrController = TextEditingController();
  final TextEditingController paymentRemarksController =
      TextEditingController();

  String? selectedPaymentStatus;
  final List<String> paymentStatusOptions = [
    'Payment Done',
    'Cancelled',
    'Payment On Hold',
    'Others'
  ];

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
    utrController.dispose();
    paymentRemarksController.dispose();
    super.dispose();
  }

  Future<void> fetchDetails() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient().getLegalBillingById(widget.billingId);
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

          print("Payload : $payload");

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

  Future<void> handleUpdatePayment() async {
    if (selectedPaymentStatus == null) {
      GlobalSnackbar.showError("Please select payment status");
      return;
    }

    if (selectedPaymentStatus == "Payment Done" &&
        utrController.text.trim().isEmpty) {
      GlobalSnackbar.showError("Please enter UTR");
      return;
    }

    if (selectedPaymentStatus == "Others" &&
        paymentRemarksController.text.trim().isEmpty) {
      GlobalSnackbar.showError("Please enter payment remarks");
      return;
    }

    _showConfirmationDialog(
      title: "Confirm Payment",
      message: "Are you sure you want to update the payment details?",
      confirmColor: Colors.green,
      onConfirm: () async {
        setState(() => isSubmitting = true);
        try {
          final payload = {
            "id": widget.billingId,
            "paymentAmount": details?.transaction.paymentAmount ?? 0,
            "paymentStatus": selectedPaymentStatus,
            "modifiedBy": widget.profile.data?.employeeId ?? "",
            "paymentRemarks": paymentRemarksController.text.trim(),
            "utr": selectedPaymentStatus == "Payment Done"
                ? utrController.text.trim()
                : ""
          };

          final response =
              await ApiClient().updateLegalBillingPayment(json.encode(payload));
          if (response != null && response["success"] == true) {
            GlobalSnackbar.showSuccess(
                response["message"] ?? "Payment updated successfully");
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

  // Helper function to format numbers with commas
  String _formatNumberWithCommas(double value) {
    final formatter = NumberFormat("#,##0.00");
    return formatter.format(value);
  }

  String _formatNumberWithCommasInt(int value) {
    final formatter = NumberFormat("#,##0");
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    String currentRole = widget.profile.data?.role?.toUpperCase() ?? "";
    bool isLegalRole = currentRole == "LEGAL";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: CustomText(
          text: widget.isAction ? 'Take Action' : 'Billing Details',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Constant.mediumYellowColor,
          tabs: const [
            Tab(text: "DETAILS"),
            Tab(text: "LOGS"),
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
                      _buildLogsTab(),
                    ],
                  ),
                ),
                if (widget.isAction) _buildActionPanel(isLegalRole),
              ],
            ),
    );
  }

  Widget _buildDetailsTab() {
    if (details == null) return const SizedBox.shrink();
    final tx = details!.transaction;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection("Basic Information", [
            _buildDetailRow("LAN", tx.lan),
            _buildDetailRow(
                "Branch", "${tx.branchId} - ${tx.branchName ?? ''}"),
            _buildDetailRow("Customer", tx.customerName),
            _buildDetailRow("Cust ID", tx.custId),
          ]),
          const SizedBox(height: 16),
          _buildInfoSection("Financial Details", [
            _buildDetailRow("POS", "₹${_formatNumberWithCommas(tx.pos)}"),
            _buildDetailRow("Outstanding",
                "₹${_formatNumberWithCommas(tx.totalOutstanding)}"),
            _buildDetailRow("DPD", _formatNumberWithCommasInt(tx.dpd)),
          ]),
          const SizedBox(height: 16),
          _buildInfoSection("Billing Information", [
            _buildDetailRow("Payment Type", tx.paymentType.toString(),
                color: Constant.mediumBlueColor),
            _buildDetailRow("Advocate",
                details!.advocate?.advocateName ?? tx.advocateId.toString()),
            _buildDetailRow(
                "Category",
                details!.legalCategory?.categoryName ??
                    tx.legalCategoryId.toString()),
            _buildDetailRow(
                "Amount", "₹${_formatNumberWithCommas(tx.paymentAmount)}"),
            _buildDetailRow("Remarks", "${tx.remarks}"),
            _buildDetailRow("Status", tx.status,
                color: Constant.mediumBlueColor),
          ]),
          if (tx.paymentType != null && tx.paymentType == "Before Service") ...[
            const SizedBox(height: 16),
            _buildInfoSection("Bank Details", [
              _buildDetailRow("Bank Name", tx.bankName ?? "N/A"),
              _buildDetailRow("Account Number", tx.bankAcNo ?? "N/A"),
              _buildDetailRow("IFSC Code", tx.ifsc ?? "N/A"),
            ]),
          ],
          if (tx.utr != null && tx.utr!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoSection("Payment Details", [
              _buildDetailRow("UTR", tx.utr!),
              _buildDetailRow("Payment Status", tx.paymentStatus ?? "N/A"),
              _buildDetailRow("Payment Remarks", tx.paymentRemarks ?? "N/A"),
            ]),
          ],
          if ((tx.invoiceFilePath != null && tx.invoiceFilePath!.isNotEmpty) ||
              (tx.cancelledChequeFilePath != null &&
                  tx.cancelledChequeFilePath!.isNotEmpty)) ...[
            const SizedBox(height: 16),
            _buildInfoSection("Documents", [_buildDocumentsSection()]),
          ],
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    if (details == null || details!.logs.isEmpty) {
      return const Center(
          child: CustomText(text: "No logs found", color: Colors.grey));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: details!.logs.length,
      itemBuilder: (context, index) {
        final log = details!.logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Constant.mediumBlueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: CustomText(
                        text: log.status ?? "N/A",
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Constant.mediumBlueColor,
                      ),
                    ),
                    CustomText(
                      text: log.updatedDate != null
                          ? DateFormat('dd-MMM-yyyy HH:mm')
                              .format(log.updatedDate!)
                          : "",
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomText(
                    text: "User: ${log.updatedBy ?? 'N/A'}",
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                const SizedBox(height: 4),
                CustomText(
                    text: "Remarks: ${log.remarks ?? 'N/A'}",
                    fontSize: 12,
                    color: Colors.black87),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
              text: title,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Constant.mediumBlueColor),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: label, fontSize: 13, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
                text: value,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.end,
                color: color ?? Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    final tx = details!.transaction;
    final docs = <Map<String, String?>>[];
    if (tx.invoiceFilePath != null && tx.invoiceFilePath!.isNotEmpty) {
      docs.add({'label': 'Invoice', 'fileName': tx.invoiceFilePath});
    }
    if (tx.cancelledChequeFilePath != null &&
        tx.cancelledChequeFilePath!.isNotEmpty) {
      docs.add({
        'label': 'Cancelled Cheque',
        'fileName': tx.cancelledChequeFilePath
      });
    }

    if (docs.isEmpty) {
      return const CustomText(
        text: 'No documents available',
        color: Colors.grey,
        fontSize: 14,
      );
    }

    return Column(
      children: docs
          .map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildDocumentItem(doc['label']!, doc['fileName']!),
              ))
          .toList(),
    );
  }

  Widget _buildDocumentItem(String label, String fileName) {
    return Row(
      children: [
        Expanded(
          child: CustomText(
            text: '$label: $fileName',
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.visibility, color: Constant.mediumBlueColor),
          onPressed: () => _viewDocument(fileName),
        ),
      ],
    );
  }

  Future<void> _viewDocument(String fileName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          text: 'Loading Document',
          fontWeight: FontWeight.bold,
        ),
        content: const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final response = await ApiClient().downloadLegalBillingFile(fileName);
      if (!mounted) return;
      Navigator.pop(context);

      if (response != null) {
        final fileExtension = fileName.toLowerCase().split('.').last;
        final isPdf = fileExtension == 'pdf';
        final isImage =
            ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension);

        if (isPdf) {
          await _openPdfInWebView(fileName, response.bodyBytes);
        } else if (isImage) {
          _showFileViewer(fileName, response.bodyBytes);
        } else {
          GlobalSnackbar.showError('Unsupported file type: $fileExtension');
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

  Future<void> _openPdfInWebView(String fileName, Uint8List fileBytes) async {
    // Save PDF to temp directory
    final tempDir = await getTemporaryDirectory();
    // Sanitize filename to avoid path issues
    final safeFileName = fileName.split('/').last;
    final tempFile = File('${tempDir.path}/$safeFileName');
    await tempFile.writeAsBytes(fileBytes);

    if (!mounted) return;

    if (Platform.isIOS) {
      // iOS: Use url_launcher to open with native viewer
      final uri = Uri.file(tempFile.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        GlobalSnackbar.showError('No PDF viewer found on this device');
      }
      return;
    }

    // Android: Use Google Docs Viewer with base64 approach via HTML + PDF.js workaround
    // Since embed/iframe data URIs don't work in Android WebView,
    // we use a JavaScript-based blob URL approach
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
      #loading {
        color: white; text-align: center;
        padding-top: 40%; font-size: 16px;
      }
      #error {
        color: #ff6b6b; text-align: center;
        padding: 20px; font-size: 14px; display: none;
      }
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

      let pdfDoc = null;
      let currentPage = 1;
      let totalPages = 0;
      let isRendering = false;

      const base64Data = '$base64Pdf';
      const raw = atob(base64Data);
      const arr = new Uint8Array(raw.length);
      for (let i = 0; i < raw.length; i++) arr[i] = raw.charCodeAt(i);

      pdfjsLib.getDocument({ data: arr }).promise.then(function(pdf) {
        pdfDoc = pdf;
        totalPages = pdf.numPages;
        document.getElementById('loading').style.display = 'none';
        document.getElementById('prevBtn').disabled = false;
        document.getElementById('nextBtn').disabled = totalPages <= 1;
        renderPage(currentPage);
      }).catch(function(err) {
        document.getElementById('loading').style.display = 'none';
        document.getElementById('error').style.display = 'block';
        document.getElementById('error').textContent = 'Error: ' + err.message;
      });

      function renderPage(num) {
        if (isRendering) return;
        isRendering = true;

        pdfDoc.getPage(num).then(function(page) {
          const container = document.getElementById('container');
          const existingCanvas = document.getElementById('pdfCanvas');
          if (existingCanvas) existingCanvas.remove();

          const canvas = document.createElement('canvas');
          canvas.id = 'pdfCanvas';
          container.appendChild(canvas);
          const ctx = canvas.getContext('2d');

          const devicePixelRatio = window.devicePixelRatio || 1;
          const viewportWidth = container.clientWidth;
          const unscaledViewport = page.getViewport({ scale: 1 });
          const scale = (viewportWidth / unscaledViewport.width) * devicePixelRatio;
          const viewport = page.getViewport({ scale: scale });

          canvas.width = viewport.width;
          canvas.height = viewport.height;
          canvas.style.width = (viewport.width / devicePixelRatio) + 'px';
          canvas.style.height = (viewport.height / devicePixelRatio) + 'px';

          page.render({ canvasContext: ctx, viewport: viewport }).promise.then(function() {
            isRendering = false;
            container.scrollTop = 0;
            updateControls();
          });
        });
      }

      function changePage(delta) {
        const newPage = currentPage + delta;
        if (newPage < 1 || newPage > totalPages) return;
        currentPage = newPage;
        renderPage(currentPage);
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
        insetPadding: const EdgeInsets.all(0),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.92,
          child: Column(
            children: [
              Container(
                color: Constant.mediumBlueColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: safeFileName,
                        color: Colors.white,
                        fontSize: 16,
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
                child: WebViewWidget(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Unchanged — only for images
  void _showFileViewer(String fileName, Uint8List fileBytes) {
    final fileExtension = fileName.toLowerCase().split('.').last;
    final isImage =
        ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension);

    if (!isImage) {
      GlobalSnackbar.showError('Unsupported file type: $fileExtension');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              color: Constant.mediumBlueColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomText(
                      text: fileName,
                      color: Colors.white,
                      fontSize: 16,
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
              child: Image.memory(
                fileBytes,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileName, Uint8List fileBytes) async {
    GlobalSnackbar.showSuccess('File ready: $fileName');
  }

  Widget _buildActionPanel(bool isLegalRole) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLegalRole) ...[
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(5),
            //     boxShadow: [
            //       BoxShadow(
            //         blurRadius: 2,
            //         color: Colors.black.withOpacity(0.1),
            //         offset: const Offset(1, 1),
            //         spreadRadius: 2,
            //       ),
            //     ],
            //   ),
            //   child: DropdownButtonFormField<String>(
            //     value: selectedPaymentStatus,
            //     decoration: InputDecoration(
            //       hintText: "Select Payment Status *",
            //       contentPadding:
            //           const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            //       enabledBorder: OutlineInputBorder(
            //         borderSide:
            //             const BorderSide(color: Colors.black, width: 0.5),
            //         borderRadius: BorderRadius.circular(5),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderSide:
            //             const BorderSide(color: Colors.black, width: 1.0),
            //         borderRadius: BorderRadius.circular(5),
            //       ),
            //       border: OutlineInputBorder(
            //         borderSide:
            //             const BorderSide(color: Colors.black, width: 1.0),
            //         borderRadius: BorderRadius.circular(5),
            //       ),
            //     ),
            //     items: paymentStatusOptions.map((String status) {
            //       return DropdownMenuItem<String>(
            //         value: status,
            //         child: CustomText(text: status, fontSize: 14),
            //       );
            //     }).toList(),
            //     onChanged: (String? newValue) {
            //       setState(() {
            //         selectedPaymentStatus = newValue;
            //       });
            //     },
            //   ),
            // ),
            // const SizedBox(height: 10),
            // if (selectedPaymentStatus == "Payment Done") ...[
            //   CustomTextFormField(
            //     controller: utrController,
            //     hintText: "Enter UTR *",
            //     onSaved: (v) {},
            //     validator: (v) => null,
            //   ),
            //   const SizedBox(height: 10),
            // ],
            // CustomTextFormField(
            //   controller: paymentRemarksController,
            //   hintText:
            //       selectedPaymentStatus == "Others" ? "Remarks *" : "Remarks",
            //   onSaved: (v) {},
            //   validator: (v) => null,
            // ),
            // const SizedBox(height: 16),
            // SizedBox(
            //   width: double.infinity,
            //   height: 45,
            //   child: ElevatedButton(
            //     onPressed: isSubmitting ? null : handleUpdatePayment,
            //     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            //     child: isSubmitting
            //         ? const CircularProgressIndicator(color: Colors.white)
            //         : const CustomText(
            //             text: "UPDATE PAYMENT",
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold),
            //   ),
            // ),
          ] else ...[
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
                        text: "Sent Back", color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => handleUpdateStatus("rejected"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const CustomText(
                        text: "Reject", color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => handleUpdateStatus("approved"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const CustomText(
                        text: "Approve", color: Colors.white, fontSize: 14),
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
