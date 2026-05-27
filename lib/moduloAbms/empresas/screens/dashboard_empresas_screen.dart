import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/core/screens/principal_shell.dart';

import 'package:inv_telas/moduloAbms/empresas/widgets/empresa_card.dart';
import 'package:inv_telas/moduloAbms/empresas/widgets/empresa_empty_state.dart';

import 'package:inv_telas/providers/auth_provider.dart';

class DashboardEmpresasScreen extends ConsumerWidget {
  const DashboardEmpresasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// USAR SESSION COMO SINGLE SOURCE OF TRUTH
    final session = ref.watch(sessionProvider);

    final empresas = session.empresasDisponibles;

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Empresas'), centerTitle: true),

      body: empresas.isEmpty
          ? EmpresaEmptyState(
              onCrearEmpresa: () {
                print('Crear empresa');
              },

              onUnirseEmpresa: () {
                print('Unirse empresa');
              },

              onEditarPerfil: () {
                print('Editar perfil');
              },

              onCerrarSesion: () async {
                await ref.read(authProvider.notifier).logout();

                /// limpiar session
                ref.read(sessionProvider.notifier).logout();
              },
            )
          : Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tus Empresas',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: GridView.builder(
                      itemCount: empresas.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: isMobile ? 3.8 : 3.2,
                      ),
                      itemBuilder: (_, index) {
                        final empresa = empresas[index];

                        return EmpresaCard(
                          empresa: empresa,
                          onTap: () async {
                            /// CAMBIAR EMPRESA EN SESSION
                            await ref
                                .read(sessionProvider.notifier)
                                .cambiarEmpresa(empresa);

                            if (!context.mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrincipalShell(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (empresas.length < 5)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_business),
                          label: const Text('Crear Empresa'),
                          onPressed: () {
                            print('crear empresa');
                          },
                        ),

                      OutlinedButton.icon(
                        icon: const Icon(Icons.group_add),
                        label: const Text('Unirme a Empresa'),
                        onPressed: () {
                          print('unirme empresa');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
