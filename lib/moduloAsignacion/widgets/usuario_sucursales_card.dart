import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/providers/sucursal_provider.dart';

class UsuarioSucursalesCard extends ConsumerWidget {
  final Empresa empresa;
  final Usuario usuario;

  const UsuarioSucursalesCard({
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

    return sucursalesAsync.when(
      data: (sucursales) {
        return Column(
          children: permiso.sucursales.map((sucursalRol) {
            final sucursal = sucursales.firstWhere(
              (e) => e.id == sucursalRol.sucursalId,
            );

            return ListTile(
              leading: const Icon(Icons.store),
              title: Text(sucursal.nombre),
              subtitle: Text("${sucursalRol.rolesIds.length} roles"),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
      error: (_, __) => const SizedBox(),
    );
  }
}
