import 'package:flutter/material.dart';
// CAMBIO 1: Importar Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';

// CAMBIO 2: Importar tu provider de proveedores
import '../../../providers/proveedores_provider.dart';

// CAMBIO 3: Cambiar a ConsumerWidget
class VarianteCard extends ConsumerWidget {
  final TipoTelaVariante variante;
  // CAMBIO 4: Necesitamos el empresaId para buscar el proveedor
  final String empresaId;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VarianteCard({
    super.key,
    required this.variante,
    required this.empresaId, // Añadido como requerido
    this.onEdit,
    this.onDelete,
  });

  // CAMBIO 5: Añadir WidgetRef
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proveedoresAsync = ref.watch(proveedoresFutureProvider(empresaId));

    return proveedoresAsync.when(
      loading: () =>
          const Card(child: ListTile(title: Text('Cargando proveedor...'))),

      error: (e, _) =>
          Card(child: ListTile(title: Text('Error cargando proveedor'))),

      data: (proveedores) {
        final prov = proveedores
            .where((p) => p.id == variante.proveedorId)
            .firstOrNull;

        final nombreProveedor = prov?.nombre ?? 'Proveedor no encontrado';

        return Card(
          child: ExpansionTile(
            title: Text(
              nombreProveedor,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${variante.precioCompra} | moneda: ${variante.monedaId}',
            ),
            children: [
              ListTile(title: Text('Precio compra: ${variante.precioCompra}')),
              const Divider(),
              if (variante.campos.isNotEmpty)
                ...variante.campos.map(
                  (c) => ListTile(
                    title: Text(c.campoNombre),
                    subtitle: Text(c.valor.toString()),
                  ),
                )
              else
                const ListTile(title: Text('Sin campos personalizados')),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
