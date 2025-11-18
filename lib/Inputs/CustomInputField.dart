import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? suffixText;
  final AutovalidateMode? autovalidateMode;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final Widget? prefixIcon;
  final String? prefixText;
  final String? hintText;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final bool showClearIcon;
  final VoidCallback? onClear;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.validator,
    this.readOnly = false,
    this.autovalidateMode,
    this.suffixIcon,
    this.suffixText,
    this.minLines,
    this.maxLines,
    this.prefixIcon,
    this.prefixText,
    this.hintText,
    this.obscureText = false,
    this.onSubmitted,
    this.onChanged,
    this.showClearIcon = false,
    this.onClear,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_textListener);
  }

  void _textListener() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener);
    super.dispose();
  }

  void _handleClear() {
    widget.controller.clear();
    widget.onChanged?.call(""); // Trigger search/filter reset
    widget.onClear?.call(); // Optional external callback
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
            ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          readOnly: widget.readOnly,
          obscureText: widget.obscureText,
          autovalidateMode: widget.autovalidateMode,
          minLines: widget.minLines,
          maxLines: widget.maxLines ?? 1,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            prefixText: widget.prefixText,
            suffixIcon: widget.showClearIcon && _hasText
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _handleClear,
                  )
                : widget.suffixIcon,
            suffixText: widget.suffixText,
            filled: true,
            fillColor: Colors.white,
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
          ),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}
