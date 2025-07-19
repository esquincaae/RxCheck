import 'package:flutter/material.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? icon;
  final bool isDisabled;
  final bool readOnly;
  final bool toUpperCase;
  final filled = false;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.validator,
    this.icon,
    this.isDisabled = false,
    this.readOnly = false,
    this.toUpperCase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        textCapitalization:
        toUpperCase ? TextCapitalization.characters : TextCapitalization.none,
        onChanged: toUpperCase
            ? (value) {
          final upperText = value.toUpperCase();
          if (value != upperText) {
            controller.value = controller.value.copyWith(
              text: upperText,
              selection: TextSelection.collapsed(offset: upperText.length),
            );
          }
        }
            : null,
        readOnly: isDisabled || readOnly,
        enableInteractiveSelection: !(isDisabled || readOnly),
        focusNode: (isDisabled || readOnly) ? AlwaysDisabledFocusNode() : null,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
          labelText: label,
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          filled: true,
          fillColor: isDisabled ? Colors.grey.shade200 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Color(0xFFE0E3E7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}
