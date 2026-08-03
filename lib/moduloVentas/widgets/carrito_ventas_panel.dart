import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import 'package:inv_telas/providers/registro_diario_provider.dart';
import 'package:inv_telas/providers/registro_diario_state.dart';
import 'package:inv_telas/providers/stock_actual_provider.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';
import 'package:inv_telas/core/providers/session_provider.dart'; // Importante para la sesión[cite: 1]
import 'package:inv_telas/providers/color_provider.dart'; // Importante para los colores[cite: 1]
import 'package:inv_telas/models/abmTiposTelas/color_tela.dart'; // Modelo del color[cite: 1]

class CarritoVentasPanel extends ConsumerWidget {
  final bool jornadaAbierta;
  final VoidCallback onConfirmar;
  final Map<String, TipoTela> mapaTiposTela;

  final String sucursalId;

  const CarritoVentasPanel({
    super.key,
    required this.jornadaAbierta,
    required this.onConfirmar,
    required this.mapaTiposTela,
    required this.sucursalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(carritoVentasProvider);
    final registroState = ref.watch(registroDiarioProvider);

    // Obtenemos la empresa de la sesión actual[cite: 1]
    final session = ref.watch(sessionProvider);
    final empresaId = session.empresaActual?.id ?? '';
    final usuario = session.usuario;

    // Escuchamos la lista de colores maestros[cite: 1]
    final coloresAsync = ref.watch(coloresProvider(empresaId));

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

                    // --- CALCULAR EL TOTAL DE ESTE ITEM ESPECÍFICO ---
                    final factorCantidad = esMetraje
                        ? metros
                        : item.cantidadRollos.toDouble();
                    final subtotalItem = factorCantidad * item.precioUnitario;

                    // --- LÓGICA PARA RENDERIZAR LA ESFERA Y OBTENER EL NOMBRE DEL COLOR ---[cite: 1]
                    Widget widgetColorEsfera = const SizedBox.shrink();
                    String nombreColorTexto = "S/C";

                    final String? itemColorId = (item as dynamic).colorId;

                    if (itemColorId != null && itemColorId.isNotEmpty) {
                      widgetColorEsfera = coloresAsync.when(
                        data: (listaColores) {
                          final colorEncontrado = listaColores.firstWhere(
                            (c) => c.id == itemColorId,
                            orElse: () => ColorTela(
                              id: '',
                              empresaId: empresaId,
                              nombre: 'N/A',
                              hexadecimal: 'CCCCCC',
                            ),
                          );

                          nombreColorTexto = colorEncontrado.nombre;

                          return Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colorEncontrado.toFlutterColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 1.2,
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                        error: (_, __) => Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    } else {
                      widgetColorEsfera = Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // 1. Esfera de color[cite: 1]
                            widgetColorEsfera,
                            const SizedBox(width: 8),

                            // 2. Información del Item
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
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      // Badge pequeño con el nombre del color[cite: 1]
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          nombreColorTexto.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Cant: $cantidadLabel',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // 3. Columna del Precio editable y el Subtotal calculado por item
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 85,
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
                                      style: const TextStyle(fontSize: 12),
                                      onChanged: (val) {
                                        final nuevoPrecio =
                                            double.tryParse(val) ?? 0.0;
                                        if (nuevoPrecio >= 0) {
                                          ref
                                              .read(
                                                carritoVentasProvider.notifier,
                                              )
                                              .actualizarPrecioItem(
                                                item.id,
                                                nuevoPrecio,
                                              );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Texto que indica el total del item de forma clara
                                  Text(
                                    'Subt: Bs ${subtotalItem.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 4. Botón de borrado
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
                          final exito = await ref
                              .read(registroDiarioProvider.notifier)
                              .ejecutarVentaDirecta(
                                usuarioId: usuario!.id,
                                usuarioNombre: usuario.nombre,
                                sucursalId: sucursalId,
                              );

                          if (exito) {
                            // 🟢 REFRESCAR / INVALIDAR TODOS LOS PROVIDERS DE STOCK AFECTADOS
                            ref.invalidate(stockActualListProvider);
                            ref.invalidate(tiposTelaDisponiblesProvider);
                            ref.invalidate(stockPorTipoProvider);

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
