import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/legal_masters.dart';
import 'package:re_kyc_mobile_app/models/foreclosure_details_response.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/widgets/custom_textform_field.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/utils/helper.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class CreateLegalBillingScreen extends StatefulWidget {
  const CreateLegalBillingScreen({
    super.key,
    required this.employeeId,
    required this.branchCode,
  });

  final String employeeId;
  final String branchCode;

  @override
  State<CreateLegalBillingScreen> createState() =>
      _CreateLegalBillingScreenState();
}

class _CreateLegalBillingScreenState extends State<CreateLegalBillingScreen> {
  final _formKey = GlobalKey<FormState>();
  late FocusNode lanFocusNode;

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

  bool isMastersLoading = false;
  bool isSubmitting = false;
  bool isLanSearching = false;
  bool isDetailsFetched = false;

  final EdgeInsets contentPadding =
      const EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  @override
  void initState() {
    super.initState();
    lanFocusNode = FocusNode();
    fetchMasters();
  }

  Future<void> fetchMasters() async {
    setState(() {
      isMastersLoading = true;
    });

    try {
      final advocatesList = await ApiClient().getAllAdvocates();
      final categoriesList = await ApiClient().getAllLegalCategories();

      setState(() {
        advocates = advocatesList ?? [];
        categories = categoriesList ?? [];
        isMastersLoading = false;
      });
    } catch (e) {
      setState(() {
        isMastersLoading = false;
      });
      GlobalSnackbar.showError("Failed to load master data");
    }
  }

  Future<void> searchLanDetails() async {
    lanFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    final lan = lanController.text.trim();
    if (lan.isEmpty) {
      GlobalSnackbar.showError("Please enter LAN number");
      return;
    }
    setState(() {
      isLanSearching = true;
    });
    try {
      final response = await ApiClient().getLanNoticeDetails(lan);
      final foreClosureResponse = await ApiClient().getForeClosureDetails(lan);

      if (response != null && response.fullName != null) {
        setState(() {
          customerNameController.text = response.fullName ?? "";
          branchIdController.text = response.branch?.branchCode ?? "";
          posController.text = foreClosureResponse?.pos?.toString() ?? "0";
          custIdController.text = response.custId ?? "";
          totalOutstandingController.text =
              foreClosureResponse?.totalOutstanding ?? "";
          dpdController.text = response.dpd ?? "";
          isDetailsFetched = true;
          isLanSearching = false;
        });
        // Ensure LAN field loses focus after search completes
        Future.delayed(Duration(milliseconds: 100), () {
          lanFocusNode.unfocus();
          FocusScope.of(context).unfocus();
        });
      } else {
        setState(() {
          isLanSearching = false;
          isDetailsFetched = false;
        });

        GlobalSnackbar.showError("No data found for this LAN");
      }
    } catch (e) {
      setState(() {
        isLanSearching = false;
        isDetailsFetched = false;
      });

      GlobalSnackbar.showError("Error fetching LAN details");
    }
  }

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    String paymentTypePayload = selectedPaymentType ?? "";
    if (paymentTypePayload == "Before Service (Advance Payment)") {
      paymentTypePayload = "Before Service";
    }

    final payload = <String, dynamic>{
      "lan": lanController.text,
      "branchId": branchIdController.text,
      "customerName": customerNameController.text,
      "custId": custIdController.text,
      "pos": double.tryParse(posController.text) ?? 0,
      "totalOutstanding": double.tryParse(totalOutstandingController.text) ?? 0,
      "dpd": int.tryParse(dpdController.text) ?? 0,
      "advocateId": selectedAdvocate!.id,
      "legalCategoryId": selectedCategory!.id,
      "paymentAmount":
          double.tryParse(paymentAmountController.text.replaceAll(',', '')) ??
              0,
      "createdBy": widget.employeeId,
      "remarks": remarksController.text,
      "paymentType": paymentTypePayload,
    };

    if (selectedPaymentType == "Before Service (Advance Payment)") {
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
      payload["cancelledChequeFile"] = {
        "fileName": fileName,
        "base64": cancelledChequeBase64
      };
    }

    try {
      final response =
          await ApiClient().createLegalBilling(json.encode(payload));

      if (response != null && response["success"] == true) {
        dynamic newIdValue;
        if (response["data"] != null) {
          if (response["data"] is Map) {
            newIdValue = response["data"]["newId"];
          } else {
            try {
              newIdValue = response["data"].newId;
            } catch (_) {}
          }
        }

        if (newIdValue?.toString() == "-2") {
          if (!mounted) return;
          bool confirm = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const CustomText(
                    text: "Confirmation",
                    fontWeight: FontWeight.bold,
                  ),
                  content: CustomText(
                    text: response["message"] ??
                        "A similar billing request already exists. Do you want to submit again?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("NO"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constant.mediumYellowColor,
                      ),
                      child: const Text(
                        "YES",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ) ??
              false;

          if (confirm) {
            payload["isRepeatRequest"] = true;
            final repeatResponse =
                await ApiClient().createLegalBilling(json.encode(payload));

            if (repeatResponse != null && repeatResponse["success"] == true) {
              GlobalSnackbar.showSuccess(
                  repeatResponse["message"] ?? "Request created successfully");
              Get.back(result: true);
            } else {
              GlobalSnackbar.showError(
                  repeatResponse?["message"] ?? "Failed to create request");
            }
          }
        } else {
          GlobalSnackbar.showSuccess(
              response["message"] ?? "Request created successfully");
          Get.back(result: true);
        }
      } else {
        GlobalSnackbar.showError(
            response?["message"] ?? "Failed to create request");
      }
    } catch (e) {
      GlobalSnackbar.showError("Something went wrong");
    } finally {
      setState(() {
        isSubmitting = false;
      });
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
          text: 'Create Legal Billing',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isMastersLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('LAN Search'),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: lanController,
                            focusNode: lanFocusNode,
                            hintText: 'Enter LAN',
                            contentPadding: contentPadding,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [UpperCaseTextFormatter()],
                            readOnly:
                                false, // LAN field stays editable as requested
                            onSaved: (v) {},
                            validator: (v) => v == null || v.isEmpty
                                ? 'LAN is required'
                                : null,
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
                    if (isDetailsFetched) ...[
                      const SizedBox(height: 10),
                      _buildInputLabel('Branch ID'),
                      CustomTextFormField(
                        controller: branchIdController,
                        readOnly: true,
                        hintText: 'Branch ID',
                        contentPadding: contentPadding,
                        onSaved: (v) {},
                        validator: (v) => v == null || v.isEmpty
                            ? 'Branch ID is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildInputLabel('Customer Name'),
                      CustomTextFormField(
                        controller: customerNameController,
                        readOnly: true,
                        hintText: 'Customer Name',
                        contentPadding: contentPadding,
                        onSaved: (v) {},
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildInputLabel('Cust ID'),
                      CustomTextFormField(
                        controller: custIdController,
                        readOnly: true,
                        hintText: 'Cust ID',
                        contentPadding: contentPadding,
                        onSaved: (v) {},
                        validator: (v) => v == null || v.isEmpty
                            ? 'Cust ID is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _buildInputLabel('POS'),
                      CustomTextFormField(
                        controller: posController,
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        hintText: 'POS',
                        contentPadding: contentPadding,
                        onSaved: (v) {},
                        validator: (v) =>
                            v == null || v.isEmpty ? 'POS is required' : null,
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
                        validator: (v) => v == null || v.isEmpty
                            ? 'Outstanding is required'
                            : null,
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
                        validator: (v) =>
                            v == null || v.isEmpty ? 'DPD is required' : null,
                      ),
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
                                    FocusScope.of(context).unfocus();
                                    setState(() => selectedAdvocate = val);
                                    print("Value: ${selectedAdvocate?.id}");
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
                                    FocusScope.of(context).unfocus();
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
                                    FocusScope.of(context).unfocus();
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
                          "Before Service (Advance Payment)") ...[
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(18),
                          ],
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
                        _buildInputLabel('Cancelled Cheque *'),
                        FormField<String>(
                          validator: (value) => cancelledChequePath == null ||
                                  cancelledChequePath!.isEmpty
                              ? 'Please upload cancelled cheque'
                              : null,
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                          state.didChange(path);
                                        }
                                      },
                                      () async {
                                        Get.back();
                                        String path = await CustomsHelper()
                                            .getGalleryFile();
                                        if (path.isNotEmpty) {
                                          setState(() {
                                            cancelledChequePath = path;
                                          });
                                          state.didChange(path);
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
                                        color: state.hasError
                                            ? Colors.red
                                            : (cancelledChequePath == null
                                                ? Colors.black
                                                : Constant.mediumBlueColor),
                                        width: state.hasError ? 1.0 : 0.5,
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
                                                ? cancelledChequePath!
                                                    .split('/')
                                                    .last
                                                : 'Upload Cancelled Cheque',
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
                      ],
                      const SizedBox(height: 12),
                      _buildInputLabel('Payment Amount *'),
                      CustomTextFormField(
                        controller: paymentAmountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          AmountInputFormatter(),
                        ],
                        contentPadding: contentPadding,
                        hintText: 'Enter Payment Amount',
                        onSaved: (v) {},
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Amount is required';
                          }
                          final amount = double.tryParse(v.replaceAll(',', ''));
                          if (amount == null) {
                            return 'Invalid amount';
                          }
                          if (amount > 9999999) {
                            return 'Amount cannot exceed 99,99,999 (9999999)';
                          }
                          return null;
                        },
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
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : submitRequest,
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
                                  text: 'SUBMIT',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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

  @override
  void dispose() {
    lanFocusNode.dispose();
    lanController.dispose();
    branchIdController.dispose();
    customerNameController.dispose();
    custIdController.dispose();
    posController.dispose();
    totalOutstandingController.dispose();
    dpdController.dispose();
    paymentAmountController.dispose();
    remarksController.dispose();
    bankNameController.dispose();
    accountNoController.dispose();
    ifscController.dispose();
    super.dispose();
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
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Only allow digits
    String value = newValue.text.replaceAll(',', '');

    // Limit to max amount of 9,999,999 (99,99,999 in Indian format - max lakhs)
    if (value.isNotEmpty) {
      final intValue = int.tryParse(value);
      if (intValue != null && intValue > 9999999) {
        // Revert to old value if exceeds max
        return oldValue;
      }
    }

    // Format with commas
    if (value.isEmpty) {
      return newValue.copyWith(text: '', selection: newValue.selection);
    }

    // Add comma formatting
    final formatted = _formatNumberWithCommas(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumberWithCommas(String text) {
    if (text.isEmpty) return '';

    // Remove any existing commas and take only digits
    final cleanText = text.replaceAll(',', '');

    if (cleanText.isEmpty) return '';

    // Format with commas (Indian style or standard)
    // Standard format: 1,000,000
    final buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      if (i > 0 && (cleanText.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(cleanText[i]);
    }

    return buffer.toString();
  }
}
