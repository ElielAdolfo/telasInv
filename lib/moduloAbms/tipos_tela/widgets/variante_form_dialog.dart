import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/campo_configurable.dart'; // Importación necesaria de los tipos de campo
import 'package:inv_telas/models/abmTiposTelas/campo_valor.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/session_provider.dart';
import '../../../providers/proveedores_provider.dart';
import 'proveedores_selector_dialog.dart';

class VarianteFormDialog extends ConsumerStatefulWidget {
  final TipoTelaVariante? variante;
  final List<CampoConfigurable>
  camposConfigurables; // 👈 NUEVO: Esquema de atributos de la tela
  final String empresaId;

  const VarianteFormDialog({
    super.key,
    this.variante,
    required this.camposConfigurables, // Agregado obligatoriamente
    required this.empresaId,
  });

  @override
  ConsumerState<VarianteFormDialog> createState() => _VarianteFormDialogState();
}

class _VarianteFormDialogState extends ConsumerState<VarianteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final precioCtrl = TextEditingController();

  Proveedor? proveedorSeleccionado;
  String monedaId = 'USD';
  bool _inicializado = false;

  // 👈 DICCIONARIOS DE CONTROL: Administran dinámicamente inputs según el Tipo de Campo
  final Map<String, TextEditingController> _dinamicosTextCtrls = {};
  final Map<String, bool> _dinamicosBoolValues = {};

  @override
  void initState() {
    super.initState();

    final v = widget.variante;
    if (v != null) {
      precioCtrl.text = v.precioCompra.toString();
      monedaId = v.monedaId;
    }

    // 👈 PREPARAR FORMULARIO DINÁMICO
    final diferenciadores = widget.camposConfigurables
        .where((c) => c.esDiferenciador)
        .toList();
    for (var campo in diferenciadores) {
      // Si estamos editando una variante, buscamos su valor existente en su lista 'campos'
      final valorExistente = v?.campos
          .where((vc) => vc.campoId == campo.id)
          .firstOrNull;

      if (campo.tipo == TipoCampo.booleano) {
        _dinamicosBoolValues[campo.id] = valorExistente?.valor == true;
      } else {
        _dinamicosTextCtrls[campo.id] = TextEditingController(
          text: valorExistente?.valor?.toString() ?? '',
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado && widget.variante != null) {
      _inicializarProveedorDesdeId(widget.variante!.proveedorId);
      _inicializado = true;
    }
  }

  Future<void> _inicializarProveedorDesdeId(String proveedorId) async {
    if (proveedorId.isEmpty) return;
    final proveedoresAsync = await ref.read(
      proveedoresFutureProvider(widget.empresaId).future,
    );
    final pEncontrado = proveedoresAsync.cast<Proveedor?>().firstWhere(
      (p) => p?.id == proveedorId,
      orElse: () => null,
    );
    if (mounted && pEncontrado != null) {
      setState(() {
        proveedorSeleccionado = pEncontrado;
      });
    }
  }

  @override
  void dispose() {
    precioCtrl.dispose();
    // 👈 IMPORTANTE: Liberar memoria de controladores creados al vuelo
    for (var ctrl in _dinamicosTextCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _abrirSelectorProveedor() async {
    final proveedorElegido = await showDialog<Proveedor>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProveedoresSelectorDialog(
        empresaId: widget.empresaId,
        proveedorIdInicial: proveedorSeleccionado?.id,
      ),
    );

    if (mounted && proveedorElegido != null) {
      setState(() {
        proveedorSeleccionado = proveedorElegido;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final diferenciadores = widget.camposConfigurables
        .where((c) => c.esDiferenciador)
        .toList();

    return AlertDialog(
      title: Text(
        widget.variante == null ? 'Nueva Variante' : 'Editar Variante',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Añadido preventivo por crecimiento vertical dinámico
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _abrirSelectorProveedor,
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: TextEditingController(
                        text: proveedorSeleccionado?.nombre ?? '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Proveedor (Obligatorio)',
                        hintText: 'Toque para seleccionar/gestionar',
                        prefixIcon: Icon(Icons.business_outlined),
                        suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                      ),
                      validator: (_) => proveedorSeleccionado == null
                          ? 'Seleccione proveedor'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: precioCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Precio compra'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (double.tryParse(v) == null) return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: monedaId,
                  decoration: const InputDecoration(labelText: 'Moneda'),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'BOB', child: Text('BOB')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      monedaId = v;
                    });
                  },
                ),

                // ==========================================================
                // 👈 RENDERIZADO COMPLEMENTARIO DE INPUTS DINÁMICOS
                // ==========================================================
                if (diferenciadores.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  ...diferenciadores.map((campo) {
                    // RAMA BOOLEANA
                    if (campo.tipo == TipoCampo.booleano) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(campo.nombre),
                        value: _dinamicosBoolValues[campo.id] ?? false,
                        onChanged: (val) {
                          setState(() {
                            _dinamicosBoolValues[campo.id] = val ?? false;
                          });
                        },
                      );
                    }

                    // RAMA TEXTO / NUMÉRICOS
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: _dinamicosTextCtrls[campo.id],
                        decoration: InputDecoration(
                          labelText:
                              campo.nombre +
                              (campo.requerido ? ' (Obligatorio)' : ''),
                        ),
                        keyboardType: campo.tipo == TipoCampo.entero
                            ? TextInputType.number
                            : campo.tipo == TipoCampo.decimal
                            ? const TextInputType.numberWithOptions(
                                decimal: true,
                              )
                            : TextInputType.text,
                        validator: (value) {
                          if (campo.requerido &&
                              (value == null || value.trim().isEmpty)) {
                            return 'El campo "${campo.nombre}" es obligatorio';
                          }
                          if (value != null && value.trim().isNotEmpty) {
                            if (campo.tipo == TipoCampo.entero &&
                                int.tryParse(value) == null) {
                              return 'Debe ser un número entero';
                            }
                            if (campo.tipo == TipoCampo.decimal &&
                                double.tryParse(value) == null) {
                              return 'Debe ser un número decimal';
                            }
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                ],
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
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            if (proveedorSeleccionado == null) return;

            // 👈 CONSTRUCCIÓN DEL LISTADO DE VALORES ASIGNADOS A LA VARIANTE
            final List<CampoValor> listadoValoresFinales = [];

            for (var campo in diferenciadores) {
              dynamic valorProcesado;

              if (campo.tipo == TipoCampo.booleano) {
                valorProcesado = _dinamicosBoolValues[campo.id] ?? false;
              } else {
                final stringRaw =
                    _dinamicosTextCtrls[campo.id]?.text.trim() ?? '';
                if (stringRaw.isNotEmpty) {
                  if (campo.tipo == TipoCampo.entero) {
                    valorProcesado = int.tryParse(stringRaw);
                  }
                  if (campo.tipo == TipoCampo.decimal) {
                    valorProcesado = double.tryParse(stringRaw);
                  }
                  if (campo.tipo == TipoCampo.texto) valorProcesado = stringRaw;
                }
              }

              listadoValoresFinales.add(
                CampoValor(
                  campoId: campo.id,
                  campoNombre: campo.nombre,
                  valor: valorProcesado,
                ),
              );
            }

            final variante = TipoTelaVariante(
              id: widget.variante?.id ?? const Uuid().v4(),
              proveedorId: proveedorSeleccionado!.id,
              precioCompra: double.tryParse(precioCtrl.text) ?? 0,
              monedaId: monedaId,
              campos:
                  listadoValoresFinales, // 👈 ENVIANDO CAMPOS VALOR DINÁMICOS COMPLETOS
              activo: widget.variante?.activo ?? true,
              eliminado: widget.variante?.eliminado ?? false,
            );

            Navigator.pop(context, variante);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
