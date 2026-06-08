import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';

import 'package:inv_telas/providers/empresa_provider.dart';
import 'package:inv_telas/providers/usuario_provider.dart';

import 'package:inv_telas/moduloAsignacion/widgets/agregar_usuario_dialog.dart';
import 'package:inv_telas/moduloAsignacion/widgets/asignar_sucursal_dialog.dart';
import 'package:inv_telas/moduloAsignacion/widgets/usuario_empresa_card.dart';

class UsuariosEmpresaScreen extends ConsumerWidget {
  const UsuariosEmpresaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empresaSeleccionada = ref.watch(sessionProvider).empresaActual;

    if (empresaSeleccionada == null) {
      return const Scaffold(
        body: Center(child: Text('No existe empresa seleccionada')),
      );
    }

    final empresaAsync = ref.watch(
      empresaDetalleProvider(empresaSeleccionada.id),
    );

    return empresaAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Usuarios')),
        body: Center(child: Text('Error: $e')),
      ),

      data: (empresa) {
        if (empresa == null) {
          return const Scaffold(
            body: Center(child: Text('Empresa no encontrada')),
          );
        }

        final usuariosAsync = ref.watch(usuariosPermitidosProvider(empresa));

        return usuariosAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text('Usuarios - ${empresa.nombre}')),
            body: const Center(child: CircularProgressIndicator()),
          ),

          error: (e, _) => Scaffold(
            appBar: AppBar(title: Text('Usuarios - ${empresa.nombre}')),
            body: Center(child: Text('Error cargando usuarios: $e')),
          ),

          data: (usuarios) {
            print('================================');
            print('EMPRESA RECARGADA DESDE FIREBASE');
            print(empresa);
            print('Usuarios permitidos: ${empresa.usuariosPermitidos.length}');
            print('Usuarios cargados: ${usuarios.length}');
            print('================================');

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

                  ref.invalidate(empresaDetalleProvider(empresa.id));

                  ref.invalidate(usuariosPermitidosProvider(empresa));
                },
              ),

              body: usuarios.isEmpty
                  ? const Center(child: Text('No existen usuarios asignados'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(empresaDetalleProvider(empresa.id));

                        ref.invalidate(usuariosPermitidosProvider(empresa));

                        await ref.read(
                          empresaDetalleProvider(empresa.id).future,
                        );
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: usuarios.length,
                        itemBuilder: (_, index) {
                          final usuario = usuarios[index];

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

                              ref.invalidate(
                                empresaDetalleProvider(empresa.id),
                              );

                              ref.invalidate(
                                usuariosPermitidosProvider(empresa),
                              );
                            },
                          );
                        },
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
