import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key, required this.label, this.hint, this.controller, this.validator, this.keyboardType,
    this.obscureText = false, this.prefixIcon, this.suffixIcon, this.maxLines = 1,
    this.inputFormatters, this.onChanged, this.enabled = true, this.readOnly = false, this.onTap, this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, validator: validator, keyboardType: keyboardType, obscureText: obscureText,
          maxLines: maxLines, inputFormatters: inputFormatters, onChanged: onChanged, enabled: enabled,
          readOnly: readOnly, onTap: onTap, focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]), prefixIcon: prefixIcon, suffixIcon: suffixIcon,
            filled: true, fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final String? hint;
  final bool enabled;
  final VoidCallback? onAddNew;

  const CustomDropdown({
    super.key, required this.label, this.value, required this.items, this.onChanged,
    this.validator, this.prefixIcon, this.hint, this.enabled = true, this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<T>(
                value: value, items: items, onChanged: enabled ? onChanged : null, validator: validator,
                decoration: InputDecoration(
                  hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]), prefixIcon: prefixIcon,
                  filled: true, fillColor: enabled ? Colors.white : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                icon: const Icon(Icons.keyboard_arrow_down), isExpanded: true,
              ),
            ),
            if (onAddNew != null) ...[
              const SizedBox(width: 8),
              IconButton(onPressed: onAddNew, icon: const Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9), foregroundColor: AppColors.textSecondary)),
            ],
          ],
        ),
      ],
    );
  }
}

class CustomNumberField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double? minValue;
  final int decimalPlaces;
  final void Function(double?)? onChanged;
  final bool enabled;

  const CustomNumberField({
    super.key, required this.label, this.hint, this.controller, this.validator,
    this.minValue, this.decimalPlaces = 2, this.onChanged, this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label, hint: hint, controller: controller, enabled: enabled,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return 'Este campo es requerido';
        final numValue = double.tryParse(value);
        if (numValue == null) return 'Ingresa un numero valido';
        if (minValue != null && numValue < minValue!) return 'El valor minimo es $minValue';
        return null;
      },
      keyboardType: TextInputType.numberWithOptions(decimal: decimalPlaces > 0),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(decimalPlaces > 0 ? r'^\d*\.?\d{0,2}' : r'^\d*'))],
      onChanged: (value) { if (onChanged != null) onChanged!(double.tryParse(value)); },
    );
  }
}

class CustomDateField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final DateTime? initialDate;
  final String? Function(String?)? validator;
  final void Function(DateTime?)? onDateSelected;

  const CustomDateField({super.key, required this.label, this.controller, this.initialDate, this.validator, this.onDateSelected});

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context, initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime(2100), locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      controller?.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(label: label, controller: controller, validator: validator, readOnly: true,
      onTap: () => _selectDate(context), prefixIcon: const Icon(Icons.calendar_today, size: 20));
  }
}

class ColorPickerField extends StatelessWidget {
  final String label;
  final Color selectedColor;
  final void Function(Color) onColorChanged;

  const ColorPickerField({super.key, required this.label, required this.selectedColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showColorPicker(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(width: 32, height: 32, decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!))),
                const SizedBox(width: 12),
                Text('#${selectedColor.value.toRadixString(16).toUpperCase().substring(2)}', style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
                const Spacer(),
                const Icon(Icons.colorize, size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: _SimpleColorPicker(pickerColor: selectedColor, onColorChanged: onColorChanged),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }
}

class _SimpleColorPicker extends StatelessWidget {
  final Color pickerColor;
  final void Function(Color) onColorChanged;
  static const List<Color> _colors = [Colors.red, Colors.pink, Colors.purple, Colors.deepPurple, Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan, Colors.teal, Colors.green, Colors.lightGreen, Colors.lime, Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange, Colors.brown, Colors.grey, Colors.blueGrey, Colors.black];

  const _SimpleColorPicker({required this.pickerColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: _colors.map((color) {
      final isSelected = color.value == pickerColor.value;
      return GestureDetector(
        onTap: () => onColorChanged(color),
        child: Container(width: 40, height: 40,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle,
            border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
            boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)] : null),
          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null),
      );
    }).toList());
  }
}
