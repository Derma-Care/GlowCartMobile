import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T? value; // Change to nullable type
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool readOnly;
  final IconData? icon;
  final AutovalidateMode? autovalidateMode;

  const CustomDropdownField({
    Key? key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.readOnly = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonFormField<T>(
          value: value, // No need to check for null here
          autovalidateMode: autovalidateMode,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.primaryColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            prefixIcon:
                icon != null ? Icon(icon, color: theme.primaryColor) : null,
          ),
          dropdownColor: theme.cardColor,
          icon:
              const Icon(Icons.arrow_drop_down, color: Colors.black, size: 28),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          items: items,
          onChanged: readOnly ? null : onChanged,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 300,
          validator: validator,
        ),
      ),
    );
  }
}
