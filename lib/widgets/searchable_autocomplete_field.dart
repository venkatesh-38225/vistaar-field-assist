import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/utils/global_snackbar.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class SearchableAutocompleteField<T> extends StatelessWidget {
  const SearchableAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.sheetTitle,
    this.searchHint,
    this.validator,
    this.isEnabled = true,
    this.isLoading = false,
    this.disabledMessage,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final List<T> items;
  final String Function(T item) itemLabel;
  final Function(T item) onSelected;
  final String? sheetTitle;
  final String? searchHint;
  final String? Function(String? value)? validator;
  final bool isEnabled;
  final bool isLoading;
  final String? disabledMessage;

  void _showSelectionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        var filtered = List<T>.from(items);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.95,
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomText(
                      text: sheetTitle ?? 'Select $label',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constant.mediumBlueColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: TextField(
                        autofocus: true,
                        onChanged: (query) {
                          setModalState(() {
                            filtered = items
                                .where((item) => itemLabel(item)
                                    .toLowerCase()
                                    .contains(query.trim().toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: searchHint ?? 'Search $label...',
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.blueGrey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No ${label.toLowerCase()} found',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 15),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final text = itemLabel(item);
                                final isSelected = controller.text
                                        .trim()
                                        .toLowerCase() ==
                                    text.trim().toLowerCase();
                                return ListTile(
                                  title: CustomText(
                                    text: text,
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Constant.mediumBlueColor,
                                        )
                                      : null,
                                  onTap: () {
                                    controller.text = text;
                                    onSelected(item);
                                    Navigator.pop(sheetContext);
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        controller: controller,
        validator: validator,
        onTap: () {
          if (isLoading) return;
          if (!isEnabled) {
            if (disabledMessage != null && disabledMessage!.isNotEmpty) {
              GlobalSnackbar.showError(disabledMessage!);
            }
            return;
          }
          _showSelectionSheet(context);
        },
        decoration: InputDecoration(
          label: Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[700]),
          filled: true,
          fillColor: isEnabled ? Colors.grey[200] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          suffixIcon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Constant.lightBlueColor,
                    ),
                  ),
                )
              : const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
        ),
      ),
    );
  }
}
