import 'package:flutter/material.dart';
import '../../models/ventas/jornada_laboral.dart';

class ResumenJornadaCard extends StatelessWidget {
  final JornadaLaboral jornada;
  final VoidCallback onCerrar;

  const ResumenJornadaCard({
    super.key,
    required this.jornada,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TURNO COMERCIAL: ${jornada.fechaDia}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'T.C: ${jornada.tipoCambio} | Caja Inicial: Bs ${jornada.cajaInicialBs} | Reaperturas: ${jornada.reaperturas}/2',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.lock, size: 14),
              label: const Text('Cerrar'),
              onPressed: onCerrar,
            ),
          ],
        ),
      ),
    );
  }
}
