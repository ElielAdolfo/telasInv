import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/providers/codigo_unico_tela_proveedor_provider.dart';
import 'package:inv_telas/providers/proveedores_provider.dart';
import 'package:inv_telas/providers/tipo_tela_provider.dart';

// 1. IMPORTA AQUÍ LOS PROVIDERS DE PROVEEDORES Y TIPOS DE TELA
// import 'package:inv_telas/providers/proveedor_provider.dart';
// import 'package:inv_telas/providers/tipo_tela_provider.dart';

import 'codigo_tela_proveedor_form_dialog.dart';

class CodigoTelaProveedorPage extends ConsumerWidget {
  const CodigoTelaProveedorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empresaId = ref.watch(sessionProvider).empresaActual!.id;

    // Obtenemos los códigos de tela de los proveedores
    final asyncData = ref.watch(codigosUnicoTelaProveedorProvider(empresaId));

    // 2. ESCUCHAMOS LOS PROVIDERS DE PROVEEDORES Y TIPOS DE TELA
    // (Ajusta los nombres según cómo se llamen en tu proyecto)
    final proveedoresAsync = ref.watch(proveedoresFutureProvider(empresaId));
    final tiposTelaAsync = ref.watch(tiposTelaProvider(empresaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Códigos Tela Proveedor')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const CodigoTelaProveedorFormDialog(),
          );
          ref.invalidate(codigosUnicoTelaProveedorProvider(empresaId));
        },
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No hay registros'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              // 3. RECUPERAMOS LAS LISTAS ACTUALES (Manejamos valores vacíos si aún cargan)
              final listaProveedores = proveedoresAsync.value ?? [];
              final listaTiposTela = tiposTelaAsync.value ?? [];

              // 4. BUSCAMOS LAS COINCIDENCIAS POR ID DE FORMA SEGURA
              final proveedorMatch = listaProveedores.where(
                (p) => p.id == item.proveedorId,
              );
              final tipoTelaMatch = listaTiposTela.where(
                (t) => t.id == item.tipoTelaId,
              );

              // 5. ASIGNAMOS EL NOMBRE O UN TEXTO DE RESPALDO MIENTRAS SE CARGA/RESUELVE
              final nombreProveedor = proveedorMatch.isNotEmpty
                  ? proveedorMatch.first.nombre
                  : 'Cargando proveedor...';

              final nombreTipoTela = tipoTelaMatch.isNotEmpty
                  ? tipoTelaMatch.first.nombre
                  : 'Cargando tipo de tela...';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  // 6. MOSTRAMOS LOS NOMBRES HUMANOS EN LUGAR DE LOS ID HASHED
                  title: Text('Proveedor: $nombreProveedor'),
                  subtitle: Text('Tipo Tela: $nombreTipoTela'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Desactivar'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              CodigoTelaProveedorFormDialog(data: item),
                        );
                        // 🔥 REFRESH AL VOLVER
                        ref.invalidate(
                          codigosUnicoTelaProveedorProvider(empresaId),
                        );
                      }

                      if (value == 'delete') {
                        final notifier = ref.read(
                          codigoUnicoTelaProveedorNotifierProvider.notifier,
                        );
                        final usuarioActual = ref.read(sessionProvider).usuario;
                        await notifier.delete(
                          id: item.id,
                          usuario: usuarioActual!.id,
                          empresaId: empresaId,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
