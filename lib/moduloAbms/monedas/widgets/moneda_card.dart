import 'package:flutter/material.dart';
import 'package:inv_telas/models/moneda.dart';

class MonedaCard extends StatelessWidget {
  final Moneda moneda;
  final void Function(Moneda moneda) onEditar;
  final void Function(Moneda moneda) onEliminar;

  const MonedaCard({
    super.key,
    required this.moneda,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(child: Text(moneda.simbolo)),
        title: Text(moneda.codigo),
        subtitle: Text(moneda.nombre),
        children: [
          ListTile(
            title: const Text('Símbolo'),
            subtitle: Text(moneda.simbolo),
          ),
          ListTile(
            title: const Text('Decimales'),
            subtitle: Text(moneda.decimales.toString()),
          ),
          ListTile(
            title: const Text('Moneda Base'),
            subtitle: Text(moneda.esMonedaBase ? 'Sí' : 'No'),
          ),
          ListTile(
            title: const Text('Permite Tipo Cambio'),
            subtitle: Text(moneda.permiteTipoCambio ? 'Sí' : 'No'),
          ),
          ButtonBar(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEditar(moneda),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onEliminar(moneda),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
