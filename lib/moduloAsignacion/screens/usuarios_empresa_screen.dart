import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';

import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';

import 'package:inv_telas/moduloAsignacion/widgets/agregar_usuario_dialog.dart';
import 'package:inv_telas/moduloAsignacion/widgets/asignar_sucursal_dialog.dart';
import 'package:inv_telas/moduloAsignacion/widgets/usuario_empresa_card.dart';

import 'usuario_empresa_detalle_screen.dart';

class UsuariosEmpresaScreen extends ConsumerWidget {
  const UsuariosEmpresaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empresa = ref.watch(sessionProvider).empresaActual;

    if (empresa == null) {
      return const Scaffold(
        body: Center(child: Text('No existe empresa seleccionada')),
      );
    }
    final usuarios = empresa.usuariosPermitidos;

    return Scaffold(
      appBar: AppBar(title: Text('Usuarios - ${empresa.nombre}')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar Usuario'),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => AgregarUsuarioDialog(empresa: empresa),
          );
        },
      ),
      body: usuarios.isEmpty
          ? const Center(child: Text('No existen usuarios asignados'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: usuarios.length,
              itemBuilder: (_, index) {
                final permiso = usuarios[index];

                final usuario = Usuario(
                  id: permiso.usuarioId,
                  nombre: 'Usuario',
                  email: '',
                );

                return UsuarioEmpresaCard(
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
                );
              },
            ),
    );
  }
}
