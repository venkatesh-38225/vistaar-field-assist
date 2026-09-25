import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/utils/constant.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

class CustomConfirmDialog extends StatefulWidget {
  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.highlightItems,
    this.confirmText = 'Submit & Proceed',
    this.cancelText = 'Cancel',
    this.icon = Icons.help_outline_rounded,
    this.iconColor = const Color(0xFFFFA000),
    this.iconBackgroundColor = const Color(0xFFFFF3E0),
    this.confirmButtonColor = Constant.mediumBlueColor,
    this.confirmIcon = Icons.check_circle_outline_rounded,
    this.showInputField = false,
    this.inputLabel = 'Comments',
    this.inputHint = 'Enter Comments...',
    this.isInputRequired = false,
    this.inputController,
    this.inputValidationErrorMessage = 'Please enter Comments',
    this.inputMaxLines = 3,
    this.inputMinLines = 2,
  });

  final String title;
  final String message;
  final Map<String, String>? highlightItems;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color confirmButtonColor;
  final IconData? confirmIcon;
  final bool showInputField;
  final String inputLabel;
  final String inputHint;
  final bool isInputRequired;
  final TextEditingController? inputController;
  final String inputValidationErrorMessage;
  final int inputMaxLines;
  final int inputMinLines;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    Map<String, String>? highlightItems,
    String confirmText = 'Submit & Proceed',
    String cancelText = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
    Color iconColor = const Color(0xFFFFA000),
    Color iconBackgroundColor = const Color(0xFFFFF3E0),
    Color confirmButtonColor = Constant.mediumBlueColor,
    IconData? confirmIcon = Icons.check_circle_outline_rounded,
    bool showInputField = false,
    String inputLabel = 'Comments',
    String inputHint = 'Enter Comments...',
    bool isInputRequired = false,
    TextEditingController? inputController,
    String inputValidationErrorMessage = 'Please enter Comments',
    int inputMaxLines = 3,
    int inputMinLines = 2,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Confirmation',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return CustomConfirmDialog(
          title: title,
          message: message,
          highlightItems: highlightItems,
          confirmText: confirmText,
          cancelText: cancelText,
          icon: icon,
          iconColor: iconColor,
          iconBackgroundColor: iconBackgroundColor,
          confirmButtonColor: confirmButtonColor,
          confirmIcon: confirmIcon,
          showInputField: showInputField,
          inputLabel: inputLabel,
          inputHint: inputHint,
          isInputRequired: isInputRequired,
          inputController: inputController,
          inputValidationErrorMessage: inputValidationErrorMessage,
          inputMaxLines: inputMaxLines,
          inputMinLines: inputMinLines,
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curvedValue = Curves.easeOutBack.transform(anim.value);
        return Transform.scale(
          scale: curvedValue.clamp(0.85, 1.0),
          child: Opacity(
            opacity: anim.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CustomConfirmDialog> createState() => _CustomConfirmDialogState();
}

class _CustomConfirmDialogState extends State<CustomConfirmDialog> {
  late final TextEditingController _controller;
  bool _isInternalController = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.inputController != null) {
      _controller = widget.inputController!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onConfirm() {
    if (widget.showInputField && widget.isInputRequired) {
      final text = _controller.text.trim();
      if (text.isEmpty) {
        setState(() {
          _errorMessage = widget.inputValidationErrorMessage;
        });
        return;
      }
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Circular Icon Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: widget.iconBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.iconColor.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),

              // Title
              CustomText(
                text: widget.title,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF102F54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Highlight Container (if provided)
              if (widget.highlightItems != null &&
                  widget.highlightItems!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6FB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD6E4F5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.highlightItems!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Color(0xFF102F54),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            CustomText(
                              text: '${entry.key}: ',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF102F54),
                            ),
                            Expanded(
                              child: CustomText(
                                text: entry.value,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Message / Explanation
              CustomText(
                text: widget.message,
                fontSize: 13,
                color: Colors.black87,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Input Field (Comments) if enabled
              if (widget.showInputField) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text: widget.inputLabel,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF102F54),
                        ),
                        if (widget.isInputRequired)
                          const Text(
                            ' *',
                            style: TextStyle(
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        else
                          Text(
                            ' (Optional)',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _controller,
                      minLines: widget.inputMinLines,
                      maxLines: widget.inputMaxLines,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      onChanged: (val) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: widget.inputHint,
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFFD6E4F5),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFFD6E4F5),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? const Color(0xFFD32F2F)
                                : Constant.mediumBlueColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFD32F2F),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CustomText(
                              text: _errorMessage!,
                              fontSize: 11,
                              color: const Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ] else ...[
                const SizedBox(height: 6),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          widget.cancelText,
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.confirmButtonColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: _onConfirm,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.confirmText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.confirmIcon != null) ...[
                              const SizedBox(width: 6),
                              Icon(
                                widget.confirmIcon,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
