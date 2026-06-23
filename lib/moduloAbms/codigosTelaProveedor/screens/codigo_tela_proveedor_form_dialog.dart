import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';
import 'package:uuid/uuid.dart';

import 'package:inv_telas/core/providers/session_provider.dart';

import 'package:inv_telas/models/codigosTelaProveedor/color_codigo.dart';
import 'package:inv_telas/models/codigosTelaProveedor/codigo_unico_tela_proveedor.dart';

import 'package:inv_telas/providers/codigo_unico_tela_proveedor_provider.dart';
import 'package:inv_telas/providers/color_provider.dart';
import 'package:inv_telas/providers/proveedores_provider.dart';
import 'package:inv_telas/providers/tipo_tela_provider.dart';

class _ColorItem {
  String? colorId;
  TextEditingController codigoCtrl;

  _ColorItem({this.colorId, String codigo = ''})
    : codigoCtrl = TextEditingController(text: codigo);
}

class CodigoTelaProveedorFormDialog extends ConsumerStatefulWidget {
  final CodigoUnicoTelaProveedor? data;

  const CodigoTelaProveedorFormDialog({super.key, this.data});

  @override
  ConsumerState<CodigoTelaProveedorFormDialog> createState() => _State();
}

class _State extends ConsumerState<CodigoTelaProveedorFormDialog> {
  final _formKey = GlobalKey<FormState>();

  String? proveedorId;
  String? tipoTelaId;

  final List<_ColorItem> items = [];

  bool get esEdicion => widget.data != null;

  @override
  void initState() {
    super.initState();

    proveedorId = widget.data?.proveedorId;
    tipoTelaId = widget.data?.tipoTelaId;

    if (esEdicion) {
      for (final color in widget.data!.colores) {
        items.add(
          _ColorItem(colorId: color.colorId, codigo: color.codigoColor),
        );
      }

      if (items.isEmpty) {
        items.add(_ColorItem());
      }
    } else {
      items.add(_ColorItem());
    }
  }

  void _addItem() {
    setState(() {
      items.add(_ColorItem());
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (proveedorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione proveedor')));
      return;
    }

    if (tipoTelaId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione tipo de tela')));
      return;
    }

    final session = ref.read(sessionProvider);

    final empresa = session.empresaActual!;
    final usuario = session.usuario!;

    final notifier = ref.read(
      codigoUnicoTelaProveedorNotifierProvider.notifier,
    );

    final coloresGuardar = items
        .where((e) => e.colorId != null && e.codigoCtrl.text.trim().isNotEmpty)
        .map(
          (e) => ColorCodigo(
            colorId: e.colorId!,
            codigoColor: e.codigoCtrl.text.trim(),
          ),
        )
        .toList();

    if (coloresGuardar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un color')),
      );
      return;
    }

    final ids = coloresGuardar.map((e) => e.colorId).toList();

    if (ids.length != ids.toSet().length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No puede repetir colores')));
      return;
    }

    if (esEdicion) {
      await notifier.update(
        widget.data!.copyWith(
          proveedorId: proveedorId,
          tipoTelaId: tipoTelaId,
          colores: coloresGuardar,
          usuarioModificacion: usuario.id,
          fechaModificacion: DateTime.now(),
        ),
      );
    } else {
      final existe = await notifier.existe(
        empresaId: empresa.id,
        proveedorId: proveedorId!,
        tipoTelaId: tipoTelaId!,
      );

      if (existe) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ya existe esta combinación Proveedor + Tipo Tela. Edítela.',
              ),
            ),
          );
        }
        return;
      }

      await notifier.create(
        CodigoUnicoTelaProveedor(
          id: const Uuid().v4(),
          empresaId: empresa.id,
          proveedorId: proveedorId!,
          tipoTelaId: tipoTelaId!,
          colores: coloresGuardar,
          activo: true,
          eliminado: false,
          usuarioCreacion: usuario.id,
          fechaCreacion: DateTime.now(),
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return Colors.grey;
    }

    try {
      final value = hex.replaceAll('#', '');

      return Color(
        int.parse(value.length == 6 ? 'FF$value' : value, radix: 16),
      );
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = ref.watch(sessionProvider).empresaActual!.id;

    final proveedores = ref.watch(proveedoresFutureProvider(empresaId));

    final tipos = ref.watch(tiposTelaProvider(empresaId));

    final colores = ref.watch(coloresProvider(empresaId));

    return AlertDialog(
      title: Text(esEdicion ? 'Editar Código Proveedor' : 'Código Proveedor'),
      content: SizedBox(
        width: 900,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                proveedores.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error proveedores'),
                  data: (list) {
                    return DropdownButtonFormField<String>(
                      value: proveedorId,
                      decoration: const InputDecoration(labelText: 'Proveedor'),
                      items: list
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: esEdicion
                          ? null
                          : (v) {
                              setState(() {
                                proveedorId = v;
                              });
                            },
                    );
                  },
                ),

                const SizedBox(height: 12),

                tipos.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error tipos'),
                  data: (list) {
                    return DropdownButtonFormField<String>(
                      value: tipoTelaId,
                      decoration: const InputDecoration(labelText: 'Tipo Tela'),
                      items: list
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: esEdicion
                          ? null
                          : (v) {
                              setState(() {
                                tipoTelaId = v;
                              });
                            },
                    );
                  },
                ),

                const SizedBox(height: 20),

                colores.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error colores'),
                  data: (listaColores) {
                    return Column(
                      children: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    value: item.colorId,
                                    decoration: const InputDecoration(
                                      labelText: 'Color',
                                    ),
                                    items: listaColores.map((c) {
                                      final colorVisual = _parseColor(
                                        c.hexadecimal,
                                      );

                                      return DropdownMenuItem<String>(
                                        value: c.id,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: colorVisual,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(c.nombre),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        item.colorId = v;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: TextFormField(
                                    controller: item.codigoCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Código',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Requerido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      items.removeAt(index);

                                      if (items.isEmpty) {
                                        items.add(_ColorItem());
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir color'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final confirmar = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => ConfirmActionDialog(
                title: esEdicion ? 'Actualizar registro' : 'Guardar registro',
                message: esEdicion
                    ? '¿Desea actualizar este registro?'
                    : '¿Desea guardar este registro?',
                icon: Icons.save,
                iconColor: Colors.green,
                confirmText: 'Guardar',
                onConfirm: _guardar,
              ),
            );

            if (confirmar == true && mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
