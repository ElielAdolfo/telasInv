import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/models/usuario_empresa_rol.dart';
import 'package:inv_telas/providers/empresa_provider.dart';
import 'package:inv_telas/services/menu_service.dart';
import 'package:inv_telas/services/rol_service.dart';

/// =====================================
/// SESSION STATE
/// =====================================
class SessionState {
  final Usuario? usuario;
  final Empresa? empresaActual;
  final Rol? rolActual;

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

/// =====================================
/// SESSION NOTIFIER
/// =====================================
class SessionNotifier extends StateNotifier<SessionState> {
  final Ref ref;

  SessionNotifier(this.ref) : super(const SessionState());

  /// -----------------------------------
  /// INIT SESSION
  /// -----------------------------------
  Future<void> initSession(Usuario user) async {
    try {
      final rolService = ref.read(rolServiceProvider);
      final empresaService = ref.read(empresaServiceProvider);

      print('🔍 Iniciando sesión ${user.nombre}');

      final empresasIds = user.empresas.map((e) => e.empresaId).toList();

      /// SIN EMPRESAS
      if (empresasIds.isEmpty) {
        state = state.copyWith(usuario: user);
        return;
      }

      /// CARGAR EMPRESAS
      final empresas = await empresaService.getEmpresasByIds(empresasIds);

      if (empresas.isEmpty) {
        state = state.copyWith(usuario: user);
        return;
      }

      /// EMPRESA DEFAULT
      final empresaSeleccionada = empresas.first;

      /// RELACIÓN EMPRESA-USUARIO
      final relacionEmpresa = user.empresas.firstWhere(
        (e) => e.empresaId == empresaSeleccionada.id,
        orElse: () => UsuarioEmpresaRol(empresaId: ''),
      );

      /// CARGAR ROLES
      List<Rol> roles = [];

      final rolesIds = _obtenerRolesEmpresa(relacionEmpresa);

      if (rolesIds.isNotEmpty) {
        roles = await rolService.getRolesByIds(rolesIds);
      }

      /// SI EXISTE SUPERADMIN LO PRIORIZAMOS
      Rol? rolInicial;

      try {
        rolInicial = roles.firstWhere((r) => r.id == 'superAdmin');
      } catch (_) {
        if (roles.isNotEmpty) {
          rolInicial = roles.first;
        }
      }

      state = state.copyWith(
        usuario: user,
        empresaActual: empresaSeleccionada,
        empresasDisponibles: empresas,
        rolesDisponibles: roles,
        rolActual: rolInicial,
      );

      print('✅ Empresa actual: ${empresaSeleccionada.nombre}');

      print('✅ Rol actual: ${rolInicial?.nombre}');
    } catch (e) {
      print('❌ initSession: $e');
    }
  }

  /// -----------------------------------
  /// CAMBIAR EMPRESA
  /// -----------------------------------
  Future<void> cambiarEmpresa(Empresa nuevaEmpresa) async {
    try {
      final user = state.usuario;

      if (user == null) return;

      final rolService = ref.read(rolServiceProvider);

      final relacionEmpresa = user.empresas.firstWhere(
        (e) => e.empresaId == nuevaEmpresa.id,
        orElse: () => UsuarioEmpresaRol(empresaId: ''),
      );

      List<Rol> roles = [];

      final rolesIds = _obtenerRolesEmpresa(relacionEmpresa);

      if (rolesIds.isNotEmpty) {
        roles = await rolService.getRolesByIds(rolesIds);
      }

      /// SUPERADMIN PRIORIDAD
      Rol? rolInicial;

      try {
        rolInicial = roles.firstWhere((r) => r.id == 'superAdmin');
      } catch (_) {
        if (roles.isNotEmpty) {
          rolInicial = roles.first;
        }
      }

      state = state.copyWith(
        empresaActual: nuevaEmpresa,
        rolesDisponibles: roles,
        rolActual: rolInicial,
      );

      print('🔄 Empresa cambiada: ${nuevaEmpresa.nombre}');

      print('🔄 Rol actual: ${rolInicial?.nombre}');
    } catch (e) {
      print('❌ cambiarEmpresa: $e');
    }
  }

  /// -----------------------------------
  /// CAMBIAR ROL
  /// -----------------------------------
  void cambiarRol(Rol rol) {
    state = state.copyWith(rolActual: rol);
  }

  /// -----------------------------------
  /// REFRESH SESSION
  /// -----------------------------------
  Future<void> refreshSession() async {
    final user = state.usuario;

    if (user == null) return;

    await initSession(user);
  }

  /// -----------------------------------
  /// LOGOUT
  /// -----------------------------------
  void logout() {
    state = const SessionState();
  }

  List<String> _obtenerRolesEmpresa(UsuarioEmpresaRol relacionEmpresa) {
    final rolesIds = <String>{};

    for (final sucursal in relacionEmpresa.sucursales) {
      if (!sucursal.activo || sucursal.eliminado) {
        continue;
      }

      rolesIds.addAll(sucursal.rolesIds);
    }

    return rolesIds.toList();
  }
}

/// =====================================
/// PROVIDERS
/// =====================================
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((
  ref,
) {
  return SessionNotifier(ref);
});

final rolServiceProvider = Provider<RolService>((ref) => RolService());

final menuServiceProvider = Provider<MenuService>((ref) => MenuService());

/// =====================================
/// MENUS DEL ROL ACTUAL
/// =====================================
final allowedMenusProvider = FutureProvider<List<MenuApp>>((ref) async {
  final rol = ref.watch(sessionProvider).rolActual;

  if (rol == null) {
    return [];
  }

  if (rol.menusPermitidos.isEmpty) {
    return [];
  }

  final menuService = ref.read(menuServiceProvider);

  return menuService.getMenusByIds(rol.menusPermitidos);
});

final currentUserProvider = Provider<Usuario>((ref) {
  final user = ref.watch(sessionProvider).usuario;

  if (user == null) {
    throw Exception('No hay sesión activa');
  }

  return user;
});
