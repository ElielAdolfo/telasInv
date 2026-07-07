import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';
import 'package:inv_telas/providers/carrito_provider.dart';

class VenderRolloDialog extends ConsumerStatefulWidget {
  final StockActual rollo;
  final String nombreTela;

  const VenderRolloDialog({
    super.key,
    required this.rollo,
    required this.nombreTela,
  });

  @override
  ConsumerState<VenderRolloDialog> createState() => __VenderRolloDialogState();
}

class __VenderRolloDialogState extends ConsumerState<VenderRolloDialog> {
  final _metrosVentaCtrl = TextEditingController();
  final _realAjusteCtrl = TextEditingController();
  bool _finalizarRollo = false;

  @override
  void initState() {
    super.initState();
    _realAjusteCtrl.text = widget.rollo.metrajeActual.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _metrosVentaCtrl.dispose();
    _realAjusteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calculamos dinámicamente si ya hay metros de este rollo en el carrito
    final cartState = ref.watch(carritoVentasProvider);
    double metrosEnCarrito = 0.0;

    for (var item in cartState.items) {
      for (var sel in item.rollosSeleccionados) {
        if (sel.rolloId == widget.rollo.id) {
          metrosEnCarrito += sel.metrosExtraidos;
        }
      }
    }

    // 2. Metraje libre disponible real
    final metrosDisponibles = widget.rollo.metrajeActual - metrosEnCarrito;

    return AlertDialog(
      title: Text('Vender de Rollo #${widget.rollo.numeroFisico}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tela: ${widget.nombreTela}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🟢 Visualización Híbrida Inteligente para pantallas móviles
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: metrosEnCarrito > 0
                    ? Colors.blue.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disponible real: ${metrosDisponibles.toStringAsFixed(2)} m',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: metrosEnCarrito > 0
                          ? Colors.blue.shade900
                          : Colors.black87,
                    ),
                  ),
                  if (metrosEnCarrito > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '(Stock total: ${widget.rollo.metrajeActual.toStringAsFixed(2)}m | En carrito: ${metrosEnCarrito.toStringAsFixed(2)}m)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 24),

            TextFormField(
              controller: _metrosVentaCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Metros a Vender',
                suffixText: 'm',
                helperText:
                    'Máximo a retirar: ${metrosDisponibles.toStringAsFixed(2)} m',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.shopping_basket_outlined),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),

            CheckboxListTile(
              title: const Text('Finalizar / Ajustar Rollo en Mesa'),
              subtitle: const Text('Marcar remanente o aplicar ajuste físico'),
              value: _finalizarRollo,
              onChanged: (v) => setState(() => _finalizarRollo = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            if (_finalizarRollo) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _realAjusteCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Medición Real en Mesa (m)',
                  border: OutlineInputBorder(),
                  helperText:
                      'Convierte el excedente o faltante en merma/sobra',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Agregar a la Venta'),
          onPressed: () {
            final metrosAVender = double.tryParse(_metrosVentaCtrl.text) ?? 0.0;

            if (metrosAVender <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, ingresa un metraje válido.'),
                ),
              );
              return;
            }

            // 🟢 CORREGIDO: Compara dinámicamente contra el remanente libre, no contra el stock estático
            if (metrosAVender > metrosDisponibles) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'No puedes agregar más metros de los disponibles (${metrosDisponibles.toStringAsFixed(2)}m) para este rollo.',
                  ),
                ),
              );
              return;
            }

            final exito = ref
                .read(carritoVentasProvider.notifier)
                .agregarMetrosEspecificoDeRollo(
                  rollo: widget.rollo,
                  nombreTela: widget.nombreTela,
                  // Si ya había metros previos en el carrito, se los sumamos para actualizar la línea existente
                  mts: metrosAVender + metrosEnCarrito,
                  precio: 12.5,
                );

            if (exito) {
              if (_finalizarRollo) {
                double medicionReal =
                    double.tryParse(_realAjusteCtrl.text) ?? 0.0;
                print('Ajustando stock físico remanente a: $medicionReal m');
              }
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
