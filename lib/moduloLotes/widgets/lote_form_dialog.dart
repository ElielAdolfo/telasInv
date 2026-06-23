import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/providers/sucursal_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/session_provider.dart';

import '../../../models/lotes/lote.dart';
import '../../../models/lotes/lote_estado.dart';
import '../../../models/lotes/lote_tipo.dart';

import '../../../providers/moneda_provider.dart';
import '../../../providers/lote_provider.dart';

import '../../../widgets/confirm_action_dialog.dart';

class LoteFormDialog extends ConsumerStatefulWidget {
  final Lote? lote;

  const LoteFormDialog({super.key, this.lote});

  @override
  ConsumerState<LoteFormDialog> createState() => _LoteFormDialogState();
}

class _LoteFormDialogState extends ConsumerState<LoteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final numeroLoteCtrl = TextEditingController();
  final observacionCtrl = TextEditingController();

  String? monedaId;

  LoteTipo tipo = LoteTipo.local;
  String? sucursalId;

  bool get isEdit => widget.lote != null;

  @override
  void initState() {
    super.initState();

    final lote = widget.lote;

    if (lote == null) return;

    numeroLoteCtrl.text = lote.numeroLote;
    observacionCtrl.text = lote.observacion ?? '';

    monedaId = lote.monedaId;
    tipo = lote.tipo;
    sucursalId = lote.sucursalId;
  }

  @override
  void dispose() {
    numeroLoteCtrl.dispose();
    observacionCtrl.dispose();
    super.dispose();
  }

  Future<void> solicitarGuardado() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fueExitoso = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmActionDialog(
        title: isEdit ? 'Actualizar Lote' : 'Crear Lote',
        message: isEdit
            ? '¿Desea actualizar este lote?'
            : '¿Desea crear este lote?',
        icon: isEdit ? Icons.edit : Icons.save,
        iconColor: Colors.blue,
        confirmText: isEdit ? 'Actualizar' : 'Guardar',
        onConfirm: ejecutarGuardado,
      ),
    );

    if (fueExitoso == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> ejecutarGuardado() async {
    final session = ref.read(sessionProvider);
    final empresa = session.empresaActual!;
    final usuario = session.usuario!;

    final lote = Lote(
      id: widget.lote?.id ?? const Uuid().v4(),
      empresaId: empresa.id,
      sucursalId: sucursalId,
      monedaId: monedaId!,
      numeroLote: numeroLoteCtrl.text.trim(),
      observacion: observacionCtrl.text.trim(),
      tipo: tipo,
      estado: widget.lote?.estado ?? LoteEstado.borrador,

      subtotalMonedaOrigen: widget.lote?.subtotalMonedaOrigen ?? 0,

      subtotalMonedaBase: widget.lote?.subtotalMonedaBase ?? 0,

      totalGastos: widget.lote?.totalGastos ?? 0,
      totalFinal: widget.lote?.totalFinal ?? 0,

      stockGenerado: widget.lote?.stockGenerado ?? false,

      activo: true,
      eliminado: false,

      usuarioCreacion: widget.lote?.usuarioCreacion ?? usuario.id,

      usuarioModificacion: usuario.id,

      fechaCreacion: widget.lote?.fechaCreacion ?? DateTime.now(),

      fechaModificacion: DateTime.now(),
    );

    try {
      await ref
          .read(lotesProvider(empresa.id).notifier)
          .guardarLote(lote, isEdit: isEdit);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = ref.read(sessionProvider).empresaActual!.id;

    final monedasAsync = ref.watch(monedasProvider(empresaId));
    final sucursalesAsync = ref.watch(sucursalesProvider(empresaId));

    return Dialog(
      child: SizedBox(
        width: 900,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  isEdit ? 'Editar Lote' : 'Nuevo Lote',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: numeroLoteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Número Lote',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese número lote';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        DropdownButtonFormField<LoteTipo>(
                          value: tipo,
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          items: const [
                            DropdownMenuItem(
                              value: LoteTipo.local,
                              child: Text('Local'),
                            ),
                            DropdownMenuItem(
                              value: LoteTipo.importacion,
                              child: Text('Importación'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              tipo = value;
                            });
                          },
                        ),

                        const SizedBox(height: 15),

                        sucursalesAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) =>
                              const Text('Error cargando sucursales'),
                          data: (sucursales) {
                            return DropdownButtonFormField<String?>(
                              value: sucursalId,
                              decoration: const InputDecoration(
                                labelText: 'Sucursal',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('S/S (Sin sucursal)'),
                                ),

                                ...sucursales.map(
                                  (s) => DropdownMenuItem<String?>(
                                    value: s.id,
                                    child: Text(s.nombre),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  sucursalId = value;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 15),

                        monedasAsync.when(
                          loading: () => DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Moneda',
                            ),
                            items: const [],
                            onChanged: null,
                            disabledHint: Row(
                              children: const [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Cargando monedas...'),
                              ],
                            ),
                          ),
                          error: (_, __) => DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Moneda',
                            ),
                            items: const [],
                            onChanged: null,
                            disabledHint: const Text('Error al cargar monedas'),
                          ),
                          data: (monedas) {
                            if (!isEdit &&
                                monedaId == null &&
                                monedas.isNotEmpty) {
                              monedaId = monedas.first.id;
                            }

                            if (monedaId != null &&
                                !monedas.any((m) => m.id == monedaId)) {
                              monedaId = null;
                            }

                            return DropdownButtonFormField<String>(
                              value: monedaId,
                              decoration: const InputDecoration(
                                labelText: 'Moneda',
                                hintText: 'Seleccione moneda',
                              ),
                              items: monedas.map((m) {
                                return DropdownMenuItem<String>(
                                  value: m.id,
                                  child: Text('${m.codigo} - ${m.nombre}'),
                                );
                              }).toList(),
                              validator: (v) {
                                if (v == null) {
                                  return 'Seleccione moneda';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  monedaId = value;
                                });
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: observacionCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Observación',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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
                      onPressed: solicitarGuardado,
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
}
