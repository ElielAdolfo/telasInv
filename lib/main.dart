import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase con las opciones del proyecto
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const MyApp());
  } catch (e) {
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

// ==========================================
// APLICACIÓN PRINCIPAL
// ==========================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventario de Telas',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const FirebaseTestPage(),
    );
  }
}

// ==========================================
// PANTALLA DE VERIFICACIÓN FIREBASE
// ==========================================

class FirebaseTestPage extends StatelessWidget {
  const FirebaseTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebase = Firebase.app();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación Firebase'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done, size: 85, color: Colors.green),

                  const SizedBox(height: 20),

                  const Text(
                    'Firebase inicializado correctamente',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  const Text('Proyecto Firebase:'),

                  const SizedBox(height: 8),

                  Text(
                    firebase.options.projectId ?? 'Sin ID',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'La aplicación Flutter pudo inicializar Firebase.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA DE ERROR
// ==========================================

class FirebaseErrorApp extends StatelessWidget {
  final String error;

  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        appBar: AppBar(
          title: const Text('Error Firebase'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 85, color: Colors.red),

                const SizedBox(height: 20),

                const Text(
                  'No se pudo conectar con Firebase',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                SelectableText(error, textAlign: TextAlign.center),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    main();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
