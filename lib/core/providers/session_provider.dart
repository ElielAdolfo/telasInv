import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/models/usuario_empresa_rol.dart';
import 'package:inv_telas/services/empresa_service.dart';
import 'package:inv_telas/services/menu_service.dart';
import 'package:inv_telas/services/rol_service.dart';

/// -----------------------------
/// ESTADO DE SESIÓN
/// -----------------------------
class SessionState {
  final Usuario? usuario;

  // Nuevo: Empresa actualmente seleccionada
  final Empresa? empresaActual;

  // Nuevo: Rol correspondiente a la empresa actual
  final Rol? rolActual;

  // Nuevo: Lista de empresas disponibles para el usuario
  final List<Rol> rolesDisponibles;
  final List<Empresa> empresasDisponibles;

  const SessionState({
    this.usuario,
    this.empresaActual,
    this.rolActual,
    this.rolesDisponibles = const [],
    this.empresasDisponibles = const [],
  });

  SessionState copyWith({
    Usuario? usuario,
    Empresa? empresaActual,
    Rol? rolActual,
    List<Rol>? rolesDisponibles,
    List<Empresa>? empresasDisponibles,
  }) {
    return SessionState(
      usuario: usuario ?? this.usuario,
      empresaActual: empresaActual ?? this.empresaActual,
      rolActual: rolActual ?? this.rolActual,
      rolesDisponibles: rolesDisponibles ?? this.rolesDisponibles,
      empresasDisponibles: empresasDisponibles ?? this.empresasDisponibles,
    );
  }
}

/// -----------------------------
/// SESSION NOTIFIER
/// -----------------------------
class SessionNotifier extends StateNotifier<SessionState> {
  final Ref ref;

  SessionNotifier(this.ref) : super(const SessionState());

  /// Inicializar sesión
  Future<void> initSession(Usuario user) async {
    try {
      final empresaService = ref.read(empresaServiceProvider);
      final rolService = ref.read(rolServiceProvider);

      print('🔍 Iniciando sesión para: ${user.nombre}');

      // 1. Obtener IDs de empresas del usuario
      final empresasIds = user.empresas.map((e) => e.empresaId).toList();

      if (empresasIds.isEmpty) {
        print('⚠️ Usuario sin empresas asignadas');
        state = state.copyWith(usuario: user);
        return;
      }

      // 2. Cargar objetos Empresa completos
      final empresas = await empresaService.getEmpresasByIds(empresasIds);

      // 3. Lógica de selección de empresa
      // Por ahora seleccionamos la PRIMERA automáticamente.
      // TODO: Si hay más de una, mostrar un diálogo de selección en la UI.
      final empresaSeleccionada = empresas.isNotEmpty ? empresas.first : null;

      if (empresaSeleccionada == null) {
        print('❌ No se encontraron datos de las empresas asignadas');
        state = state.copyWith(usuario: user, empresasDisponibles: empresas);
        return;
      }

      // 4. Buscar el Rol correspondiente a esta empresa
      final userEmpresaRol = user.empresas.firstWhere(
        (e) => e.empresaId == empresaSeleccionada.id,
        orElse: () => UsuarioEmpresaRol(empresaId: '', rolesIds: []),
      );

      List<Rol> roles = [];
      if (userEmpresaRol.rolesIds.isNotEmpty) {
        roles = await rolService.getRolesByIds(userEmpresaRol.rolesIds);
      }
      Rol? rolInicial = roles.isNotEmpty ? roles.first : null;

      print('✅ Empresa seleccionada: ${empresaSeleccionada.nombre}');
      print('✅ Roles disponibles: ${roles.map((r) => r.nombre).join(", ")}');
      print('✅ Rol activo: ${rolInicial?.nombre}');

      state = state.copyWith(
        usuario: user,
        empresaActual: empresaSeleccionada,
        rolesDisponibles: roles,
        rolActual: rolInicial,
        empresasDisponibles: empresas,
      );
    } catch (e) {
      print('❌ Error initSession: $e');
    }
  }

  void cambiarRol(Rol nuevoRol) {
    state = state.copyWith(rolActual: nuevoRol);
    print('🔄 Rol cambiado a: ${nuevoRol.nombre}');
  }

  /// Cambiar de empresa (y por ende de rol)
  Future<void> cambiarEmpresa(Empresa nuevaEmpresa) async {
    final user = state.usuario;
    if (user == null) return;

    final userEmpresaRol = user.empresas.firstWhere(
      (e) => e.empresaId == nuevaEmpresa.id,
      orElse: () => UsuarioEmpresaRol(empresaId: '', rolesIds: []),
    );

    if (userEmpresaRol.rolesIds.isEmpty) return;

    final rolService = ref.read(rolServiceProvider);
    final roles = await rolService.getRolesByIds(userEmpresaRol.rolesIds);
    final rolInicial = roles.isNotEmpty ? roles.first : null;

    state = state.copyWith(
      empresaActual: nuevaEmpresa,
      rolesDisponibles: roles,
      rolActual: rolInicial,
    );
  }

  /// Logout
  void logout() {
    state = const SessionState();
  }
}

/// -----------------------------
/// PROVIDERS
/// -----------------------------
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((
  ref,
) {
  return SessionNotifier(ref);
});

final rolServiceProvider = Provider<RolService>((ref) => RolService());
final menuServiceProvider = Provider<MenuService>((ref) => MenuService());
final empresaServiceProvider = Provider<EmpresaService>(
  (ref) => EmpresaService(),
);

/// -----------------------------
/// MENUS DEL ROL ACTUAL
/// -----------------------------
final allowedMenusProvider = FutureProvider<List<MenuApp>>((ref) async {
  final session = ref.watch(sessionProvider);
  final rol = session.rolActual;

  if (rol == null) {
    print('⚠️ Sin rol actual definido para la empresa');
    return [];
  }

  if (rol.menusPermitidos.isEmpty) {
    return [];
  }

  final menuService = ref.read(menuServiceProvider);
  final menus = await menuService.getMenusByIds(rol.menusPermitidos);

  return menus;
});

final currentUserProvider = Provider<Usuario>((ref) {
  final usuario = ref.watch(sessionProvider).usuario;

  if (usuario == null) {
    throw Exception('No hay sesión activa');
  }

  return usuario;
});
