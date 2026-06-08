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

    final sucursalesAsync = ref.watch(sucursalesProvider(empresa.id));

    return sucursalesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),

      error: (e, _) =>
          Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),

      data: (sucursales) {
        return Column(
          children: permiso.sucursales.map((sucursalRol) {
            final encontradas = sucursales
                .where((e) => e.id == sucursalRol.sucursalId)
                .toList();

            if (encontradas.isEmpty) {
              return const SizedBox();
            }

            final sucursal = encontradas.first;

            return ListTile(
              leading: const Icon(Icons.store),
              title: Text(sucursal.nombre),
              subtitle: Text('${sucursalRol.rolesIds.length} roles'),
            );
          }).toList(),
        );
      },
    );
  }
}
