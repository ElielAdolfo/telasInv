import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inv_telas/core/screens/session_gate_screen.dart';

import 'firebase_options.dart';
import 'config/system_initializer.dart'; // Importamos el inicializador

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseConectado = false;
  String mensaje = '';

  try {
    // 1. Conectar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Inicializar datos del sistema (Menús, Roles, etc.)
    // Esto creará los documentos si no existen
    await SystemInitializer().initialize();

    firebaseConectado = true;
    // mensaje = '✅ Conectado correctamente a Firebase';
  } catch (e) {
    firebaseConectado = false;
    mensaje = '❌ Falló la conexión a Firebase\n\n$e';
  }

  runApp(
    ProviderScope(
      child: MyApp(conectado: firebaseConectado, mensaje: mensaje),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool conectado;
  final String mensaje;

  const MyApp({super.key, required this.conectado, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: conectado
          ? const SessionGateScreen()
          : Scaffold(
              backgroundColor: Colors.red.shade50,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
