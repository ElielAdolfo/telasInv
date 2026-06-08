import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';

import 'package:inv_telas/moduloAsignacion/widgets/asignar_roles_dialog.dart';
import 'package:inv_telas/moduloAsignacion/widgets/asignar_sucursal_dialog.dart';
import 'package:inv_telas/moduloAsignacion/widgets/sucursal_roles_card.dart';
import 'package:inv_telas/moduloAsignacion/widgets/usuario_resumen_panel.dart';

import 'package:inv_telas/moduloAbms/roles/providers/rol_abm_provider.dart';
import 'package:inv_telas/providers/sucursal_provider.dart';

class UsuarioEmpresaDetalleScreen extends ConsumerWidget {
  final Empresa empresa;
  final Usuario usuario;

  const UsuarioEmpresaDetalleScreen({
    super.key,
    required this.empresa,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permiso = empresa.usuariosPermitidos.firstWhere(
      (e) => e.usuarioId == usuario.id,
    );

    final sucursalesAsync = ref.watch(sucursalesProvider(empresa.id));

    final rolesAsync = ref.watch(rolesAbmStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(usuario.nombre)),
      body: Row(
        children: [
          SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: UsuarioResumenPanel(
                empresa: empresa,
                usuario: usuario,
                onAsignarSucursal: () async {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AsignarSucursalDialog(
                      empresa: empresa,
                      usuario: usuario,
                    ),
                  );

                  ref.invalidate(sucursalesProvider(empresa.id));
                },
                onDesactivar: () {
                  // siguiente fase
                },
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          Expanded(
            child: sucursalesAsync.when(
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },

              error: (e, _) {
                return Center(
                  child: Text(
                    'Error cargando sucursales\n$e',
                    textAlign: TextAlign.center,
                  ),
                );
              },

              data: (sucursales) {
                return rolesAsync.when(
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },

                  error: (e, _) {
                    return Center(
                      child: Text(
                        'Error cargando roles\n$e',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },

                  data: (roles) {
                    if (permiso.sucursales.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.store_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Este usuario no tiene sucursales asignadas',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: permiso.sucursales.length,
                      itemBuilder: (_, index) {
                        final sucursalRol = permiso.sucursales[index];

                        final coincidencias = sucursales
                            .where((e) => e.id == sucursalRol.sucursalId)
                            .toList();

                        if (coincidencias.isEmpty) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.warning_amber,
                                color: Colors.orange,
                              ),
                              title: const Text('Sucursal no encontrada'),
                              subtitle: Text(sucursalRol.sucursalId),
                            ),
                          );
                        }

                        final sucursal = coincidencias.first;

                        final rolesAsignados = roles
                            .where((r) => sucursalRol.rolesIds.contains(r.id))
                            .toList();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SucursalRolesCard(
                            sucursal: sucursal,
                            roles: rolesAsignados,
                            onEditarRoles: () async {
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => AsignarRolesDialog(
                                  empresa: empresa,
                                  usuario: usuario,
                                  sucursalId: sucursal.id,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
