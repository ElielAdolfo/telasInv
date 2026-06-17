import 'package:flutter/material.dart';
import '../../../models/lotes/lote.dart';
import '../../../models/lotes/lote_estado.dart';
import '../../../models/lotes/lote_tipo.dart';

class LoteCard extends StatelessWidget {
  final Lote lote;

  final VoidCallback? onDetalle;
  final VoidCallback? onEditar;
  final VoidCallback? onCosteo;
  final VoidCallback? onGastos;
  final VoidCallback? onEliminar;

  const LoteCard({
    super.key,
    required this.lote,
    this.onDetalle,
    this.onEditar,
    this.onCosteo,
    this.onGastos,
    this.onEliminar,
  });

  Color _estadoColor() {
    switch (lote.estado) {
      case LoteEstado.borrador:
        return Colors.grey;

      case LoteEstado.enTransito:
        return Colors.orange;

      case LoteEstado.revision:
        return Colors.blue;

      case LoteEstado.finalizado:
        return Colors.green;

      case LoteEstado.cancelado:
        return Colors.red;
    }
  }

  String _estadoTexto() {
    switch (lote.estado) {
      case LoteEstado.borrador:
        return 'Borrador';

      case LoteEstado.enTransito:
        return 'En Tránsito';

      case LoteEstado.revision:
        return 'Revisión';

      case LoteEstado.finalizado:
        return 'Finalizado';

      case LoteEstado.cancelado:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lote.numeroLote,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(_estadoTexto()),
                  backgroundColor: _estadoColor().withValues(alpha: .15),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text('Tipo: ${lote.tipo.nombre}'),

            const SizedBox(height: 5),

            Text('Total Final: ${lote.totalFinal.toStringAsFixed(2)}'),

            const SizedBox(height: 5),

            Text(
              'Fecha: ${lote.fechaCreacion.day}/${lote.fechaCreacion.month}/${lote.fechaCreacion.year}',
            ),

            const Divider(height: 25),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                IconButton(
                  tooltip: 'Detalle',
                  icon: const Icon(Icons.visibility),
                  onPressed: onDetalle,
                ),

                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  onPressed: onEditar,
                ),

                IconButton(
                  tooltip: 'Gastos',
                  icon: const Icon(Icons.receipt_long),
                  onPressed: onGastos,
                ),

                IconButton(
                  tooltip: 'Costeo',
                  icon: const Icon(Icons.calculate),
                  onPressed: onCosteo,
                ),

                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete),
                  onPressed: onEliminar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
