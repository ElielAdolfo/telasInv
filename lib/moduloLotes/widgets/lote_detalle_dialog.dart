import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/session_provider.dart';

import '../../../models/lotes/lote_detalle.dart';

import '../../../providers/tipo_tela_provider.dart';

class LoteDetalleDialog extends ConsumerStatefulWidget {
  final String loteId;
  final LoteDetalle? detalle;

  const LoteDetalleDialog({super.key, required this.loteId, this.detalle});

  @override
  ConsumerState<LoteDetalleDialog> createState() => _LoteDetalleDialogState();
}

class _LoteDetalleDialogState extends ConsumerState<LoteDetalleDialog> {
  final _formKey = GlobalKey<FormState>();

  String? tipoTelaId;
  String? varianteId;
  String? colorId;

  final cantidadRollosCtrl = TextEditingController();
  final metrosPorRolloCtrl = TextEditingController();

  final costoMetroOrigenCtrl = TextEditingController();
  final costoMetroBaseCtrl = TextEditingController();

  bool get isEdit => widget.detalle != null;

  @override
  void initState() {
    super.initState();

    final d = widget.detalle;

    if (d == null) return;

    tipoTelaId = d.tipoTelaId;
    varianteId = d.varianteId;
    colorId = d.colorId;

    cantidadRollosCtrl.text = d.cantidadRollos.toString();

    metrosPorRolloCtrl.text = d.metrosPorRollo.toString();

    costoMetroOrigenCtrl.text = d.costoMetroOrigen.toString();

    costoMetroBaseCtrl.text = d.costoMetroBase.toString();
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = ref.read(sessionProvider).empresaActual!.id;

    final tiposAsync = ref.watch(tiposTelaProvider(empresaId));

    return Dialog(
      child: SizedBox(
        width: 700,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: tiposAsync.when(
              data: (tipos) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit ? 'Editar Detalle' : 'Nuevo Detalle',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: tipoTelaId,
                      decoration: const InputDecoration(labelText: 'Tipo Tela'),
                      items: tipos.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo.id,
                          child: Text(tipo.nombre),
                        );
                      }).toList(),
                      validator: (v) {
                        if (v == null) {
                          return 'Seleccione tipo tela';
                        }
                        return null;
                      },
                      onChanged: (v) {
                        setState(() {
                          tipoTelaId = v;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: cantidadRollosCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad Rollos',
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: metrosPorRolloCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Metros por Rollo',
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: costoMetroOrigenCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Costo Metro Origen',
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: costoMetroBaseCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Costo Metro Base',
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            final cantidad =
                                int.tryParse(cantidadRollosCtrl.text) ?? 0;

                            final metros =
                                double.tryParse(metrosPorRolloCtrl.text) ?? 0;

                            final costoMetroOrigen =
                                double.tryParse(costoMetroOrigenCtrl.text) ?? 0;

                            final costoMetroBase =
                                double.tryParse(costoMetroBaseCtrl.text) ?? 0;

                            final totalMetros = cantidad * metros;

                            final detalle = LoteDetalle(
                              id: widget.detalle?.id ?? const Uuid().v4(),

                              loteId: widget.loteId,

                              tipoTelaId: tipoTelaId!,

                              varianteId: varianteId,

                              colorId: colorId,

                              cantidadRollos: cantidad,

                              metrosPorRollo: metros,

                              totalMetros: totalMetros,

                              costoMetroOrigen: costoMetroOrigen,

                              costoMetroBase: costoMetroBase,

                              costoRolloOrigen: costoMetroOrigen * metros,

                              costoRolloBase: costoMetroBase * metros,

                              activo: true,
                              eliminado: false,

                              usuarioCreacion:
                                  widget.detalle?.usuarioCreacion ?? '',

                              fechaCreacion:
                                  widget.detalle?.fechaCreacion ??
                                  DateTime.now(),
                            );

                            Navigator.pop(context, detalle);
                          },
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error'),
            ),
          ),
        ),
      ),
    );
  }
}
