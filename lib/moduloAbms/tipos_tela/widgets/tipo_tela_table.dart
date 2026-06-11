import 'package:flutter/material.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';

class TipoTelaTable extends StatelessWidget {
  final List<TipoTela> tiposTela;

  final void Function(TipoTela tipoTela)? onEdit;

  final void Function(TipoTela tipoTela)? onDelete;

  final void Function(TipoTela tipoTela)? onVariantes;

  const TipoTelaTable({
    super.key,
    required this.tiposTela,
    this.onEdit,
    this.onDelete,
    this.onVariantes,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Variantes')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: tiposTela.map((tipoTela) {
          return DataRow(
            cells: [
              DataCell(Text(tipoTela.nombre)),
              DataCell(Text(tipoTela.variantes.length.toString())),
              DataCell(
                Chip(label: Text(tipoTela.activo ? 'Activo' : 'Inactivo')),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.layers_outlined),
                      onPressed: () => onVariantes?.call(tipoTela),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEdit?.call(tipoTela),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => onDelete?.call(tipoTela),
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
