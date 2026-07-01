// lib/moduloVentas/screens/ventas_pos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import '../../providers/ventas_provider.dart';

class VentasPosScreen extends ConsumerWidget {
  const VentasPosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final empresaId = session.empresaActual?.id ?? '';
    final sucursalId = '';

    final jornadaAsync = ref.watch(jornadaActivaProvider(sucursalId));

    return Scaffold(
      appBar: AppBar(title: const Text("Módulo de Ventas / Facturación POS")),
      body: jornadaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (jornada) {
          // GESTIÓN DE FLUJO: Si no hay jornada configurada, bloqueamos y exigimos Apertura
          if (jornada == null || !jornada.abierta) {
            return const Center(child: WidgetFormAperturaJornada());
          }

          return Column(
            children: [
              //===========================================================
              // LABEL DEL TIPO DE CAMBIO (REQUERIDO)
              //===========================================================
              Container(
                color: Colors.amber.shade700,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          "TIPO DE CAMBIO REGISTRADO: 1 USD = ${jornada.tipoCambio.toStringAsFixed(2)} Bs.",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                      ),
                      icon: const Icon(Icons.lock_clock, color: Colors.white),
                      label: const Text(
                        "Cerrar Jornada",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => _mostrarDialogoCierre(context, ref),
                    ),
                  ],
                ),
              ),

              // Aquí se despliega el catálogo de rollos en StockActual y tu Carrito de Ventas...
              const Expanded(
                child: Center(
                  child: Text(
                    "Cargar Catálogo de StockActual Filtro por Sucursal",
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogoCierre(BuildContext context, WidgetRef ref) {
    // Diálogo interactivo para recolectar el dinero final de caja y ejecutar `forzarCierre()`
  }
}

class WidgetFormAperturaJornada extends StatelessWidget {
  const WidgetFormAperturaJornada({super.key});
  @override
  Widget build(BuildContext context) {
    // Interfaz con TextFields para capturar Caja Inicial (Bs) y el Tipo de Cambio Actual del mercado boliviano
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No existe una jornada abierta para hoy.",
            style: TextStyle(fontSize: 18),
          ),
          // Formulario de entrada...
        ],
      ),
    );
  }
}
