import 'package:flutter/material.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';
import 'package:uuid/uuid.dart';

class VarianteFormDialog extends StatefulWidget {
  final TipoTelaVariante? variante;

  const VarianteFormDialog({super.key, this.variante});

  @override
  State<VarianteFormDialog> createState() => _VarianteFormDialogState();
}

class _VarianteFormDialogState extends State<VarianteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final proveedorCtrl = TextEditingController();
  final precioCtrl = TextEditingController();

  String monedaId = 'USD';

  @override
  void initState() {
    super.initState();

    final v = widget.variante;
    if (v == null) return;

    proveedorCtrl.text = v.proveedor;
    precioCtrl.text = v.precioCompra.toString();
    monedaId = v.monedaId;
  }

  @override
  void dispose() {
    proveedorCtrl.dispose();
    precioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.variante == null ? 'Nueva Variante' : 'Editar Variante',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: proveedorCtrl,
                decoration: const InputDecoration(labelText: 'Proveedor'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingrese proveedor';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: precioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio compra'),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: monedaId,
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

            final variante = TipoTelaVariante(
              id: widget.variante?.id ?? const Uuid().v4(),
              proveedor: proveedorCtrl.text.trim(),
              precioCompra: double.tryParse(precioCtrl.text) ?? 0,
              monedaId: monedaId,
            );

            Navigator.pop(context, variante);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
