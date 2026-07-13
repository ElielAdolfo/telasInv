import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import 'package:inv_telas/providers/registro_diario_provider.dart'; // Importante añadir tus nuevos providers
import 'package:inv_telas/providers/registro_diario_state.dart';
import 'package:inv_telas/providers/stock_actual_provider.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';

class CarritoVentasPanel extends ConsumerWidget {
  final bool jornadaAbierta;
  final VoidCallback onConfirmar;
  final Map<String, TipoTela> mapaTiposTela;

  const CarritoVentasPanel({
    super.key,
    required this.jornadaAbierta,
    required this.onConfirmar,
    required this.mapaTiposTela,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(carritoVentasProvider);
    // Escuchamos el estado del módulo de registro diario para controlar el loading
    final registroState = ref.watch(registroDiarioProvider);

    // Listener reactivo no intrusivo para alertas rápidas al usuario
    ref.listen<RegistroDiarioState>(registroDiarioProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al vender: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next.exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Venta e inventario registrados con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(registroDiarioProvider.notifier).resetearEstado();
      }
    });

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
                    final nombreTela =
                        mapaTiposTela[item.tipoTelaId]?.nombre ??
                        item.tipoTelaId;

                    final metros = item.cantidadMetros;
                    final esMetraje = metros > 0;
                    final cantidadLabel = esMetraje
                        ? "${metros.toStringAsFixed(2)} m"
                        : "${item.cantidadRollos} u";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombreTela,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cantidad: $cantidadLabel',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Campo editable interactivo en línea para cambiar el precio unitario
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: item.precioUnitario
                                    .toStringAsFixed(2),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Precio (Bs)',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 13),
                                onChanged: (val) {
                                  final nuevoPrecio =
                                      double.tryParse(val) ?? 0.0;
                                  if (nuevoPrecio >= 0) {
                                    ref
                                        .read(carritoVentasProvider.notifier)
                                        .actualizarPrecioItem(
                                          item.id,
                                          nuevoPrecio,
                                        );
                                  }
                                },
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: registroState.procesando
                                  ? null
                                  : () {
                                      ref
                                          .read(carritoVentasProvider.notifier)
                                          .eliminarItem(item.id);
                                    },
                            ),
                          ],
                        ),
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
            // El botón se inhabilita si la jornada está cerrada, el carrito vacío, o ya está procesando en FireStore
            onPressed:
                (!jornadaAbierta ||
                    cart.items.isEmpty ||
                    registroState.procesando)
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
                          // 1. Ejecutamos la venta transaccional pasándole las credenciales dinámicas
                          // Nota: Reemplaza estos strings quemados por tus providers reales de Auth/Sucursal si cuentas con ellos
                          final exito = await ref
                              .read(registroDiarioProvider.notifier)
                              .ejecutarVentaDirecta(
                                usuarioId: 'ID_USUARIO_ACTIVO',
                                usuarioNombre: 'Nombre del Cajero',
                                sucursalId: 'SUCURSAL_ACTUAL',
                              );

                          // 2. Si la transacción fue exitosa, disparamos el callback nativo heredado
                          if (exito) {
                            ref.invalidate(stockActualListProvider);
                            onConfirmar();
                          }
                        },
                      ),
                    );
                  },
            child: registroState.procesando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('PROCESAR COMPRA'),
          ),
        ),
      ],
    );
  }
}
