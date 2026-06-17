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
  bool esDiferenciador = false;

  @override
  void initState() {
    super.initState();
    final campo = widget.campo;
    if (campo == null) return;

    nombreCtrl.text = campo.nombre;
    tipo = campo.tipo;
    requerido = campo.requerido;
    esDiferenciador = campo.esDiferenciador;
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    super.dispose();
  }

  // 👈 FUNCIÓN AUTOMÁTICA PARA CONFIGURAR "METRAJE"
  void _cargarPlantillaMetraje() {
    setState(() {
      nombreCtrl.text = 'Metraje';
      tipo = TipoCampo.decimal;
      requerido = true;
      esDiferenciador = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // 👈 AGREGAMOS EL BOTÓN DE AUTO-RELLENADO EN LA BARRA DE TÍTULO
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.campo == null ? 'Nuevo Campo' : 'Editar Campo'),
          if (widget.campo == null) // Solo mostrar si es un campo nuevo
            TextButton.icon(
              onPressed: _cargarPlantillaMetraje,
              icon: const Icon(Icons.flash_on, color: Colors.orange),
              label: const Text(
                'Usar Metraje',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
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
              CheckboxListTile(
                value: esDiferenciador,
                contentPadding: EdgeInsets.zero,
                title: const Text('Es Diferenciador (Genera Variante)'),
                subtitle: const Text(
                  'Si se activa, este campo se definirá individualmente por cada variante.',
                ),
                onChanged: (value) {
                  setState(() {
                    esDiferenciador = value ?? false;
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
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop(
              context,
              CampoConfigurable(
                id: widget.campo?.id ?? const Uuid().v4(),
                empresaId: widget.empresaId,
                nombre: nombreCtrl.text.trim(),
                tipo: tipo,
                requerido: requerido,
                esDiferenciador: esDiferenciador,
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
