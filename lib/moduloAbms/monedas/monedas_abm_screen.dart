import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';

import 'package:inv_telas/models/moneda.dart';
import 'package:inv_telas/moduloAbms/monedas/widgets/moneda_card.dart';
import 'package:inv_telas/moduloAbms/monedas/widgets/moneda_form_dialog.dart';
import 'package:inv_telas/moduloAbms/monedas/widgets/moneda_table.dart';

import 'package:inv_telas/providers/moneda_provider.dart';

import 'package:inv_telas/widgets/confirm_action_dialog.dart';

class MonedasAbmScreen extends ConsumerWidget {
  const MonedasAbmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    final empresa = session.empresaActual;
    final usuario = session.usuario;

    if (empresa == null || usuario == null) {
      return const Scaffold(
        body: Center(child: Text('No existe una empresa seleccionada.')),
      );
    }

    final monedasAsync = ref.watch(monedasProvider(empresa.id));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva Moneda'),
        onPressed: () async {
          final resultado = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                MonedaFormDialog(empresaId: empresa.id, usuarioId: usuario.id),
          );

          if (resultado == true) {
            await ref
                .read(monedasProvider(empresa.id).notifier)
                .cargarMonedas();
          }
        },
      ),

      body: monedasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stack) => Center(child: Text('Error: $error')),

        data: (monedas) {
          if (monedas.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(monedasProvider(empresa.id).notifier)
                    .cargarMonedas();
              },
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No existen monedas registradas')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(monedasProvider(empresa.id).notifier)
                  .cargarMonedas();
            },

            child: LayoutBuilder(
              builder: (context, constraints) {
                final esDesktop = constraints.maxWidth > 900;

                if (esDesktop) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: MonedaTable(
                      monedas: monedas,

                      onEditar: (Moneda moneda) async {
                        final resultado = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => MonedaFormDialog(
                            empresaId: empresa.id,
                            usuarioId: usuario.id,
                            monedaAEditar: moneda,
                          ),
                        );

                        if (resultado == true) {
                          await ref
                              .read(monedasProvider(empresa.id).notifier)
                              .cargarMonedas();
                        }
                      },

                      onEliminar: (Moneda moneda) async {
                        final resultado = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ConfirmActionDialog(
                            title: 'Eliminar Moneda',
                            message: '¿Desea eliminar ${moneda.codigo}?',
                            icon: Icons.delete,
                            iconColor: Colors.red,
                            confirmText: 'Eliminar',
                            onConfirm: () async {
                              await ref
                                  .read(monedasProvider(empresa.id).notifier)
                                  .eliminarMoneda(
                                    id: moneda.id,
                                    usuarioId: usuario.id,
                                  );
                            },
                          ),
                        );

                        if (resultado == true) {
                          await ref
                              .read(monedasProvider(empresa.id).notifier)
                              .cargarMonedas();
                        }
                      },
                    ),
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: monedas.length,
                  itemBuilder: (_, index) {
                    final moneda = monedas[index];

                    return MonedaCard(
                      moneda: moneda,

                      onEditar: (Moneda moneda) async {
                        final resultado = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => MonedaFormDialog(
                            empresaId: empresa.id,
                            usuarioId: usuario.id,
                            monedaAEditar: moneda,
                          ),
                        );

                        if (resultado == true) {
                          await ref
                              .read(monedasProvider(empresa.id).notifier)
                              .cargarMonedas();
                        }
                      },

                      onEliminar: (Moneda moneda) async {
                        final resultado = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ConfirmActionDialog(
                            title: 'Eliminar Moneda',
                            message: '¿Desea eliminar ${moneda.codigo}?',
                            icon: Icons.delete,
                            iconColor: Colors.red,
                            confirmText: 'Eliminar',
                            onConfirm: () async {
                              await ref
                                  .read(monedasProvider(empresa.id).notifier)
                                  .eliminarMoneda(
                                    id: moneda.id,
                                    usuarioId: usuario.id,
                                  );
                            },
                          ),
                        );

                        if (resultado == true) {
                          await ref
                              .read(monedasProvider(empresa.id).notifier)
                              .cargarMonedas();
                        }
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
