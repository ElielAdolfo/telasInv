import 'package:flutter/material.dart';
import 'package:inv_telas/models/catalogos.dart';

class PrecioTelaTile extends StatelessWidget {
  final TipoTela tipoTela;
  final double? precioActual;
  final double tipoCambio;
  final bool esBoliviano;
  final Function(double) onPriceChanged;

  const PrecioTelaTile({
    super.key,
    required this.tipoTela,
    required this.precioActual,
    required this.tipoCambio,
    required this.esBoliviano,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: precioActual?.toStringAsFixed(2) ?? '',
    );

    // Cálculo de conversión
    final precioNum = double.tryParse(controller.text) ?? 0.0;
    final totalBs = esBoliviano ? precioNum : precioNum * tipoCambio;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tipoTela.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Precio Compra",
                      suffixText: esBoliviano ? "Bs" : "USD",
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => onPriceChanged(double.tryParse(v) ?? 0.0),
                  ),
                ),
                if (!esBoliviano) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cambio:",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          "${tipoCambio.toStringAsFixed(2)} Bs",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Total Bs:",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          "${totalBs.toStringAsFixed(2)} Bs",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
