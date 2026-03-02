import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../../constants/constants.dart';

class NuevoCatalogoDialog extends StatefulWidget {
  final String tipo;
  const NuevoCatalogoDialog({super.key, required this.tipo});

  @override
  State<NuevoCatalogoDialog> createState() => _NuevoCatalogoDialogState();
}

class _NuevoCatalogoDialogState extends State<NuevoCatalogoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  Color _selectedColor = const Color(0xFF3B82F6);
  bool _isLoading = false;
  bool get _showColorPicker => widget.tipo == 'sucursal' || widget.tipo == 'color';

  @override
  void dispose() { _nombreController.dispose(); super.dispose(); }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      Navigator.of(context).pop({
        'nombre': _nombreController.text.trim(),
        'color': '#${_selectedColor.value.toRadixString(16).toUpperCase().substring(2)}',
      });
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return FormModal(
      title: 'Agregar ${widget.tipo == 'empresa' ? 'Empresa' : widget.tipo == 'sucursal' ? 'Sucursal' : widget.tipo == 'color' ? 'Color' : 'Tipo de Tela'}',
      formKey: _formKey, isLoading: _isLoading, onSave: _guardar,
      onCancel: () => Navigator.of(context).pop(),
      formContent: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(label: 'Nombre *', controller: _nombreController, hint: 'Ingresa el nombre',
            validator: (v) => v == null || v.trim().isEmpty ? AppStrings.ingreseNombre : null),
          if (_showColorPicker) ...[
            const SizedBox(height: 16),
            ColorPickerField(label: 'Color', selectedColor: _selectedColor, onColorChanged: (c) => setState(() => _selectedColor = c)),
          ],
        ],
      ),
    );
  }
}
