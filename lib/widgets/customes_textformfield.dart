import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.inputType,
    this.isMultiline,
    this.padding,
    this.onSaved,
    this.controller,
    this.validator,
    this.obscureText,
    this.textCapitalization,
    this.counterText,
    this.maxLength,
    this.isEnabled,
    this.autovalidateMode,
    this.onChanged,
    required this.label,
  });

  final String hint;
  final IconData icon;
  final TextInputType? inputType;
  final bool? isMultiline;
  final Function(String? value)? onSaved;
  final TextEditingController? controller;
  final String? Function(dynamic value)? validator;
  final bool? obscureText;
  final TextCapitalization? textCapitalization;
  final String? counterText;
  final int? maxLength;
  final String label;
  final bool? isEnabled;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;

  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        enabled: isEnabled,
        textInputAction: TextInputAction.next,
        obscureText: obscureText ?? false,
        controller: controller,
        onSaved: onSaved,
        onChanged: onChanged,
        autovalidateMode: autovalidateMode,
        maxLength: maxLength,
        textCapitalization: textCapitalization != null
            ? textCapitalization!
            : TextCapitalization.none,
        validator: validator,
        keyboardType: inputType ?? TextInputType.text,
        maxLines: (isMultiline ?? false) ? 2 : 1,
        decoration: InputDecoration(
            label: Text(
              label,
              style: TextStyle(color: Colors.grey[700]),
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[700]),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            prefixIcon: Padding(
                padding: padding != null
                    ? EdgeInsets.only(bottom: padding!)
                    : const EdgeInsets.all(0),
                child: Icon(icon, color: Colors.blueGrey)),
            counterText: counterText ?? ""),
      ),
    );
  }
}
