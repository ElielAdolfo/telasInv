// lib/moduloVentas/widgets/venta_grupo_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import 'package:inv_telas/providers/precio_venta_provider.dart'; // Importante para leer el precio asignado
import '../../models/ventas/stock_actual.dart';
import 'detalle_rollo_dialog.dart';
import 'vender_rollo_dialog.dart';
import '../screens/ventas_pos_screen.dart';

class VentaGrupoCard extends ConsumerWidget {
  final String tipoTelaId;
  final String? colorId;
  final String loteId;
  final List<StockActual> rollosGrupo;
  final String nombreTela;

  const VentaGrupoCard({
    super.key,
    required this.tipoTelaId,
    required this.colorId,
    required this.loteId,
    required this.rollosGrupo,
    required this.nombreTela,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(carritoVentasProvider);
    final filtroActual = ref.watch(filtroEstadoProvider);

    // Verificamos si este tipo de tela cuenta con precio en la sucursal actual
    final precioConfig = ref.watch(precioPorTipoTelaProvider(tipoTelaId));
    final bool tienePrecioAsignado = precioConfig != null;

    final rollosActivos = rollosGrupo
        .where((r) => r.estado != StockRolloEstado.vendido)
        .toList();

    final rollosFiltrados = rollosActivos.where((rollo) {
      switch (filtroActual) {
        case FiltroRolloEstado.cerrado:
          return rollo.estado == StockRolloEstado.cerrado;
        case FiltroRolloEstado.abierto:
          return rollo.estado == StockRolloEstado.abierto;
        case FiltroRolloEstado.todos:
        default:
          return true;
      }
    }).toList();

    if (rollosFiltrados.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      // Si no tiene precio asignado, le damos una tonalidad sutil para denotar el bloqueo
      color: tienePrecioAsignado ? null : Colors.red.shade50.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...rollosFiltrados.map((rollo) {
              double metrosEnCarrito = 0.0;
              for (var item in cartState.items) {
                for (var sel in item.rollosSeleccionados) {
                  if (sel.rolloId == rollo.id) {
                    metrosEnCarrito += sel.metrosExtraidos;
                  }
                }
              }

              final bool estaRealmenteCerrado =
                  rollo.estado == StockRolloEstado.cerrado;
              final bool tieneMetrosEnCarrito = metrosEnCarrito > 0;

              // Los botones se muestran únicamente si la tela tiene precio asignado
              final bool mostrarBotonVentaCompleta =
                  tienePrecioAsignado &&
                  estaRealmenteCerrado &&
                  !tieneMetrosEnCarrito;
              final bool mostrarBotonAbrirManualmente =
                  tienePrecioAsignado &&
                  estaRealmenteCerrado &&
                  !tieneMetrosEnCarrito;

              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.circle,
                  size: 10,
                  color: !tienePrecioAsignado
                      ? Colors
                            .grey // Gris si está completamente bloqueado
                      : (tieneMetrosEnCarrito ||
                                rollo.estado == StockRolloEstado.abierto
                            ? Colors.green
                            : (rollo.estado == StockRolloEstado.sobra
                                  ? Colors.orange
                                  : Colors.blue)),
                ),
                title: Text(
                  'Rollo #${rollo.numeroFisico} (${tieneMetrosEnCarrito ? "PROV. ABIERTO" : rollo.estado.nombre})',
                  style: TextStyle(
                    fontWeight: tieneMetrosEnCarrito
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: tienePrecioAsignado ? null : Colors.grey.shade700,
                  ),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    children: [
                      TextSpan(
                        text:
                            '${rollo.metrajeActual.toStringAsFixed(2)} m restantes',
                      ),
                      if (tieneMetrosEnCarrito)
                        TextSpan(
                          text:
                              ' - ${metrosEnCarrito.toStringAsFixed(2)} m carrito',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (!tienePrecioAsignado)
                        const TextSpan(
                          text: ' - No se puede vender Sin Precio asignado',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mostrarBotonVentaCompleta)
                      IconButton(
                        icon: const Icon(Icons.archive, color: Colors.blueGrey),
                        tooltip: 'Vender Rollo Completo',
                        onPressed: () => ref
                            .read(carritoVentasProvider.notifier)
                            .agregarRolloCompleto(
                              rollo: rollo,
                              nombre: nombreTela,
                              precio: precioConfig
                                  .precioVentaMetro, // Usamos el precio real de la DB en vez de 500.0 estático
                            ),
                      ),
                    if (mostrarBotonAbrirManualmente)
                      IconButton(
                        icon: const Icon(Icons.lock_open, color: Colors.amber),
                        tooltip: 'Cambiar Estado a Abierto en Mesa',
                        onPressed: () {
                          debugPrint(
                            'Forzando cambio de estado a ABIERTO para el rollo ID: ${rollo.id}',
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Ver Info',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => DetalleRolloDialog(rollo: rollo),
                      ),
                    ),
                    // Solo mostramos el botón de corte/vender si tiene precio asignado en sucursal
                    if (tienePrecioAsignado)
                      IconButton(
                        icon: const Icon(Icons.cut, color: Colors.red),
                        tooltip: 'Vender metraje de este rollo',
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => VenderRolloDialog(
                            rollo: rollo,
                            nombreTela: nombreTela,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
