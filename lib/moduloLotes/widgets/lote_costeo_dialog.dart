import 'package:flutter/material.dart';

import '../../../models/lotes/lote_costeo.dart';

class LoteCosteoDialog extends StatelessWidget {
  final String loteId;

  final LoteCosteo? costeo;

  const LoteCosteoDialog({super.key, required this.loteId, this.costeo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 800,
        height: 550,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.calculate),

                  const SizedBox(width: 10),

                  Text(
                    'Costeo del Lote',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              if (costeo == null)
                const Expanded(
                  child: Center(child: Text('No existe costeo generado')),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      Card(
                        child: ListTile(
                          title: const Text('Subtotal Compra'),
                          trailing: Text(
                            costeo!.subtotalCompra.toStringAsFixed(2),
                          ),
                        ),
                      ),

                      Card(
                        child: ListTile(
                          title: const Text('Subtotal Gastos'),
                          trailing: Text(
                            costeo!.subtotalGastos.toStringAsFixed(2),
                          ),
                        ),
                      ),

                      Card(
                        child: ListTile(
                          title: const Text('Costo Final'),
                          trailing: Text(costeo!.costoFinal.toStringAsFixed(2)),
                        ),
                      ),

                      Card(
                        child: ListTile(
                          title: const Text('Costo Metro Final'),
                          trailing: Text(
                            costeo!.costoMetroFinal.toStringAsFixed(2),
                          ),
                        ),
                      ),

                      Card(
                        child: ListTile(
                          title: const Text('Costo Rollo Final'),
                          trailing: Text(
                            costeo!.costoRolloFinal.toStringAsFixed(2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Desglose',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(costeo!.jsonDesglose),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
