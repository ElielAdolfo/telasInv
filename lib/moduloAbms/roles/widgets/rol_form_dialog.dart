import 'package:flutter/material.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/moduloAbms/roles/providers/rol_abm_provider.dart';
import 'package:inv_telas/moduloAbms/menus/providers/menu_abm_provider.dart'; // Para obtener lista de menús

class RolFormDialog extends ConsumerStatefulWidget {
  final Rol? rol;
  const RolFormDialog({super.key, this.rol});

  @override
  ConsumerState<RolFormDialog> createState() => _RolFormDialogState();
}

class _RolFormDialogState extends ConsumerState<RolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late List<String> _selectedMenuIds;
  bool _activo = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.rol?.nombre ?? '');
    _selectedMenuIds = widget.rol?.menusPermitidos.toList() ?? [];
    _activo = widget.rol?.activo ?? true;
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos todos los menús disponibles para mostrar checkboxes
    final menusAsync = ref.watch(
      menusAbmStreamProvider,
    ); // Reutilizamos el provider de menús

    return AlertDialog(
      title: Text(widget.rol == null ? 'Crear Rol' : 'Editar Rol'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Rol *',
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Activo'),
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const Divider(),
              const Text(
                'Permisos de Menú:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),

              // Lista de Checkboxes Responsiva
              menusAsync.when(
                data: (menus) {
                  return Container(
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                    ), // Scroll si hay muchos
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: menus.map((m) {
                        final isSelected = _selectedMenuIds.contains(m.id);
                        return FilterChip(
                          label: Text(m.nombre),
                          selected: isSelected,
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedMenuIds.add(m.id);
                              } else {
                                _selectedMenuIds.remove(m.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error cargando menús'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);

                    final nuevoRol = Rol(
                      id: widget.rol?.id ?? '',
                      nombre: _nombreCtrl.text,
                      activo: _activo,
                      menusPermitidos: _selectedMenuIds,
                      eliminado: false,
                    );

                    await ref.read(rolAbmServiceProvider).guardarRol(nuevoRol);

                    if (mounted) {
                      Navigator.pop(context); // Cierra el dialog
                    }
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
