import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/campo_configurable.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/session_provider.dart';
import '../../../providers/tipo_tela_provider.dart';
import '../../../widgets/confirm_action_dialog.dart';

import 'campo_configurable_dialog.dart';
import 'variante_form_dialog.dart';
import 'variante_card.dart';
import 'variante_table.dart';

class TipoTelaFormDialog extends ConsumerStatefulWidget {
  final TipoTela? tipoTela;

  const TipoTelaFormDialog({super.key, this.tipoTela});

  @override
  ConsumerState<TipoTelaFormDialog> createState() => _TipoTelaFormDialogState();
}

class _TipoTelaFormDialogState extends ConsumerState<TipoTelaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();

  List<TipoTelaVariante> variantes = [];
  List<CampoConfigurable> campos = [];

  @override
  void initState() {
    super.initState();

    final item = widget.tipoTela;
    if (item == null) return;

    nombreCtrl.text = item.nombre;
    variantes = List.from(item.variantes);
    campos = List.from(item.camposConfigurables);
  }

  bool get isEdit => widget.tipoTela != null;

  // ==========================================================
  // MÉTODO CORREGIDO
  // ==========================================================
  Future<void> agregarVariante() async {
    // 1. Obtenemos el ID de la empresa actual desde la sesión
    final empresaId = ref.read(sessionProvider).empresaActual!.id;

    final variante = await showDialog<TipoTelaVariante>(
      context: context,
      barrierDismissible: false, // Recomendado para formularios
      builder: (_) => VarianteFormDialog(
        // 2. Pasamos el empresaId requerido al constructor
        empresaId: empresaId,
      ),
    );

    if (variante == null) return;

    setState(() {
      variantes.add(variante);
    });
  }

  Future<void> agregarCampo() async {
    final empresaId = ref.read(sessionProvider).empresaActual!.id;
    final campo = await showDialog<CampoConfigurable>(
      context: context,
      builder: (_) => CampoConfigurableDialog(empresaId: empresaId),
    );

    if (campo == null) return;

    setState(() {
      campos.add(campo);
    });
  }

  // ==========================================================
  // PASO 1: VALIDAR Y PEDIR CONFIRMACIÓN
  // ==========================================================
  Future<void> solicitarGuardado() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (variantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos una variante')),
      );
      return;
    }

    // Levantar el modal de confirmación
    final fueExitoso = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmActionDialog(
        title: isEdit ? 'Actualizar Tipo Tela' : 'Crear Tipo Tela',
        message: isEdit
            ? '¿Está seguro que desea actualizar este registro?'
            : '¿Está seguro que desea guardar este nuevo tipo de tela?',
        icon: isEdit ? Icons.edit : Icons.save,
        iconColor: Colors.blue,
        confirmText: isEdit ? 'Actualizar' : 'Guardar',
        onConfirm:
            ejecutarGuardadoEnBD, // Pasamos la función que hace el trabajo pesado
      ),
    );

    // Si ConfirmActionDialog devolvió true (éxito), cerramos este formulario
    if (fueExitoso == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  // ==========================================================
  // PASO 2: EJECUCIÓN (Llamado por el ConfirmActionDialog)
  // ==========================================================
  Future<void> ejecutarGuardadoEnBD() async {
    final session = ref.read(sessionProvider);
    final empresa = session.empresaActual!;
    final usuario = session.usuario!;

    final tipoTela = TipoTela(
      id: widget.tipoTela?.id ?? const Uuid().v4(),
      empresaId: empresa.id,
      nombre: nombreCtrl.text.trim(),
      variantes: variantes,
      camposConfigurables: campos,
      activo: true,
      eliminado: false,
      usuarioCreadorId: isEdit ? widget.tipoTela?.usuarioCreadorId : usuario.id,
      usuarioModificadorId: usuario.id,
      fechaCreacion: isEdit ? widget.tipoTela?.fechaCreacion : DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );

    final notifier = ref.read(tipoTelaNotifierProvider.notifier);

    if (isEdit) {
      await notifier.update(tipoTela);
    } else {
      await notifier.create(tipoTela);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Dialog(
      child: SizedBox(
        width: 1200,
        height: 850,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  isEdit ? 'Editar Tipo Tela' : 'Nuevo Tipo Tela',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Tipo Tela',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Variante'),
                      onPressed: agregarVariante,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: const Text('Campo Configurable'),
                      onPressed: agregarCampo,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: isMobile
                      ? ListView.builder(
                          itemCount: variantes.length,
                          itemBuilder: (_, index) {
                            return VarianteCard(
                              variante: variantes[index],
                              empresaId: ref
                                  .read(sessionProvider)
                                  .empresaActual!
                                  .id,
                            );
                          },
                        )
                      : VarianteTable(
                          variantes: variantes,
                          empresaId: ref
                              .read(sessionProvider)
                              .empresaActual!
                              .id,
                        ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Campos configurables',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: campos.length,
                    itemBuilder: (_, index) {
                      final campo = campos[index];

                      return ListTile(
                        leading: const Icon(Icons.tune),
                        title: Text(campo.nombre),
                        subtitle: Text(_tipoCampoTexto(campo.tipo)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Uso del diálogo para confirmar la eliminación de la lista local
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (_) => ConfirmActionDialog(
                                title: 'Quitar campo',
                                message: '¿Desea quitar el campo de la lista?',
                                icon: Icons.delete,
                                iconColor: Colors.red,
                                confirmText: 'Quitar',
                                onConfirm: () async {
                                  // No es necesario llamar a BD aquí, solo aceptamos
                                  await Future.delayed(
                                    const Duration(milliseconds: 200),
                                  );
                                },
                              ),
                            );

                            if (confirmar == true) {
                              setState(() {
                                campos.removeAt(index);
                              });
                            }
                          },
                        ),
                      );
                    },
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

  String _tipoCampoTexto(TipoCampo tipo) {
    switch (tipo) {
      case TipoCampo.texto:
        return 'Texto';
      case TipoCampo.entero:
        return 'Entero';
      case TipoCampo.decimal:
        return 'Decimal';
      case TipoCampo.booleano:
        return 'Sí / No';
    }
  }
}
