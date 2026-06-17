import 'package:flutter/material.dart';

import '../../../models/lotes/lote_historial_estado.dart';
import '../../../models/lotes/lote_estado.dart';

class LoteHistorialWidget extends StatelessWidget {
  final List<LoteHistorialEstado> historial;

  const LoteHistorialWidget({super.key, required this.historial});

  String estadoTexto(LoteEstado estado) {
    switch (estado) {
      case LoteEstado.borrador:
        return 'Borrador';

      case LoteEstado.enTransito:
        return 'En Tránsito';

      case LoteEstado.revision:
        return 'Revisión';

      case LoteEstado.finalizado:
        return 'Finalizado';

      case LoteEstado.cancelado:
        return 'Cancelado';
    }
  }

  Color estadoColor(LoteEstado estado) {
    switch (estado) {
      case LoteEstado.borrador:
        return Colors.grey;

      case LoteEstado.enTransito:
        return Colors.orange;

      case LoteEstado.revision:
        return Colors.blue;

      case LoteEstado.finalizado:
        return Colors.green;

      case LoteEstado.cancelado:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return const Center(child: Text('Sin historial disponible'));
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: historial.length,
      separatorBuilder: (_, __) => const Divider(height: 25),
      itemBuilder: (_, index) {
        final item = historial[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: estadoColor(item.estadoNuevo),
            child: const Icon(Icons.history, color: Colors.white),
          ),

          title: Text(
            '${estadoTexto(item.estadoAnterior)} → ${estadoTexto(item.estadoNuevo)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.fechaCreacion.day}/${item.fechaCreacion.month}/${item.fechaCreacion.year}',
              ),

              const SizedBox(height: 4),

              Text('Usuario: ${item.usuarioCreacion}'),

              if ((item.observacion ?? '').trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(item.observacion!),
                ),
            ],
          ),
        );
      },
    );
  }
}
