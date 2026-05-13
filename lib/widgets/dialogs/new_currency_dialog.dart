import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/catalogos.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:uuid/uuid.dart';

class NewCurrencyDialog extends ConsumerStatefulWidget {
  const NewCurrencyDialog({super.key});

  @override
  ConsumerState<NewCurrencyDialog> createState() => _NewCurrencyDialogState();
}

class _NewCurrencyDialogState extends ConsumerState<NewCurrencyDialog> {
  final _nameCtrl = TextEditingController();
  final _symbolCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    
    setState(() => _loading = true);
    
    final newMoneda = Moneda(
      id: const Uuid().v4().toString().substring(0, 12),
      nombre: _nameCtrl.text.toUpperCase(),
      simbolo: _symbolCtrl.text,
    );

    try {
      // Usamos el servicio directamente o el notifier
      await ref.read(catalogServiceProvider).addMoneda(newMoneda);
      // Recargamos la lista de monedas
      ref.read(monedasProvider.notifier).load();
      
      Navigator.pop(context, newMoneda); // Retornamos la nueva moneda
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear moneda: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nueva Moneda"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: "Nombre (ej. Dólar, Yuan)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _symbolCtrl,
            decoration: const InputDecoration(
              labelText: "Símbolo (ej. \$, ¥)",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: _loading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text("Crear"),
        ),
      ],
    );
  }
}