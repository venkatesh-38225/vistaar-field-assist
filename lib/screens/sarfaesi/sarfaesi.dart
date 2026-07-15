import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/models/legal_billing_res.dart';
import 'package:re_kyc_mobile_app/models/profile_response.dart';
import 'package:re_kyc_mobile_app/models/sarfaesi_res.dart';
import 'package:re_kyc_mobile_app/screens/sarfaesi/create_sarfaesi_screen.dart';
import 'package:re_kyc_mobile_app/screens/sarfaesi/edit_sarfaesi_screen.dart';
import 'package:re_kyc_mobile_app/screens/sarfaesi/sarfaesi_management.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:intl/intl.dart';

/// Route observer used by [SarfaesiScreen] to auto-refresh when the screen
/// becomes active again. Register this in your MaterialApp's navigatorObservers.
final RouteObserver<PageRoute> sarfaesiRouteObserver =
    RouteObserver<PageRoute>();

class SarfaesiScreen extends StatefulWidget {
  const SarfaesiScreen({
    super.key,
    required this.profile,
    required this.access,
  });

  final ProfileResponse profile;
  final String access;

  @override
  State<SarfaesiScreen> createState() => _SarfaesiScreenState();
}

class _SarfaesiScreenState extends State<SarfaesiScreen> with RouteAware {
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<SarfaesiData> billingRecords = [];
  List<SarfaesiData> filteredRecords = [];

  String selectedStatus = "Completed";
  final List<String> statusOptions = ["Completed"];

  @override
  void initState() {
    super.initState();
    fetchData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe so we get notified when this screen becomes visible again
    // after popping back from create / edit / management screens.
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      sarfaesiRouteObserver.subscribe(this, route);
    }
  }

  /// Called when another route is popped and this screen is revealed.
  @override
  void didPopNext() {
    fetchData();
  }

  @override
  void dispose() {
    sarfaesiRouteObserver.unsubscribe(this);
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      filteredRecords = billingRecords.where((record) {
        final query = searchController.text.toLowerCase();
        return record.lan.toLowerCase().contains(query) ||
            record.customerName.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String userId = widget.profile.data?.employeeId ?? "";
      final String role = widget.profile.data?.role ?? "";

      final response = await ApiClient().getSarfaesiList(
        userId,
        selectedStatus == "In Progress" ? "inprogress" : selectedStatus,
        role,
      );

      if (response != null && response.success) {
        setState(() {
          billingRecords = response.data;
          filteredRecords = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          billingRecords = [];
          filteredRecords = [];
          isLoading = false;
        });
        GlobalSnackbar.showError(
            response?.message ?? "Failed to fetch records");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      GlobalSnackbar.showError("Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Image.asset(
                'assets/images/v_logo_white.png',
                height: 30,
                width: 30,
              ),
            ),
            const SizedBox(width: 10),
            const CustomText(
              text: 'SARFAESI 13(4)',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildStatusTabs(),
              // const SizedBox(height: 10),
              // Filters Section
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Search...',
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.access.toUpperCase() == "CREATE") ...[
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Get.to(() => CreateSarfaesiScreen(
                              employeeId: widget.profile.data?.employeeId ?? "",
                              branchCode: widget.profile.data?.branchCode ?? "",
                            ));
                        if (result == true) fetchData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constant.mediumYellowColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 20),
                      label: const CustomText(
                        text: 'Create',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Scroll down to refresh',
                    fontSize: 10,
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_downward_sharp,
                    size: 10,
                  )
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Constant.lightBlueColor,
                        ),
                      )
                    : filteredRecords.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 80,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                CustomText(
                                  text: 'No Records Found',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredRecords.length,
                            itemBuilder: (context, index) {
                              final record = filteredRecords[index];
                              return _buildBillingCard(record);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Row(
      children: statusOptions.map((status) {
        bool isSelected = selectedStatus == status;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (selectedStatus != status) {
                setState(() {
                  selectedStatus = status;
                });
                fetchData();
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Constant.mediumBlueColor : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected
                      ? Constant.mediumBlueColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: CustomText(
                  text: status,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBillingCard(SarfaesiData record) {
    String currentRole = widget.profile.data?.role?.toUpperCase() ?? "";

    bool canEdit = record.status.toLowerCase().contains("pending");

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Constant.lightBlueColor.withOpacity(0.1),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Constant.lightBlueColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: record.customerName,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      CustomText(
                        text: 'LAN: ${record.lan}',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ((record.status.toLowerCase() == "completed" ||
                                record.status
                                    .toLowerCase()
                                    .contains("approved"))
                            ? Colors.green
                            : record.status.toLowerCase().contains("rejected")
                                ? Colors.red
                                : Colors.orange)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomText(
                    text: record.status,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (record.status.toLowerCase() == "completed" ||
                            record.status.toLowerCase().contains("approved"))
                        ? Colors.green.shade700
                        : record.status.toLowerCase().contains("rejected")
                            ? Colors.red.shade700
                            : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.phone,
                    'Mobile',
                    record.mobile != null ? record.mobile : '-',
                  ),
                  const SizedBox(height: 5),
                  _buildInfoRow(
                    Icons.post_add_sharp,
                    'Possession',
                    record.isPossessionTaken == true ? "Yes" : 'No',
                  ),
                  SizedBox(height: record.isPossessionTaken == true ? 5 : 0),
                  if (record.isPossessionTaken == true)
                    _buildInfoRow(
                      Icons.calendar_month_outlined,
                      'Possession Date',
                      record.possessionDate != null
                          ? DateFormat('dd-MMM-yyyy')
                              .format(record.possessionDate!)
                          : 'N/A',
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 15, endIndent: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _navigateToManagement(record, false),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('VIEW'),
                  style: TextButton.styleFrom(
                      foregroundColor: Constant.mediumBlueColor),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToEdit(record),
                    icon: const Icon(Icons.edit_note_outlined,
                        size: 18, color: Colors.white),
                    label: const Text('EDIT',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToManagement(SarfaesiData record, bool isAction) async {
    final result = await Get.to(() => SarfaesiManagementScreen(
          billingId: record.id,
          profile: widget.profile,
          isAction: isAction,
        ));
    if (result == true) fetchData();
  }

  void _navigateToEdit(SarfaesiData record) async {
    final result = await Get.to(() => EditSarfaesiScreen(
          reqId: record.id,
          employeeId: widget.profile.data?.employeeId ?? "",
        ));
    if (result == true) fetchData();
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          CustomText(
            text: '$label: ',
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          Expanded(
            child: CustomText(
              text: value,
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
}
