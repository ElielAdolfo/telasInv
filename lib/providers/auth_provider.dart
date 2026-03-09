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

  // Verificar si ya hay sesión activa al arrancar
  Future<void> _checkSession() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.getUsuarioActual();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Crear el Admin automático al arrancar
  Future<void> _initAdmin() async {
    await _authService.seedAdminUser();
  }

  // Login
  Future<String?> login(String email, String pass) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email, pass);
      if (user != null) {
        state = AsyncValue.data(user);
        return null; // Éxito
      } else {
        state = const AsyncValue.data(null);
        return "Usuario o contraseña incorrectos";
      }
    } catch (e) {
      state = const AsyncValue.data(null);
      return "Error de conexión";
    }
  }

  // Register
  Future<String?> register({
    required String email,
    required String pass,
    required String nombre,
    String rol = 'VENDEDOR',
  }) async {
    return await _authService.register(
      email: email,
      password: pass,
      nombre: nombre,
      rol: rol,
    );
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}
