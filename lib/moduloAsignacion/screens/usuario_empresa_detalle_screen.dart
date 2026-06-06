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

    final sucursalesAsync = ref.watch(sucursalesStreamProvider(empresa.id));

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
                    builder: (_) => AsignarSucursalDialog(
                      empresa: empresa,
                      usuario: usuario,
                    ),
                  );
                },
                onDesactivar: () {
                  // siguiente fase
                },
              ),
            ),
          ),

          const VerticalDivider(),

          Expanded(
            child: sucursalesAsync.when(
              data: (sucursales) {
                return rolesAsync.when(
                  data: (roles) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: permiso.sucursales.map((sucursalRol) {
                        final sucursal = sucursales.firstWhere(
                          (e) => e.id == sucursalRol.sucursalId,
                        );

                        final rolesAsignados = roles
                            .where((r) => sucursalRol.rolesIds.contains(r.id))
                            .toList();

                        return SucursalRolesCard(
                          sucursal: sucursal,
                          roles: rolesAsignados,
                          onEditarRoles: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => AsignarRolesDialog(
                                empresa: empresa,
                                usuario: usuario,
                                sucursalId: sucursal.id,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
