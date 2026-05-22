import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inv_telas/moduloConfiguracion/screens/configuracion_screen.dart';
import 'package:inv_telas/moduloLotes/screens/lotes_screen.dart';
import 'package:inv_telas/moduloPrecios/screens/precios_screen.dart';
import 'package:inv_telas/moduloRelaciones/screens/relaciones_screen.dart';
import 'package:inv_telas/moduloRelaciones/screens/roles_screen.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/screens/auth_screen.dart';
import 'package:inv_telas/screens/homeScreen.dart';
import 'package:inv_telas/screens/json_view_screen.dart';
import 'package:inv_telas/services/menus_service.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<FirebaseApp> _firebaseFuture;

  @override
  void initState() {
    super.initState();
    _firebaseFuture = _initializeFirebase();
  }

  Future<FirebaseApp> _initializeFirebase() async {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // SOLO UNA VEZ
    await MenusService().seedDefaultMenus();

    return app;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario de Telas',
      debugShowCheckedModeBanner: false,

      // ✅ RUTAS GLOBALES
      routes: {
        '/inventario': (_) => const HomeScreen(),

        '/lotes': (_) => const LotesScreen(),

        '/precios': (_) => const PreciosScreen(),

        '/relaciones': (_) => const RelacionesScreen(),

        '/roles': (_) => const RolesScreen(),

        '/ver-json': (_) => const JsonViewScreen(),

        '/configuracion': (_) => const ConfiguracionScreen(),

        '/roles1': (_) => const ConfiguracionScreen(),
      },

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      home: FutureBuilder<FirebaseApp>(
        future: _firebaseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Error Firebase:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return const AuthGate();
        },
      ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        }

        return const AuthScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const AuthScreen(),
    );
  }
}
