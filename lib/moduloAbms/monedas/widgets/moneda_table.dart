import 'package:flutter/material.dart';
import 'package:inv_telas/models/moneda.dart';

class MonedaTable extends StatelessWidget {
  final List<Moneda> monedas;

  final void Function(Moneda moneda) onEditar;
  final void Function(Moneda moneda) onEliminar;

  const MonedaTable({
    super.key,
    required this.monedas,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Código')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Símbolo')),
          DataColumn(label: Text('Decimales')),
          DataColumn(label: Text('Base')),
          DataColumn(label: Text('Tipo Cambio')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: monedas.map((m) {
          return DataRow(
            cells: [
              DataCell(Text(m.codigo)),
              DataCell(Text(m.nombre)),
              DataCell(Text(m.simbolo)),
              DataCell(Text(m.decimales.toString())),
              DataCell(
                Icon(m.esMonedaBase ? Icons.check_circle : Icons.cancel),
              ),
              DataCell(
                Icon(m.permiteTipoCambio ? Icons.check_circle : Icons.cancel),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEditar(m),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onEliminar(m),
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
