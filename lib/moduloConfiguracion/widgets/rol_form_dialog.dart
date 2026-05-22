import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/moduloConfiguracion/providers/configuracion_provider.dart';

class RolFormDialog extends ConsumerStatefulWidget {
  final Rol? rol;
  const RolFormDialog({super.key, required this.rol});

  @override
  ConsumerState<RolFormDialog> createState() => _RolFormDialogState();
}

class _RolFormDialogState extends ConsumerState<RolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  List<String> _selectedMenus = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.rol?.nombre ?? '');
    _selectedMenus = widget.rol?.menusPermitidos ?? [];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newRol = Rol(
      id: widget.rol?.id ?? '',
      nombre: _nombreCtrl.text,
      activo: widget.rol?.activo ?? true,
      menusPermitidos: _selectedMenus,
      eliminado: false,
    );

    try {
      await ref.read(rolAdminServiceProvider).saveRol(newRol);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menusAsync = ref.watch(menusAdminProvider);

    // Hacemos el diálogo más grande para Web
    return Dialog(
      child: Container(
        width: 500, // Ancho fijo para que se vea bien en Web
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    widget.rol == null
                        ? "NUEVO ROL"
                        : "EDITAR ROL: ${widget.rol?.nombre}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo Nombre
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nombre del Rol *",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? "Requerido" : null,
                      ),
                      const SizedBox(height: 20),

                      // Sección de Asignación de Menús
                      const Text(
                        "MENÚS ASIGNADOS:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(),

                      menusAsync.when(
                        data: (menus) {
                          if (menus.isEmpty) {
                            return const Text(
                              "No hay menús creados. Cree menús primero.",
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: menus.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final m = menus[i];
                                final isSelected = _selectedMenus.contains(
                                  m.id,
                                );
                                return CheckboxListTile(
                                  title: Text(m.nombre),
                                  subtitle: Text(
                                    m.ruta,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  secondary: Icon(
                                    Icons.arrow_right,
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  activeColor: Colors.blue[800],
                                  value: isSelected,
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        _selectedMenus.add(m.id);
                                      } else {
                                        _selectedMenus.remove(m.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text("Error cargando menús"),
                      ),
                      const SizedBox(height: 20),

                      // Botones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text("CANCELAR"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submit,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: const Text("GUARDAR CAMBIOS"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
