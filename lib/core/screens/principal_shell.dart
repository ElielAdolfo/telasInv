import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/moduloAbms/codigosTelaProveedor/screens/codigo_tela_proveedor_page.dart';
import 'package:inv_telas/moduloAbms/colores/screens/colores_abm_screen.dart';
import 'package:inv_telas/moduloAbms/menus/screens/menus_abm_screen.dart';
import 'package:inv_telas/moduloAbms/monedas/monedas_abm_screen.dart';
import 'package:inv_telas/moduloAbms/roles/screens/roles_abm_screen.dart';
import 'package:inv_telas/moduloAbms/sucursal/screens/sucursales_abm_screen.dart';
import 'package:inv_telas/moduloAbms/tipos_tela/screens/tipos_tela_abm_screen.dart';
import 'package:inv_telas/moduloAsignacion/screens/usuarios_empresa_screen.dart';
import 'package:inv_telas/moduloLotes/screens/lotes_abm_screen.dart';
import 'package:inv_telas/modulo_json/screens/json_view_screen.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/screens/auth_screen.dart';

import 'package:inv_telas/screens/homeScreen.dart';
import 'package:inv_telas/utils/icon_mapper.dart';
import 'package:inv_telas/utils/styles.dart';

class PrincipalShell extends ConsumerStatefulWidget {
  const PrincipalShell({super.key});

  @override
  ConsumerState<PrincipalShell> createState() => _PrincipalShellState();
}

class _PrincipalShellState extends ConsumerState<PrincipalShell> {
  /// Ruta actual
  String _currentRoute = '/home';

  /// Pantallas registradas
  final Map<String, Widget> _routes = {
    '/home': const HomeScreen(),

    /// JSON
    '/ver-json': const JsonViewScreen(),

    /// Temporales
    '/inventario': const Center(child: Text('Pantalla Inventario')),
    '/lotes': const Center(child: Text('Pantalla Lotes')),
    '/precios': const Center(child: Text('Pantalla Precios')),
    '/relaciones': const Center(child: Text('Pantalla Relaciones')),
    '/ventas': const Center(child: Text('Pantalla Ventas')),
    '/usuarios': const Center(child: Text('Pantalla Usuarios')),
    '/abm-menus': const MenusAbmScreen(),
    '/abm-roles': const RolesAbmScreen(),
    '/abm-sucursales': const SucursalesAbmScreen(),
    //'/empresa': const empr
    '/asignaciones': const UsuariosEmpresaScreen(),
    '/tipos-telas': const TiposTelaAbmScreen(),
    '/colores': const ColoresAbmScreen(),
    '/moneda': const MonedasAbmScreen(),
    '/lote': const LotesAbmScreen(),
    '/proveedor-colores': const CodigoTelaProveedorPage(),
  };

  /// Navegación
  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });

    Navigator.pop(context);
  }

  /// Widget actual
  Widget get currentScreen {
    return _routes[_currentRoute] ??
        const Center(child: Text('Pantalla no implementada'));
  }

  /// Dialog para cambiar empresa
  Future<void> _showEmpresaDialog() async {
    final session = ref.read(sessionProvider);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar empresa'),

          content: SizedBox(
            width: 350,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: session.empresasDisponibles.length,
              itemBuilder: (_, index) {
                final empresa = session.empresasDisponibles[index];

                final selected = session.empresaActual?.id == empresa.id;

                return ListTile(
                  title: Text(empresa.nombre),

                  trailing: selected ? const Icon(Icons.check_circle) : null,

                  onTap: () async {
                    await ref
                        .read(sessionProvider.notifier)
                        .cambiarEmpresa(empresa);

                    if (!mounted) return;

                    setState(() {
                      _currentRoute = '/home';
                    });

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    final user = session.usuario;

    final allowedMenusAsync = ref.watch(allowedMenusProvider);

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),

              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.nombre.substring(0, 1).toUpperCase() ?? "?",
                  style: const TextStyle(
                    fontSize: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),

              accountName: Text(user?.nombre ?? "Usuario"),

              accountEmail: Text(user?.email ?? ""),
            ),

            /// MENUS DINÁMICOS
            Expanded(
              child: allowedMenusAsync.when(
                data: (menus) {
                  if (menus.isEmpty) {
                    return const Center(
                      child: Text('No hay menús asignados para este rol'),
                    );
                  }

                  return ListView.builder(
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index];

                      final isSelected = _currentRoute == menu.ruta;

                      return ListTile(
                        leading: Icon(IconMapper.getIcon(menu.icono)),

                        title: Text(menu.nombre),

                        selected: isSelected,

                        selectedTileColor: AppColors.primary.withOpacity(0.1),

                        onTap: () => _navigateTo(menu.ruta),
                      );
                    },
                  );
                },

                loading: () => const Center(child: CircularProgressIndicator()),

                error: (e, _) => Center(child: Text('Error cargando menú: $e')),
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.only(bottom: 18, top: 8),
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        /// FIX DRAWER
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        title: Text(session.empresaActual?.nombre ?? "Inventario de Telas"),

        // En el build del AppBar, dentro de actions:
        actions: [
          /// SELECTOR DE ROL (Nuevo)
          //if (session.rolesDisponibles.length > 1)
          PopupMenuButton<Rol>(
            icon: Row(
              children: [
                Text(
                  session.rolActual?.nombre ?? "Rol",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
            onSelected: (Rol rol) {
              ref.read(sessionProvider.notifier).cambiarRol(rol);
            },
            itemBuilder: (context) {
              return session.rolesDisponibles.map((rol) {
                return PopupMenuItem<Rol>(
                  value: rol,
                  child: Row(
                    children: [
                      if (session.rolActual?.id == rol.id)
                        const Icon(Icons.check, size: 20, color: Colors.green)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Text(rol.nombre),
                    ],
                  ),
                );
              }).toList();
            },
          ),

          /// CAMBIAR EMPRESA (Existente)
          if (!user!.esSuperAdmin && session.empresasDisponibles.length > 1)
            TextButton.icon(
              icon: const Icon(Icons.business, color: Colors.white),
              label: Text(
                session.empresaActual?.nombre ?? "Empresa",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              onPressed: _showEmpresaDialog,
            ),

          /// LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar Sesión 1",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Seguro que desea cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancelar'),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  );
                },
              );

              if (confirm != true) return;

              /// logout firebase
              await ref.read(authProvider.notifier).logout();

              /// limpiar session state
              ref.read(sessionProvider.notifier).logout();

              if (!mounted) return;

              /// limpiar stack completo
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),

      /// BODY
      body: currentScreen,
    );
  }
}
