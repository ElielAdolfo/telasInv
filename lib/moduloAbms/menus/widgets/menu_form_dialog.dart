import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/moduloAbms/menus/icon_picker_dialog.dart';
import 'package:inv_telas/moduloAbms/menus/providers/menu_abm_provider.dart';
import 'package:inv_telas/utils/icon_mapper.dart';

class MenuFormDialog extends ConsumerStatefulWidget {
  final MenuApp? menu;

  const MenuFormDialog({super.key, this.menu});

  @override
  ConsumerState<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends ConsumerState<MenuFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _rutaCtrl;
  late TextEditingController _ordenCtrl;

  bool _activo = true;

  // 🔥 Icono seleccionado
  String _selectedIcon = 'help';
  bool get _iconoInvalido => _selectedIcon == 'help';

  @override
  void initState() {
    super.initState();

    final m = widget.menu;

    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');

    _rutaCtrl = TextEditingController(text: m?.ruta ?? '/');

    _ordenCtrl = TextEditingController(text: (m?.ordenBase ?? 0).toString());

    _activo = m?.activo ?? true;

    final savedIcon = m?.icono;

    final availableIcons = IconMapper.availableIcons;

    _selectedIcon = savedIcon != null && availableIcons.contains(savedIcon)
        ? savedIcon
        : 'help';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.menu == null ? 'Crear Menú' : 'Editar Menú'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ========================
                // NOMBRE
                // ========================
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                ),

                const SizedBox(height: 16),

                // ========================
                // RUTA
                // ========================
                TextFormField(
                  controller: _rutaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ruta (ej: /inventario) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                ),

                const SizedBox(height: 16),

                // ========================
                // SELECT DE ICONOS
                // ========================
                // ========================
                // SELECTOR DE ICONOS
                // ========================
                InkWell(
                  onTap: () async {
                    final selected = await showDialog<String>(
                      context: context,
                      builder: (_) =>
                          IconPickerDialog(selectedIcon: _selectedIcon),
                    );

                    if (selected != null) {
                      setState(() {
                        _selectedIcon = selected;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _iconoInvalido
                            ? Colors.red
                            : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _iconoInvalido
                          ? Colors.red.withOpacity(0.05)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          IconMapper.getIcon(_selectedIcon),
                          size: 24,
                          color: _iconoInvalido ? Colors.red : null,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Icono',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              Text(
                                _selectedIcon,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _iconoInvalido ? Colors.red : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.search),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PREVIEW DEL ICONO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _iconoInvalido ? Colors.red : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _iconoInvalido ? Colors.red.withOpacity(0.08) : null,
                  ),
                  child: Row(
                    children: [
                      const Text("Vista previa: "),
                      const SizedBox(width: 12),

                      Icon(
                        IconMapper.getIcon(_selectedIcon),
                        size: 28,
                        color: _iconoInvalido ? Colors.red : null,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedIcon,
                              style: TextStyle(
                                color: _iconoInvalido ? Colors.red : null,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            if (_iconoInvalido)
                              const Text(
                                'Icono inválido o reservado. No se puede guardar.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ========================
                // ORDEN
                // ========================
                TextFormField(
                  controller: _ordenCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Orden',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                // ========================
                // ACTIVO
                // ========================
                SwitchListTile(
                  title: const Text('Activo'),
                  value: _activo,
                  onChanged: (v) {
                    setState(() {
                      _activo = v;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),

        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Guardar'),
          onPressed: () async {
            // ==========================
            // VALIDAR FORM
            // ==========================
            if (!_formKey.currentState!.validate()) {
              return;
            }

            // ==========================
            // VALIDAR ICONO
            // ==========================
            if (_iconoInvalido) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Debe seleccionar un icono válido.'),
                ),
              );

              return;
            }

            // ==========================
            // LOADING
            // ==========================
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              final nuevoMenu = MenuApp(
                id: widget.menu?.id ?? '',
                nombre: _nombreCtrl.text.trim(),
                ruta: _rutaCtrl.text.trim(),
                icono: _selectedIcon,
                ordenBase: int.tryParse(_ordenCtrl.text) ?? 0,
                activo: _activo,
                visible: true,
                eliminado: false,
              );
              final userId = ref.read(currentUserProvider).id;
              await ref
                  .read(menuAbmServiceProvider)
                  .guardarMenu(nuevoMenu, userId);

              if (context.mounted) {
                Navigator.pop(context); // loading
                Navigator.pop(context); // dialog
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
        ),
      ],
    );
  }
}
