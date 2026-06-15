import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/abmTiposTelas/color_tela.dart';
import '../../../providers/color_provider.dart';
import 'color_picker_tabs.dart';

class ColorFormDialog extends ConsumerStatefulWidget {
  final String empresaId;
  final String usuarioId;
  final ColorTela? colorAEditar;

  const ColorFormDialog({
    super.key,
    required this.empresaId,
    required this.usuarioId,
    this.colorAEditar,
  });

  @override
  ConsumerState<ColorFormDialog> createState() => _ColorFormDialogState();
}

class _ColorFormDialogState extends ConsumerState<ColorFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late Color _colorSeleccionado;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(
      text: widget.colorAEditar?.nombre ?? '',
    );

    _colorSeleccionado = widget.colorAEditar != null
        ? widget.colorAEditar!.toFlutterColor
        : Colors.blue;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final hexString = _colorSeleccionado.value
          .toRadixString(16)
          .substring(2)
          .toUpperCase();

      await ref
          .read(coloresProvider(widget.empresaId).notifier)
          .guardarColor(
            id: widget.colorAEditar?.id,
            nombre: _nombreController.text.trim(),
            hexadecimal: hexString,
            usuarioId: widget.usuarioId,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.colorAEditar != null;
    final size = MediaQuery.of(context).size;
    final esWeb = size.width > 650;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            esEdicion ? Icons.colorize : Icons.add_circle,
            color: Colors.indigo,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(esEdicion ? 'Modificar Color' : 'Agregar Nuevo Color'),
          ),
        ],
      ),
      content: Container(
        // Ancho y alto adaptables según el dispositivo
        width: esWeb ? 550 : size.width * 0.95,
        height: esWeb ? 620 : size.height * 0.75,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Color',
                  hintText: 'Ej: Azul Marino',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Contenedor de las pestañas que toma el espacio restante de forma segura
              Expanded(
                child: ColorPickerTabs(
                  initialColor: _colorSeleccionado,
                  onColorChanged: (color) {
                    setState(() {
                      _colorSeleccionado = color;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _guardar,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(esEdicion ? Icons.save : Icons.add),
          label: Text(esEdicion ? 'Actualizar' : 'Guardar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
