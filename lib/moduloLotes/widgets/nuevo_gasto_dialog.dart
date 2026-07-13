import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/lotes/gastos.dart';
import 'package:inv_telas/models/moneda.dart';
import 'package:inv_telas/providers/moneda_provider.dart';
import 'package:inv_telas/providers/gasto_provider.dart';
// Importamos el provider que contiene la lista de detalles agrupados
import '../../providers/lote_gastos_provider.dart';

class NuevoGastoDialog extends ConsumerStatefulWidget {
  final String empresaId;
  final String? loteDetalleId;
  final String loteId;
  final Gasto? gasto;

  const NuevoGastoDialog({
    super.key,
    required this.empresaId,
    this.loteDetalleId,
    required this.loteId,
    this.gasto,
  });

  @override
  ConsumerState<NuevoGastoDialog> createState() => _NuevoGastoDialogState();
}

class _NuevoGastoDialogState extends ConsumerState<NuevoGastoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _factorConversionCtrl = TextEditingController(text: "1");
  final _tipoCambioCtrl = TextEditingController();

  Moneda? _monedaSeleccionada;
  double _totalCalculadoBs = 0.0;
  bool _estaGuardando = false;

  // Nuevas variables de estado para el tipo de gasto y el lote detalle
  String _tipoGasto = "COMUN"; // "COMUN" o "TRANSPORTE"
  String? _loteDetalleSeleccionadoId;

  @override
  void initState() {
    super.initState();

    final gasto = widget.gasto;

    if (gasto != null) {
      _descripcionCtrl.text = gasto.descripcion;
      _montoCtrl.text = gasto.montoOrigen.toString();
      _factorConversionCtrl.text = gasto.factor.toString();
      _tipoCambioCtrl.text = gasto.tipoCambio.toString();
      _totalCalculadoBs = gasto.totalBs;

      // Si el gasto ya venía con un loteDetalleId, lo marcamos como transporte
      if (gasto.loteDetalleId != null) {
        _tipoGasto = "TRANSPORTE";
        _loteDetalleSeleccionadoId = gasto.loteDetalleId;
      }
    } else if (widget.loteDetalleId != null) {
      // Por si se abre el diálogo pre-seleccionando un detalle desde fuera
      _tipoGasto = "TRANSPORTE";
      _loteDetalleSeleccionadoId = widget.loteDetalleId;
    }
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _montoCtrl.dispose();
    _factorConversionCtrl.dispose();
    _tipoCambioCtrl.dispose();
    super.dispose();
  }

  void _calcularTotal() {
    final monto = double.tryParse(_montoCtrl.text) ?? 0.0;

    if (_monedaSeleccionada == null) return;

    if (_monedaSeleccionada!.esMonedaBase) {
      setState(() {
        _totalCalculadoBs = monto;
      });
    } else {
      final factor = double.tryParse(_factorConversionCtrl.text) ?? 1.0;
      final tipoCambio = double.tryParse(_tipoCambioCtrl.text) ?? 0.0;

      setState(() {
        _totalCalculadoBs = factor > 0 ? (monto / factor) * tipoCambio : 0.0;
      });
    }
  }

  Future<void> _procesarGuardado() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _estaGuardando = true);

    try {
      const usuarioActualId = "usuario_sistema_id";

      final gastoGuardar = Gasto(
        id: widget.gasto?.id ?? '',
        activo: widget.gasto?.activo ?? true,
        eliminado: widget.gasto?.eliminado ?? false,
        usuarioCreacion: widget.gasto?.usuarioCreacion ?? usuarioActualId,
        fechaCreacion: widget.gasto?.fechaCreacion ?? DateTime.now(),
        usuarioModificacion: widget.gasto?.usuarioModificacion,
        fechaModificacion: widget.gasto?.fechaModificacion,
        empresaId: widget.empresaId,
        loteId: widget.loteId,
        // Si es común, se guarda como null. Si es transporte, su ID respectivo
        loteDetalleId: _tipoGasto == "TRANSPORTE"
            ? _loteDetalleSeleccionadoId
            : null,
        descripcion: _descripcionCtrl.text.trim(),
        monedaId: _monedaSeleccionada!.id,
        monedaCodigo: _monedaSeleccionada!.codigo,
        montoOrigen: double.parse(_montoCtrl.text),
        factor: double.tryParse(_factorConversionCtrl.text) ?? 1.0,
        tipoCambio: double.tryParse(_tipoCambioCtrl.text) ?? 1.0,
        totalBs: _totalCalculadoBs,
      );
      await ref
          .read(
            gastosLoteProvider((
              empresaId: widget.empresaId,
              loteId: widget.loteId,
            )).notifier,
          )
          .guardarGasto(gasto: gastoGuardar, usuarioId: usuarioActualId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e, stack) {
      debugPrint("================ ERROR AL GUARDAR GASTO ================");
      debugPrint("Error: $e");
      debugPrint("Stacktrace:\n$stack");
      debugPrint("========================================================");

      if (mounted) {
        setState(() => _estaGuardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar el gasto: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monedasAsync = ref.watch(monedasProvider(widget.empresaId));
    // Obtenemos los detalles agrupados del lote para llenar el select condicional
    final loteGastosState = ref.watch(loteGastosProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final esCelular = constraints.maxWidth < 500;

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                widget.gasto == null ? Icons.add_circle : Icons.edit,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 10),
              Text(widget.gasto == null ? "Registrar Gasto" : "Editar Gasto"),
            ],
          ),
          content: SizedBox(
            width: esCelular ? double.infinity : 460,
            child: monedasAsync.when(
              loading: () => const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    "Error al cargar monedas: $err",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              data: (monedasList) {
                if (monedasList.isEmpty) {
                  return const SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        "No hay monedas configuradas para esta empresa.",
                      ),
                    ),
                  );
                }
                if (_monedaSeleccionada == null) {
                  if (widget.gasto != null) {
                    try {
                      _monedaSeleccionada = monedasList.firstWhere(
                        (m) => m.id == widget.gasto!.monedaId,
                      );
                    } catch (_) {
                      _monedaSeleccionada = monedasList.first;
                    }
                  } else {
                    _monedaSeleccionada = monedasList.firstWhere(
                      (m) => m.esMonedaBase,
                      orElse: () => monedasList.first,
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _calcularTotal();
                    }
                  });
                }

                final esMonedaBase = _monedaSeleccionada?.esMonedaBase ?? true;

                return Form(
                  key: _formKey,
                  child: AbsorbPointer(
                    absorbing: _estaGuardando,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Selector de Tipo de Gasto
                          DropdownButtonFormField<String>(
                            value: _tipoGasto,
                            decoration: const InputDecoration(
                              labelText: "Clasificación del Gasto",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.layers),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "COMUN",
                                child: Text(
                                  "Gastos Comunes (Comida, Pasajes, etc.)",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "TRANSPORTE",
                                child: Text("Gastos de Transporte / Traslado"),
                              ),
                            ],
                            onChanged: (nuevoTipo) {
                              if (nuevoTipo == null) return;
                              setState(() {
                                _tipoGasto = nuevoTipo;
                                // Resetear el detalle si vuelve a común
                                if (_tipoGasto == "COMUN") {
                                  _loteDetalleSeleccionadoId = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 15),

                          // 2. Selector condicional de Lote Detalle (Solo si es transporte)
                          if (_tipoGasto == "TRANSPORTE") ...[
                            DropdownButtonFormField<String>(
                              value: _loteDetalleSeleccionadoId,
                              decoration: const InputDecoration(
                                labelText: "Asociar a Detalle de Lote",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.inventory_2),
                              ),
                              items: loteGastosState.agrupados.map((detalle) {
                                return DropdownMenuItem<String>(
                                  value: detalle.loteDetalleId,
                                  child: Text(
                                    "${detalle.tipoTela} - ${detalle.proveedor} (${detalle.cantidadRollos} Rollos)",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? nuevoDetalleId) {
                                setState(() {
                                  _loteDetalleSeleccionadoId = nuevoDetalleId;
                                });
                              },
                              validator: (v) =>
                                  _tipoGasto == "TRANSPORTE" && v == null
                                  ? "Debe seleccionar un lote detalle"
                                  : null,
                            ),
                            const SizedBox(height: 15),
                          ],

                          TextFormField(
                            controller: _descripcionCtrl,
                            decoration: const InputDecoration(
                              labelText: "Descripción del Gasto",
                              hintText: "Ej: Flete de rollos / Almuerzo equipo",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            validator: (v) =>
                                v!.trim().isEmpty ? "Campo requerido" : null,
                          ),
                          const SizedBox(height: 15),

                          DropdownButtonFormField<Moneda>(
                            initialValue: _monedaSeleccionada,
                            decoration: const InputDecoration(
                              labelText: "Moneda de Origen",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monetization_on),
                            ),
                            items: monedasList.map((moneda) {
                              return DropdownMenuItem<Moneda>(
                                value: moneda,
                                child: Text(
                                  '${moneda.nombre} (${moneda.simbolo})',
                                ),
                              );
                            }).toList(),
                            onChanged: (Moneda? nuevaMoneda) {
                              if (nuevaMoneda == null) return;
                              setState(() {
                                _monedaSeleccionada = nuevaMoneda;
                                if (nuevaMoneda.esMonedaBase) {
                                  _factorConversionCtrl.text = "1";
                                  _tipoCambioCtrl.clear();
                                }
                                _calcularTotal();
                              });
                            },
                          ),
                          const SizedBox(height: 15),

                          TextFormField(
                            controller: _montoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText:
                                  "Monto Original (${_monedaSeleccionada?.simbolo ?? ''})",
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.numbers),
                            ),
                            onChanged: (_) => _calcularTotal(),
                            validator: (v) =>
                                v!.isEmpty ? "Ingrese el monto" : null,
                          ),

                          if (!esMonedaBase) ...[
                            const SizedBox(height: 15),
                            Flex(
                              direction: esCelular
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: esCelular ? 0 : 1,
                                  child: TextFormField(
                                    controller: _factorConversionCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Por cada (Factor)",
                                      hintText: "Ej: 1000 o 1",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (_) => _calcularTotal(),
                                    validator: (v) =>
                                        v!.isEmpty ? "Mínimo 1" : null,
                                  ),
                                ),
                                if (esCelular)
                                  const SizedBox(height: 15)
                                else
                                  const SizedBox(width: 10),
                                Expanded(
                                  flex: esCelular ? 0 : 1,
                                  child: TextFormField(
                                    controller: _tipoCambioCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: "Equivale en Bs a:",
                                      hintText: "Ej: 10.10 o 9.10",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (_) => _calcularTotal(),
                                    validator: (v) =>
                                        v!.isEmpty ? "Requerido" : null,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Total Calculado: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "${_totalCalculadoBs.toStringAsFixed(2)} Bs",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: _estaGuardando ? null : () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: _estaGuardando ? null : _procesarGuardado,
              child: _estaGuardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(widget.gasto == null ? "Guardar" : "Actualizar"),
            ),
          ],
        );
      },
    );
  }
}
