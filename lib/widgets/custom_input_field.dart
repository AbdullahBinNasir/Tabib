import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isMultiline;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const CustomInputField({
    Key? key,
    required this.label,
    this.hint,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isMultiline = false,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: isMultiline ? 3 : 1,
          readOnly: readOnly,  // Use the readOnly parameter from constructor
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textColor.withOpacity(0.5),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}