import 'package:flutter/material.dart';
import 'package:inv_telas/models/abmTiposTelas/campo_configurable.dart';
import 'package:uuid/uuid.dart';

class CampoConfigurableDialog extends StatefulWidget {
  final String empresaId;
  final CampoConfigurable? campo;

  const CampoConfigurableDialog({
    super.key,
    required this.empresaId,
    this.campo,
  });

  @override
  State<CampoConfigurableDialog> createState() =>
      _CampoConfigurableDialogState();
}

class _CampoConfigurableDialogState extends State<CampoConfigurableDialog> {
  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();

  TipoCampo tipo = TipoCampo.texto;

  bool requerido = false;

  @override
  void initState() {
    super.initState();

    final campo = widget.campo;

    if (campo == null) return;

    nombreCtrl.text = campo.nombre;
    tipo = campo.tipo;
    requerido = campo.requerido;
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.campo == null ? 'Nuevo Campo' : 'Editar Campo'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese nombre';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<TipoCampo>(
                value: tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(
                    value: TipoCampo.texto,
                    child: Text('Texto'),
                  ),
                  DropdownMenuItem(
                    value: TipoCampo.entero,
                    child: Text('Entero'),
                  ),
                  DropdownMenuItem(
                    value: TipoCampo.decimal,
                    child: Text('Decimal'),
                  ),
                  DropdownMenuItem(
                    value: TipoCampo.booleano,
                    child: Text('Sí / No'),
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

              CheckboxListTile(
                value: requerido,
                contentPadding: EdgeInsets.zero,
                title: const Text('Requerido'),
                onChanged: (value) {
                  setState(() {
                    requerido = value ?? false;
                  });
                },
              ),
            ],
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
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.pop(
              context,
              CampoConfigurable(
                id: widget.campo?.id ?? const Uuid().v4(),

                empresaId: widget.empresaId,

                nombre: nombreCtrl.text.trim(),

                tipo: tipo,

                requerido: requerido,

                activo: widget.campo?.activo ?? true,

                eliminado: widget.campo?.eliminado ?? false,

                usuarioCreadorId: widget.campo?.usuarioCreadorId,

                usuarioModificadorId: widget.campo?.usuarioModificadorId,

                usuarioEliminadorId: widget.campo?.usuarioEliminadorId,

                fechaCreacion: widget.campo?.fechaCreacion ?? DateTime.now(),

                fechaActualizacion: DateTime.now(),

                fechaEliminacion: widget.campo?.fechaEliminacion,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
