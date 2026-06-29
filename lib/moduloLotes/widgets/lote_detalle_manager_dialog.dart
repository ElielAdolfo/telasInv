import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/models/lotes/lote.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/moduloLotes/screens/modificar_rollos_screen.dart';
import 'package:inv_telas/providers/lote_detalle_provider.dart';

import '../../../providers/codigo_tela_proveedor_provider.dart';
import '../../../providers/proveedores_provider.dart';
import '../../../providers/tipo_tela_provider.dart';

import 'lote_detalle_dialog.dart';

class LoteDetalleManagerDialog extends ConsumerStatefulWidget {
  final Lote lote;

  const LoteDetalleManagerDialog({super.key, required this.lote});

  @override
  ConsumerState<LoteDetalleManagerDialog> createState() =>
      _LoteDetalleManagerDialogState();
}

class _LoteDetalleManagerDialogState
    extends ConsumerState<LoteDetalleManagerDialog> {
  Map<String, dynamic>? _cache; // cache lookup optimizado

  @override
  Widget build(BuildContext context) {
    final empresaId = widget.lote.empresaId;

    final detallesAsync = ref.watch(loteDetallesProvider(widget.lote.id));
    final codigosAsync = ref.watch(codigoTelaProveedorProvider(empresaId));
    final proveedoresAsync = ref.watch(proveedoresFutureProvider(empresaId));
    final tiposAsync = ref.watch(tiposTelaProvider(empresaId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 800,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalles del Lote ${widget.lote.numeroLote}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ================= BODY =================
            Expanded(
              child: detallesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (detalles) {
                  return Column(
                    children: [
                      // ================= RESUMEN =================
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Items: ${detalles.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar Detalle'),
                              onPressed: () async {
                                await _abrirFormulario();
                              },
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // ================= LISTA =================
                      Expanded(
                        child: codigosAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) =>
                              Center(child: Text("Error códigos: $e")),
                          data: (codigos) {
                            // construir cache SOLO 1 vez
                            _cache ??= {for (final c in codigos) c.id: c};

                            return proveedoresAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, _) =>
                                  Center(child: Text("Error proveedores: $e")),
                              data: (proveedores) {
                                return tiposAsync.when(
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (e, _) =>
                                      Center(child: Text("Error tipos: $e")),
                                  data: (tipos) {
                                    if (detalles.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No hay detalles en este lote',
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      padding: const EdgeInsets.all(12),
                                      itemCount: detalles.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final detalle = detalles[index];

                                        final codigo =
                                            _cache?[detalle
                                                .codigoTelaProveedorId];

                                        final proveedor = proveedores
                                            .firstWhere(
                                              (p) =>
                                                  p.id == codigo?.proveedorId,
                                              orElse: () => proveedores.first,
                                            );

                                        final tipo = tipos.firstWhere(
                                          (t) => t.id == codigo?.tipoTelaId,
                                          orElse: () => tipos.first,
                                        );

                                        return _buildItem(
                                          detalle,
                                          proveedor.nombre,
                                          tipo.nombre,
                                          proveedor,
                                          tipo,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // ITEM UI
  //==================================================
  Widget _buildItem(
    LoteDetalle detalle,
    String proveedorNombre,
    String tipoTelaNombre,
    Proveedor proveedor,
    TipoTela tipoTela,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proveedor: $proveedorNombre',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Tipo Tela: $tipoTelaNombre',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text('Rollos: ${detalle.cantidadRollos}'),
            Text('Metros por rollo: ${detalle.metrosPorRollo}'),
            Text('Total metros: ${detalle.totalMetros}'),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () => _editar(detalle),
                ),

                const SizedBox(width: 8),

                TextButton.icon(
                  icon: const Icon(Icons.tune),
                  label: const Text('Modificar'),
                  onPressed: () => _modificar(detalle, proveedor, tipoTela),
                ),

                const SizedBox(width: 8),

                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => _eliminar(detalle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _modificar(
    LoteDetalle detalle,
    Proveedor proveedor,
    TipoTela tipoTela,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModificarRollosScreen(
          lote: widget.lote,
          detalle: detalle,
          proveedor: proveedor,
          tipoTela: tipoTela,
        ),
      ),
    );

    if (!mounted) return;

    await ref.read(loteDetallesProvider(widget.lote.id).notifier).refresh();
  }

  //==================================================
  // AGREGAR
  //==================================================
  Future<void> _abrirFormulario({LoteDetalle? detalle}) async {
    final guardadoExitoso = await showDialog<bool>(
      context: context,
      builder: (_) => LoteDetalleDialog(
        loteId: widget.lote.id,
        lote: widget.lote,
        detalle: detalle,
      ),
    );

    if (guardadoExitoso == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            detalle != null
                ? '¡Detalle actualizado con éxito!'
                : '¡Nuevo detalle agregado con éxito!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  //==================================================
  // EDITAR
  //==================================================
  Future<void> _editar(LoteDetalle detalle) async {
    final result = await showDialog<LoteDetalle>(
      context: context,
      builder: (_) => LoteDetalleDialog(
        loteId: widget.lote.id,
        lote: widget.lote,
        detalle: detalle,
      ),
    );

    if (result != null) {
      await ref
          .read(loteDetallesProvider(widget.lote.id).notifier)
          .guardar(result);
    }
  }

  //==================================================
  // ELIMINAR
  //==================================================
  Future<void> _eliminar(LoteDetalle detalle) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar detalle'),
        content: const Text('¿Desea eliminar este item del lote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ref
          .read(loteDetallesProvider(widget.lote.id).notifier)
          .eliminar(detalle.id);
    }
  }
}
