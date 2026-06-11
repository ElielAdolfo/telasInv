import 'package:flutter/material.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';

class VarianteCard extends StatelessWidget {
  final TipoTelaVariante variante;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VarianteCard({
    super.key,
    required this.variante,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(variante.proveedor),
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
  }
}
