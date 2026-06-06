import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/providers/empresa_provider.dart';

class CrearEmpresaDialog extends ConsumerStatefulWidget {
  const CrearEmpresaDialog({super.key});

  @override
  ConsumerState<CrearEmpresaDialog> createState() => _CrearEmpresaDialogState();
}

class _CrearEmpresaDialogState extends ConsumerState<CrearEmpresaDialog> {
  final _nombreEmpresaCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();

  final _nombreSucursalCtrl = TextEditingController();
  final _direccionSucursalCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nombreEmpresaCtrl.dispose();
    _nitCtrl.dispose();
    _nombreSucursalCtrl.dispose();
    _direccionSucursalCtrl.dispose();
    super.dispose();
  }

  Future<void> _crearEmpresa() async {
    if (_loading) return;

    final nombreEmpresa = _nombreEmpresaCtrl.text.trim();
    final nombreSucursal = _nombreSucursalCtrl.text.trim();
    final direccionSucursal = _direccionSucursalCtrl.text.trim();

    if (nombreEmpresa.isEmpty) {
      _showError('Ingrese nombre de empresa');
      return;
    }

    if (nombreSucursal.isEmpty) {
      _showError('Ingrese nombre de la sucursal');
      return;
    }

    if (direccionSucursal.isEmpty) {
      _showError('Ingrese dirección de la sucursal');
      return;
    }

    setState(() {
      _loading = true;
    });

    final empresa = await ref
        .read(empresaProvider)
        .crearEmpresa(
          nombreEmpresa: nombreEmpresa,
          nombreSucursal: nombreSucursal,
          direccionSucursal: direccionSucursal,
          nitEmpresa: _nitCtrl.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (empresa == null) {
      _showError('No se pudo crear la empresa');
      return;
    }

    Navigator.pop(context, true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Empresa'),

      content: SizedBox(
        width: 420,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreEmpresaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre Empresa *',
                prefixIcon: Icon(Icons.business),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _nitCtrl,
              decoration: const InputDecoration(
                labelText: 'NIT (Opcional)',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 8),

            Text(
              'Sucursal Inicial',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _nombreSucursalCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre Sucursal *',
                prefixIcon: Icon(Icons.store),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _direccionSucursalCtrl,
              decoration: const InputDecoration(
                labelText: 'Dirección *',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancelar'),
        ),

        ElevatedButton.icon(
          onPressed: _loading ? null : _crearEmpresa,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.add_business),
          label: const Text('Crear'),
        ),
      ],
    );
  }
}
