import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/screens/auth_screen.dart';
import 'package:inv_telas/screens/homeScreen.dart';
import 'firebase_options.dart';

import 'package:inv_telas/services/seed_service.dart';

import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 🔥 Creamos el Future de inicialización
  Future<FirebaseApp> _initializeFirebase() async {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 🔥 Ejecuta precarga eliminarEsto para que no precarge datos
    //await SeedService().initialize();

    return app;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario de Telas',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<FirebaseApp>(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          // 🔄 CARGANDO
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ❌ ERROR
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  '❌ Error al conectar con Firebase\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authProvider);

              return authState.when(
                data: (user) {
                  if (user != null) {
                    // Usuario logueado -> Ir a Home
                    return const HomeScreen();
                  } else {
                    // No hay usuario -> Ir a Login
                    return const AuthScreen();
                  }
                },
                loading: () => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => const AuthScreen(), // En error, mostrar login
              );
            },
          );
        },
      ),
      // ✅ CONECTADO
      /*if (snapshot.hasData) {
            return SafeArea(child: Scaffold(body: HomeScreen()));
          }

          return const SizedBox();*/
    );
  }
}
