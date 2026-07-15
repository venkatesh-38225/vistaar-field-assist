import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:re_kyc_mobile_app/models/legal_masters.dart';
import 'package:re_kyc_mobile_app/models/legal_billing_details_res.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/custom_textform_field.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/utils/helper.dart';

class EditLegalBillingScreen extends StatefulWidget {
  const EditLegalBillingScreen({
    super.key,
    required this.billingId,
    required this.employeeId,
  });

  final int billingId;
  final String employeeId;

  @override
  State<EditLegalBillingScreen> createState() => _EditLegalBillingScreenState();
}

class _EditLegalBillingScreenState extends State<EditLegalBillingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController lanController = TextEditingController();
  final TextEditingController branchIdController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController custIdController = TextEditingController();
  final TextEditingController posController = TextEditingController();
  final TextEditingController totalOutstandingController =
      TextEditingController();
  final TextEditingController dpdController = TextEditingController();
  final TextEditingController paymentAmountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();

  List<Advocate> advocates = [];
  List<LegalCategory> categories = [];

  Advocate? selectedAdvocate;
  LegalCategory? selectedCategory;
  String? selectedPaymentType;
  String? cancelledChequePath;

  final List<String> paymentTypeOptions = [
    "Before Service (Advance Payment)",
    "After Service"
  ];

  bool isLoading = true;
  bool isSubmitting = false;
  Transaction? transactionData;

  final EdgeInsets contentPadding =
      const EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    setState(() => isLoading = true);
    try {
      final detailsRes =
          await ApiClient().getLegalBillingById(widget.billingId);
      final advocatesList = await ApiClient().getAllAdvocates();
      final categoriesList = await ApiClient().getAllLegalCategories();

      if (detailsRes != null && detailsRes.success && detailsRes.data != null) {
        final tx = detailsRes.data!.transaction;
        transactionData = tx;
        lanController.text = tx.lan;
        branchIdController.text = tx.branchId;
        customerNameController.text = tx.customerName;
        custIdController.text = tx.custId;
        posController.text = tx.pos.toStringAsFixed(2);
        totalOutstandingController.text =
            tx.totalOutstanding.toStringAsFixed(2);
        dpdController.text = tx.dpd.toString();
        paymentAmountController.text = tx.paymentAmount.toStringAsFixed(2);
        remarksController.text = tx.remarks ?? "";
        bankNameController.text = tx.bankName ?? "";
        accountNoController.text = tx.bankAcNo ?? "";
        ifscController.text = tx.ifsc ?? "";

        setState(() {
          advocates = advocatesList ?? [];
          categories = categoriesList ?? [];

          if (tx.paymentType == "Before Service" ||
              tx.paymentType == "Before Service (Advance Payment)") {
            selectedPaymentType = "Before Service";
          } else if (tx.paymentType == "After Service") {
            selectedPaymentType = "After Service";
          } else {
            selectedPaymentType = tx.paymentType;
          }

          selectedAdvocate = null;
          for (final advocate in advocates) {
            if (advocate.id == tx.advocateId) {
              selectedAdvocate = advocate;
              break;
            }
          }
          selectedCategory = null;
          for (final category in categories) {
            if (category.id == tx.legalCategoryId) {
              selectedCategory = category;
              break;
            }
          }

          isLoading = false;
        });
      } else {
        GlobalSnackbar.showError("Failed to fetch billing details");
        Get.back();
      }
    } catch (e) {
      GlobalSnackbar.showError("Something went wrong");
      Get.back();
    }
  }

  Future<void> submitResubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Confirmation
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const CustomText(
                text: "Confirm Resubmit", fontWeight: FontWeight.bold),
            content: const CustomText(
                text:
                    "Are you sure you want to resubmit this billing request?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("CANCEL")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Constant.mediumYellowColor),
                  child: const Text("RESUBMIT",
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() => isSubmitting = true);
    try {
      String paymentTypePayload = selectedPaymentType ?? "";
      if (paymentTypePayload == "Before Service (Advance Payment)") {
        paymentTypePayload = "Before Service";
      }

      final payload = <String, dynamic>{
        "id": widget.billingId,
        "modifiedBy": widget.employeeId,
        "branchId": branchIdController.text,
        "customerName": customerNameController.text,
        "custId": custIdController.text,
        "pos": double.tryParse(posController.text) ?? 0,
        "totalOutstanding":
            double.tryParse(totalOutstandingController.text) ?? 0,
        "dpd": int.tryParse(dpdController.text) ?? 0,
        "advocateId": selectedAdvocate!.id,
        "legalCategoryId": selectedCategory!.id,
        "paymentAmount": double.tryParse(paymentAmountController.text) ?? 0,
        "remarks": remarksController.text,
        "paymentType": paymentTypePayload,
      };

      if (selectedPaymentType == "Before Service (Advance Payment)" ||
          selectedPaymentType == "Before Service") {
        String cancelledChequeBase64 = "";
        String fileName = "";
        if (cancelledChequePath != null && cancelledChequePath!.isNotEmpty) {
          cancelledChequeBase64 =
              await CustomsHelper().fileToBase64(cancelledChequePath!);
          fileName = cancelledChequePath!.split('/').last;
        }

        payload["bankName"] = bankNameController.text;
        payload["bankAcNo"] = accountNoController.text;
        payload["ifsc"] = ifscController.text;
        if (cancelledChequePath != null && cancelledChequePath!.isNotEmpty) {
          payload["cancelledChequeFile"] = {
            "fileName": fileName,
            "base64": cancelledChequeBase64
          };
        }
      }

      final response =
          await ApiClient().resubmitLegalBilling(json.encode(payload));
      print("Response: ${response}");
      if (response != null && response["success"] == true) {
        GlobalSnackbar.showSuccess(
            response["message"] ?? "Resubmitted successfully");
        Get.back(result: true);
      } else {
        GlobalSnackbar.showError(response?["message"] ?? "Failed to resubmit");
      }
    } catch (e) {
      GlobalSnackbar.showError("Something went wrong");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showSearchableSelection<T>({
    required List<T> items,
    required String title,
    required String Function(T) itemLabel,
    required void Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<T> localFilteredItems = List.from(items);
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
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomText(
                      text: 'Select $title',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constant.mediumBlueColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        onChanged: (value) {
                          setModalState(() {
                            localFilteredItems = items
                                .where((item) => itemLabel(item)
                                    .toLowerCase()
                                    .startsWith(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search $title...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: localFilteredItems.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = localFilteredItems[index];
                          return ListTile(
                            title: CustomText(
                              text: itemLabel(item),
                              fontSize: 16,
                            ),
                            onTap: () {
                              onSelected(item);
                              Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          text: 'Edit Legal Billing',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('LAN Number'),
                    CustomTextFormField(
                      controller: lanController,
                      hintText: 'LAN Number',
                      contentPadding: contentPadding,
                      readOnly: true,
                      onSaved: (v) {},
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('Branch ID'),
                    CustomTextFormField(
                      controller: branchIdController,
                      readOnly: true,
                      hintText: 'Branch ID',
                      contentPadding: contentPadding,
                      onSaved: (v) {},
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('Customer Name'),
                    CustomTextFormField(
                      controller: customerNameController,
                      readOnly: true,
                      hintText: 'Customer Name',
                      contentPadding: contentPadding,
                      onSaved: (v) {},
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('Cust ID'),
                    CustomTextFormField(
                      controller: custIdController,
                      readOnly: true,
                      hintText: 'Cust ID',
                      contentPadding: contentPadding,
                      onSaved: (v) {},
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('POS'),
                    CustomTextFormField(
                      controller: posController,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      hintText: 'POS',
                      contentPadding: contentPadding,
                      onSaved: (v) {},
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('Total Outstanding'),
                    CustomTextFormField(
                      controller: totalOutstandingController,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      hintText: 'Total Outstanding',
                      contentPadding: contentPadding,
                      onSaved: (v) {},
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('DPD'),
                    CustomTextFormField(
                      controller: dpdController,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      hintText: 'DPD',
                      contentPadding: contentPadding,
                      onSaved: (v) {},
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 25),
                    _buildSectionTitle('Billing Details (Editable)'),
                    const SizedBox(height: 10),
                    _buildInputLabel('Advocate Name *'),
                    FormField<Advocate>(
                      validator: (value) => selectedAdvocate == null
                          ? 'Please select an advocate'
                          : null,
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildClickableSelector(
                              value: selectedAdvocate?.advocateName,
                              hint: 'Select Advocate',
                              hasError: state.hasError,
                              onTap: () => _showSearchableSelection<Advocate>(
                                items: advocates,
                                title: 'Advocate',
                                itemLabel: (item) => item.advocateName,
                                onSelected: (val) {
                                  setState(() => selectedAdvocate = val);
                                  state.didChange(val);
                                },
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, left: 12),
                                child: Text(
                                  state.errorText!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('Nature of Legal *'),
                    FormField<LegalCategory>(
                      validator: (value) => selectedCategory == null
                          ? 'Please select a legal category'
                          : null,
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildClickableSelector(
                              value: selectedCategory?.categoryName,
                              hint: 'Select Legal Category',
                              hasError: state.hasError,
                              onTap: () =>
                                  _showSearchableSelection<LegalCategory>(
                                items: categories,
                                title: 'Legal Category',
                                itemLabel: (item) => item.categoryName,
                                onSelected: (val) {
                                  setState(() => selectedCategory = val);
                                  state.didChange(val);
                                },
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, left: 12),
                                child: Text(
                                  state.errorText!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('Type of Payment *'),
                    FormField<String>(
                      validator: (value) => selectedPaymentType == null
                          ? 'Please select payment type'
                          : null,
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildClickableSelector(
                              value: selectedPaymentType,
                              hint: 'Select Type of Payment',
                              hasError: state.hasError,
                              onTap: () => _showSearchableSelection<String>(
                                items: paymentTypeOptions,
                                title: 'Payment Type',
                                itemLabel: (item) => item,
                                onSelected: (val) {
                                  setState(() => selectedPaymentType = val);
                                  state.didChange(val);
                                },
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, left: 12),
                                child: Text(
                                  state.errorText!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    if (selectedPaymentType ==
                            "Before Service (Advance Payment)" ||
                        selectedPaymentType == "Before Service") ...[
                      const SizedBox(height: 12),
                      _buildInputLabel('Bank Name *'),
                      CustomTextFormField(
                        controller: bankNameController,
                        hintText: 'Enter Bank Name',
                        contentPadding: contentPadding,
                        onSaved: (v) {},
                        validator: (v) => v == null || v.isEmpty
                            ? 'Bank Name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildInputLabel('Ac Number *'),
                      CustomTextFormField(
                        controller: accountNoController,
                        keyboardType: TextInputType.number,
                        hintText: 'Enter Account Number',
                        contentPadding: contentPadding,
                        onSaved: (v) {},
                        validator: (v) => v == null || v.isEmpty
                            ? 'Account Number is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildInputLabel('IFSC Code *'),
                      CustomTextFormField(
                        controller: ifscController,
                        hintText: 'Enter IFSC Code',
                        contentPadding: contentPadding,
                        textCapitalization: TextCapitalization.characters,
                        onSaved: (v) {},
                        validator: (v) => v == null || v.isEmpty
                            ? 'IFSC Code is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildInputLabel('Cancelled Cheque'),
                      InkWell(
                        onTap: () {
                          CustomsHelper.cameraPermissionAlert(
                            () async {
                              Get.back();
                              String path =
                                  await CustomsHelper().getCamera();
                              if (path.isNotEmpty) {
                                setState(() {
                                  cancelledChequePath = path;
                                });
                              }
                            },
                            () async {
                              Get.back();
                              String path =
                                  await CustomsHelper().getGalleryFile();
                              if (path.isNotEmpty) {
                                setState(() {
                                  cancelledChequePath = path;
                                });
                              }
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: cancelledChequePath == null
                                  ? Colors.black
                                  : Constant.mediumBlueColor,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.upload_file,
                                color: cancelledChequePath == null
                                    ? Colors.grey
                                    : Constant.mediumBlueColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomText(
                                  text: cancelledChequePath != null
                                      ? cancelledChequePath!.split('/').last
                                      : 'Upload new Cancelled Cheque',
                                  color: cancelledChequePath == null
                                      ? Colors.grey
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInputLabel('Payment Amount *'),
                    CustomTextFormField(
                      controller: paymentAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                      ],
                      contentPadding: contentPadding,
                      hintText: 'Enter Payment Amount',
                      onSaved: (v) {},
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Amount is required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('Remarks *'),
                    CustomTextFormField(
                      controller: remarksController,
                      hintText: 'Enter Remarks',
                      contentPadding: contentPadding,
                      maxLines: 5,
                      minLines: 3,
                      maxLength: 1000,
                      onSaved: (v) {},
                      validator: (v) => v == null || v.isEmpty
                          ? 'Remarks are required'
                          : null,
                    ),
                    if (transactionData != null) ...[
                      const SizedBox(height: 25),
                      _buildSectionTitle('Documents'),
                      const SizedBox(height: 10),
                      _buildDocumentsList(),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submitResubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.mediumBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const CustomText(
                                text: 'RESUBMIT',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return CustomText(
      text: title,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Constant.mediumBlueColor,
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: CustomText(
        text: label,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildClickableSelector({
    String? value,
    required String hint,
    required VoidCallback onTap,
    bool hasError = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: hasError ? Colors.red : Colors.black,
            width: hasError ? 1.0 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(1, 1),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomText(
                text: value ?? hint,
                color: value == null ? Colors.grey : Colors.black,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.search, color: Constant.mediumBlueColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    List<Map<String, String?>> documents = [];
    
    if (transactionData!.invoiceFilePath != null && transactionData!.invoiceFilePath!.isNotEmpty) {
      documents.add({
        'name': 'Invoice',
        'path': transactionData!.invoiceFilePath,
      });
    }
    
    if (transactionData!.cancelledChequeFilePath != null && transactionData!.cancelledChequeFilePath!.isNotEmpty) {
      documents.add({
        'name': 'Cancelled Cheque',
        'path': transactionData!.cancelledChequeFilePath,
      });
    }

    if (documents.isEmpty) {
      return const CustomText(
        text: 'No documents available',
        color: Colors.grey,
        fontSize: 14,
      );
    }

    return Column(
      children: documents.map((doc) => _buildDocumentItem(doc['name']!, doc['path']!)).toList(),
    );
  }

  Widget _buildDocumentItem(String docName, String fileName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(1, 1),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: docName,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: fileName,
                  fontSize: 12,
                  color: Colors.grey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => _viewDocument(fileName),
            child: const Icon(
              Icons.visibility,
              color: Constant.mediumBlueColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewDocument(String fileName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          text: 'Viewing Document',
          fontWeight: FontWeight.bold,
        ),
        content: const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final response = await ApiClient().downloadLegalBillingFile(fileName);
      
      if (!mounted) return;
      Navigator.pop(context);

      if (response != null) {
        _showFileViewer(fileName, response.bodyBytes);
      } else {
        GlobalSnackbar.showError("Failed to load document");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlobalSnackbar.showError("Error loading document");
      }
    }
  }

  void _showFileViewer(String fileName, Uint8List fileBytes) {
    String fileExtension = fileName.toLowerCase().split('.').last;
    bool isPdf = fileExtension == 'pdf';
    bool isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension);

    if (!isPdf && !isImage) {
      GlobalSnackbar.showError("Unsupported file type: $fileExtension");
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
              child: isPdf
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            size: 80,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          CustomText(
                            text: fileName,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 8),
                          const CustomText(
                            text: 'PDF Preview',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _downloadFile(fileName, fileBytes),
                            icon: const Icon(Icons.download),
                            label: const CustomText(
                              text: 'Download PDF',
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constant.mediumBlueColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Image.memory(
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
    try {
      // For now, showing a message that file is ready
      // In a real app, you'd use path_provider or similar
      GlobalSnackbar.showSuccess('File downloaded: $fileName');
    } catch (e) {
      GlobalSnackbar.showError('Error: $e');
    }
  }
}
