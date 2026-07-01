// lib/moduloVentas/screens/ventas_pos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';

import 'package:inv_telas/models/usuario_sucursal_rol.dart';

import 'package:inv_telas/providers/asignacion_provider.dart';
import 'package:inv_telas/providers/ventas_provider.dart';
import 'package:inv_telas/providers/ventas_sucursal_provider.dart';

class VentasPosScreen extends ConsumerStatefulWidget {
  const VentasPosScreen({super.key});

  @override
  ConsumerState<VentasPosScreen> createState() => _VentasPosScreenState();
}

class _VentasPosScreenState extends ConsumerState<VentasPosScreen> {
  bool _cargandoSucursal = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seleccionarSucursalVenta();
    });
  }

  Future<void> _seleccionarSucursalVenta() async {
    try {
      final session = ref.read(sessionProvider);

      final usuario = session.usuario;
      final empresa = session.empresaActual;

      if (usuario == null || empresa == null) {
        return;
      }

      final sucursalesVenta = await ref
          .read(asignacionProvider)
          .obtenerSucursalesVentaUsuario(
            empresaId: empresa.id,
            usuarioId: usuario.id,
          );

      if (sucursalesVenta.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No tiene sucursales autorizadas para realizar ventas',
            ),
          ),
        );

        return;
      }

      // ======================================================
      // SOLO UNA SUCURSAL
      // ======================================================

      if (sucursalesVenta.length == 1) {
        ref.read(sucursalVentaSeleccionadaProvider.notifier).state =
            sucursalesVenta.first.sucursalId;

        return;
      }

      // ======================================================
      // VARIAS SUCURSALES
      // ======================================================

      final sucursalSeleccionada = await _mostrarSelectorSucursal(
        sucursalesVenta,
      );

      if (sucursalSeleccionada == null) {
        return;
      }

      ref.read(sucursalVentaSeleccionadaProvider.notifier).state =
          sucursalSeleccionada;
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargandoSucursal = false;
        });
      }
    }
  }

  Future<String?> _mostrarSelectorSucursal(
    List<UsuarioSucursalRol> sucursales,
  ) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccione la sucursal donde realizará ventas'),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sucursales.length,
              itemBuilder: (_, index) {
                final sucursal = sucursales[index];

                return ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(sucursal.sucursalId),
                  subtitle: const Text('Sucursal autorizada para ventas'),
                  onTap: () {
                    Navigator.pop(context, sucursal.sucursalId);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoSucursal) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final session = ref.watch(sessionProvider);

    final empresaId = session.empresaActual?.id ?? '';

    final sucursalId = ref.watch(sucursalVentaSeleccionadaProvider) ?? '';

    if (sucursalId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No existe una sucursal seleccionada para ventas'),
        ),
      );
    }

    final jornadaAsync = ref.watch(jornadaActivaProvider(sucursalId));

    return Scaffold(
      appBar: AppBar(title: const Text('Módulo de Ventas / Facturación POS')),

      body: jornadaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text('Error: $e')),

        data: (jornada) {
          if (jornada == null || !jornada.abierta) {
            return const Center(child: WidgetFormAperturaJornada());
          }

          return Column(
            children: [
              //=========================================================
              // CABECERA DE JORNADA
              //=========================================================
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
                          "TIPO DE CAMBIO REGISTRADO: "
                          "1 USD = ${jornada.tipoCambio.toStringAsFixed(2)} Bs.",
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
                        'Cerrar Jornada',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => _mostrarDialogoCierre(context),
                    ),
                  ],
                ),
              ),

              //=========================================================
              // CONTENIDO POS
              //=========================================================
              Expanded(
                child: Center(
                  child: Text(
                    'POS cargado para sucursal:\n$sucursalId\n\nEmpresa:\n$empresaId',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogoCierre(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Cerrar Jornada'),
          content: const Text('Implementar formulario de cierre de caja.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

class WidgetFormAperturaJornada extends StatelessWidget {
  const WidgetFormAperturaJornada({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No existe una jornada abierta para hoy.',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
