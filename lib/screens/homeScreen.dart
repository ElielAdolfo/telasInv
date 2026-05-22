import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/moduloLotes/screens/lotes_screen.dart';
import 'package:inv_telas/moduloPrecios/screens/precios_screen.dart';
import 'package:inv_telas/moduloRelaciones/screens/relaciones_screen.dart';
import 'package:inv_telas/moduloRelaciones/screens/roles_screen.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/screens/json_view_screen.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/widgets.dart';
import 'package:inv_telas/widgets/dynamic_drawer.dart'; // ✅ 1. IMPORTAR
import 'package:inv_telas/screens/pending_screen.dart';
import 'package:collection/collection.dart';
import 'package:inv_telas/services/menus_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Estado de filtros
  String _busqueda = '';
  String _filtroSucursalId = '';
  String _filtroEmpresaId = '';
  String _filtroColorId = '';
  String _filtroTipoTelaId = '';

  List<MenuApp> _menus = [];

  bool _loadingMenus = true;

  @override
  void initState() {
    super.initState();

    _loadMenus();
  }

  Future<void> _loadMenus() async {
    print("🔥 CARGANDO MENUS");

    try {
      final menus = await MenusService().getMenus();

      print("📦 MENUS OBTENIDOS:");
      print(menus.length);

      for (final m in menus) {
        print("${m.id} | ${m.nombre}");
      }

      if (mounted) {
        setState(() {
          _menus = menus;

          _loadingMenus = false;
        });

        print("✅ MENUS GUARDADOS EN STATE");
      }
    } catch (e) {
      print("❌ ERROR MENUS");
      print(e);

      if (mounted) {
        setState(() {
          _loadingMenus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rollosState = ref.watch(rollosProvider);
    final stats = ref.watch(estadisticasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),

      // ✅ 2. USAR EL NUEVO DRAWER AQUÍ
      //drawer: _buildDrawer(),
      drawer: _loadingMenus
          ? const Drawer(child: Center(child: CircularProgressIndicator()))
          : DynamicDrawer(menus: _menus),
      body: rollosState.when(
        data: (rollos) {
          final rollosFiltrados = _filtrarRollos(rollos);
          final grupos = _agruparRollos(rollosFiltrados);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HomeStats(stats: stats),
              const SizedBox(height: 16),
              HomeFilters(
                busqueda: _busqueda,
                filtroSucursal: _filtroSucursalId,
                filtroEmpresa: _filtroEmpresaId,
                filtroColor: _filtroColorId,
                filtroTipoTela: _filtroTipoTelaId,
                onBusquedaChanged: (v) => setState(() => _busqueda = v),
                onSucursalChanged: (v) =>
                    setState(() => _filtroSucursalId = v ?? ''),
                onEmpresaChanged: (v) =>
                    setState(() => _filtroEmpresaId = v ?? ''),
                onColorChanged: (v) => setState(() => _filtroColorId = v ?? ''),
                onTipoChanged: (v) =>
                    setState(() => _filtroTipoTelaId = v ?? ''),
              ),
              const SizedBox(height: 16),
              _buildListaGrupos(grupos),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const NewRolloDialog(),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Inventario de Rollos de Tela',
        style: AppTextStyles.heading2,
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey[200],
      actions: [
        IconButton(
          icon: const Icon(Icons.cloud_sync),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PendingScreen()),
            );
          },
          tooltip: 'Ver Pendientes',
        ),
      ],
    );
  }

  // ✅ NUEVO MÉTODO: MENÚ LATERAL
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.inventory_2, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    "Menú Principal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Inventario
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text("Inventario"),
            subtitle: const Text("Rollos en stock"),
            selected: true,
            selectedTileColor: AppColors.primary.withOpacity(0.1),
            onTap: () => Navigator.pop(context),
          ),

          const Divider(),

          // Lotes
          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text("Lotes"),
            subtitle: const Text("Gestión de Lotes y Precios"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LotesScreen()),
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.price_change),
            title: const Text("Módulo de Precios"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreciosScreen()),
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Gestión de Roles'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RolesScreen()),
            ),
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_alt),
            title: const Text('Relaciones Usuarios'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RelacionesScreen()),
            ),
          ),
          // JSON
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text("Ver JSON"),
            subtitle: const Text("Datos crudos de Firebase"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JsonViewScreen()),
              );
            },
          ),

          const Spacer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ 3. ELIMINAR EL MÉTODO _buildDrawer() COMPLETO
  // (Borra todo el método _buildDrawer que tenías abajo)

  Widget _buildListaGrupos(List<Map<String, dynamic>> grupos) {
    if (grupos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text("No hay rollos que coincidan con los filtros."),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: grupos.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final grupo = grupos[index];
          return GroupListTile(
            grupo: grupo,
            onTap: () => showDialog(
              context: context,
              builder: (_) => GroupDetailDialog(grupo: grupo),
            ),
          );
        },
      ),
    );
  }

  // --- LOGICA DE NEGOCIO (Sin cambios) ---

  List<Rollo> _filtrarRollos(List<Rollo> rollos) {
    final colores = ref.read(coloresProvider);
    final tipos = ref.read(tiposTelaProvider);
    final empresas = ref.read(empresasProvider);

    return rollos.where((r) {
      final colorNombre = colores
          .firstWhere(
            (c) => c.id == r.colorId,
            orElse: () => ColorTela(id: '', nombre: ''),
          )
          .nombre;
      final tipoNombre = tipos
          .firstWhere(
            (t) => t.id == r.tipoTelaId,
            orElse: () => TipoTela(id: '', nombre: ''),
          )
          .nombre;
      final empresaNombre = empresas
          .firstWhere(
            (e) => e.id == r.empresaId,
            orElse: () => Empresa(id: '', nombre: ''),
          )
          .nombre;

      final matchBusqueda =
          _busqueda.isEmpty ||
          colorNombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          r.codigoColor.toLowerCase().contains(_busqueda.toLowerCase()) ||
          empresaNombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          tipoNombre.toLowerCase().contains(_busqueda.toLowerCase());

      final matchSucursal =
          _filtroSucursalId.isEmpty || r.sucursalId == _filtroSucursalId;
      final matchEmpresa =
          _filtroEmpresaId.isEmpty || r.empresaId == _filtroEmpresaId;
      final matchColor = _filtroColorId.isEmpty || r.colorId == _filtroColorId;
      final matchTipo =
          _filtroTipoTelaId.isEmpty || r.tipoTelaId == _filtroTipoTelaId;

      return matchBusqueda &&
          matchSucursal &&
          matchEmpresa &&
          matchColor &&
          matchTipo;
    }).toList();
  }

  List<Map<String, dynamic>> _agruparRollos(List<Rollo> rollos) {
    final map = groupBy(
      rollos,
      (Rollo r) =>
          "${r.colorId}|${r.empresaId}|${r.codigoColor}|${r.tipoTelaId}",
    );

    return map.entries.map((entry) {
      final listaRollos = entry.value;

      return {
        'colorId': listaRollos.first.colorId,
        'empresaId': listaRollos.first.empresaId,
        'codigoColor': listaRollos.first.codigoColor,
        'tipoTelaId': listaRollos.first.tipoTelaId,
        'rollos': listaRollos,
        'cantidad': listaRollos.length,
        'metrajeTotal': listaRollos.fold<double>(
          0,
          (sum, r) => sum + r.metraje,
        ),
        'sucursalIds': listaRollos
            .where((r) => r.sucursalId != null)
            .map((r) => r.sucursalId)
            .toSet()
            .toList(),
      };
    }).toList();
  }
}
