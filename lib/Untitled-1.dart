import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/services/auth_service.dart';

// Provider del servicio
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Provider del estado del usuario
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Usuario?>>((
  ref,
) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<Usuario?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _checkSession();
    _initAdmin();
  }

  // Verificar sesión activa al arrancar
  Future<void> _checkSession() async {
    state =
        const AsyncValue.loading(); // Aquí SÍ es necesario para el splash inicial
    try {
      final user = await _authService.getUsuarioActual();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Crear el Admin automático
  Future<void> _initAdmin() async {
    await _authService.seedAdminUser();
  }

  // Login
  Future<String?> login(String email, String pass) async {
    // ✅ QUITAMOS: state = const AsyncValue.loading();
    // Esto evita que el main.dart destruya la pantalla de login mientras esperamos.

    try {
      final user = await _authService.login(email, pass);
      if (user != null) {
        state = AsyncValue.data(
          user,
        ); // Aquí actualizamos el estado global, el main.dart navegará.
        return null; // Éxito
      } else {
        // No cambiamos el estado global, dejamos la pantalla de login como está
        return "Usuario o contraseña incorrectos";
      }
    } catch (e) {
      return "Error de conexión";
    }
  }

  // Register
  Future<String?> register({
    required String email,
    required String pass,
    required String nombre,
    String rolId = 'VENDEDOR',
  }) async {
    // Aquí tampoco necesitamos cambiar el estado global a loading
    return await _authService.register(
      email: email,
      password: pass,
      nombre: nombre,
      rolId: rolId,
    );
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}
