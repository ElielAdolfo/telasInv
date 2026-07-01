import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/models/usuario_empresa_permiso.dart';
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
  final dynamic sucursalActual; // Se asignará la sucursal activa
  final Rol? rolActual;

  final List<Rol> rolesDisponibles;
  final List<Empresa> empresasDisponibles;
  final List<dynamic>
  sucursalesDisponibles; // Almacena las sucursales de la empresa seleccionada

  const SessionState({
    this.usuario,
    this.empresaActual,
    this.sucursalActual,
    this.rolActual,
    this.rolesDisponibles = const [],
    this.empresasDisponibles = const [],
    this.sucursalesDisponibles = const [],
  });

  SessionState copyWith({
    Usuario? usuario,
    Empresa? empresaActual,
    dynamic sucursalActual,
    Rol? rolActual,
    List<Rol>? rolesDisponibles,
    List<Empresa>? empresasDisponibles,
    List<dynamic>? sucursalesDisponibles,
  }) {
    return SessionState(
      usuario: usuario ?? this.usuario,
      empresaActual: empresaActual ?? this.empresaActual,
      sucursalActual: sucursalActual ?? this.sucursalActual,
      rolActual: rolActual ?? this.rolActual,
      rolesDisponibles: rolesDisponibles ?? this.rolesDisponibles,
      empresasDisponibles: empresasDisponibles ?? this.empresasDisponibles,
      sucursalesDisponibles:
          sucursalesDisponibles ?? this.sucursalesDisponibles,
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
      final empresaService = ref.read(empresaServiceProvider);

      print('🔍 Iniciando sesión ${user.nombre}');

      /// SUPER ADMIN GLOBAL
      if (user.esSuperAdmin) {
        final rolService = ref.read(rolServiceProvider);
        final roles = await rolService.getRolesByIds(['superAdmin']);

        state = state.copyWith(
          usuario: user,
          empresaActual: null,
          sucursalActual: null,
          empresasDisponibles: [],
          sucursalesDisponibles: [],
          rolesDisponibles: roles,
          rolActual: roles.isNotEmpty ? roles.first : null,
        );

        print('✅ Sesión SuperAdmin');
        return;
      }

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

      final empresaSeleccionada = empresas.first;

      // Establecemos las empresas y disparamos el flujo encadenado para la primera
      state = state.copyWith(usuario: user, empresasDisponibles: empresas);

      await _seleccionarEmpresaFlujo(empresaSeleccionada, user);
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

      await _seleccionarEmpresaFlujo(nuevaEmpresa, user);
      print('🔄 Empresa cambiada: ${nuevaEmpresa.nombre}');
    } catch (e) {
      print('❌ cambiarEmpresa: $e');
    }
  }

  /// -----------------------------------
  /// FLUJO INTERNO: Cargar Sucursales de la Empresa
  /// -----------------------------------
  Future<void> _seleccionarEmpresaFlujo(Empresa empresa, Usuario user) async {
    final relacionEmpresa = user.empresas.firstWhere(
      (e) => e.empresaId == empresa.id,
      orElse: () => UsuarioEmpresaRol(empresaId: ''),
    );

    // Filtramos únicamente las sucursales que están activas y no eliminadas
    final sucursalesValidas = relacionEmpresa.sucursales
        .where((s) => s.activo && !s.eliminado)
        .toList();

    dynamic sucursalInicial = sucursalesValidas.isNotEmpty
        ? sucursalesValidas.first
        : null;

    state = state.copyWith(
      empresaActual: empresa,
      sucursalesDisponibles: sucursalesValidas,
      sucursalActual: sucursalInicial,
    );

    // Si encontramos una sucursal por defecto, cargamos sus roles específicos
    if (sucursalInicial != null) {
      await cambiarSucursal(sucursalInicial);
    } else {
      // Si la empresa no tiene sucursales asignadas, limpiamos roles
      state = state.copyWith(rolesDisponibles: [], rolActual: null);
    }
  }

  /// -----------------------------------
  /// CAMBIAR SUCURSAL (Filtra roles específicos)
  /// -----------------------------------
  Future<void> cambiarSucursal(dynamic nuevaSucursal) async {
    try {
      final rolService = ref.read(rolServiceProvider);

      // Obtenemos los IDs de los roles mapeados ÚNICAMENTE en esta sucursal
      final List<String> rolesIds = List<String>.from(
        nuevaSucursal.rolesIds ?? [],
      );
      List<Rol> roles = [];

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
        sucursalActual: nuevaSucursal,
        rolesDisponibles: roles,
        rolActual: rolInicial,
      );

      // CORREGIDO: Usamos sucursalId en lugar de nombre para el log
      print(
        '✅ Sucursal actual: ${nuevaSucursal.sucursalId} | Roles cargados: ${roles.length}',
      );
    } catch (e) {
      print('❌ cambiarSucursal: $e');
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

  UsuarioEmpresaPermiso? get permisoEmpresaActual {
    final empresa = state.empresaActual;
    final usuario = state.usuario;

    if (empresa == null || usuario == null) {
      return null;
    }

    try {
      return empresa.usuariosPermitidos.firstWhere(
        (p) => p.usuarioId == usuario.id && p.activo && !p.eliminado,
      );
    } catch (_) {
      return null;
    }
  }

  bool get esPrincipalEmpresa {
    return permisoEmpresaActual?.esPrincipal ?? false;
  }

  Set<String> get sucursalesPermitidas {
    final permiso = permisoEmpresaActual;

    if (permiso == null) {
      return {};
    }

    return permiso.sucursales
        .where((s) => s.activo && !s.eliminado)
        .map((s) => s.sucursalId)
        .toSet();
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
  final session = ref.watch(sessionProvider);
  final user = session.usuario;

  if (user == null) return [];

  final menuService = ref.read(menuServiceProvider);

  if (user.esSuperAdmin) {
    return menuService.getAllMenus();
  }

  final rol = session.rolActual;
  if (rol == null || rol.menusPermitidos.isEmpty) return [];

  return menuService.getMenusByIds(rol.menusPermitidos);
});

final currentUserProvider = Provider<Usuario>((ref) {
  final user = ref.watch(sessionProvider).usuario;
  if (user == null) throw Exception('No hay sesión activa');
  return user;
});
