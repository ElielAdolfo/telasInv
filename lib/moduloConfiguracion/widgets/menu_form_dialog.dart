import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/moduloConfiguracion/providers/configuracion_provider.dart';
import 'package:inv_telas/providers/providers.dart'; // Asumiendo que tienes iconos ahí

class MenuFormDialog extends ConsumerStatefulWidget {
  final MenuApp? menu;
  const MenuFormDialog({super.key, required this.menu});

  @override
  ConsumerState<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends ConsumerState<MenuFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _rutaCtrl;
  late TextEditingController _iconoCtrl;
  late TextEditingController _ordenCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.menu?.nombre ?? '');
    _rutaCtrl = TextEditingController(text: widget.menu?.ruta ?? '/');
    _iconoCtrl = TextEditingController(text: widget.menu?.icono ?? 'inventory');
    _ordenCtrl = TextEditingController(
      text: (widget.menu?.ordenBase ?? 0).toString(),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newMenu = MenuApp(
      id: widget.menu?.id ?? '',
      nombre: _nombreCtrl.text,
      ruta: _rutaCtrl.text,
      icono: _iconoCtrl.text,
      ordenBase: int.tryParse(_ordenCtrl.text) ?? 0,
      activo: widget.menu?.activo ?? true,
      visible: true,
      eliminado: false,
    );

    try {
      await ref.read(menuAdminServiceProvider).saveMenu(newMenu);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.menu == null ? "Nuevo Menú" : "Editar Menú"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: _rutaCtrl,
                decoration: const InputDecoration(
                  labelText: "Ruta (ej: /inventario)",
                ),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: _iconoCtrl,
                decoration: const InputDecoration(
                  labelText: "Icono (ej: inventory, settings)",
                ),
              ),
              TextFormField(
                controller: _ordenCtrl,
                decoration: const InputDecoration(labelText: "Orden"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Guardar"),
        ),
      ],
    );
  }
}
