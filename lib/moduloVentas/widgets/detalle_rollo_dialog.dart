import 'package:flutter/material.dart';
import '../../models/ventas/stock_actual.dart';

class DetalleRolloDialog extends StatelessWidget {
  final StockActual rollo;
  const DetalleRolloDialog({super.key, required this.rollo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Trazabilidad Rollo #${rollo.numeroFisico}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Código Fábrica: ${rollo.idRollo}'),
          Text('Lote Origen: ${rollo.loteId}'),
          Text('Metraje Inicial: ${rollo.metrajeOriginal} m'),
          Text('Metraje Actual: ${rollo.metrajeActual} m'),
          Text('Estado: ${rollo.estado.nombre}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
