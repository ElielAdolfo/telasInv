import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Usuario?>>((
  ref,
) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<Usuario?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      try {
        if (firebaseUser == null) {
          state = const AsyncValue.data(null);
          return;
        }

        final usuario = await _authService.getUsuarioActual();

        state = AsyncValue.data(usuario);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  /// LOGIN
  Future<String?> login(String email, String pass) async {
    return await _authService.login(email, pass);
  }

  /// REGISTER
  Future<String?> register({
    required String email,
    required String pass,
    required String nombre,

    /// NUEVOS PARAMETROS
    required String empresaId,
    required String rolId,
  }) async {
    return await _authService.register(
      email: email,
      password: pass,
      nombre: nombre,
      empresaId: empresaId,
      rolId: rolId,
    );
  }

  /// LOGOUT
  Future<void> logout() async {
    await _authService.logout();

    state = const AsyncValue.data(null);
  }
}
