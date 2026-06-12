import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/campo_configurable.dart'; // Asegurar importación de TipoCampo
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';
import '../../../providers/proveedores_provider.dart';

class VarianteTable extends ConsumerWidget {
  final List<TipoTelaVariante> variantes;
  final List<CampoConfigurable>
  camposConfigurables; // 👈 NUEVO: Esquema de campos configurados
  final String empresaId;

  final Function(TipoTelaVariante)? onEdit;
  final Function(TipoTelaVariante)? onDelete;

  const VarianteTable({
    super.key,
    required this.variantes,
    required this.camposConfigurables, // Requerido en constructor
    required this.empresaId,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proveedoresAsync = ref.watch(proveedoresFutureProvider(empresaId));

    // 👈 FILTRAR: Obtenemos solo los campos que actúan como columnas dinámicas
    final columnasDiferenciadoras = camposConfigurables
        .where((c) => c.esDiferenciador)
        .toList();

    return DataTable(
      // COLUMNAS DINÁMICAS
      columns: [
        const DataColumn(label: Text('Proveedor')),
        const DataColumn(label: Text('Precio')),
        const DataColumn(label: Text('Moneda')),
        // Generamos dinámicamente las columnas extras según los campos diferenciadores asignados
        ...columnasDiferenciadoras.map(
          (campo) => DataColumn(label: Text(campo.nombre)),
        ),
        const DataColumn(label: Text('Acciones')),
      ],
      // FILAS DE DATOS
      rows: variantes.map((v) {
        String nombreProveedor = 'Cargando...';

        proveedoresAsync.whenData((listaProveedores) {
          final prov = listaProveedores
              .where((p) => p.id == v.proveedorId)
              .firstOrNull;
          nombreProveedor = prov?.nombre ?? 'No encontrado';
        });

        return DataRow(
          cells: [
            DataCell(Text(nombreProveedor)),
            DataCell(Text(v.precioCompra.toString())),
            DataCell(Text(v.monedaId)),

            // 👈 CELDA DINÁMICA: Mapeamos el valor correspondiente a cada columna dinámica
            ...columnasDiferenciadoras.map((columna) {
              // Buscamos si la variante actual tiene un valor registrado para este campoId
              final valorAsignado = v.campos
                  .where((cVal) => cVal.campoId == columna.id)
                  .firstOrNull;

              if (valorAsignado == null || valorAsignado.valor == null) {
                return const DataCell(
                  Text('-'),
                ); // Celda vacía si no se configuró aún
              }

              // Formateo visual rápido si es booleano
              if (columna.tipo == TipoCampo.booleano) {
                return DataCell(
                  Text(valorAsignado.valor == true ? 'Sí' : 'No'),
                );
              }

              return DataCell(Text(valorAsignado.valor.toString()));
            }),

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
