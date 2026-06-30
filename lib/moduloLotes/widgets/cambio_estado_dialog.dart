import 'package:flutter/material.dart';

import '../../../models/lotes/lote.dart';
import '../../../models/lotes/lote_estado.dart';

class CambioEstadoDialog extends StatefulWidget {
  final Lote lote;
  final Function(LoteEstado nuevoEstado, String observacion) onConfirmar;

  const CambioEstadoDialog({
    super.key,
    required this.lote,
    required this.onConfirmar,
  });

  @override
  State<CambioEstadoDialog> createState() => _CambioEstadoDialogState();
}

class _CambioEstadoDialogState extends State<CambioEstadoDialog> {
  final observacionCtrl = TextEditingController();

  late LoteEstado nuevoEstado;

  @override
  void initState() {
    super.initState();

    nuevoEstado = widget.lote.estado;
  }

  @override
  void dispose() {
    observacionCtrl.dispose();
    super.dispose();
  }

  List<LoteEstado> estadosDisponibles() {
    return LoteEstado.values.where((e) => e != widget.lote.estado).toList();
  }

  String nombreEstado(LoteEstado estado) {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar Estado'),

      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<LoteEstado>(
              initialValue: nuevoEstado,
              decoration: const InputDecoration(labelText: 'Nuevo Estado'),
              items: estadosDisponibles()
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(nombreEstado(e)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  nuevoEstado = value;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: observacionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observación',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),

        ElevatedButton(
          onPressed: () {
            widget.onConfirmar(nuevoEstado, observacionCtrl.text.trim());

            Navigator.pop(context);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
