import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/bank_details_application.dart';
import 'package:re_kyc_mobile_app/screens/onboard_vcp_screens/business_application.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/helper.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_button.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

import '../../widgets/AnimatedStepCircle.dart';
import 'e-sign_enable.dart';

class DocVerification extends StatefulWidget {
  const DocVerification({
    super.key,
    required this.id,
    required this.employeeId,
    this.close,
    required this.companyType,
    this.onboardType,
    this.isSentBack,
  });

  final String id;
  final String employeeId;
  final int? close;
  final String? companyType;
  final String? onboardType;
  final bool? isSentBack;

  @override
  State<DocVerification> createState() => _DocVerificationState();
}

class _DocVerificationState extends State<DocVerification> {
  String? selectedCertify;
  String? selectedAddressProof;
  String? selectedOfficeAddressProof;

  String uploadPhoto = "";
  bool photo = false;
  String uploadPan = "";
  bool pan = false;
  String uploadUrc = "";
  bool urc = false;
  String uploadSignature = "";
  bool signature = false;
  String officeAddressProof = "";
  bool officeAddress = false;
  String personalAddressProof = "";
  bool personalAddress = false;
  String uploadCompanyCer = "";
  bool companyCert = false;
  String uploadCompanyPan = "";
  bool companyPan = false;
  String uploadDSA = "";
  bool dsa = false;
  String uploadBioData = "";
  bool uploadedPhoto = false;
  bool uploadedPan = false;
  bool uploadedUrc = false;
  bool uploadedSignature = false;
  bool uploadedOfficeAddressProof = false;
  bool uploadedPersonalAddressProof = false;
  bool uploadedComCertify = false;
  bool uploadedComPan = false;
  bool uploadedDSA = false;
  bool uploadedBioData = false;

  String uploadOtherDocument = "";
  bool otherDocument = false;
  bool uploadedOtherDocument = false;

  String? selectedProfileProof;
  String uploadProfileDocument = "";
  bool profileDocument = false;
  bool uploadedProfileDocument = false;
  Map<String, dynamic>? bankDetails;
  bool isSentBackValue = false;
  String? submittedId;
  dynamic documentInfo;
  bool isPhotoUploading = false;
  bool isPanUploading = false;
  bool isSignatureUploading = false;
  bool isAddressProofUploading = false;
  bool isOfficeAddressProofUploading = false;
  bool isCompanyCertUploading = false;
  bool isCompanyPanUploading = false;
  bool isDSAUploading = false;
  bool isProfileUploading = false;
  bool isOtherDocUploading = false;

  List<String> addressProof = [
    'Passport',
    'Driving License',
    'Voter Id',
    'Aadhaar card',
  ];
  List<String> profileDocumentList = [
    'Letter of Appointment (Individual)',
    'Company Profile (Agency)',
  ];
  late List<String> officeAddressList = [
    'Passport',
    'Driving License',
    'Voter Id',
    'Aadhaar card',
  ];

  late List<String> propertyAddressProof = [
    'Partnership Deed',
    'Registration Certificate',
    'utility bill',
    'Authorities Establishment Act',
    'Sales and Income tax return',
    'GST/CST/VAT certificate',
  ];

  List<String> companyCertify = [
    'Registration Certificate',
    'Licence issued by the Municipal',
    'Sales and Income tax return',
    'GST / CST',
  ];

  bool isAppraiser() {
    final type = widget.onboardType ?? "";
    return type.isNotEmpty && type == "Appraiser";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the arguments passed from the previous screen
    final arguments = Get.arguments;
    print("arguments, ${arguments}");

    if (arguments != null && arguments is Map) {
      final documents = arguments['documents'];
      bankDetails = arguments["bankDetails"];
      final isSameIndividualAddress =
          arguments['isSameIndividualAddress'] ?? false;

      if (isSameIndividualAddress == true) {
        // Merge individual and company address proof options
        final combinedSet = {...addressProof, ...officeAddressList};
        officeAddressList = combinedSet.toList();
      }

      submittedId = arguments["id"];
      var isSentBack = arguments["isSentBack"];
      isSentBackValue = isSentBack ? true : false;
      documentInfo = arguments["documents"];

      if (documents != null) {
        setState(() {
          // Set uploaded flags based on existing documents
          if (documents['photo'] != null &&
              documents['photo'].toString().isNotEmpty) {
            photo = true;
            uploadedPhoto = false;
            uploadPhoto = isSentBack ? documentInfo["photo"] : "";
          }

          if (documents['signature'] != null &&
              documents['signature'].toString().isNotEmpty) {
            signature = true;
            uploadedSignature = false;
            uploadSignature = isSentBack ? documentInfo["signature"] : "";
          }

          if (documents['pan'] != null &&
              documents['pan'].toString().isNotEmpty) {
            pan = true;
            uploadedPan = false;
            uploadPan = isSentBack ? documentInfo["pan"] : "";
          }

          if (documents['addressProof'] != null &&
              documents['addressProof'].toString().isNotEmpty) {
            personalAddress = true;
            uploadedPersonalAddressProof = false;
            personalAddressProof = documents['addressProof'];
            if (documents['addressProofType'] != null &&
                documents['addressProofType'].toString().isNotEmpty) {
              selectedAddressProof = documents['addressProofType'];
            } else {
              // Try to extract from addressProof if it's a Map
              final addressProofData = documents['addressProof'];
              if (addressProofData is Map &&
                  addressProofData['subCategory'] != null) {
                selectedAddressProof = addressProofData['subCategory'];
              }
            }
          }
          if (documents['officeAddressProof'] != null &&
              documents['officeAddressProof'].toString().isNotEmpty) {
            officeAddress = true;
            uploadedOfficeAddressProof = false;
            officeAddressProof =
                isSentBack ? documentInfo["officeAddressProof"] : "";
            if (documents['officeAddressProofType'] != null &&
                documents['officeAddressProofType'].toString().isNotEmpty) {
              selectedOfficeAddressProof = documents['officeAddressProofType'];
            } else {
              // Try to extract from officeAddressProof if it's a Map
              final officeProofData = documents['officeAddressProof'];
              if (officeProofData is Map &&
                  officeProofData['subCategory'] != null) {
                selectedOfficeAddressProof = officeProofData['subCategory'];
              }
            }
          }

          // Company documents (only if not Individual)
          if (widget.companyType != 'Individual') {
            if (documents['urc'] != null &&
                documents['urc'].toString().isNotEmpty) {
              urc = true;
              uploadedUrc = false;
              uploadUrc = isSentBack ? documentInfo["urc"] : "";
            }

            if (documents['companyPAN'] != null &&
                documents['companyPAN'].toString().isNotEmpty) {
              companyPan = true;
              uploadedComPan = false;
              uploadCompanyPan = isSentBack ? documentInfo["companyPAN"] : "";
            }

            if (documents['dsa'] != null &&
                documents['dsa'].toString().isNotEmpty) {
              dsa = true;
              uploadedDSA = false;
              uploadDSA = isSentBack ? documentInfo["dsa"] : "";
            }

            if (documents['entityProof'] != null &&
                documents['entityProof'].toString().isNotEmpty) {
              companyCert = true;
              uploadedComCertify = false;
              uploadCompanyCer = documents['entityProof'];
              if (documents['entityProofType'] != null &&
                  documents['entityProofType'].toString().isNotEmpty) {
                selectedCertify = documents['entityProofType'];
              } else {
                // Try to extract from entityProof if it's a Map
                final entityProofData = documents['entityProof'];
                if (entityProofData is Map &&
                    entityProofData['subCategory'] != null) {
                  selectedCertify = entityProofData['subCategory'];
                }
              }
            }
          }

          // Appraiser-specific documents
          if (isAppraiser()) {
            if (documents['otherDoc'] != null &&
                documents['otherDoc'].toString().isNotEmpty) {
              otherDocument = true;
              uploadedOtherDocument = false;
              uploadOtherDocument = isSentBack ? documentInfo["otherDoc"] : "";
            }

            // Profile document if it exists
            final profileData = documents['profile'];
            if (profileData != null && profileData.toString().isNotEmpty) {
              profileDocument = true;
              uploadedProfileDocument = false;
              if (profileData is Map && profileData['subCategory'] != null) {
                selectedProfileProof = profileData['subCategory'];
              }
            }
          }
        });
      }
    }
  }

  Widget buildDocumentStatusIndicator(bool isUploaded) {
    if (!isUploaded) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text(
            'Already Uploaded',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // void showImagePreview({required String image}) {
  //   if (image.isNotEmpty && File(image).existsSync()) {
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return Dialog(
  //           child: Container(
  //             padding: const EdgeInsets.all(8),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Image.file(File(image)),
  //                 const SizedBox(height: 10),
  //                 TextButton(
  //                   onPressed: () => Get.back(),
  //                   child: const SizedBox(
  //                     width: 100,
  //                     child: Row(
  //                       children: [
  //                         ImageIcon(
  //                           AssetImage('assets/icons/close.png'),
  //                           color: Colors.red,
  //                         ),
  //                         SizedBox(width: 5),
  //                         Text(
  //                           "Close",
  //                           style: TextStyle(
  //                               color: Colors.red,
  //                               fontSize: 18,
  //                               fontWeight: FontWeight.bold),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  void showImagePreview({
    required String image,
    String? category,
    bool isFromServer = false,
  }) async {
    // Show loading dialog while fetching
    if (isFromServer && category != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Call API to get file
        Map<String, dynamic> body = {
          "id": widget.id,
          "category": category,
        };

        Map<String, dynamic>? response =
            await ApiClient().getVCPFile(json.encode(body));

        // Close loading dialog
        Get.back();

        if (response != null && response['success']) {
          final fileData = response['file'];
          final base64String = fileData['base64'];

          if (base64String != null && base64String.isNotEmpty) {
            // Decode base64 to bytes
            final bytes = base64Decode(base64String);

            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Image.memory(
                            bytes,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                ImageIcon(
                                  AssetImage('assets/icons/close.png'),
                                  color: Colors.red,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Close",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            /*Get.snackbar("Error", "No file data available",
                backgroundColor: Colors.redAccent, colorText: Colors.white);*/
            GlobalSnackbar.showError("No file data available");
          }
        } else {
          /*Get.snackbar(
              "Error", response?['error'] ?? "Failed to fetch file",
              backgroundColor: Colors.redAccent, colorText: Colors.white);*/
          GlobalSnackbar.showError(
              response?['error'] ?? "Failed to fetch file");
        }
      } catch (e) {
        // Close loading dialog if still open
        Get.back();
        /*Get.snackbar("Error", "Failed to load file: $e",
            backgroundColor: Colors.redAccent, colorText: Colors.white);*/
        GlobalSnackbar.showError("Failed to load file: $e");
      }
    } else {
      // Original logic for local files
      if (image.isNotEmpty && File(image).existsSync()) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.file(File(image)),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            ImageIcon(
                              AssetImage('assets/icons/close.png'),
                              color: Colors.red,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Close",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    addressProof = [
      'Passport',
      'Driving License',
      'Voter Id',
      'Aadhaar card',
      if (isAppraiser()) 'Upload other docs prof',
    ];
    officeAddressList = [
      'Passport',
      'Driving License',
      'Voter Id',
      'Aadhaar card',
      if (isAppraiser()) 'Upload other docs prof',
    ];
    companyCertify = [
      'Registration Certificate',
      'Licence issued by the Municipal',
      'Sales and Income tax return',
      'GST / CST',
      if (isAppraiser()) 'Upload other docs prof',
    ];

    propertyAddressProof = [
      'Partnership Deed',
      'Registration Certificate',
      'utility bill',
      'Authorities Establishment Act',
      'Sales and Income tax return',
      'GST/CST/VAT certificate',
      if (isAppraiser()) 'Upload other docs prof',
    ];
    callPendingScreen(companyType: widget.companyType!);
  }

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
    return Expanded(
      child: Container(height: 4, color: color),
    );
  }

  bool isBankDetailsCompleted() => widget.isSentBack == true;

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
              // color: Colors.white,
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
      body: SingleChildScrollView(
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
                AnimatedStepCircle(
                  text: "3",
                  fillColor: Constant.mediumBlueColor,
                  borderColor: Colors.green,
                ),
                stepConnector(Colors.grey),

                // Step 4
                isBankDetailsCompleted()
                    ? completedStepCircle()
                    : stepCircle(
                        text: "4",
                        fillColor: Colors.grey,
                        borderColor: Constant.mediumBlueColor,
                      ),
                stepConnector(Colors.grey),

                // Step 5
                stepCircle(
                  text: "5",
                  fillColor: Colors.grey,
                  borderColor: Constant.mediumBlueColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const CustomText(
              text: 'Document Verification',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 15),
            const CustomText(
              text: 'Personal Documents',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const SizedBox(height: 10),
            const CustomText(
              text: 'Upload your photo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            InkWell(
              onTap: () {
                CustomsHelper.cameraPermissionAlert(() async {
                  String camera = await CustomsHelper().getCamera();
                  setState(() {
                    uploadPhoto = camera;
                    if (uploadPhoto != '') {
                      uploadedPhoto = true;
                      // Reset the flag to indicate this is a newly uploaded file
                      photo = false;
                    }
                    Get.back();
                  });
                }, null);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 55,
                  // width: 320,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.upload_file_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: uploadPhoto == ""
                            ? CustomText(
                                text: 'Upload your photo',
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      // text: isSentBackValue ? documentInfo["photo"] : uploadPhoto.split('/').last,
                                      text: (isSentBackValue &&
                                              photo &&
                                              !uploadedPhoto &&
                                              uploadPhoto == "")
                                          ? documentInfo["photo"]
                                          : uploadPhoto == ""
                                              ? 'Upload your photo'
                                              : uploadPhoto.split('/').last,
                                      fontSize: 16,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      color: uploadPhoto == ""
                                          ? Colors.grey.shade700
                                          : Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (uploadedPhoto) {
                                          showImagePreview(image: uploadPhoto);
                                        }
                                        // If old document and not replaced yet
                                        else if (isSentBackValue && photo) {
                                          showImagePreview(
                                            image: "",
                                            category: "Photo",
                                            isFromServer: true,
                                          );
                                        } else {
                                          // Show local file
                                          showImagePreview(image: uploadPhoto);
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.blueGrey),
                                  )
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: uploadedPhoto,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: CustomButton(
                        backgroundColor: Colors.grey,
                        text: 'Cancel',
                        onPressed: () {
                          setState(() {
                            uploadPhoto = ""; // Always clear to empty
                            uploadedPhoto = false;
                            photo = isSentBackValue &&
                                documentInfo["photo"] != null;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 150,
                    child: isPhotoUploading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Submit',
                            onPressed: () {
                              setState(() {
                                isPhotoUploading = true;
                              });

                              () async {
                                String base64 = await CustomsHelper()
                                    .fileToBase64(uploadPhoto);
                                String extension =
                                    uploadPhoto.split('.').last.toLowerCase();
                                bool isUploaded = await uploadDoc(
                                  doc: base64,
                                  docName: '${widget.id}_Photo.$extension',
                                  category: 'Photo',
                                  subCategory: '',
                                );

                                if (isUploaded) {
                                  setState(() {
                                    photo = true;
                                    uploadedPhoto = false;
                                  });
                                }

                                setState(() {
                                  isPhotoUploading = false;
                                });
                              }();
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const CustomText(
              text: 'Upload your pan card',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            InkWell(
              onTap: () {
                CustomsHelper.cameraPermissionAlert(() async {
                  String camera = await CustomsHelper().getCamera();
                  setState(() {
                    uploadPan = camera;
                    if (uploadPan != '') {
                      uploadedPan = true;
                      pan = false; // Reset to indicate new upload
                    }
                    Get.back();
                  });
                }, null);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.upload_file_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: uploadPan == ""
                            ? CustomText(
                                text: 'Upload pan card',
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      text: (isSentBackValue &&
                                              pan &&
                                              !uploadedPan &&
                                              uploadPan == "")
                                          ? documentInfo["pan"]
                                          : (uploadPan == ""
                                              ? 'Upload pan card'
                                              : uploadPan.split('/').last),
                                      fontSize: 16,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      color: uploadPan == ""
                                          ? Colors.grey.shade700
                                          : Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (uploadedPan) {
                                          showImagePreview(image: uploadPan);
                                        } else if (isSentBackValue && pan) {
                                          showImagePreview(
                                            image: "",
                                            category: "Indiv_Pan",
                                            isFromServer: true,
                                          );
                                        } else {
                                          showImagePreview(image: uploadPan);
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.blueGrey),
                                  )
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: uploadedPan,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: CustomButton(
                        backgroundColor: Colors.grey,
                        text: 'Cancel',
                        onPressed: () {
                          setState(() {
                            uploadPan = "";
                            uploadedPan = false;
                            pan =
                                isSentBackValue && documentInfo["pan"] != null;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 150,
                    child: isPanUploading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Submit',
                            onPressed: () {
                              setState(() {
                                isPanUploading = true;
                              });

                              () async {
                                String base64 = await CustomsHelper()
                                    .fileToBase64(uploadPan);
                                String extension =
                                    uploadPan.split('.').last.toLowerCase();
                                bool isUploaded = await uploadDoc(
                                  doc: base64,
                                  docName: '${widget.id}_Indiv_Pan.$extension',
                                  category: 'Indiv_Pan',
                                  subCategory: '',
                                );

                                if (isUploaded) {
                                  setState(() {
                                    pan = true;
                                    uploadedPan = false;
                                  });
                                }

                                setState(() {
                                  isPanUploading = false;
                                });
                              }();
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const CustomText(
              text: 'Select your address proof',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  // color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: selectedAddressProof,
                  decoration: const InputDecoration(border: InputBorder.none),
                  hint: Row(
                    children: [
                      const Icon(
                        Icons.arrow_drop_down_circle_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Address proof types',
                        style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  icon: Icon(
                    Icons.arrow_right,
                    color: Colors.grey.shade200,
                  ),
                  items: addressProof.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style:
                            const TextStyle(fontSize: 17, color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedAddressProof = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 13),
            const CustomText(
              text: 'Upload your address proof',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            InkWell(
              onTap: () {
                if (selectedAddressProof != null) {
                  CustomsHelper.cameraPermissionAlert(() async {
                    String camera = await CustomsHelper().getCamera();
                    setState(() {
                      personalAddressProof = camera;
                      if (personalAddressProof != '') {
                        uploadedPersonalAddressProof = true;
                        personalAddress = false; // Reset to indicate new upload
                      }
                      Get.back();
                    });
                  }, null);
                } else {
                  /*Get.snackbar("Failed", 'Please select address proof type',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white);*/
                  GlobalSnackbar.showError('Please select address proof type');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.upload_file_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: personalAddressProof == ""
                            ? CustomText(
                                text: selectedAddressProof == null
                                    ? 'Upload address proof'
                                    : 'Upload $selectedAddressProof',
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      text: (isSentBackValue &&
                                              personalAddress &&
                                              !uploadedPersonalAddressProof &&
                                              personalAddressProof == "")
                                          ? (documentInfo["addressProof"] is Map
                                              ? documentInfo["addressProof"]
                                                      ["name"] ??
                                                  "Address Proof"
                                              : "Address Proof")
                                          : (personalAddressProof == ""
                                              ? (selectedAddressProof == null
                                                  ? 'Upload address proof'
                                                  : 'Upload $selectedAddressProof')
                                              : personalAddressProof
                                                  .split('/')
                                                  .last),
                                      fontSize: 16,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      color: personalAddressProof == ""
                                          ? Colors.grey.shade700
                                          : Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (uploadedPersonalAddressProof) {
                                          showImagePreview(
                                              image: personalAddressProof);
                                        } else if (isSentBackValue &&
                                            personalAddress) {
                                          showImagePreview(
                                            image: "",
                                            category: "Indiv_AddressProof",
                                            isFromServer: true,
                                          );
                                        } else {
                                          showImagePreview(
                                              image: personalAddressProof);
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.blueGrey),
                                  )
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: uploadedPersonalAddressProof,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: CustomButton(
                        backgroundColor: Colors.grey,
                        text: 'Cancel',
                        onPressed: () {
                          setState(() {
                            personalAddressProof = "";
                            uploadedPersonalAddressProof = false;
                            personalAddress = isSentBackValue &&
                                documentInfo["addressProof"] != null &&
                                documentInfo["addressProof"]
                                    .toString()
                                    .isNotEmpty;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 150,
                    child: isAddressProofUploading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Submit',
                            onPressed: () {
                              setState(() {
                                isAddressProofUploading = true;
                              });

                              () async {
                                String base64 = await CustomsHelper()
                                    .fileToBase64(personalAddressProof);
                                String extension = personalAddressProof
                                    .split('.')
                                    .last
                                    .toLowerCase();
                                bool isUploaded = await uploadDoc(
                                  doc: base64,
                                  docName:
                                      '${widget.id}_Indiv_AddressProof.$extension',
                                  category: 'Indiv_AddressProof',
                                  subCategory: selectedAddressProof!,
                                );

                                if (isUploaded) {
                                  setState(() {
                                    personalAddress = true;
                                    uploadedPersonalAddressProof = false;
                                  });
                                }

                                setState(() {
                                  isAddressProofUploading = false;
                                });
                              }();
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const CustomText(
              text: 'Select company Address Proof',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: selectedOfficeAddressProof,
                  decoration: const InputDecoration(border: InputBorder.none),
                  hint: Row(
                    children: [
                      const Icon(
                        Icons.arrow_drop_down_circle_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Address proof types',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 17, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  icon: const Icon(Icons.arrow_right, color: Colors.grey),
                  isExpanded: true,
                  // Important for full-width dropdown
                  items: officeAddressList.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 17, color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOfficeAddressProof = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 13),
            const CustomText(
              text: 'Upload company address proof',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            InkWell(
              onTap: () {
                if (selectedOfficeAddressProof != null) {
                  CustomsHelper.cameraPermissionAlert(() async {
                    String camera = await CustomsHelper().getCamera();
                    setState(() {
                      officeAddressProof = camera;
                      if (officeAddressProof != '') {
                        uploadedOfficeAddressProof = true;
                        officeAddress = false; // Reset to indicate new upload
                      }

                      Get.back();
                    });
                  }, () async {
                    String gallery = await CustomsHelper().getGalleryFile();
                    setState(() {
                      officeAddressProof = gallery;
                      if (officeAddressProof != '') {
                        uploadedOfficeAddressProof = true;
                        officeAddress = false; // Reset to indicate new upload
                      }

                      Get.back();
                    });
                  });
                } else {
                  /*Get.snackbar(
                    "Failed",
                    'Please select address proof type',
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );*/
                  GlobalSnackbar.showError('Please select address proof type');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.upload_file_sharp,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: officeAddressProof == ""
                            ? CustomText(
                                text: selectedOfficeAddressProof == null
                                    ? 'Upload address proof'
                                    : 'Upload $selectedOfficeAddressProof',
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      text: (isSentBackValue &&
                                              officeAddress &&
                                              !uploadedOfficeAddressProof &&
                                              officeAddressProof == "")
                                          ? (documentInfo["officeAddressProof"]
                                                  is Map
                                              ? documentInfo[
                                                          "officeAddressProof"]
                                                      ["name"] ??
                                                  "Office Address Proof"
                                              : "Office Address Proof")
                                          : (officeAddressProof == ""
                                              ? (selectedOfficeAddressProof ==
                                                      null
                                                  ? 'Upload address proof'
                                                  : 'Upload $selectedOfficeAddressProof')
                                              : officeAddressProof
                                                  .split('/')
                                                  .last),
                                      fontSize: 16,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      color: officeAddressProof == ""
                                          ? Colors.grey.shade700
                                          : Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (uploadedOfficeAddressProof) {
                                          showImagePreview(
                                              image: officeAddressProof);
                                        } else if (isSentBackValue &&
                                            officeAddress) {
                                          showImagePreview(
                                            image: "",
                                            category: "OfficeAddressProof",
                                            isFromServer: true,
                                          );
                                        } else {
                                          showImagePreview(
                                              image: officeAddressProof);
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.blueGrey,
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: uploadedOfficeAddressProof,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: CustomButton(
                        backgroundColor: Colors.grey,
                        text: 'Cancel',
                        onPressed: () {
                          setState(() {
                            officeAddressProof = "";
                            uploadedOfficeAddressProof = false;
                            officeAddress = isSentBackValue &&
                                documentInfo["officeAddressProof"] != null &&
                                documentInfo["officeAddressProof"]
                                    .toString()
                                    .isNotEmpty;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 150,
                    child: isOfficeAddressProofUploading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Submit',
                            onPressed: () {
                              setState(() {
                                isOfficeAddressProofUploading = true;
                              });

                              () async {
                                String base64 = await CustomsHelper()
                                    .fileToBase64(officeAddressProof);
                                String extension = officeAddressProof
                                    .split('.')
                                    .last
                                    .toLowerCase();
                                bool isUploaded = await uploadDoc(
                                  doc: base64,
                                  docName:
                                      '${widget.id}_OfficeAddressProof.$extension',
                                  category: 'OfficeAddressProof',
                                  subCategory: selectedOfficeAddressProof!,
                                );

                                if (isUploaded) {
                                  setState(() {
                                    officeAddress = true;
                                    uploadedOfficeAddressProof = false;
                                  });
                                }

                                setState(() {
                                  isOfficeAddressProofUploading = false;
                                });
                              }();
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const CustomText(
              text: 'Upload your signature',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            InkWell(
              onTap: () {
                CustomsHelper.cameraPermissionAlert(() async {
                  String camera = await CustomsHelper().getCamera();
                  setState(() {
                    uploadSignature = camera;
                    if (uploadSignature != '') {
                      uploadedSignature = true;
                      signature = false; // Reset to indicate new upload
                    }
                    Get.back();
                  });
                }, null);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.upload_file_sharp,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: uploadSignature == ""
                              ? CustomText(
                                  text: 'Upload your signature',
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CustomText(
                                        text: (isSentBackValue &&
                                                signature &&
                                                !uploadedSignature &&
                                                uploadSignature == "")
                                            ? documentInfo["signature"]
                                            : (uploadSignature == ""
                                                ? 'Upload your signature'
                                                : uploadSignature
                                                    .split('/')
                                                    .last),
                                        fontSize: 16,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        color: uploadSignature == ""
                                            ? Colors.grey.shade700
                                            : Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (uploadedSignature) {
                                            showImagePreview(
                                                image: uploadSignature);
                                          } else if (isSentBackValue &&
                                              signature) {
                                            showImagePreview(
                                              image: "",
                                              category: "Signature",
                                              isFromServer: true,
                                            );
                                          } else {
                                            showImagePreview(
                                                image: uploadSignature);
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.visibility,
                                          color: Colors.blueGrey),
                                    )
                                  ],
                                ),
                        ),
                      ],
                    )),
              ),
            ),
            Visibility(
              visible: uploadedSignature,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: CustomButton(
                        backgroundColor: Colors.grey,
                        text: 'Cancel',
                        onPressed: () {
                          setState(() {
                            uploadSignature = "";
                            uploadedSignature = false;
                            signature = isSentBackValue &&
                                documentInfo["signature"] != null;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 150,
                    child: isSignatureUploading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Submit',
                            onPressed: () {
                              setState(() {
                                isSignatureUploading = true;
                              });

                              () async {
                                String base64 = await CustomsHelper()
                                    .fileToBase64(uploadSignature);
                                String extension = uploadSignature
                                    .split('.')
                                    .last
                                    .toLowerCase();
                                bool isUploaded = await uploadDoc(
                                  doc: base64,
                                  docName: '${widget.id}_Signature.$extension',
                                  category: 'Signature',
                                  subCategory: '',
                                );

                                if (isUploaded) {
                                  setState(() {
                                    signature = true;
                                    uploadedSignature = false;
                                  });
                                }

                                setState(() {
                                  isSignatureUploading = false;
                                });
                              }();
                            },
                          ),
                  ),
                ],
              ),
            ),
            widget.companyType != 'Individual'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const CustomText(
                        text: 'Company Documents',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 10),
                      CustomText(
                        text: isAppraiser()
                            ? 'Upload URC/GST/Shop code'
                            : 'Upload URC',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      InkWell(
                        onTap: () {
                          CustomsHelper.cameraPermissionAlert(() async {
                            String camera = await CustomsHelper().getCamera();
                            setState(() {
                              uploadUrc = camera;
                              if (uploadUrc != '') {
                                uploadedUrc = true;
                                urc = false; // Reset to indicate new upload
                              }

                              Get.back();
                            });
                          }, () async {
                            String gallery =
                                await CustomsHelper().getGalleryFile();
                            setState(() {
                              uploadUrc = gallery;
                              if (uploadUrc != '') {
                                uploadedUrc = true;
                                urc = false; // Reset to indicate new upload
                              }
                              Get.back();
                            });
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.upload_file_sharp,
                                    color: Colors.blueGrey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: uploadUrc == ""
                                        ? CustomText(
                                            text: isAppraiser()
                                                ? 'Upload URC/GST/Shop code doc'
                                                : 'Upload URC',
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: CustomText(
                                                  text: (isSentBackValue &&
                                                          urc &&
                                                          !uploadedUrc &&
                                                          uploadUrc == "")
                                                      ? documentInfo["urc"]
                                                      : (uploadUrc == ""
                                                          ? (isAppraiser()
                                                              ? 'Upload URC/GST/Shop code doc'
                                                              : 'Upload URC')
                                                          : uploadUrc
                                                              .split('/')
                                                              .last),
                                                  fontSize: 16,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: uploadUrc == ""
                                                      ? Colors.grey.shade700
                                                      : Colors.black87,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (uploadedUrc) {
                                                      showImagePreview(
                                                          image: uploadUrc);
                                                    } else if (isSentBackValue &&
                                                        urc) {
                                                      showImagePreview(
                                                        image: "",
                                                        category: "URC",
                                                        isFromServer: true,
                                                      );
                                                    } else {
                                                      showImagePreview(
                                                          image: uploadUrc);
                                                    }
                                                  });
                                                },
                                                icon: const Icon(
                                                    Icons.visibility,
                                                    color: Colors.blueGrey),
                                              )
                                            ],
                                          ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      Visibility(
                        visible: uploadedUrc,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 150,
                              child: CustomButton(
                                  backgroundColor: Colors.grey,
                                  text: 'Cancel',
                                  onPressed: () {
                                    setState(() {
                                      uploadUrc = "";
                                      uploadedUrc = false;
                                      urc = isSentBackValue &&
                                          documentInfo["urc"] != null;
                                    });
                                  }),
                            ),
                            SizedBox(
                              width: 150,
                              child: CustomButton(
                                  text: 'Submit',
                                  onPressed: () async {
                                    String base64 = await CustomsHelper()
                                        .fileToBase64(uploadUrc);
                                    String extension =
                                        uploadUrc.split('.').last.toLowerCase();
                                    bool isUploaded = await uploadDoc(
                                        doc: base64,
                                        docName: '${widget.id}_URC.$extension',
                                        category: 'URC',
                                        subCategory: '');

                                    if (isUploaded) {
                                      setState(() {
                                        urc = true;
                                        uploadedUrc = false;
                                      });
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const CustomText(
                        text: 'Upload company pan',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      InkWell(
                        onTap: () {
                          CustomsHelper.cameraPermissionAlert(() async {
                            String camera = await CustomsHelper().getCamera();
                            setState(() {
                              uploadCompanyPan = camera;
                              if (uploadCompanyPan != '') {
                                uploadedComPan = true;
                                companyPan =
                                    false; // Reset to indicate new upload
                              }

                              Get.back();
                            });
                          }, null);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.upload_file_sharp,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: uploadCompanyPan == ""
                                      ? CustomText(
                                          text: 'Upload company pan',
                                          fontSize: 16,
                                          color: Colors.grey.shade700,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: CustomText(
                                                text: (isSentBackValue &&
                                                        companyPan &&
                                                        !uploadedComPan &&
                                                        uploadCompanyPan == "")
                                                    ? documentInfo["companyPAN"]
                                                    : (uploadCompanyPan == ""
                                                        ? 'Upload company pan'
                                                        : uploadCompanyPan
                                                            .split('/')
                                                            .last),
                                                fontSize: 16,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                color: uploadCompanyPan == ""
                                                    ? Colors.grey.shade700
                                                    : Colors.black87,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (uploadedComPan) {
                                                    showImagePreview(
                                                        image:
                                                            uploadCompanyPan);
                                                  } else if (isSentBackValue &&
                                                      companyPan) {
                                                    showImagePreview(
                                                      image: "",
                                                      category: "CompanyPAN",
                                                      isFromServer: true,
                                                    );
                                                  } else {
                                                    showImagePreview(
                                                        image:
                                                            uploadCompanyPan);
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.visibility,
                                                  color: Colors.blueGrey),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: uploadedComPan,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 150,
                              child: CustomButton(
                                  backgroundColor: Colors.grey,
                                  text: 'Cancel',
                                  onPressed: () {
                                    setState(() {
                                      uploadCompanyPan = "";
                                      uploadedComPan = false;
                                      companyPan = isSentBackValue &&
                                          documentInfo["companyPAN"] != null;
                                    });
                                  }),
                            ),
                            SizedBox(
                              width: 150,
                              child: isCompanyPanUploading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : CustomButton(
                                      text: 'Submit',
                                      onPressed: () {
                                        setState(() {
                                          isCompanyPanUploading = true;
                                        });

                                        () async {
                                          String base64 = await CustomsHelper()
                                              .fileToBase64(uploadCompanyPan);
                                          String extension = uploadCompanyPan
                                              .split('.')
                                              .last
                                              .toLowerCase();
                                          bool isUploaded = await uploadDoc(
                                            doc: base64,
                                            docName:
                                                '${widget.id}_CompanyPAN.$extension',
                                            category: 'CompanyPAN',
                                            subCategory: '',
                                          );

                                          if (isUploaded) {
                                            setState(() {
                                              uploadedComPan = false;
                                              companyPan = true;
                                            });
                                          }

                                          setState(() {
                                            isCompanyPanUploading = false;
                                          });
                                        }();
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomText(
                        text: isAppraiser()
                            ? 'Upload DSA/Company Profile/RBH approval'
                            : 'Upload DSA',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      InkWell(
                        onTap: () {
                          CustomsHelper.cameraPermissionAlert(() async {
                            String camera = await CustomsHelper().getCamera();
                            setState(() {
                              uploadDSA = camera;
                              if (uploadDSA != '') {
                                uploadedDSA = true;
                                dsa = false; // Reset to indicate new upload
                              }
                              Get.back();
                            });
                          }, () async {
                            String gallery =
                                await CustomsHelper().getGalleryFile();
                            setState(() {
                              uploadDSA = gallery;
                              if (uploadDSA != '') {
                                uploadedDSA = true;
                                dsa = false; // Reset to indicate new upload
                              }
                              Get.back();
                            });
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.upload_file_sharp,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: uploadDSA == ""
                                      ? CustomText(
                                          text: isAppraiser()
                                              ? 'Upload DSA/Company Profile'
                                              : 'Upload DSA',
                                          fontSize: 16,
                                          color: Colors.grey.shade700,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: CustomText(
                                                text: (isSentBackValue &&
                                                        dsa &&
                                                        !uploadedDSA &&
                                                        uploadDSA == "")
                                                    ? documentInfo["dsa"]
                                                    : (uploadDSA == ""
                                                        ? (isAppraiser()
                                                            ? 'Upload DSA/Company Profile'
                                                            : 'Upload DSA')
                                                        : uploadDSA
                                                            .split('/')
                                                            .last),
                                                fontSize: 16,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                color: uploadDSA == ""
                                                    ? Colors.grey.shade700
                                                    : Colors.black87,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (uploadedDSA) {
                                                    showImagePreview(
                                                        image: uploadDSA);
                                                  } else if (isSentBackValue &&
                                                      dsa) {
                                                    showImagePreview(
                                                      image: "",
                                                      category: "DSA",
                                                      isFromServer: true,
                                                    );
                                                  } else {
                                                    showImagePreview(
                                                        image: uploadDSA);
                                                  }
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.visibility,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: uploadedDSA,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 150,
                              child: CustomButton(
                                  backgroundColor: Colors.grey,
                                  text: 'Cancel',
                                  onPressed: () {
                                    setState(() {
                                      uploadDSA = "";
                                      uploadedDSA = false;
                                      dsa = isSentBackValue &&
                                          documentInfo["dsa"] != null;
                                    });
                                  }),
                            ),
                            SizedBox(
                              width: 150,
                              child: isDSAUploading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : CustomButton(
                                      text: 'Submit',
                                      onPressed: () {
                                        setState(() {
                                          isDSAUploading = true;
                                        });

                                        () async {
                                          String base64 = await CustomsHelper()
                                              .fileToBase64(uploadDSA);
                                          String extension = uploadDSA
                                              .split('.')
                                              .last
                                              .toLowerCase();
                                          bool isUploaded = await uploadDoc(
                                            doc: base64,
                                            docName:
                                                '${widget.id}_DSA.$extension',
                                            category: 'DSA',
                                            subCategory: '',
                                          );

                                          if (isUploaded) {
                                            setState(() {
                                              uploadedDSA = false;
                                              dsa = true;
                                            });
                                          }

                                          setState(() {
                                            isDSAUploading = false;
                                          });
                                        }();
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomText(
                        text: isAppraiser()
                            ? 'Select Values addition'
                            : 'Select Company certify types',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonFormField<String>(
                            value: selectedCertify,
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            hint: Row(
                              children: [
                                const Icon(
                                  Icons.arrow_drop_down_circle_sharp,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isAppraiser()
                                      ? 'Values addition'
                                      : 'Company certify types',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            icon: Icon(
                              Icons.arrow_right,
                              color: Colors.grey[200],
                              size: 5,
                            ),
                            items: companyCertify.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: SizedBox(
                                  width: 300,
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                    maxLines: 4,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCertify = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      const CustomText(
                        text: 'Upload your entity proof',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      InkWell(
                        onTap: () {
                          if (selectedCertify != null) {
                            CustomsHelper.cameraPermissionAlert(() async {
                              String camera = await CustomsHelper().getCamera();
                              setState(() {
                                uploadCompanyCer = camera;
                                if (uploadCompanyCer != '') {
                                  uploadedComCertify = true;
                                  companyCert =
                                      false; // Reset to indicate new upload
                                }

                                Get.back();
                              });
                            }, () async {
                              String gallery =
                                  await CustomsHelper().getGalleryFile();
                              setState(() {
                                uploadCompanyCer = gallery;
                                if (uploadCompanyCer != '') {
                                  uploadedComCertify = true;
                                  companyCert =
                                      false; // Reset to indicate new upload
                                }

                                Get.back();
                              });
                            });
                          } else {
                            /*Get.snackbar("Failed", 'Please select entity proof',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white);*/
                            GlobalSnackbar.showError(
                                'Please select entity proof');
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.upload_file_sharp,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: uploadCompanyCer == ""
                                      ? CustomText(
                                          text: selectedCertify == null
                                              ? 'Upload entity proof'
                                              : 'Upload $selectedCertify',
                                          fontSize: 16,
                                          color: Colors.grey.shade700,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: CustomText(
                                                text: (isSentBackValue &&
                                                        companyCert &&
                                                        !uploadedComCertify &&
                                                        uploadCompanyCer == "")
                                                    ? (documentInfo[
                                                                "entityProof"]
                                                            is Map
                                                        ? documentInfo[
                                                                    "entityProof"]
                                                                ["name"] ??
                                                            "Entity Proof"
                                                        : "Entity Proof")
                                                    : (uploadCompanyCer == ""
                                                        ? (selectedCertify ==
                                                                null
                                                            ? 'Upload entity proof'
                                                            : 'Upload $selectedCertify')
                                                        : uploadCompanyCer
                                                            .split('/')
                                                            .last),
                                                fontSize: 16,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                color: uploadCompanyCer == ""
                                                    ? Colors.grey.shade700
                                                    : Colors.black87,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (uploadedComCertify) {
                                                    showImagePreview(
                                                        image:
                                                            uploadCompanyCer);
                                                  } else if (isSentBackValue &&
                                                      companyCert) {
                                                    showImagePreview(
                                                      image: "",
                                                      category: "EntityProof",
                                                      isFromServer: true,
                                                    );
                                                  } else {
                                                    showImagePreview(
                                                        image:
                                                            uploadCompanyCer);
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.visibility,
                                                  color: Colors.blueGrey),
                                            )
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: uploadedComCertify,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 150,
                              child: CustomButton(
                                  backgroundColor: Colors.grey,
                                  text: 'Cancel',
                                  onPressed: () {
                                    setState(() {
                                      uploadCompanyCer = "";
                                      uploadedComCertify = false;
                                      companyCert = isSentBackValue &&
                                          documentInfo["entityProof"] != null &&
                                          documentInfo["entityProof"]
                                              .toString()
                                              .isNotEmpty;
                                    });
                                  }),
                            ),
                            SizedBox(
                              width: 150,
                              child: isCompanyCertUploading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : CustomButton(
                                      text: 'Submit',
                                      onPressed: () {
                                        setState(() {
                                          isCompanyCertUploading = true;
                                        });

                                        () async {
                                          String base64 = await CustomsHelper()
                                              .fileToBase64(uploadCompanyCer);
                                          String extension = uploadCompanyCer
                                              .split('.')
                                              .last
                                              .toLowerCase();
                                          bool isUploaded = await uploadDoc(
                                            doc: base64,
                                            docName:
                                                '${widget.id}_EntityProof.$extension',
                                            category: 'EntityProof',
                                            subCategory: selectedCertify!,
                                          );

                                          if (isUploaded) {
                                            setState(() {
                                              uploadedComCertify = false;
                                              companyCert = true;
                                            });
                                          }

                                          setState(() {
                                            isCompanyCertUploading = false;
                                          });
                                        }();
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(),
            Visibility(
              visible: isAppraiser(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const CustomText(
                    text: 'Select your Profile',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        // color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<String>(
                        value: selectedProfileProof,
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                        hint: Row(
                          children: [
                            const Icon(
                              Icons.arrow_drop_down_circle_sharp,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Profile types',
                              style: TextStyle(
                                  fontSize: 17, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        icon: Icon(
                          Icons.arrow_right,
                          color: Colors.grey.shade200,
                        ),
                        items: profileDocumentList.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedProfileProof = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CustomText(
                    text: 'Upload Profile',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  InkWell(
                    onTap: () {
                      if (selectedProfileProof != null) {
                        CustomsHelper.cameraPermissionAlert(() async {
                          String camera = await CustomsHelper().getCamera();
                          setState(() {
                            uploadProfileDocument = camera;
                            if (uploadProfileDocument != '') {
                              uploadedProfileDocument = true;
                              profileDocument =
                                  false; // Reset to indicate new upload
                            }
                            Get.back();
                          });
                        }, () async {
                          String gallery =
                              await CustomsHelper().getGalleryFile();
                          setState(() {
                            uploadProfileDocument = gallery;
                            if (uploadProfileDocument != '') {
                              uploadedProfileDocument = true;
                              profileDocument =
                                  false; // Reset to indicate new upload
                            }
                            Get.back();
                          });
                        });
                      } else {
                        /*Get.snackbar("Failed", 'Please select profile proof',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white);*/
                        GlobalSnackbar.showError('Please select profile proof');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.upload_file_sharp,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: uploadProfileDocument == ""
                                  ? CustomText(
                                      text: 'Upload Profile',
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: (isSentBackValue &&
                                                    profileDocument &&
                                                    !uploadedProfileDocument &&
                                                    uploadProfileDocument == "")
                                                ? (documentInfo["profile"]
                                                        is Map
                                                    ? documentInfo["profile"]
                                                            ["name"] ??
                                                        "Profile"
                                                    : "Profile")
                                                : (uploadProfileDocument == ""
                                                    ? 'Upload Profile'
                                                    : uploadProfileDocument
                                                        .split('/')
                                                        .last),
                                            fontSize: 16,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            color: uploadProfileDocument == ""
                                                ? Colors.grey.shade700
                                                : Colors.black87,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (uploadedProfileDocument) {
                                                showImagePreview(
                                                    image:
                                                        uploadProfileDocument);
                                              } else if (isSentBackValue &&
                                                  profileDocument) {
                                                showImagePreview(
                                                  image: "",
                                                  category: "Profile",
                                                  isFromServer: true,
                                                );
                                              } else {
                                                showImagePreview(
                                                    image:
                                                        uploadProfileDocument);
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.visibility,
                                              color: Colors.blueGrey),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: uploadedProfileDocument,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: CustomButton(
                        backgroundColor: Colors.grey,
                        text: 'Cancel',
                        onPressed: () {
                          setState(() {
                            uploadProfileDocument = "";
                            uploadedProfileDocument = false;
                            profileDocument = isSentBackValue &&
                                documentInfo["profile"] != null &&
                                documentInfo["profile"].toString().isNotEmpty;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 150,
                    child: isProfileUploading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Submit',
                            onPressed: () {
                              setState(() {
                                isProfileUploading = true;
                              });

                              () async {
                                String base64 = await CustomsHelper()
                                    .fileToBase64(uploadProfileDocument);
                                String extension = uploadProfileDocument
                                    .split('.')
                                    .last
                                    .toLowerCase();
                                bool isUploaded = await uploadDoc(
                                  doc: base64,
                                  docName: '${widget.id}_Profile.$extension',
                                  category: 'Profile',
                                  subCategory: selectedProfileProof ?? '',
                                );

                                if (isUploaded) {
                                  setState(() {
                                    uploadedProfileDocument = false;
                                    profileDocument = true;
                                  });
                                }

                                setState(() {
                                  isProfileUploading = false;
                                });
                              }();
                            },
                          ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: isAppraiser(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const CustomText(
                    text: 'Upload other docs prof',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  InkWell(
                    onTap: () {
                      CustomsHelper.cameraPermissionAlert(() async {
                        String camera = await CustomsHelper().getCamera();
                        setState(() {
                          uploadOtherDocument = camera;
                          if (uploadOtherDocument != '') {
                            uploadedOtherDocument = true;
                            otherDocument =
                                false; // Reset to indicate new upload
                          }
                          Get.back();
                        });
                      }, () async {
                        String gallery = await CustomsHelper().getGalleryFile();
                        setState(() {
                          uploadOtherDocument = gallery;
                          if (uploadOtherDocument != '') {
                            uploadedOtherDocument = true;
                            otherDocument =
                                false; // Reset to indicate new upload
                          }
                          Get.back();
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.upload_file_sharp,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: uploadOtherDocument == ""
                                  ? CustomText(
                                      text: 'Upload other docs prof',
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: (isSentBackValue &&
                                                    otherDocument &&
                                                    !uploadedOtherDocument &&
                                                    uploadOtherDocument == "")
                                                ? documentInfo["otherDoc"]
                                                : (uploadOtherDocument == ""
                                                    ? 'Upload other docs prof'
                                                    : uploadOtherDocument
                                                        .split('/')
                                                        .last),
                                            fontSize: 16,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            color: uploadOtherDocument == ""
                                                ? Colors.grey.shade700
                                                : Colors.black87,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (uploadedOtherDocument) {
                                                showImagePreview(
                                                    image: uploadOtherDocument);
                                              } else if (isSentBackValue &&
                                                  otherDocument) {
                                                showImagePreview(
                                                  image: "",
                                                  category: "Other",
                                                  isFromServer: true,
                                                );
                                              } else {
                                                showImagePreview(
                                                    image: uploadOtherDocument);
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.visibility,
                                              color: Colors.blueGrey),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: uploadedOtherDocument,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: CustomButton(
                        backgroundColor: Colors.grey,
                        text: 'Cancel',
                        onPressed: () {
                          setState(() {
                            uploadOtherDocument = "";
                            uploadedOtherDocument = false;
                            otherDocument = isSentBackValue &&
                                documentInfo["otherDoc"] != null;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 150,
                    child: isOtherDocUploading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: 'Submit',
                            onPressed: () {
                              setState(() {
                                isOtherDocUploading = true;
                              });

                              () async {
                                String base64 = await CustomsHelper()
                                    .fileToBase64(uploadOtherDocument);
                                String extension = uploadOtherDocument
                                    .split('.')
                                    .last
                                    .toLowerCase();
                                bool isUploaded = await uploadDoc(
                                  doc: base64,
                                  docName: '${widget.id}_Other.$extension',
                                  category: 'Other',
                                  subCategory: '',
                                );

                                if (isUploaded) {
                                  setState(() {
                                    uploadedOtherDocument = false;
                                    otherDocument = true;
                                  });
                                }

                                setState(() {
                                  isOtherDocUploading = false;
                                });
                              }();
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Save & Next',
                  onPressed: () {
                    if (widget.companyType == 'Proprietorship') {
                      if (photo &&
                          pan &&
                          signature &&
                          personalAddress &&
                          officeAddress &&
                          dsa &&
                          companyCert &&
                          selectedAddressProof != null &&
                          selectedOfficeAddressProof != null &&
                          selectedCertify != null) {
                        handleSaveAndNext();
                      } else {
                        /*Get.snackbar(
                          "Failed", 'Please upload all the documents',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );*/
                        GlobalSnackbar.showError(
                            'Please upload all the documents');
                      }
                    } else if (widget.companyType == 'Individual') {
                      if (photo &&
                          pan &&
                          signature &&
                          personalAddress &&
                          selectedAddressProof != null) {
                        handleSaveAndNext();
                      } else {
                        /*Get.snackbar(
                          "Failed", 'Please upload all the documents',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );*/
                        GlobalSnackbar.showError(
                            'Please upload all the documents');
                      }
                    } else {
                      if (photo &&
                          pan &&
                          signature &&
                          personalAddress &&
                          officeAddress &&
                          dsa &&
                          companyPan &&
                          companyCert &&
                          selectedAddressProof != null &&
                          selectedOfficeAddressProof != null &&
                          selectedCertify != null) {
                        handleSaveAndNext();
                      } else {
                        /*Get.snackbar(
                          "Failed", 'Please upload all the documents',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );*/
                        GlobalSnackbar.showError(
                            'Please upload all the documents');
                      }
                    }
                  },
                  backgroundColor: const Color(0xFFfaa61a),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void callPendingScreen({required String companyType}) {
    switch (companyType) {
      case "Proprietorship":
        setState(() {
          officeAddressList = [
            'Partnership Deed',
            'Registration Certificate',
            'Telephone /utility bill',
            'Municipal authorities under Shop & Establishment Act',
            'Sales and Income tax return',
            'GST / CST (Central Sales Tax) / VAT certificate',
            if (isAppraiser()) 'Upload other docs prof',
          ];
          propertyAddressProof = [
            'Partnership Deed ',
            'Registration Certificate',
            'Certificate of Incorporation',
            'Telephone /utility bill',
            'PAN Card of the Firm',
            if (isAppraiser()) 'Upload other docs prof',
          ];
        });
        break;
      case "Pvt ltd":
        setState(() {
          officeAddressList = [
            'Telephone /utility bill',
            'Sales and Income tax returns'
                'GST / CST',
            'Sales Tax/Service Tax',
            'Government Authority/Department',
            'Sale/Rental/Lease Agreement',
            if (isAppraiser()) 'Upload other docs prof',
          ];
          propertyAddressProof = [
            'Memorandum of Association',
            'Share Holding Pattern',
            'Certificate of Incorporation',
            'The Board of Directors',
            'PAN of the Company',
            if (isAppraiser()) 'Upload other docs prof',
          ];
        });
        break;
      case "Partnership":
        setState(() {
          officeAddressList = [
            'Partnership Deed',
            'Registration Certificate',
            'Telephone /utility bill',
            'Municipal authorities under Shop & Establishment Act',
            'Sales and Income tax return',
            'GST / CST (Central Sales Tax) / VAT certificate',
            if (isAppraiser()) 'Upload other docs prof',
          ];
          propertyAddressProof = [
            'Partnership Deed ',
            'Registration Certificate',
            'Certificate of Incorporation',
            'Telephone /utility bill',
            'PAN Card of the Firm',
            if (isAppraiser()) 'Upload other docs prof',
          ];
        });
        break;
      case "Individual":
        setState(() {
          officeAddressList = [
            'Partnership Deed',
            'Registration Certificate',
            'Telephone /utility bill',
            'Municipal authorities under Shop & Establishment Act',
            'Sales and Income tax return',
            'GST / CST (Central Sales Tax) / VAT certificate',
            if (isAppraiser()) 'Upload other docs prof',
          ];
          propertyAddressProof = [
            'Firm address',
            if (isAppraiser()) 'Upload other docs prof',
          ];
        });
        break;
      default:
    }
  }

  Future<bool> uploadDoc({
    required String doc,
    required String docName,
    required String category,
    required String subCategory,
  }) async {
    Map<String, dynamic> body = {
      "id": widget.id,
      "file": {
        "category": category,
        "subCategory": subCategory,
        "name": docName,
        "base64": doc
      }
    };

    Map<String, dynamic>? response =
        await ApiClient().vcpUploadDoc(json.encode(body));
    // print("body:, ${json.encode(body)}");
    // print("response:, ${response}");
    if (response != null) {
      if (response['success']) {
        /*Get.snackbar("Success", "$docName uploaded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);*/
        GlobalSnackbar.showSuccess("$docName uploaded successfully");
        return true;
      } else {
        /*Get.snackbar("Failed", response["error"],
            backgroundColor: Colors.redAccent, colorText: Colors.white);*/
        GlobalSnackbar.showError(response["error"] ?? "Failed to save documents");
        return false;
      }
    } else {
      /*Get.snackbar("Failed", 'Something went wrong',
          backgroundColor: Colors.redAccent, colorText: Colors.white);*/
      GlobalSnackbar.showError('Something went wrong');
      return false;
    }
  }

  Future<bool> docStatusUpdate() async {
    Map<String, dynamic>? response =
        await ApiClient().updateDocStatus(json.encode(widget.id));
    if (response != null) {
      if (response['success']) {
        /*Get.snackbar("Success", "Documents are uploaded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);*/
        GlobalSnackbar.showSuccess("Document details are saved successfully");
        if (isBankDetailsCompleted()) {
          Get.to(
              () => ESignEnable(
                    id: widget.id,
                    employeeId: widget.employeeId,
                    close: widget.close,
                  ),
              arguments: {"id": submittedId});
        } else {
          Get.to(
              () => BankApplication(
                  id: widget.id,
                  employeeId: widget.employeeId,
                  close: widget.close),
              arguments: {"id": submittedId, "bankDetails": bankDetails});
        }

        return true;
      } else {
        /*Get.snackbar("Failed", response["error"],
            backgroundColor: Colors.redAccent, colorText: Colors.white);*/
        GlobalSnackbar.showError("${response["error"]}");
        return false;
      }
    } else {
      /*Get.snackbar("Failed", 'Something went wrong',
          backgroundColor: Colors.redAccent, colorText: Colors.white);*/
      GlobalSnackbar.showError('Something went wrong');
      return false;
    }
  }

  void handleSaveAndNext() {
    if (isSentBackValue) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Center(child: const Text("Edit Bank Details?")),
          content: const Text("Do you want to edit the bank details?"),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFfaa61a), // or any other color
                      foregroundColor: Colors.white, // text/icon color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.to(
                        () => BankApplication(
                          id: widget.id,
                          employeeId: widget.employeeId,
                          close: widget.close,
                        ),
                        arguments: {
                          "id": submittedId,
                          "bankDetails": bankDetails,
                        },
                      );
                    },
                    child: const Text("Yes"),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Constant.mediumBlueColor, // or any other color
                      foregroundColor: Colors.white, // text/icon color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.to(
                        () => ESignEnable(
                          id: widget.id,
                          employeeId: widget.employeeId,
                          close: widget.close,
                        ),
                        arguments: {
                          "id": submittedId,
                        },
                      );
                    },
                    child: const Text("No"),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      docStatusUpdate();
    }
  }
}
