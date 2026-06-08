import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/core/screens/principal_shell.dart';

import 'package:inv_telas/moduloAbms/empresas/screens/dashboard_empresas_screen.dart';

import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/screens/auth_screen.dart';

class SessionGateScreen extends ConsumerStatefulWidget {
  const SessionGateScreen({super.key});

  @override
  ConsumerState<SessionGateScreen> createState() => _SessionGateScreenState();
}

class _SessionGateScreenState extends ConsumerState<SessionGateScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },

      error: (_, __) {
        return const AuthScreen();
      },

      data: (user) {
        /// NO LOGIN
        if (user == null) {
          return const AuthScreen();
        }

        /// INIT SOLO UNA VEZ
        if (!_initialized) {
          _initialized = true;

          Future.microtask(() async {
            await ref.read(sessionProvider.notifier).initSession(user);
          });
        }

        final session = ref.watch(sessionProvider);

        /// esperando init
        if (session.usuario == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// SIN EMPRESAS
        if (session.usuario!.esSuperAdmin) {
          return const PrincipalShell();
        }
        if (session.empresasDisponibles.isEmpty) {
          return const DashboardEmpresasScreen();
        }

        /// UNA EMPRESA
        if (session.empresasDisponibles.length == 1) {
          return const PrincipalShell();
        }

        /// VARIAS EMPRESAS
        return const DashboardEmpresasScreen();
      },
    );
  }
}
