import 'package:flutter/material.dart';
import '../../models/lotes/lote_gasto_agrupado.dart';

class LoteGastoAgrupadoCard extends StatelessWidget {
  final LoteGastoAgrupado item;

  const LoteGastoAgrupadoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final total = item.totalCosto;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.proveedor,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        item.tipoTela,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Wrap distribuye los chips dinámicamente si falta espacio horizontal en teléfonos
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip(Icons.layers, "Rollos", item.cantidadRollos.toString()),
                _chip(
                  Icons.straighten,
                  "Metros",
                  "${item.totalMetros.toStringAsFixed(2)} m",
                ),
                _chip(
                  Icons.attach_money,
                  "Costo por metro",
                  "${item.costoMetroOrigen.toStringAsFixed(2)} ${item.monedaSimbolo}",
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Total",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Text(
                    "${total.toStringAsFixed(2)} ${item.monedaSimbolo}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            "$label: $value",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
