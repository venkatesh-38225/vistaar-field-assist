import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_kyc_mobile_app/controllers/vcp_application_controller.dart';
import 'package:re_kyc_mobile_app/models/esign_message_model.dart';
import 'package:re_kyc_mobile_app/models/esign_pdf_model.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import '../../utils/global_snackbar.dart';
import '../../widgets/AnimatedStepCircle.dart';

class ESignEnable extends StatefulWidget {
  const ESignEnable(
      {super.key, required this.id, required this.employeeId, this.close});

  final String id;
  final String employeeId;
  final int? close;

  @override
  State<ESignEnable> createState() => _ESignEnableState();
}

class _ESignEnableState extends State<ESignEnable> {
  late final WebViewController _controller;
  bool _pageLoaded = false;
  String? _pendingBase64;
  bool isPdfLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // mark page loaded and push pending PDF if any
            _pageLoaded = true;
            if (_pendingBase64 != null) {
              final encoded = _pendingBase64!;
              // small delay to ensure JS function available
              Future.delayed(const Duration(milliseconds: 100), () {
                _controller.runJavaScript("loadPDF(`$encoded`);");
              });
              _pendingBase64 = null;
            }
          },
        ),
      )
      ..loadFlutterAsset("assets/pdfjs/viewer.html");
    // _applyBasicPrefillIfAny();

    callPDf();
  }

  String? eSignPDF;
  String? pdfPath;
  int totalPages = 0;
  int currentPage = 0;
  bool? isSentBackValue;
  String? submittedId;

  //
  // void _applyBasicPrefillIfAny() {
  //   final args = Get.arguments;
  //   submittedId = args["id"];
  //   var isSentBack = args["isSentBack"];
  //   isSentBackValue = isSentBack ? true : false;
  // }

  final VcpApplicationController vcpController = Get.find();

  Widget stepCircle({
    required String text,
    required Color fillColor,
    required Color borderColor,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3.0),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget completedStepCircle() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
        border: Border.all(color: Colors.green[900]!, width: 3.0),
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget stepConnector(Color color) {
    print("Pdf: ${pdfPath}");
    return Expanded(
      child: Container(height: 4, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 20,
        backgroundColor: Constant.mediumBlueColor,
        title: Row(
          children: [
            Image.asset(
              'assets/images/v_logo_white.png',
              height: 30,
              width: 35,
            ),
            const SizedBox(width: 10),
            const CustomText(
              text: 'VCP Application',
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Step 1
                completedStepCircle(),
                stepConnector(Colors.green),

                // Step 2
                completedStepCircle(),
                stepConnector(Colors.green),

                // Step 3
                completedStepCircle(),
                stepConnector(Colors.green),

                // Step 4
                completedStepCircle(),
                stepConnector(Colors.green),

                // Step 5
                AnimatedStepCircle(
                  text: "5",
                  fillColor: Constant.mediumBlueColor,
                  borderColor: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),
            const CustomText(
              text: 'E-sign PDF',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 9),

            // pdfPath != null
            //     ? SizedBox(
            //         height: 550,
            //         child: Scrollbar(
            //           thumbVisibility: true,
            //           child: PDFView(
            //             filePath: pdfPath!,
            //             enableSwipe: true,
            //             swipeHorizontal: false,
            //             autoSpacing: true,
            //             pageSnap: true,
            //             fitPolicy: FitPolicy.BOTH,
            //             onRender: (pages) {
            //               setState(() {
            //                 totalPages = pages ?? 0;
            //               });
            //             },
            //             onPageChanged: (page, _) {
            //               setState(() {
            //                 currentPage = page ?? 0;
            //               });
            //             },
            //             onError: (error) {},
            //           ),
            //         ),
            //       )
            //     : const Center(
            //         child: CircularProgressIndicator(
            //           color: Constant.lightBlueColor,
            //         ),
            //       ),
            Expanded(
              child: isPdfLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Constant.lightBlueColor,
                      ),
                    )
                  : pdfPath != null
                      ? WebViewWidget(controller: _controller)
                      : const Center(
                          child: CustomText(
                            text: 'PDF could not be loaded.',
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
            ),

            Visibility(
              visible: pdfPath != null,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: CustomText(
                    text: '(Scroll up the pdf to see all the pages)',
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Submit',
                  onPressed: () {
                    initiateESign();
                  },
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void callPDf() async {
  //   Map<String, dynamic> body = {
  //     "id": widget.id,
  //     // "id": "29",
  //     "userId": widget.employeeId,
  //     "userName": vcpController.employeeName,
  //     "branchName": vcpController.branchName
  //   };
  //
  //   print("Body: ${body}");
  //
  //
  //   ESignPdfModel? response = await ApiClient().getESignPDF(json.encode(body));
  //
  //  print("response value : ${response?.success}");
  //  if(response == null){
  //    print("Error");
  //    WidgetsBinding.instance.addPostFrameCallback((_) {
  //      Get.snackbar(
  //        "Failed",
  //        response?.error ?? "E-sign PDF is not available right now",
  //        backgroundColor: Colors.redAccent,
  //        colorText: Colors.white,
  //      );
  //    });
  //  }
  //   if (response != null) {
  //     if (response.success!) {
  //       setState(() {
  //         eSignPDF = response.data;
  //       });
  //       _loadPdfFromBase64(eSignPDF!);
  //     } else {
  //       // Get.snackbar("Failed", response.error,
  //       //     backgroundColor: Colors.redAccent, colorText: Colors.white);
  //
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         Get.snackbar(
  //           "Failed",
  //           response.error,
  //           backgroundColor: Colors.redAccent,
  //           colorText: Colors.white,
  //         );
  //       });
  //
  //   }
  //   } else {
  //     Get.snackbar("Failed", 'Something went wrong',
  //         backgroundColor: Colors.redAccent, colorText: Colors.white);
  //   }
  // }

  void callPDf() async {
    Map<String, dynamic> body = {
      "id": widget.id,
      "userId": widget.employeeId,
      "userName": vcpController.employeeName,
      "branchName": vcpController.branchName,
    };

    ESignPdfModel? response = await ApiClient().getESignPDF(json.encode(body));

    if (response != null &&
        response.success == true &&
        response.data != null &&
        response.data!.isNotEmpty) {
      // ✅ SUCCESS
      setState(() {
        eSignPDF = response.data;
        isPdfLoading = false;
      });

      _loadPdfFromBase64(eSignPDF!);
    } else {
      // ✅ VERY IMPORTANT: stop spinner FIRST
      setState(() {
        isPdfLoading = false;
      });

      // ✅ now show snackbar
      GlobalSnackbar.showError(
        response?.error ??
            "E-sign document could not be loaded. Please try again later.",
      );
    }
  }

  void _showErrorSnackbar(String message) {
    debugPrint("Showing Error Snackbar:- $message");
    GlobalSnackbar.showError("Error: ${message}");
  }

  void _showSuccessSnackbar(String message) {
    debugPrint("Showing Success Snackbar : $message");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          Get.rawSnackbar(
            title: "Success",
            message: message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            margin: const EdgeInsets.all(15),
            borderRadius: 10,
            duration: const Duration(seconds: 4),
            isDismissible: true,
          );
        } catch (e) {
          debugPrint("Failed to show success snackbar: $e");
        }
      });
    });
  }

  void eSignEnableMessage() async {
    Map<String, dynamic> value = {
      "signers": [
        {
          "identifier": "6379808523",
          "name": "G Thaaranya",
          "sign_type": "aadhaar",
          "reason": "VCP Onboard"
        }
      ],
      "expire_in_days": 10,
      "display_on_page": "all",
      "notify_signers": true,
      "send_sign_link": true,
      "file_name": "eSignPDF.pdf",
      "file_data": eSignPDF,
      "sequential": true,
    };
    ESignMessageModel? response =
        await ApiClient().enableESignMessage(json.encode(value));
    if (response != null) {
      /*  initiateESign(
          eSignID: response.id,
          eSignAgreementStatus: response.agreementStatus,
          eSignAgreementType: response.agreementType,
          eSignStatus: 'Signed');*/
    } else {
      _showErrorSnackbar('Something went wrong. Please try again.');
    }
  }

  void initiateESign(
      /*{
    required String? eSignID,
    required String? eSignAgreementStatus,
    required String? eSignAgreementType,
    required String eSignStatus,
  }*/
      ) async {
/*    Map<String, dynamic> body = {
      "ID": widget.id,
      "eSignModel": {
        "ESignID": eSignID,
        "ESignAgreementStatus": eSignAgreementStatus,
        "ESignAgreementType": eSignAgreementType,
        "ESignStatus": eSignStatus
      }
    };*/

    // ✅ Safety check
    if (pdfPath == null || eSignPDF == null) {
      _showErrorSnackbar(isPdfLoading
          ? "Please wait until the e-sign PDF is loaded."
          : "E-sign PDF is not available. Please try again.");
      return;
    }

    Map<String, dynamic> body = {
      "ID": widget.id,
      "eSignModel": {
        "ESignID": "",
        "ESignAgreementStatus": "",
        "ESignAgreementType": "",
        "ESignStatus": ""
      }
    };
    Map<String, dynamic>? response =
        await ApiClient().initiateESignApi(json.encode(body));
    if (response != null) {
      if (response['success']) {
        _showSuccessSnackbar("Application Submitted Successfully!");
        Get.close(widget.close ?? 5);
      } else {
        _showErrorSnackbar(response["error"]);
      }
    } else {
      _showErrorSnackbar('Something went wrong. Please try again.');
    }
  }

  // Future<void> _loadPdfFromBase64(String eSignPDF) async {
  //   try {
  //     Uint8List bytes = base64Decode(eSignPDF);
  //     final dir = await getTemporaryDirectory();
  //     final file = File("${dir.path}/temp.pdf");
  //     await file.writeAsBytes(bytes, flush: true);
  //     setState(() {
  //       pdfPath = file.path;
  //     });
  //   } catch (e) {
  //     debugPrint("Error loading PDF: $e");
  //   }
  // }

  Future<void> _loadPdfFromBase64(String eSignPDF) async {
    try {
      // clean base64 if server prefixes data:...
      final clean =
          eSignPDF.replaceAll(RegExp(r'^data:application\/pdf;base64,'), '');

      Uint8List bytes = base64Decode(clean);
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        pdfPath = file.path;
      });

      // prepare base64 for webview
      final base64ForWeb = base64Encode(bytes);

      // If page is already loaded, call JS; otherwise store pending base64
      if (_pageLoaded) {
        // use backticks to avoid escaping issues; ensure small delay
        Future.delayed(const Duration(milliseconds: 100), () {
          _controller.runJavaScript("loadPDF(`$base64ForWeb`);");
        });
      } else {
        _pendingBase64 = base64ForWeb;
      }
    } catch (e) {
      debugPrint("Error loading PDF: $e");
    }
  }
}
