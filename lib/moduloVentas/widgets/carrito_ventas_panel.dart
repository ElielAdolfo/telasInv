import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';

class CarritoVentasPanel extends ConsumerWidget {
  final bool jornadaAbierta;
  final VoidCallback onConfirmar;

  const CarritoVentasPanel({
    super.key,
    required this.jornadaAbierta,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(carritoVentasProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Carrito actual',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (cart.guardandoEnBaseDeDatos)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (cart.tieneErrorSincronizacion)
                const Icon(Icons.cloud_off, color: Colors.orange, size: 18),
            ],
          ),
        ),

        Expanded(
          child: cart.items.isEmpty
              ? const Center(child: Text('No hay productos en el carrito'))
              : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, idx) {
                    final item = cart.items[idx];

                    return ListTile(
                      title: Text(
                        item.detalleAgrupacionNombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      // 🟢 CORREGIDO: Muestra la cantidad física añadida al carrito de forma compacta
                      subtitle: Text(
                        'Bs ${item.precioUnitario} × ${item.cantidadMetros > 0 ? "${item.cantidadMetros.toStringAsFixed(2)} m" : "${item.cantidadRollos} u"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(carritoVentasProvider.notifier)
                              .eliminarItem(item.id);
                        },
                      ),
                    );
                  },
                ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'TOTAL: Bs ${cart.total.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: (!jornadaAbierta || cart.items.isEmpty)
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmActionDialog(
                        title: 'Procesar Orden',
                        message:
                            '¿Registrar venta de forma síncrona inmediata?',
                        icon: Icons.gpp_good_outlined,
                        iconColor: Colors.green,
                        onConfirm: () async {
                          onConfirmar();
                          ref.read(carritoVentasProvider.notifier).limpiar();
                        },
                      ),
                    );
                  },
            child: const Text('PROCESAR COMPRA'),
          ),
        ),
      ],
    );
  }
}
