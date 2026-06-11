import 'package:flutter/material.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';

class TipoTelaCard extends StatelessWidget {
  final TipoTela tipoTela;

  final VoidCallback? onEdit;

  final VoidCallback? onDelete;

  final VoidCallback? onVariantes;

  const TipoTelaCard({
    super.key,
    required this.tipoTela,
    this.onEdit,
    this.onDelete,
    this.onVariantes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(tipoTela.nombre),
        subtitle: Text('${tipoTela.variantes.length} variantes'),
        children: [
          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: const Text('Administrar variantes'),
            onTap: onVariantes,
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Eliminar'),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
