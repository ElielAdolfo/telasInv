import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../constants/constants.dart';
import 'dialogs/nuevo_rollo_dialog.dart';
import 'dialogs/detalle_grupo_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
  }

  Future<void> _cargarDatos() async {
    await context.read<InventarioProvider>().cargarDatos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<InventarioProvider>(
        builder: (context, provider, child) {
          return LoadingOverlay(
            isLoading: provider.isLoading,
            message: 'Cargando inventario...',
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(child: _buildStats(provider)),
                SliverToBoxAdapter(child: _buildFiltros(provider)),
                _buildGruposList(provider),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarNuevoRollo,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Rollo'),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppStrings.appSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STATS =================

  Widget _buildStats(InventarioProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StatsGrid(
        items: [
          StatItem(
            title: AppStrings.totalRollos,
            value: provider.totalRollos.toString(),
            icon: Icons.inventory_2,
            color: const Color(0xFF3B82F6),
          ),
          StatItem(
            title: AppStrings.metrajeTotal,
            value: '${provider.metrajeTotal.toStringAsFixed(1)} m',
            icon: Icons.straighten,
            color: const Color(0xFF10B981),
          ),
          StatItem(
            title: AppStrings.totalEmpresas,
            value: provider.totalEmpresas.toString(),
            icon: Icons.business,
            color: const Color(0xFF8B5CF6),
          ),
          StatItem(
            title: AppStrings.totalSucursales,
            value: provider.totalSucursales.toString(),
            icon: Icons.location_on,
            color: const Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }

  // ================= FILTROS =================

  Widget _buildFiltros(InventarioProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _busquedaController,
            onChanged: provider.setBusqueda,
            decoration: InputDecoration(
              hintText: AppStrings.buscarPlaceholder,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busquedaController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _busquedaController.clear();
                        provider.setBusqueda('');
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  label: provider.filtroSucursal.isEmpty
                      ? 'Todas las Sucursales'
                      : provider.filtroSucursal,
                  icon: Icons.location_on,
                  selected: provider.filtroSucursal.isNotEmpty,
                  onTap: () => _mostrarFiltroSucursal(provider),
                  onClear: () => provider.setFiltroSucursal(''),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: provider.filtroEmpresa.isEmpty
                      ? 'Todas las Empresas'
                      : provider.filtroEmpresa,
                  icon: Icons.business,
                  selected: provider.filtroEmpresa.isNotEmpty,
                  onTap: () => _mostrarFiltroEmpresa(provider),
                  onClear: () => provider.setFiltroEmpresa(''),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: provider.filtroColor.isEmpty
                      ? 'Todos los Colores'
                      : provider.filtroColor,
                  icon: Icons.palette,
                  selected: provider.filtroColor.isNotEmpty,
                  onTap: () => _mostrarFiltroColor(provider),
                  onClear: () => provider.setFiltroColor(''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return FilterChip(
      label: SizedBox(
        width: 130,
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      avatar: Icon(icon, size: 18),
      selected: selected,
      onSelected: (_) => onTap(),
      onDeleted: selected ? onClear : null,
    );
  }

  // ================= LISTA =================

  Widget _buildGruposList(InventarioProvider provider) {
    final grupos = provider.gruposFiltrados;

    if (grupos.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('Sin resultados')),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildGrupoItem(grupos[index], provider),
        childCount: grupos.length,
      ),
    );
  }

  Widget _buildGrupoItem(GrupoRollosModel grupo, InventarioProvider provider) {
    final colorData = provider.getColorByNombre(grupo.color);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ColorPreview(hexColor: colorData?.hex ?? '#94a3b8', size: 36),
        title: Text(grupo.color, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          grupo.empresa,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SizedBox(
          width: 90,
          child: Wrap(
            alignment: WrapAlignment.end,
            runSpacing: 4,
            children: [
              CantidadBadge(cantidad: grupo.cantidad),
              StockBadge(metraje: grupo.metrajeTotal, isCompact: true),
            ],
          ),
        ),
        onTap: () => _mostrarDetalleGrupo(grupo),
      ),
    );
  }

  // ================= DIALOGOS =================

  void _mostrarNuevoRollo() async {
    await showDialog(
      context: context,
      builder: (_) => const NuevoRolloDialog(),
    );
  }

  void _mostrarDetalleGrupo(GrupoRollosModel grupo) async {
    await showDialog(
      context: context,
      builder: (_) => DetalleGrupoDialog(grupo: grupo),
    );
  }

  // ================= BOTTOM SHEET =================

  void _mostrarFiltroSucursal(InventarioProvider provider) {
    _mostrarBottomSheet(
      titulo: 'Filtrar por Sucursal',
      items: provider.sucursales
          .map(
            (s) => ListTile(
              title: Text(s.nombre),
              onTap: () {
                provider.setFiltroSucursal(s.nombre);
                Navigator.pop(context);
              },
            ),
          )
          .toList(),
    );
  }

  void _mostrarFiltroEmpresa(InventarioProvider provider) {
    _mostrarBottomSheet(
      titulo: 'Filtrar por Empresa',
      items: provider.empresas
          .map(
            (e) => ListTile(
              title: Text(e.nombre),
              onTap: () {
                provider.setFiltroEmpresa(e.nombre);
                Navigator.pop(context);
              },
            ),
          )
          .toList(),
    );
  }

  void _mostrarFiltroColor(InventarioProvider provider) {
    _mostrarBottomSheet(
      titulo: 'Filtrar por Color',
      items: provider.colores
          .map(
            (c) => ListTile(
              title: Text(c.nombre),
              onTap: () {
                provider.setFiltroColor(c.nombre);
                Navigator.pop(context);
              },
            ),
          )
          .toList(),
    );
  }

  void _mostrarBottomSheet({
    required String titulo,
    required List<Widget> items,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(controller: controller, children: items),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
