import 'package:flutter/material.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';

class VarianteTable extends StatelessWidget {
  final List<TipoTelaVariante> variantes;

  final Function(TipoTelaVariante)? onEdit;
  final Function(TipoTelaVariante)? onDelete;

  const VarianteTable({
    super.key,
    required this.variantes,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Proveedor')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Moneda')),
        DataColumn(label: Text('Campos')),
        DataColumn(label: Text('Acciones')),
      ],
      rows: variantes.map((v) {
        return DataRow(
          cells: [
            DataCell(Text(v.proveedor)),
            DataCell(Text(v.precioCompra.toString())),
            DataCell(Text(v.monedaId)),
            DataCell(Text(v.campos.length.toString())),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEdit?.call(v),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onDelete?.call(v),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
