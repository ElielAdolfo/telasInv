import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
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
  String _filtroSucursal = '';
  String _filtroEmpresa = '';
  String _filtroColor = '';
  String _filtroTipoTela = '';

  @override
  Widget build(BuildContext context) {
    final rollosState = ref.watch(rollosProvider);
    final stats = ref.watch(estadisticasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
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
                filtroSucursal: _filtroSucursal,
                filtroEmpresa: _filtroEmpresa,
                filtroColor: _filtroColor,
                filtroTipoTela: _filtroTipoTela,
                onBusquedaChanged: (v) => setState(() => _busqueda = v),
                onSucursalChanged: (v) =>
                    setState(() => _filtroSucursal = v ?? ''),
                onEmpresaChanged: (v) =>
                    setState(() => _filtroEmpresa = v ?? ''),
                onColorChanged: (v) => setState(() => _filtroColor = v ?? ''),
                onTipoChanged: (v) => setState(() => _filtroTipoTela = v ?? ''),
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
    return rollos.where((r) {
      final matchBusqueda =
          _busqueda.isEmpty ||
          r.color.toLowerCase().contains(_busqueda.toLowerCase()) ||
          r.codigoColor.toLowerCase().contains(_busqueda.toLowerCase()) ||
          r.empresa.toLowerCase().contains(_busqueda.toLowerCase()) ||
          (r.tipoTela?.toLowerCase().contains(_busqueda.toLowerCase()) ??
              false);

      final matchSucursal =
          _filtroSucursal.isEmpty || r.sucursal == _filtroSucursal;
      final matchEmpresa =
          _filtroEmpresa.isEmpty || r.empresa == _filtroEmpresa;
      final matchColor = _filtroColor.isEmpty || r.color == _filtroColor;
      final matchTipo =
          _filtroTipoTela.isEmpty || r.tipoTela == _filtroTipoTela;

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
          "${r.color}|${r.empresa}|${r.codigoColor}|${r.tipoTela ?? ''}",
    );

    return map.entries.map((entry) {
      final parts = entry.key.split('|');
      final listaRollos = entry.value;

      return {
        'color': parts[0],
        'empresa': parts[1],
        'codigoColor': parts[2],
        'tipoTela': parts[3],
        'rollos': listaRollos,
        'cantidad': listaRollos.length,
        'metrajeTotal': listaRollos.fold<double>(
          0,
          (sum, r) => sum + r.metraje,
        ),
        'sucursales': listaRollos
            .where((r) => r.sucursal != null)
            .map((r) => r.sucursal)
            .toSet()
            .toList(),
      };
    }).toList();
  }
}
