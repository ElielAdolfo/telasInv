import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/providers/sucursal_provider.dart';

import '../widgets/empresa_selector.dart';
import '../widgets/sucursal_card.dart';
import '../widgets/sucursal_form_dialog.dart';
import '../widgets/sucursal_table.dart';

class SucursalesAbmScreen extends ConsumerStatefulWidget {
  const SucursalesAbmScreen({super.key});

  @override
  ConsumerState<SucursalesAbmScreen> createState() =>
      _SucursalesAbmScreenState();
}

class _SucursalesAbmScreenState extends ConsumerState<SucursalesAbmScreen> {
  String? empresaId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final session = ref.read(sessionProvider);

      if (!mounted) return;

      setState(() {
        empresaId = session.empresaActual?.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    if (empresaId == null) {
      return const Scaffold(
        body: Center(child: Text('Debe seleccionar una empresa')),
      );
    }

    final sucursalesAsync = ref.watch(sucursalesProvider(empresaId!));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva sucursal'),
        onPressed: () async {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const SucursalFormDialog(sucursal: null),
          );

          ref.invalidate(sucursalesProvider(empresaId!));
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: EmpresaSelector(
                    onChanged: (empresa) {
                      setState(() {
                        empresaId = empresa.id;
                      });

                      ref.invalidate(sucursalesProvider(empresa.id));
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: sucursalesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (e, _) => Center(
                  child: Text(
                    'Error cargando sucursales\n$e',
                    textAlign: TextAlign.center,
                  ),
                ),

                data: (sucursales) {
                  if (sucursales.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.store_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No existen sucursales registradas',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!isMobile) {
                    return SucursalTable(sucursales: sucursales);
                  }

                  return ListView.separated(
                    itemCount: sucursales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      return SucursalCard(sucursal: sucursales[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
