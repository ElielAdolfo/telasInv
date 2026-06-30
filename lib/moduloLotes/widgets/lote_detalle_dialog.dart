import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/models/lotes/lote.dart';
import 'package:inv_telas/models/lotes/lote_tipo.dart';
import 'package:inv_telas/providers/lote_detalle_provider.dart';
import 'package:inv_telas/providers/moneda_provider.dart';
import 'package:inv_telas/services/codigo_tela_proveedor_service.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/session_provider.dart';
import '../../../models/lotes/lote_detalle.dart';
import '../../../models/lotes/codigo_tela_proveedor.dart';

import '../../../providers/tipo_tela_provider.dart';
import '../../../providers/proveedores_provider.dart';
import '../../../providers/codigo_tela_proveedor_provider.dart';

import 'codigo_tela_proveedor_dialog.dart';

class LoteDetalleDialog extends ConsumerStatefulWidget {
  final String loteId;
  final LoteDetalle? detalle;
  final Lote lote;

  const LoteDetalleDialog({
    super.key,
    required this.loteId,
    required this.lote,
    this.detalle,
  });

  @override
  ConsumerState<LoteDetalleDialog> createState() => _LoteDetalleDialogState();
}

class _LoteDetalleDialogState extends ConsumerState<LoteDetalleDialog> {
  final _formKey = GlobalKey<FormState>();

  String? proveedorId;
  String? tipoTelaId;

  Proveedor? proveedorSeleccionado;
  TipoTela? tipoTelaSeleccionado;

  CodigoTelaProveedor? relacionActual;

  final cantidadRollosCtrl = TextEditingController();
  final metrosPorRolloCtrl = TextEditingController();
  final costoMetroOrigenCtrl = TextEditingController();
  final costoMetroBaseCtrl = TextEditingController();

  String? monedaIdSeleccionada;

  bool _editInitialized = false;

  @override
  void initState() {
    super.initState();

    final d = widget.detalle;
    if (d != null) {
      cantidadRollosCtrl.text = d.cantidadRollos.toString();
      metrosPorRolloCtrl.text = d.metrosPorRollo.toString();
      costoMetroOrigenCtrl.text = d.costoMetroOrigen.toString();
      costoMetroBaseCtrl.text = d.costoMetroBase.toString();
    }
  }

  Future<void> _tryInitEdit(
    List<Proveedor> proveedores,
    List<TipoTela> tipos,
    CodigoTelaProveedorService service,
  ) async {
    if (_editInitialized) return;
    if (widget.detalle == null) return;
    if (proveedores.isEmpty || tipos.isEmpty) return;

    _editInitialized = true;

    try {
      final relacion = await service.getById(
        widget.detalle!.codigoTelaProveedorId!,
      );
      if (relacion == null) return;

      final prov = proveedores.firstWhere((p) => p.id == relacion.proveedorId);
      final tipo = tipos.firstWhere((t) => t.id == relacion.tipoTelaId);

      if (!mounted) return;

      setState(() {
        proveedorId = prov.id;
        tipoTelaId = tipo.id;
        proveedorSeleccionado = prov;
        tipoTelaSeleccionado = tipo;
        relacionActual = relacion;

        monedaIdSeleccionada = widget.detalle?.monedaId;
      });
    } catch (e) {
      debugPrint("Error init edit: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = ref.read(sessionProvider).empresaActual!.id;

    final proveedoresAsync = ref.watch(proveedoresFutureProvider(empresaId));
    final tiposAsync = ref.watch(tiposTelaProvider(empresaId));

    final service = ref.read(codigoTelaProveedorServiceProvider);
    final monedasAsync = ref.watch(monedasProvider(empresaId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 720,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === TÍTULO FIJO ===
                Center(
                  child: Text(
                    widget.detalle != null
                        ? 'Editar Detalle de Lote'
                        : 'Nuevo Detalle de Lote',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // === CONTENIDO DEL FORMULARIO CON SCROLL ===
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ================= PROVEEDOR =================
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: proveedoresAsync.when(
                              loading: () => const Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("Cargando proveedores..."),
                                ],
                              ),
                              error: (_, __) =>
                                  const Text("Error al cargar proveedores"),
                              data: (proveedores) {
                                final tipos = tiposAsync.asData?.value ?? [];

                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _tryInitEdit(proveedores, tipos, service);
                                });
                                return DropdownButtonFormField<String>(
                                  initialValue: proveedorId,
                                  decoration: const InputDecoration(
                                    labelText: 'Proveedor',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: proveedores.map((p) {
                                    return DropdownMenuItem(
                                      value: p.id,
                                      child: Text(p.nombre),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      proveedorId = v;
                                      proveedorSeleccionado = proveedores
                                          .firstWhere((p) => p.id == v);

                                      tipoTelaId = null;
                                      tipoTelaSeleccionado = null;
                                      relacionActual = null;
                                      monedaIdSeleccionada = null;

                                      cantidadRollosCtrl.clear();
                                      metrosPorRolloCtrl.clear();
                                      costoMetroOrigenCtrl.clear();
                                      costoMetroBaseCtrl.clear();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                        // ================= TIPO TELA =================
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: tiposAsync.when(
                              loading: () => const Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("Cargando tipos de tela..."),
                                ],
                              ),
                              error: (_, __) =>
                                  const Text("Error al cargar tipos"),
                              data: (tipos) {
                                if (proveedorId == null) {
                                  return const Text(
                                    "⚠️ Selecciona un proveedor primero",
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }

                                final tiposFiltrados = tipos
                                    .where(
                                      (t) => t.variantes.any(
                                        (v) => v.proveedorId == proveedorId,
                                      ),
                                    )
                                    .toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: tipoTelaId,
                                      decoration: const InputDecoration(
                                        labelText: 'Tipo De Tela',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: tiposFiltrados.map((t) {
                                        return DropdownMenuItem(
                                          value: t.id,
                                          child: Text(t.nombre),
                                        );
                                      }).toList(),
                                      onChanged: (v) async {
                                        if (v == null || proveedorId == null) {
                                          return;
                                        }

                                        setState(() {
                                          tipoTelaId = v;
                                          tipoTelaSeleccionado = tiposFiltrados
                                              .firstWhere((t) => t.id == v);
                                          relacionActual = null;
                                        });

                                        final existe = await service.existe(
                                          empresaId: empresaId,
                                          proveedorId: proveedorId!,
                                          tipoTelaId: v,
                                        );

                                        if (existe) {
                                          final data = await service
                                              .getByProveedorTipo(
                                                empresaId: empresaId,
                                                proveedorId: proveedorId!,
                                                tipoTelaId: v,
                                              );

                                          if (data == null) {
                                            print(
                                              'ERROR: existe=true pero getByProveedorTipo retornó null',
                                            );
                                            return;
                                          }
                                          print(
                                            '====================================',
                                          );
                                          print(
                                            'LOTE TIPO: ${widget.lote.tipo.nombre}',
                                          );
                                          print('RELACION ENCONTRADA');
                                          print('ID: ${data.id}');
                                          print('EMPRESA: ${data.empresaId}');
                                          print(
                                            'PROVEEDOR: ${data.proveedorId}',
                                          );
                                          print(
                                            'TIPO TELA: ${data.tipoTelaId}',
                                          );

                                          print(
                                            '---------- IMPORTACION ----------',
                                          );
                                          print(
                                            'MONEDA: ${data.precioImportacion.monedaId}',
                                          );
                                          print(
                                            'PRECIO METRO: ${data.precioImportacion.precioMetro}',
                                          );
                                          print(
                                            'PRECIO ROLLO: ${data.precioImportacion.precioRollo}',
                                          );
                                          print(
                                            'METRAJE FIJO: ${data.precioImportacion.metrajeFijo}',
                                          );

                                          print(
                                            '---------- LOCAL GENERAL ----------',
                                          );
                                          print(
                                            'MONEDA: ${data.precioLocalGeneral.monedaId}',
                                          );
                                          print(
                                            'PRECIO METRO: ${data.precioLocalGeneral.precioMetro}',
                                          );
                                          print(
                                            'PRECIO ROLLO: ${data.precioLocalGeneral.precioRollo}',
                                          );
                                          print(
                                            'METRAJE FIJO: ${data.precioLocalGeneral.metrajeFijo}',
                                          );

                                          print(
                                            '---------- SUCURSALES ----------',
                                          );

                                          for (final suc
                                              in data.preciosLocalPorSucursal) {
                                            print(
                                              'SUCURSAL: ${suc.sucursalId}',
                                            );
                                            print(
                                              'MONEDA: ${suc.precio.monedaId}',
                                            );
                                            print(
                                              'PRECIO METRO: ${suc.precio.precioMetro}',
                                            );
                                            print(
                                              'PRECIO ROLLO: ${suc.precio.precioRollo}',
                                            );
                                            print(
                                              'METRAJE FIJO: ${suc.precio.metrajeFijo}',
                                            );
                                            print(
                                              '-----------------------------',
                                            );
                                          }

                                          print(
                                            '====================================',
                                          );
                                          print(data.toMap());

                                          setState(() {
                                            relacionActual = data;
                                          });

                                          _cargarConfiguracionCosto();
                                          return;
                                        }

                                        if (!mounted) return;

                                        final result = await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) =>
                                              CodigoTelaProveedorDialog(
                                                empresaId: empresaId,
                                                proveedorId: proveedorId!,
                                                tipoTelaId: v,
                                                proveedorNombre:
                                                    proveedorSeleccionado
                                                        ?.nombre ??
                                                    '',
                                                tipoTelaNombre:
                                                    tipoTelaSeleccionado
                                                        ?.nombre ??
                                                    '',
                                              ),
                                        );

                                        if (result == true) {
                                          final data = await service
                                              .getByProveedorTipo(
                                                empresaId: empresaId,
                                                proveedorId: proveedorId!,
                                                tipoTelaId: v,
                                              );

                                          setState(() {
                                            relacionActual = data;
                                          });

                                          _cargarConfiguracionCosto();
                                        } else {
                                          setState(() {
                                            tipoTelaId = null;
                                            tipoTelaSeleccionado = null;
                                          });
                                        }
                                      },
                                    ),
                                    if (relacionActual != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            icon: const Icon(Icons.edit),
                                            label: const Text(
                                              "Editar relación",
                                            ),
                                            onPressed: () async {
                                              final result = await showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) =>
                                                    CodigoTelaProveedorDialog(
                                                      empresaId: empresaId,
                                                      proveedorId: proveedorId!,
                                                      tipoTelaId: tipoTelaId!,
                                                      proveedorNombre:
                                                          proveedorSeleccionado
                                                              ?.nombre ??
                                                          '',
                                                      tipoTelaNombre:
                                                          tipoTelaSeleccionado
                                                              ?.nombre ??
                                                          '',
                                                      relacion: relacionActual,
                                                    ),
                                              );

                                              if (result == true) {
                                                final data = await service
                                                    .getByProveedorTipo(
                                                      empresaId: empresaId,
                                                      proveedorId: proveedorId!,
                                                      tipoTelaId: tipoTelaId!,
                                                    );

                                                setState(() {
                                                  relacionActual = data;
                                                });

                                                _cargarConfiguracionCosto();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ================= MONEDAS Y CAMPOS RESTANTES =================
                        monedasAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                          error: (_, __) =>
                              const Text('Error cargando monedas'),
                          data: (monedas) {
                            if (widget.detalle != null &&
                                monedaIdSeleccionada == null) {
                              /*final id = widget
                                  .detalle!
                                  .monedaId; // (SI NO LO TIENES, aquí está otro bug)

                              final encontrada = monedas.firstWhere(
                                (m) => m.id == id,
                                orElse: () => monedas.first,
                              );

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  monedaIdSeleccionada = encontrada.id;
                                });
                              });*/
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DropdownButtonFormField<String>(
                                initialValue: monedaIdSeleccionada,
                                decoration: const InputDecoration(
                                  labelText: 'Moneda',
                                  border: OutlineInputBorder(),
                                ),
                                items: monedas.map((m) {
                                  return DropdownMenuItem(
                                    value: m.id,
                                    child: Text('${m.simbolo} (${m.codigo})'),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v == null) return;

                                  setState(() {
                                    monedaIdSeleccionada = v;
                                  });

                                  _cargarConfiguracionSegunMoneda();
                                },
                              ),
                            );
                          },
                        ),
                        _input("Cantidad Rollos", cantidadRollosCtrl),
                        _input("Metros por Rollo", metrosPorRolloCtrl),
                        _input("Precio por Metro", costoMetroOrigenCtrl),
                        _input("Precio por Rollo", costoMetroBaseCtrl),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // === BOTONES DE ACCIÓN FIJOS ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (tipoTelaId == null) return;

                        final cantidad =
                            int.tryParse(cantidadRollosCtrl.text) ?? 0;
                        final metros =
                            double.tryParse(metrosPorRolloCtrl.text) ?? 0;

                        final detalle = LoteDetalle(
                          id: widget.detalle?.id ?? const Uuid().v4(),
                          loteId: widget.loteId,
                          tipoTelaId: tipoTelaId!,

                          varianteId: widget.detalle?.varianteId,
                          colorId: widget.detalle?.colorId,

                          codigoTelaProveedorId: relacionActual?.id,

                          monedaId: monedaIdSeleccionada,

                          cantidadRollos: cantidad,
                          metrosPorRollo: metros,
                          totalMetros: cantidad * metros,

                          costoMetroOrigen:
                              double.tryParse(costoMetroOrigenCtrl.text) ?? 0,

                          costoMetroBase:
                              double.tryParse(costoMetroBaseCtrl.text) ?? 0,

                          costoRolloOrigen: 0,
                          costoRolloBase: 0,

                          activo: true,
                          eliminado: false,

                          usuarioCreacion:
                              widget.detalle?.usuarioCreacion ?? '',

                          fechaCreacion:
                              widget.detalle?.fechaCreacion ?? DateTime.now(),
                        );
                        // 1. LLAMAMOS A TU PROPIO PROVIDER (Esperamos a que guarde en la BD)
                        await ref
                            .read(loteDetallesProvider(widget.loteId).notifier)
                            .guardar(detalle);

                        // 2. RECIÉN CUANDO TERMINA EL PROCESO ASÍNCRONO, CERRAMOS EL MODAL
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cantidadRollosCtrl.dispose();
    metrosPorRolloCtrl.dispose();
    costoMetroOrigenCtrl.dispose();
    costoMetroBaseCtrl.dispose();
    super.dispose();
  }

  void _cargarConfiguracionCosto() {
    if (relacionActual == null) return;

    // Si aún no hay moneda seleccionada,
    // usamos la configuración por defecto del lote.
    if (monedaIdSeleccionada == null) {
      if (widget.lote.tipo == LoteTipo.importacion) {
        monedaIdSeleccionada = relacionActual!.precioImportacion.monedaId;
      } else {
        final sucursalId = widget.lote.sucursalId;

        final sucursal = relacionActual!.preciosLocalPorSucursal
            .where((e) => e.sucursalId == sucursalId)
            .toList();

        if (sucursal.isNotEmpty) {
          monedaIdSeleccionada = sucursal.first.precio.monedaId;
        } else {
          monedaIdSeleccionada = relacionActual!.precioLocalGeneral.monedaId;
        }
      }
    }

    _cargarConfiguracionSegunMoneda();
  }

  void _cargarConfiguracionSegunMoneda() {
    if (relacionActual == null) return;
    if (monedaIdSeleccionada == null) return;

    // ================= IMPORTACION =================

    if (relacionActual!.precioImportacion.monedaId == monedaIdSeleccionada) {
      setState(() {
        metrosPorRolloCtrl.text = relacionActual!.precioImportacion.metrajeFijo
            .toString();

        costoMetroOrigenCtrl.text = relacionActual!
            .precioImportacion
            .precioMetro
            .toString();

        costoMetroBaseCtrl.text = relacionActual!.precioImportacion.precioRollo
            .toString();
      });

      return;
    }

    // ================= LOCAL SUCURSAL =================

    final sucursalId = widget.lote.sucursalId;

    if (sucursalId != null) {
      final sucursal = relacionActual!.preciosLocalPorSucursal
          .where(
            (e) =>
                e.sucursalId == sucursalId &&
                e.precio.monedaId == monedaIdSeleccionada,
          )
          .toList();

      if (sucursal.isNotEmpty) {
        final precio = sucursal.first.precio;

        setState(() {
          metrosPorRolloCtrl.text = precio.metrajeFijo.toString();

          costoMetroOrigenCtrl.text = precio.precioMetro.toString();

          costoMetroBaseCtrl.text = precio.precioRollo.toString();
        });

        return;
      }
    }

    // ================= LOCAL GENERAL =================

    if (relacionActual!.precioLocalGeneral.monedaId == monedaIdSeleccionada) {
      setState(() {
        metrosPorRolloCtrl.text = relacionActual!.precioLocalGeneral.metrajeFijo
            .toString();

        costoMetroOrigenCtrl.text = relacionActual!
            .precioLocalGeneral
            .precioMetro
            .toString();

        costoMetroBaseCtrl.text = relacionActual!.precioLocalGeneral.precioRollo
            .toString();
      });

      return;
    }
  }
}
