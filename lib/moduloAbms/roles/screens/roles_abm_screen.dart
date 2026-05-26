import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/widgets/action_dialog.dart';
import 'package:inv_telas/moduloAbms/roles/providers/rol_abm_provider.dart';
import 'package:inv_telas/moduloAbms/roles/widgets/rol_form_dialog.dart';
import 'package:inv_telas/models/rol.dart';

class RolesAbmScreen extends ConsumerWidget {
  const RolesAbmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesAbmStreamProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const RolFormDialog(rol: null),
        ),
        label: const Text('Nuevo Rol'),
        icon: const Icon(Icons.add),
      ),
      body: rolesAsync.when(
        data: (roles) {
          if (roles.isEmpty) return const Center(child: Text('No hay roles'));
          return ListView.builder(
            itemCount: roles.length,
            itemBuilder: (_, i) {
              final rol = roles[i];
              return Card(
                child: ListTile(
                  title: Text(rol.nombre),
                  subtitle: Text(
                    'Permisos: ${rol.menusPermitidos.length} menús',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openForm(context, rol),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, rol),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _openForm(BuildContext context, Rol? rol) {
    showDialog(
      context: context,
      builder: (_) => RolFormDialog(rol: rol),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Rol rol) {
    showDialog(
      context: context,
      builder: (_) => ActionDialog(
        titulo: 'Eliminar Rol',
        mensaje:
            '¿Está seguro de eliminar el rol "${rol.nombre}"? Esto afectará a los usuarios asignados.',
        type: ActionDialogType.delete,
        onConfirm: () async {
          await ref.read(rolAbmServiceProvider).eliminarRol(rol.id);
        },
      ),
    );
  }
}
