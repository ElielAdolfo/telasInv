import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/providers/relaciones_provider.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:uuid/uuid.dart';

class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  bool _isLoading = false;

  Future<void> _crearOEditarRol({Rol? rol}) async {
    // Controladores
    final nombreCtrl = TextEditingController(text: rol?.nombre ?? '');
    final menusSeleccionados = Set<String>.from(rol?.menusPermitidos ?? []);
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final menusAsync = ref.read(menusProvider);

          return AlertDialog(
            title: Text(rol == null ? 'Nuevo Rol' : 'Editar Rol'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Rol',
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Permisos (Menús):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: menusAsync.when(
                        data: (menus) => ListView.builder(
                          shrinkWrap: true,
                          itemCount: menus.length,
                          itemBuilder: (ctx, i) {
                            final menu = menus[i];
                            return CheckboxListTile(
                              title: Text(menu.nombre),
                              value: menusSeleccionados.contains(menu.id),
                              onChanged: (v) {
                                setStateDialog(() {
                                  if (v == true) {
                                    menusSeleccionados.add(menu.id);
                                  } else {
                                    menusSeleccionados.remove(menu.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setStateDialog(() => saving = true);

                        final nuevoRol = Rol(
                          id: rol?.id ?? const Uuid().v4(),
                          nombre: nombreCtrl.text,
                          activo: true,
                          menusPermitidos: menusSeleccionados.toList(),
                        );

                        try {
                          await ref
                              .read(relacionesServiceProvider)
                              .guardarRol(nuevoRol);
                          Navigator.pop(context);
                          ref.invalidate(rolesProvider); // Refrescar lista
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rol guardado correctamente'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        } finally {
                          setStateDialog(() => saving = false);
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: rolesAsync.when(
        data: (roles) {
          if (roles.isEmpty) return const Center(child: Text('No hay roles.'));
          return ListView.builder(
            itemCount: roles.length,
            itemBuilder: (context, i) {
              final rol = roles[i];
              return Card(
                child: ListTile(
                  title: Text(rol.nombre),
                  subtitle: Text(
                    'Permisos: ${rol.menusPermitidos.length} menús',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _crearOEditarRol(rol: rol),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _crearOEditarRol(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
