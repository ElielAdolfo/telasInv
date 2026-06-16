import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/models/moneda.dart';
import 'package:inv_telas/moduloAbms/monedas/moneda_validator.dart';
import 'package:inv_telas/providers/moneda_provider.dart';

class MonedaFormDialog extends ConsumerStatefulWidget {
  final String empresaId;
  final String usuarioId;

  final Moneda? monedaAEditar;

  const MonedaFormDialog({
    super.key,
    required this.empresaId,
    required this.usuarioId,
    this.monedaAEditar,
  });

  @override
  ConsumerState<MonedaFormDialog> createState() => _MonedaFormDialogState();
}

class _MonedaFormDialogState extends ConsumerState<MonedaFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController codigoController;
  late TextEditingController nombreController;
  late TextEditingController simboloController;
  late TextEditingController descripcionController;
  late TextEditingController decimalesController;

  bool esMonedaBase = false;
  bool permiteTipoCambio = true;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final moneda = widget.monedaAEditar;

    codigoController = TextEditingController(text: moneda?.codigo ?? '');

    nombreController = TextEditingController(text: moneda?.nombre ?? '');

    simboloController = TextEditingController(text: moneda?.simbolo ?? '');

    descripcionController = TextEditingController(
      text: moneda?.descripcion ?? '',
    );

    decimalesController = TextEditingController(
      text: (moneda?.decimales ?? 2).toString(),
    );

    esMonedaBase = moneda?.esMonedaBase ?? false;
    permiteTipoCambio = moneda?.permiteTipoCambio ?? true;
  }

  @override
  void dispose() {
    codigoController.dispose();
    nombreController.dispose();
    simboloController.dispose();
    descripcionController.dispose();
    decimalesController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final monedas = ref.read(monedasProvider(widget.empresaId)).value ?? [];

      final moneda = Moneda(
        id: widget.monedaAEditar?.id ?? '',
        empresaId: widget.empresaId,

        codigo: codigoController.text.trim(),
        nombre: nombreController.text.trim(),
        simbolo: simboloController.text.trim(),
        descripcion: descripcionController.text.trim().isEmpty
            ? null
            : descripcionController.text.trim(),

        decimales: int.tryParse(decimalesController.text) ?? 2,

        esMonedaBase: esMonedaBase,
        permiteTipoCambio: permiteTipoCambio,

        activo: true,
        eliminado: false,

        usuarioCreacion: widget.usuarioId,
        usuarioModificacion: widget.usuarioId,

        fechaCreacion: widget.monedaAEditar?.fechaCreacion ?? DateTime.now(),

        fechaModificacion: DateTime.now(),
      );

      MonedaValidator.validarOError(moneda: moneda, monedasExistentes: monedas);

      await ref
          .read(monedasProvider(widget.empresaId).notifier)
          .guardarMoneda(moneda);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.monedaAEditar != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(esEdicion ? 'Modificar Moneda' : 'Nueva Moneda'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: codigoController,
                  decoration: const InputDecoration(labelText: 'Código'),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: simboloController,
                  decoration: const InputDecoration(labelText: 'Símbolo'),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: decimalesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Decimales'),
                ),

                SwitchListTile(
                  title: const Text('Moneda Base'),
                  value: esMonedaBase,
                  onChanged: (v) {
                    setState(() {
                      esMonedaBase = v;
                    });
                  },
                ),

                SwitchListTile(
                  title: const Text('Permite Tipo Cambio'),
                  value: permiteTipoCambio,
                  onChanged: (v) {
                    setState(() {
                      permiteTipoCambio = v;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: isLoading ? null : guardar,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(esEdicion ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
}
