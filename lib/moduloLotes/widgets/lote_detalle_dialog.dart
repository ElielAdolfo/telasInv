import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
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

  const LoteDetalleDialog({super.key, required this.loteId, this.detalle});

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

  @override
  Widget build(BuildContext context) {
    final empresaId = ref.read(sessionProvider).empresaActual!.id;

    final proveedoresAsync = ref.watch(proveedoresFutureProvider(empresaId));
    final tiposAsync = ref.watch(tiposTelaProvider(empresaId));

    final service = ref.read(codigoTelaProveedorServiceProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 720,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.detalle != null
                      ? 'Editar Detalle de Lote'
                      : 'Nuevo Detalle de Lote',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text("Cargando proveedores..."),
                        ],
                      ),
                      error: (_, __) =>
                          const Text("Error al cargar proveedores"),
                      data: (proveedores) {
                        return DropdownButtonFormField<String>(
                          value: proveedorId,
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
                              proveedorSeleccionado = proveedores.firstWhere(
                                (p) => p.id == v,
                              );

                              tipoTelaId = null;
                              tipoTelaSeleccionado = null;
                              relacionActual = null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 15),

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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text("Cargando tipos de tela..."),
                        ],
                      ),
                      error: (_, __) => const Text("Error al cargar tipos"),
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
                              value: tipoTelaId,
                              decoration: const InputDecoration(
                                labelText: 'Tipo Tela',
                                border: OutlineInputBorder(),
                              ),
                              items: tiposFiltrados.map((t) {
                                return DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.nombre),
                                );
                              }).toList(),
                              onChanged: (v) async {
                                if (v == null || proveedorId == null) return;

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
                                  final data = await service.getByProveedorTipo(
                                    empresaId: empresaId,
                                    proveedorId: proveedorId!,
                                    tipoTelaId: v,
                                  );

                                  setState(() {
                                    relacionActual = data;
                                  });

                                  return;
                                }

                                final result = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => CodigoTelaProveedorDialog(
                                    empresaId: empresaId,
                                    proveedorId: proveedorId!,
                                    tipoTelaId: v,
                                    proveedorNombre:
                                        proveedorSeleccionado?.nombre ?? '',
                                    tipoTelaNombre:
                                        tipoTelaSeleccionado?.nombre ?? '',
                                  ),
                                );

                                if (result == true) {
                                  final data = await service.getByProveedorTipo(
                                    empresaId: empresaId,
                                    proveedorId: proveedorId!,
                                    tipoTelaId: v,
                                  );

                                  setState(() {
                                    relacionActual = data;
                                  });
                                } else {
                                  setState(() {
                                    tipoTelaId = null;
                                    tipoTelaSeleccionado = null;
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 10),

                            // ================= BOTÓN EDITAR =================
                            if (relacionActual != null)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Editar relación"),
                                  onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => CodigoTelaProveedorDialog(
                                        empresaId: empresaId,
                                        proveedorId: proveedorId!,
                                        tipoTelaId: tipoTelaId!,
                                        proveedorNombre:
                                            proveedorSeleccionado?.nombre ?? '',
                                        tipoTelaNombre:
                                            tipoTelaSeleccionado?.nombre ?? '',
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
                                    }
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _input("Cantidad Rollos", cantidadRollosCtrl),
                _input("Metros por Rollo", metrosPorRolloCtrl),
                _input("Costo Metro Origen", costoMetroOrigenCtrl),
                _input("Costo Metro Base", costoMetroBaseCtrl),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        if (tipoTelaId == null) return;

                        final detalle = LoteDetalle(
                          id: widget.detalle?.id ?? const Uuid().v4(),
                          loteId: widget.loteId,
                          tipoTelaId: tipoTelaId!,
                          varianteId: widget.detalle?.varianteId,
                          colorId: widget.detalle?.colorId,
                          cantidadRollos:
                              int.tryParse(cantidadRollosCtrl.text) ?? 0,
                          metrosPorRollo:
                              double.tryParse(metrosPorRolloCtrl.text) ?? 0,
                          totalMetros: 0,
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

                        Navigator.pop(context, detalle);
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
}
