import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/moduloAbms/roles/providers/rol_abm_provider.dart';
import 'package:inv_telas/providers/asignacion_provider.dart';

class AsignarRolesDialog extends ConsumerStatefulWidget {
  final Empresa empresa;
  final Usuario usuario;
  final String sucursalId;

  const AsignarRolesDialog({
    super.key,
    required this.empresa,
    required this.usuario,
    required this.sucursalId,
  });

  @override
  ConsumerState<AsignarRolesDialog> createState() => _AsignarRolesDialogState();
}

class _AsignarRolesDialogState extends ConsumerState<AsignarRolesDialog> {
  final selectedRoles = <String>{};

  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesAbmStreamProvider);

    return AlertDialog(
      title: const Text('Asignar Roles'),
      content: SizedBox(
        width: 500,
        child: rolesAsync.when(
          data: (roles) {
            return ListView(
              shrinkWrap: true,
              children: roles.map((rol) {
                return CheckboxListTile(
                  value: selectedRoles.contains(rol.id),
                  title: Text(rol.nombre),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedRoles.add(rol.id);
                      } else {
                        selectedRoles.remove(rol.id);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: saving
              ? null
              : () async {
                  setState(() {
                    saving = true;
                  });

                  try {
                    await ref
                        .read(asignacionProvider)
                        .asignarRoles(
                          empresa: widget.empresa,
                          usuario: widget.usuario,
                          sucursalId: widget.sucursalId,
                          rolesIds: selectedRoles.toList(),
                        );

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        saving = false;
                      });
                    }
                  }
                },
          child: saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
