import 'package:flutter/material.dart';
import '../../../models/lotes/lote_detalle.dart';

class LoteDetalleCard extends StatelessWidget {
  final LoteDetalle detalle;

  final String tipoTelaNombre;
  final String? varianteNombre;
  final String? colorNombre;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LoteDetalleCard({
    super.key,
    required this.detalle,
    required this.tipoTelaNombre,
    this.varianteNombre,
    this.colorNombre,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tipoTelaNombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            if (varianteNombre != null) Text("Variante: $varianteNombre"),

            if (colorNombre != null) Text("Color: $colorNombre"),

            const SizedBox(height: 8),

            Text("Rollos: ${detalle.cantidadRollos}"),
            Text("Mts/Rollo: ${detalle.metrosPorRollo}"),
            Text("Total Mts: ${detalle.totalMetros}"),

            const Divider(),

            Text(
              "Costo Mt Origen: ${detalle.costoMetroOrigen.toStringAsFixed(2)}",
            ),

            Text("Costo Mt Base: ${detalle.costoMetroBase.toStringAsFixed(2)}"),

            Text(
              "Costo Rollo Origen: ${detalle.costoRolloOrigen.toStringAsFixed(2)}",
            ),

            Text(
              "Costo Rollo Base: ${detalle.costoRolloBase.toStringAsFixed(2)}",
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
