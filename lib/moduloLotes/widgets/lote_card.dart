import 'package:flutter/material.dart';
import 'package:inv_telas/models/lotes/lote_tipo.dart';
import '../../../models/lotes/lote.dart';
import '../../../models/lotes/lote_estado.dart';

class LoteCard extends StatelessWidget {
  final Lote lote;

  final VoidCallback? onDetalle;
  final VoidCallback? onEditar;
  final VoidCallback? onHistorial;
  final VoidCallback? onGastos;
  final VoidCallback? onEliminar;
  final VoidCallback? onAvanzar; // <-- 1. Agregado

  const LoteCard({
    super.key,
    required this.lote,
    this.onDetalle,
    this.onEditar,
    this.onHistorial,
    this.onGastos,
    this.onEliminar,
    this.onAvanzar, // <-- 2. Agregado al constructor
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
                // <-- 3. Botón de avanzar añadido al inicio del Wrap de acciones
                IconButton(
                  tooltip: 'Avanzar Estado',
                  icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                  onPressed: onAvanzar,
                ),
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
                  tooltip: 'Historial',
                  icon: const Icon(Icons.history),
                  onPressed: onHistorial,
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
