import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/sucursal.dart';

import 'sucursal_form_dialog.dart';

class SucursalTable extends ConsumerWidget {
  final List<Sucursal> sucursales;

  const SucursalTable({super.key, required this.sucursales});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Sucursal')),
            DataColumn(label: Text('Dirección')),
            DataColumn(label: Text('NIT')),
            DataColumn(label: Text('WhatsApp')),
            DataColumn(label: Text('Acciones')),
          ],

          rows: sucursales.map((s) {
            return DataRow(
              cells: [
                DataCell(Text(s.nombre)),

                DataCell(Text(s.direccion)),

                DataCell(Text(s.nit ?? '-')),

                DataCell(Text(s.whatsapp ?? '-')),

                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => SucursalFormDialog(sucursal: s),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
