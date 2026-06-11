import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/moduloAbms/tipos_tela/widgets/tipo_tela_form_dialog.dart';

import '../../../core/providers/session_provider.dart';
import '../../../providers/tipo_tela_provider.dart';

class TiposTelaAbmScreen extends ConsumerWidget {
  const TiposTelaAbmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final empresa = session.empresaActual;

    if (empresa == null) {
      return const Scaffold(
        body: Center(child: Text('Debe seleccionar una empresa')),
      );
    }

    final tiposTelaAsync = ref.watch(tiposTelaProvider(empresa.id));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tipo tela'),
        onPressed: () async {
          // 1. Esperamos el resultado del modal
          final guardadoExitoso = await showDialog<bool>(
            context: context,
            builder: (_) => const TipoTelaFormDialog(),
          );

          // 2. Si devolvió true, invalidamos el provider para que vuelva a hacer el GET
          if (guardadoExitoso == true) {
            ref.invalidate(tiposTelaProvider(empresa.id));
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: tiposTelaAsync.when(
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
          error: (e, _) {
            return Center(child: Text('Error\n$e'));
          },
          data: (tiposTela) {
            if (tiposTela.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text('No existen tipos de tela registrados'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: tiposTela.length,
              itemBuilder: (_, index) {
                final item = tiposTela[index];

                return Card(
                  child: ListTile(
                    title: Text(item.nombre),
                    subtitle: Text('${item.variantes.length} variantes'),
                    trailing: const Icon(
                      Icons.edit_outlined,
                      color: Colors.grey,
                    ),
                    onTap: () async {
                      // 1. Esperamos el resultado de la edición
                      final editadoExitoso = await showDialog<bool>(
                        context: context,
                        builder: (_) => TipoTelaFormDialog(tipoTela: item),
                      );

                      // 2. Si devolvió true, invalidamos el provider para refrescar la lista
                      if (editadoExitoso == true) {
                        ref.invalidate(tiposTelaProvider(empresa.id));
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
