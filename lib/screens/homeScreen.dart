import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/screens/json_view_screen.dart';
import 'package:inv_telas/screens/pending_screen.dart';
import 'package:inv_telas/screens/lote_screen.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/widgets.dart';
import 'package:collection/collection.dart';

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

  @override
  Widget build(BuildContext context) {
    final rollosState = ref.watch(rollosProvider);
    final stats = ref.watch(estadisticasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
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

          // Opción 1: Inventario (Actual)
          ListTile(
            leading: const Icon(Icons.home_work_outlined),
            title: const Text(
              "Inventario",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text("Rollos en stock"),
            selected: true, // Resaltar que estamos en esta pantalla
            selectedTileColor: AppColors.primary.withOpacity(0.1),
            onTap: () => Navigator.pop(context), // Solo cierra el drawer
          ),
          const Divider(),

          // Opción 2: Gestión de Lotes
          ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: const Text("Gestión de Lotes"),
            subtitle: const Text("Ingresos y precios de compra"),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoteScreen()),
              );
            },
          ),

          const Divider(),

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

          const Divider(),
          // Espaciador para empujar opciones futuras hacia abajo si es necesario
          const Spacer(),

          // Opción de cierre de sesión o configuración (opcional)
          /*ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {
              Navigator.pop(context);
            },
          ),*/
          const SizedBox(height: 20),
        ],
      ),
    );
  }

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

  // --- LOGICA DE NEGOCIO ---

  List<Rollo> _filtrarRollos(List<Rollo> rollos) {
    // Necesitamos acceso a los catálogos para buscar por nombre en la búsqueda general
    final catalog = ref.read(catalogServiceProvider);
    // Nota: Para optimizar, esto debería hacerse con los providers de estado de catálogo
    // pero para mantenerlo simple usamos el servicio o buscamos en los providers.
    // Usaremos los providers que ya tenemos cargados:

    final colores = ref.read(coloresProvider);
    final tipos = ref.read(tiposTelaProvider);
    final empresas = ref.read(empresasProvider);

    return rollos.where((r) {
      // Búsqueda general (textual): necesita resolver IDs a Nombres
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

      // Filtros específicos por ID
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
