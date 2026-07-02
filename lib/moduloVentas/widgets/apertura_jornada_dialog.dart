import 'package:flutter/material.dart';

class AperturaJornadaDialog extends StatefulWidget {
  const AperturaJornadaDialog({super.key});

  @override
  State<AperturaJornadaDialog> createState() => _AperturaJornadaDialogState();
}

class _AperturaJornadaDialogState extends State<AperturaJornadaDialog> {
  bool usarMontoInicial = false;

  final montoInicialCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController(text: "6.96");

  final cortes = {
    '200 Bs': TextEditingController(),
    '100 Bs': TextEditingController(),
    '50 Bs': TextEditingController(),
    '20 Bs': TextEditingController(),
    '10 Bs': TextEditingController(),
    '5 Bs': TextEditingController(),
    '2 Bs': TextEditingController(),
    '1 Bs': TextEditingController(),
    '50 Centavos': TextEditingController(),
    '20 Centavos': TextEditingController(),
    '10 Centavos': TextEditingController(),
  };

  @override
  void dispose() {
    montoInicialCtrl.dispose();
    tipoCambioCtrl.dispose();
    for (final c in cortes.values) {
      c.dispose();
    }
    super.dispose();
  }

  double calcularTotalCortes() {
    double total = 0;

    total += (int.tryParse(cortes['200 Bs']!.text) ?? 0) * 200;
    total += (int.tryParse(cortes['100 Bs']!.text) ?? 0) * 100;
    total += (int.tryParse(cortes['50 Bs']!.text) ?? 0) * 50;
    total += (int.tryParse(cortes['20 Bs']!.text) ?? 0) * 20; // 👈 FIX
    total += (int.tryParse(cortes['10 Bs']!.text) ?? 0) * 10;
    total += (int.tryParse(cortes['5 Bs']!.text) ?? 0) * 5;
    total += (int.tryParse(cortes['2 Bs']!.text) ?? 0) * 2;
    total += (int.tryParse(cortes['1 Bs']!.text) ?? 0) * 1;
    total += (int.tryParse(cortes['50 Centavos']!.text) ?? 0) * 0.5;
    total += (int.tryParse(cortes['20 Centavos']!.text) ?? 0) * 0.2;
    total += (int.tryParse(cortes['10 Centavos']!.text) ?? 0) * 0.1;

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Formulario de Apertura'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: tipoCambioCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Tipo de Cambio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              CheckboxListTile(
                value: usarMontoInicial,
                onChanged: (v) {
                  setState(() => usarMontoInicial = v ?? false);
                },
                title: const Text('Usar monto inicial'),
              ),

              if (usarMontoInicial)
                TextFormField(
                  controller: montoInicialCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monto inicial'),
                )
              else
                ...cortes.entries.map((e) {
                  return Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Expanded(
                        child: TextFormField(
                          controller: e.value,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  );
                }),

              const SizedBox(height: 10),
              Text('Total: Bs ${calcularTotalCortes().toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final monto = usarMontoInicial
                ? double.tryParse(montoInicialCtrl.text) ?? 0.0
                : calcularTotalCortes();

            final tc = double.tryParse(tipoCambioCtrl.text) ?? 6.96;

            Navigator.pop(context, {'montoInicial': monto, 'tipoCambio': tc});
          },
          child: const Text('Abrir Jornada'),
        ),
      ],
    );
  }
}
