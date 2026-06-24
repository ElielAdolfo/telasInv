import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/moduloLotes/widgets/lote_costeo_dialog.dart';
import 'package:inv_telas/moduloLotes/widgets/lote_gastos_dialog.dart';

import '../../../core/providers/session_provider.dart';

import '../../../models/lotes/lote.dart';

import '../../../providers/lote_provider.dart';

import '../widgets/lote_card.dart';
import '../widgets/lote_table.dart';
import '../widgets/lote_form_dialog.dart';
import '../widgets/lote_detalle_manager_dialog.dart';
import '../widgets/cambio_estado_dialog.dart';

class LotesAbmScreen extends ConsumerWidget {
  const LotesAbmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empresaId = ref.watch(sessionProvider).empresaActual!.id;

    final usuarioId = ref.watch(sessionProvider).usuario!.id;

    final lotesAsync = ref.watch(lotesProvider(empresaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Lotes'),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(lotesProvider(empresaId).notifier).recargar();
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Lote'),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => const LoteFormDialog(),
          );
        },
      ),

      body: lotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (lotes) {
          if (lotes.isEmpty) {
            return const Center(child: Text('No existen lotes registrados'));
          }

          final isMobile = MediaQuery.of(context).size.width < 900;

          if (isMobile) {
            return ListView.builder(
              itemCount: lotes.length,
              itemBuilder: (_, index) {
                final lote = lotes[index];

                return LoteCard(
                  lote: lote,

                  onDetalle: () => _abrirDetalle(context, lote),

                  onEditar: () => _editar(context, lote),

                  onGastos: () => _abrirGastos(context, lote),

                  onCosteo: () => _abrirCosteo(context, lote),

                  onEliminar: () =>
                      _eliminar(context, ref, empresaId, usuarioId, lote),
                );
              },
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: LoteTable(
              lotes: lotes,

              onDetalle: (lote) => _abrirDetalle(context, lote),

              onEditar: (lote) => _editar(context, lote),

              onGastos: (lote) => _abrirGastos(context, lote),

              onCosteo: (lote) => _abrirCosteo(context, lote),

              onEliminar: (lote) =>
                  _eliminar(context, ref, empresaId, usuarioId, lote),
            ),
          );
        },
      ),
    );
  }

  //==================================================
  // DETALLE
  //==================================================

  static Future<void> _abrirDetalle(BuildContext context, Lote lote) async {
    await showDialog(
      context: context,
      builder: (_) => LoteDetalleManagerDialog(lote: lote),
      
    );
  }

  //==================================================
  // EDITAR
  //==================================================

  static Future<void> _editar(BuildContext context, Lote lote) async {
    await showDialog(
      context: context,
      builder: (_) => LoteFormDialog(lote: lote),
    );
  }

  //==================================================
  // GASTOS
  //==================================================

  static Future<void> _abrirGastos(BuildContext context, Lote lote) async {
    await showDialog(
      context: context,
      builder: (_) => LoteGastosDialog(loteId: lote.id),
    );
  }

  //==================================================
  // COSTEO
  //==================================================

  static Future<void> _abrirCosteo(BuildContext context, Lote lote) async {
    await showDialog(
      context: context,
      builder: (_) => LoteCosteoDialog(loteId: lote.id),
    );
  }

  //==================================================
  // ELIMINAR
  //==================================================

  static Future<void> _eliminar(
    BuildContext context,
    WidgetRef ref,
    String empresaId,
    String usuarioId,
    Lote lote,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Eliminar lote'),

          content: Text('¿Desea eliminar el lote ${lote.numeroLote}?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await ref
        .read(lotesProvider(empresaId).notifier)
        .eliminarLote(loteId: lote.id, usuarioId: usuarioId);
  }

  //==================================================
  // CAMBIO ESTADO
  //==================================================

  static Future<void> abrirCambioEstado(BuildContext context, Lote lote) async {
    await showDialog(
      context: context,
      builder: (_) => CambioEstadoDialog(
        lote: lote,
        onConfirmar: (nuevoEstado, observacion) {
          debugPrint('Nuevo estado: $nuevoEstado - $observacion');
        },
      ),
    );
  }
}
