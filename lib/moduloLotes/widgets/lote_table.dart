import 'package:flutter/material.dart';
import '../../../models/lotes/lote.dart';
import '../../../models/lotes/lote_tipo.dart';
import '../../../models/lotes/lote_estado.dart';

class LoteTable extends StatelessWidget {
  final List<Lote> lotes;

  final Function(Lote)? onDetalle;
  final Function(Lote)? onEditar;
  final Function(Lote)? onCosteo;
  final Function(Lote)? onGastos;
  final Function(Lote)? onEliminar;

  const LoteTable({
    super.key,
    required this.lotes,
    this.onDetalle,
    this.onEditar,
    this.onCosteo,
    this.onGastos,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 25,
        columns: const [
          DataColumn(label: Text('Lote')),
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Tipo Cambio')),
          DataColumn(label: Text('Total Gastos')),
          DataColumn(label: Text('Total Final')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: lotes.map((lote) {
          return DataRow(
            cells: [
              DataCell(Text(lote.numeroLote)),

              DataCell(Text(lote.tipo.nombre)),

              DataCell(Text(lote.estado.nombre)),

              DataCell(Text(lote.tipoCambioRegistro.toStringAsFixed(2))),

              DataCell(Text(lote.totalGastos.toStringAsFixed(2))),

              DataCell(Text(lote.totalFinal.toStringAsFixed(2))),

              DataCell(
                Icon(lote.stockGenerado ? Icons.check_circle : Icons.cancel),
              ),

              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Detalle',
                      icon: const Icon(Icons.visibility),
                      onPressed: () => onDetalle?.call(lote),
                    ),

                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEditar?.call(lote),
                    ),

                    IconButton(
                      tooltip: 'Gastos',
                      icon: const Icon(Icons.receipt_long),
                      onPressed: () => onGastos?.call(lote),
                    ),

                    IconButton(
                      tooltip: 'Costeo',
                      icon: const Icon(Icons.calculate),
                      onPressed: () => onCosteo?.call(lote),
                    ),

                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete),
                      onPressed: () => onEliminar?.call(lote),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
