import 'package:flutter/material.dart';
import '../../../models/lotes/lote_detalle.dart';

class LoteDetalleTable extends StatelessWidget {
  final List<LoteDetalle> detalles;

  final String Function(String id) getTipoTelaNombre;

  const LoteDetalleTable({
    super.key,
    required this.detalles,
    required this.getTipoTelaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Tela')),
          DataColumn(label: Text('Rollos')),
          DataColumn(label: Text('Mt/Rollo')),
          DataColumn(label: Text('Total Mt')),
          DataColumn(label: Text('Costo Mt')),
          DataColumn(label: Text('Costo Rollo')),
        ],
        rows: detalles.map((detalle) {
          return DataRow(
            cells: [
              DataCell(Text(getTipoTelaNombre(detalle.tipoTelaId))),

              DataCell(Text(detalle.cantidadRollos.toString())),

              DataCell(Text(detalle.metrosPorRollo.toStringAsFixed(2))),

              DataCell(Text(detalle.totalMetros.toStringAsFixed(2))),

              DataCell(Text(detalle.costoMetroBase.toStringAsFixed(2))),

              DataCell(Text(detalle.costoRolloBase.toStringAsFixed(2))),
            ],
          );
        }).toList(),
      ),
    );
  }
}
