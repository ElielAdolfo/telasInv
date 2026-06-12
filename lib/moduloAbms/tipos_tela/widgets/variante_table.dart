import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // CAMBIO 1: Importar Riverpod
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';
import '../../../providers/proveedores_provider.dart'; // CAMBIO 2: Importar proveedores_provider

class VarianteTable extends ConsumerWidget {
  // CAMBIO 3: ConsumerWidget
  final List<TipoTelaVariante> variantes;
  final String empresaId; // CAMBIO 4: Requerimos empresaId

  final Function(TipoTelaVariante)? onEdit;
  final Function(TipoTelaVariante)? onDelete;

  const VarianteTable({
    super.key,
    required this.variantes,
    required this.empresaId, // Actualizado
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CAMBIO 5: Escuchamos los proveedores
    final proveedoresAsync = ref.watch(proveedoresFutureProvider(empresaId));

    return DataTable(
      columns: const [
        DataColumn(label: Text('Proveedor')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Moneda')),
        DataColumn(label: Text('Campos')),
        DataColumn(label: Text('Acciones')),
      ],
      rows: variantes.map((v) {
        // CAMBIO 6: Buscamos el nombre del proveedor
        String nombreProveedor = 'Cargando...';

        proveedoresAsync.whenData((listaProveedores) {
          final prov = listaProveedores
              .where((p) => p.id == v.proveedorId)
              .firstOrNull;
          nombreProveedor = prov?.nombre ?? 'No encontrado';
        });

        return DataRow(
          cells: [
            DataCell(Text(nombreProveedor)), // Usamos el nombre buscado
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
