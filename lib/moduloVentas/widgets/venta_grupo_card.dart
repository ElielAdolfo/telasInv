import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import '../../models/ventas/stock_actual.dart';
import 'detalle_rollo_dialog.dart';
import 'vender_rollo_dialog.dart';

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
    // 1. Escuchamos el estado del carrito actual para que el diseño reaccione a los cambios
    final cartState = ref.watch(carritoVentasProvider);

    final activos = rollosGrupo
        .where((r) => r.estado != StockRolloEstado.vendido)
        .length;
    final totalMts = rollosGrupo
        .where((r) => r.estado != StockRolloEstado.vendido)
        .fold(0.0, (sum, r) => sum + r.metrajeActual);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del grupo de telas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nombreTela,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    '$activos Rollos ($totalMts m)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Listado de cada uno de los rollos del grupo
            ...rollosGrupo.where((r) => r.estado != StockRolloEstado.vendido).map((
              rollo,
            ) {
              // 2. Calculamos cuántos metros de ESTE rollo en específico están ya en el carrito
              double metrosEnCarrito = 0.0;
              for (var item in cartState.items) {
                for (var sel in item.rollosSeleccionados) {
                  if (sel.rolloId == rollo.id) {
                    metrosEnCarrito += sel.metrosExtraidos;
                  }
                }
              }

              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.circle,
                  size: 10,
                  color: rollo.estado == StockRolloEstado.abierto
                      ? Colors.green
                      : (rollo.estado == StockRolloEstado.sobra
                            ? Colors.orange
                            : Colors.blue),
                ),
                title: Text(
                  'Rollo #${rollo.numeroFisico} (${rollo.estado.nombre})',
                ),
                // 3. Modificamos el subtítulo usando un RichText para añadir el indicador visual rojo
                subtitle: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13, // Tamaño base similar al original
                      color: Colors.grey.shade600,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${rollo.metrajeActual.toStringAsFixed(2)} m restantes',
                      ),
                      if (metrosEnCarrito > 0)
                        TextSpan(
                          text:
                              ' - ${metrosEnCarrito.toStringAsFixed(2)} m carrito',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rollo.estado == StockRolloEstado.cerrado)
                      IconButton(
                        icon: const Icon(Icons.archive, color: Colors.blueGrey),
                        tooltip: 'Vender Rollo Completo',
                        onPressed: () => ref
                            .read(carritoVentasProvider.notifier)
                            .agregarRolloCompleto(
                              rollo: rollo,
                              nombre: nombreTela,
                              precio: 500.0,
                            ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => DetalleRolloDialog(rollo: rollo),
                      ),
                    ),
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
