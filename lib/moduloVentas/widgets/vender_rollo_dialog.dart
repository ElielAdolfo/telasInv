// lib/moduloVentas/widgets/vender_rollo_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import 'package:inv_telas/providers/precio_venta_provider.dart'; // Importante para leer el precio de la sucursal

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
  final _precioManualCtrl =
      TextEditingController(); // Controlador para modificar el precio libremente[cite: 8]
  final _realAjusteCtrl = TextEditingController();
  bool _finalizarRollo = false;
  bool _precioModificadoManualmente =
      false; // Bandera para respetar el input del usuario[cite: 8]

  @override
  void initState() {
    super.initState();
    _realAjusteCtrl.text = widget.rollo.metrajeActual.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _metrosVentaCtrl.dispose();
    _precioManualCtrl.dispose();
    _realAjusteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(carritoVentasProvider);
    final precioConfig = ref.watch(
      precioPorTipoTelaProvider(widget.rollo.tipoTelaId),
    ); //[cite: 8]

    double metrosEnCarrito = 0.0;
    for (var item in cartState.items) {
      for (var sel in item.rollosSeleccionados) {
        if (sel.rolloId == widget.rollo.id) {
          metrosEnCarrito += sel.metrosExtraidos;
        }
      }
    }

    final metrosDisponibles = widget.rollo.metrajeActual - metrosEnCarrito;

    // Obtener metros ingresados actualmente
    final metrosIngresados = double.tryParse(_metrosVentaCtrl.text) ?? 0.0;

    // Lógica de cálculo dinámico de precio sugerido
    double precioSugerido = precioConfig?.precioVentaMetro ?? 0.0;
    if (precioConfig != null && metrosIngresados > 0) {
      precioSugerido = ref
          .read(carritoVentasProvider.notifier)
          .calcularPrecioSugerido(precioConfig, metrosIngresados);
    }

    // Si el usuario no ha editado el precio manualmente, autollenamos el campo
    if (!_precioModificadoManualmente && precioConfig != null) {
      _precioManualCtrl.text = precioSugerido.toStringAsFixed(2);
    }

    final precioFinal =
        double.tryParse(_precioManualCtrl.text) ?? precioSugerido;
    final totalEstimado = metrosIngresados * precioFinal;

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
                ],
              ),
            ),
            const Divider(height: 24),

            // INPUT: Metros a Vender
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
              onChanged: (value) {
                // Al cambiar los metros, se gatilla el setState para recalcular el precio sugerido
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // INPUT NUEVO: Precio Unitario Modificable
            TextFormField(
              controller: _precioManualCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Precio de Venta (Unitario)',
                suffixText: 'Bs',
                helperText: precioConfig != null
                    ? 'Precio base sugerido: Bs ${precioSugerido.toStringAsFixed(2)}'
                    : 'Sin precio configurado',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.monetization_on_outlined),
              ),
              onChanged: (value) {
                // Si el usuario edita este campo, activamos la bandera para detener la sobreescritura automática
                setState(() {
                  _precioModificadoManualmente = true;
                });
              },
            ),

            if (metrosIngresados > 0) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    'Subtotal: Bs ${totalEstimado.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ),
            ],

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

            // Usamos el precio ingresado en el input para la transacción
            final exito = ref
                .read(carritoVentasProvider.notifier)
                .agregarMetrosEspecificoDeRollo(
                  rollo: widget.rollo,
                  nombreTela: widget.nombreTela,
                  mts: metrosAVender + metrosEnCarrito,
                  precio:
                      precioFinal, // Pasamos el valor editado por pantalla[cite: 8]
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
