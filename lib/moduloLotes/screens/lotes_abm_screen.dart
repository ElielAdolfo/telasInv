import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/lotes/lote_estado.dart';
import 'package:inv_telas/moduloLotes/widgets/lote_gastos_dialog.dart';
import 'package:inv_telas/moduloLotes/widgets/lote_historial_dialog.dart';
import 'package:inv_telas/providers/lote_historial_provider.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';

import '../../../core/providers/session_provider.dart';
import '../../../models/lotes/lote.dart';
import '../../../providers/lote_provider.dart';

import '../widgets/lote_card.dart';
import '../widgets/lote_table.dart';
import '../widgets/lote_form_dialog.dart';
import '../widgets/lote_detalle_manager_dialog.dart';
import '../widgets/cambio_estado_dialog.dart';
// Asegúrate de importar correctamente la ubicación de tu ConfirmActionDialog

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
                  onGastos: () => _abrirGastos(context, lote, empresaId),
                  onHistorial: () => _abrirHistorial(context, lote),
                  onEliminar: () =>
                      _eliminar(context, ref, empresaId, usuarioId, lote),
                  // Pasamos la nueva acción aquí:
                  onAvanzar: () =>
                      _avanzarEstado(context, ref, lote, usuarioId),
                  onDevolver:
                      (lote.estado != LoteEstado.borrador &&
                          lote.estado != LoteEstado.finalizado &&
                          lote.estado != LoteEstado.cancelado)
                      ? () => _devolverEstado(context, ref, lote, usuarioId)
                      : null,
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
              onGastos: (lote) => _abrirGastos(context, lote, empresaId),
              onHistorial: (lote) => _abrirHistorial(context, lote),
              onEliminar: (lote) =>
                  _eliminar(context, ref, empresaId, usuarioId, lote),
              // Pasamos la nueva acción aquí:
              onAvanzar: (lote) =>
                  _avanzarEstado(context, ref, lote, usuarioId),
              onDevolver: (lote) =>
                  (lote.estado != LoteEstado.borrador &&
                      lote.estado != LoteEstado.finalizado &&
                      lote.estado != LoteEstado.cancelado)
                  ? _devolverEstado(context, ref, lote, usuarioId)
                  : null,
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
  static Future<void> _abrirGastos(
    BuildContext context,
    Lote lote,
    dynamic empresaId,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => LoteGastosDialog(loteId: lote.id, empresaId: empresaId),
    );
  }

  //==================================================
  // HISTORIAL
  //==================================================
  static Future<void> _abrirHistorial(BuildContext context, Lote lote) async {
    await showDialog(
      context: context,
      builder: (_) => LoteHistorialDialog(loteId: lote.id),
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

  // ==================================================
  // DEVOLVER ESTADO (NUEVA ACCIÓN)
  // ==================================================
  static Future<void> _devolverEstado(
    BuildContext context,
    WidgetRef ref,
    Lote lote,
    String usuarioId,
  ) async {
    final LoteEstado estadoAnterior = _obtenerEstadoAnterior(lote.estado);

    if (estadoAnterior == lote.estado) return;

    await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: "Devolver Lote",
        message:
            "¿Está seguro de regresar el lote ${lote.numeroLote} al estado ${estadoAnterior.nombre}? Se conservarán los datos actuales para su corrección.",
        icon: Icons.arrow_back,
        iconColor: Colors.orange,
        confirmText: "Devolver",
        onConfirm: () async {
          try {
            // El servicio registrará el snapshot del estado actual antes de cambiarlo hacia atrás
            await ref
                .read(loteHistorialServiceProvider)
                .registrarCambioEstado(
                  lote: lote,
                  nuevoEstado: estadoAnterior,
                  usuarioId: usuarioId,
                  observacion:
                      "Devolución voluntaria de estado para corrección de datos.",
                );

            // Forzamos la recarga del listado para ver el cambio reflejado inmediatamente
            ref.read(lotesProvider(lote.empresaId).notifier).recargar();

            debugPrint(
              'Lote ${lote.id} devuelto al estado ${estadoAnterior.nombre}.',
            );
          } catch (e) {
            debugPrint('Error al devolver el estado del lote: $e');
          }
        },
      ),
    );
  }

  /// Determina secuencialmente el estado anterior del flujo
  static LoteEstado _obtenerEstadoAnterior(LoteEstado actual) {
    switch (actual) {
      case LoteEstado.enTransito:
        return LoteEstado.borrador;
      case LoteEstado.revision:
        return LoteEstado.enTransito;
      default:
        return actual; // No permite regresar si está en borrador, finalizado o cancelado
    }
  }

  //==================================================
  // AVANZAR ESTADO (DENTRO DE LOTESABMSCREEN)
  //==================================================
  static Future<void> _avanzarEstado(
    BuildContext context,
    WidgetRef ref,
    Lote lote,
    String usuarioId,
  ) async {
    final LoteEstado siguienteEstado = _obtenerSiguienteEstado(lote.estado);

    if (siguienteEstado == lote.estado) return;

    await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: "Avanzar Lote",
        message:
            "¿Está seguro de avanzar el lote ${lote.numeroLote} al estado ${siguienteEstado.nombre}?",
        icon: Icons.arrow_forward,
        iconColor: Colors.blue,
        confirmText: "Aceptar",
        onConfirm: () async {
          // El servicio ejecutará de forma transparente la transposición a StockActual si es FINALIZADO
          await ref
              .read(loteHistorialServiceProvider)
              .registrarCambioEstado(
                lote: lote,
                nuevoEstado: siguienteEstado,
                usuarioId: usuarioId,
                observacion: "Cambio de estado automático en flujo de la app.",
              );

          // RECARGA DEL LISTADO: Forzamos la actualización inmediata del UI state
          ref.read(lotesProvider(lote.empresaId).notifier).recargar();

          debugPrint('Lote ${lote.id} avanzado con éxito.');
        },
      ),
    );
  }

  /// Método auxiliar para determinar secuencialmente el siguiente estado del flujo
  static LoteEstado _obtenerSiguienteEstado(LoteEstado actual) {
    switch (actual) {
      case LoteEstado.borrador:
        return LoteEstado.enTransito;
      case LoteEstado.enTransito:
        return LoteEstado.revision;
      case LoteEstado.revision:
        return LoteEstado.finalizado;
      default:
        return actual; // Mantiene el estado si ya es finalizado o cancelado
    }
  }
}
