import 'package:flutter/material.dart';

import '../../../models/lotes/lote_gasto.dart';

class LoteGastosDialog extends StatelessWidget {
  final String loteId;

  final List<LoteGasto> gastos;

  const LoteGastosDialog({
    super.key,
    required this.loteId,
    this.gastos = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 900,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long),

                  const SizedBox(width: 10),

                  Text(
                    'Gastos del Lote',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO
                      // abrir formulario gasto
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: gastos.isEmpty
                    ? const Center(child: Text('No existen gastos registrados'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Descripción')),
                            DataColumn(label: Text('Moneda')),
                            DataColumn(label: Text('Monto')),
                            DataColumn(label: Text('Tipo Cambio')),
                            DataColumn(label: Text('Monto Base')),
                          ],
                          rows: gastos.map((gasto) {
                            return DataRow(
                              cells: [
                                DataCell(Text(gasto.descripcion)),

                                DataCell(Text(gasto.monedaId)),

                                DataCell(Text(gasto.monto.toStringAsFixed(2))),

                                DataCell(
                                  Text(gasto.tipoCambio.toStringAsFixed(2)),
                                ),

                                DataCell(
                                  Text(gasto.montoBase.toStringAsFixed(2)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
