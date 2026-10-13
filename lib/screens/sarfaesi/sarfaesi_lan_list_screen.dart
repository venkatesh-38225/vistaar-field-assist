import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:re_kyc_mobile_app/screens/sarfaesi/create_sarfaesi_screen.dart';
import 'package:re_kyc_mobile_app/service/api_client.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class SarfaesiLanListScreen extends StatefulWidget {
  const SarfaesiLanListScreen({
    super.key,
    required this.employeeId,
    required this.branchCode,
  });

  final String employeeId;
  final String branchCode;

  @override
  State<SarfaesiLanListScreen> createState() => _SarfaesiLanListScreenState();
}

class _SarfaesiLanItem {
  final String lan;
  final String custName;
  final String category;

  _SarfaesiLanItem({
    required this.lan,
    required this.custName,
    this.category = '',
  });
}

class _SarfaesiLanListScreenState extends State<SarfaesiLanListScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<_SarfaesiLanItem> lanItems = [];
  List<_SarfaesiLanItem> filteredLanItems = [];

  @override
  void initState() {
    super.initState();
    fetchMappedLans();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.trim().toLowerCase();
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        filteredLanItems = List.from(lanItems);
      } else {
        filteredLanItems = lanItems.where((item) {
          return item.lan.toLowerCase().contains(query) ||
              item.custName.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchMappedLans() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final data = await ApiClient().getMappedLansWithDetails(
        widget.employeeId,
        sectionCode: '13_4',
      );
      if (!mounted) return;

      if (data != null && data.isNotEmpty) {
        final items = data
            .map((map) => _SarfaesiLanItem(
                  lan: map['lan'] ?? '',
                  custName: map['customerName'] ?? map['custName'] ?? '',
                  category: map['category'] ?? '',
                ))
            .where((item) => item.lan.isNotEmpty)
            .toList();

        setState(() {
          lanItems = items;
          _onSearchChanged();
          isLoading = false;
        });
      } else {
        setState(() {
          lanItems = [];
          filteredLanItems = [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      GlobalSnackbar.showError('Error fetching mapped LANs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Constant.mediumBlueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          text: 'Available LANs',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchMappedLans,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search LAN, Customer, or Category...',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Constant.lightBlueColor,
                        ),
                      )
                    : filteredLanItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                CustomText(
                                  text: 'No Available LANs Found',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredLanItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredLanItems[index];
                              return _buildLanCard(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanCard(_SarfaesiLanItem item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () async {
          final result = await Get.to(() => CreateSarfaesiScreen(
                employeeId: widget.employeeId,
                branchCode: widget.branchCode,
                initialLan: item.lan,
                initialCategory: item.category,
              ));
          if (result == true) {
            Get.back(result: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Constant.mediumBlueColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.file_copy,
                  color: Constant.mediumBlueColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: item.lan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Constant.mediumBlueColor,
                    ),
                    if (item.custName.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CustomText(
                              text: item.custName,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.category.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CustomText(
                              text: 'Category: ${item.category}',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
