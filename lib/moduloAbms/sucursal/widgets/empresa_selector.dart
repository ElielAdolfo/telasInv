import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/empresa.dart';

class EmpresaSelector extends ConsumerStatefulWidget {
  final Empresa? initialEmpresa;

  final Function(Empresa) onChanged;

  const EmpresaSelector({
    super.key,
    required this.onChanged,
    this.initialEmpresa,
  });

  @override
  ConsumerState<EmpresaSelector> createState() => _EmpresaSelectorState();
}

class _EmpresaSelectorState extends ConsumerState<EmpresaSelector> {
  Empresa? empresa;

  @override
  void initState() {
    super.initState();

    empresa = widget.initialEmpresa;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    final empresas = session.empresasDisponibles;

    if (empresas.isEmpty) {
      return const SizedBox();
    }

    return DropdownButtonFormField<Empresa>(
      value: empresa,

      decoration: const InputDecoration(
        labelText: 'Empresa',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),

      items: empresas
          .map(
            (e) => DropdownMenuItem<Empresa>(value: e, child: Text(e.nombre)),
          )
          .toList(),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          empresa = value;
        });

        widget.onChanged(value);
      },
    );
  }
}
