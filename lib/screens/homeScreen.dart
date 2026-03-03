import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/widgets.dart';
import 'package:collection/collection.dart'; // Necesario para groupBy

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
          // 1. Filtrar
          final rollosFiltrados = _filtrarRollos(rollos);
          // 2. Agrupar
          final grupos = _agruparRollos(rollosFiltrados);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsGrid(stats),
              const SizedBox(height: 16),
              _buildFiltros(),
              const SizedBox(height: 16),
              _buildTablaGrupos(grupos),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarModalNuevoRollo(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- UI COMPONENTS ---

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

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1100
            ? 5
            : (constraints.maxWidth > 600 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              title: "Total Rollos",
              value: "${stats['totalRollos']}",
              icon: Icons.inventory_2,
              color: Colors.blue,
            ),
            _StatCard(
              title: "Metraje Total",
              value: "${stats['metrajeTotal'].toStringAsFixed(1)} m",
              icon: Icons.straighten,
              color: Colors.green,
            ),
            _StatCard(
              title: "Empresas",
              value: "${stats['empresas']}",
              icon: Icons.business,
              color: Colors.purple,
            ),
            _StatCard(
              title: "Sucursales",
              value: "${stats['sucursales']}",
              icon: Icons.store,
              color: Colors.cyan,
            ),
            _StatCard(
              title: "Colores",
              value: "${stats['colores']}",
              icon: Icons.palette,
              color: Colors.amber,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltros() {
    final sucursales = ref.watch(sucursalesProvider);
    final empresas = ref.watch(empresasProvider);
    final colores = ref.watch(coloresProvider);
    final tipos = ref.watch(tiposTelaProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Busqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por color, código, empresa o tipo...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (v) => setState(() => _busqueda = v),
          ),
          const SizedBox(height: 12),
          // Dropdowns
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildFilterDropdown(
                'Sucursal',
                _filtroSucursal,
                sucursales.map((e) => e.nombre).toList(),
                (v) => setState(() => _filtroSucursal = v ?? ''),
              ),
              _buildFilterDropdown(
                'Empresa',
                _filtroEmpresa,
                empresas.map((e) => e.nombre).toList(),
                (v) => setState(() => _filtroEmpresa = v ?? ''),
              ),
              _buildFilterDropdown(
                'Color',
                _filtroColor,
                colores.map((e) => e.nombre).toList(),
                (v) => setState(() => _filtroColor = v ?? ''),
              ),
              _buildFilterDropdown(
                'Tipo',
                _filtroTipoTela,
                tipos.map((e) => e.nombre).toList(),
                (v) => setState(() => _filtroTipoTela = v ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text("Todos")),
          ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTablaGrupos(List<Map<String, dynamic>> grupos) {
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
          return _GrupoListTile(
            grupo: grupo,
            onTap: () => _abrirDetalleGrupo(grupo),
          );
        },
      ),
    );
  }

  // --- LOGICA ---

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
    // Agrupar igual que en JS: color|empresa|codigoColor|tipoTela
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

  // --- MODALES ---

  void _mostrarModalNuevoRollo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NuevoRolloDialog(),
    );
  }

  void _abrirDetalleGrupo(Map<String, dynamic> grupo) {
    showDialog(
      context: context,
      builder: (_) => _DetalleGrupoDialog(grupo: grupo),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrupoListTile extends StatelessWidget {
  final Map<String, dynamic> grupo;
  final VoidCallback onTap;

  const _GrupoListTile({required this.grupo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colores = ProviderContainer().read(coloresProvider);
    final sucursales = ProviderContainer().read(sucursalesProvider);

    final colorHex = colores
        .firstWhere(
          (c) => c.nombre == grupo['color'],
          orElse: () => ColorTela(id: '', nombre: '', hex: '#94a3b8'),
        )
        .hex;

    // Badges de sucursal
    final badges = (grupo['sucursales'] as List).map((s) {
      final sColor = sucursales
          .firstWhere(
            (su) => su.nombre == s,
            orElse: () => Sucursal(id: '', nombre: '', color: '#6b7280'),
          )
          .color;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Helpers.hexToColorFlutter(sColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          s,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      );
    }).toList();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Color visual
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Helpers.hexToColorFlutter(colorHex),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${grupo['tipoTela'] ?? 'Sin Tipo'} - ${grupo['color']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${grupo['empresa']} • ${grupo['codigoColor']}",
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            // Cant / Metraje
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                "${grupo['cantidad']}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Text(
                "${(grupo['metrajeTotal'] as double).toStringAsFixed(1)} m",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            // Sucursales badges
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: badges.isEmpty
                    ? [
                        const Text(
                          "Sin asignar",
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ]
                    : badges,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// --- DIALOGS ---

class _NuevoRolloDialog extends ConsumerStatefulWidget {
  const _NuevoRolloDialog({super.key});

  @override
  ConsumerState<_NuevoRolloDialog> createState() => _NuevoRolloDialogState();
}

class _NuevoRolloDialogState extends ConsumerState<_NuevoRolloDialog> {
  final _formKey = GlobalKey<FormState>();
  int _cantidad = 1;
  String? _tipoTela;
  String? _sucursal;
  String? _empresa;
  String? _color;
  String _codigoColor = '';
  double _metraje = 0.0;
  DateTime? _fecha;

  @override
  Widget build(BuildContext context) {
    final tipos = ref.watch(tiposTelaProvider);
    final sucursales = ref.watch(sucursalesProvider);
    final empresas = ref.watch(empresasProvider);
    final colores = ref.watch(coloresProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Nuevo Rollo de Tela",
                  style: AppTextStyles.heading2,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Cantidad
                  _buildInputDecorator(
                    child: Row(
                      children: [
                        const Expanded(child: Text("Cantidad de Rollos")),
                        IconButton(
                          onPressed: () => setState(() => _cantidad++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        Text(
                          "$_cantidad",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            if (_cantidad > 1) _cantidad--;
                          }),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dropdowns con botón agregar
                  _buildDropdownWithAdd(
                    "Tipo de Tela",
                    tipos.map((e) => e.nombre).toList(),
                    _tipoTela,
                    (v) => setState(() => _tipoTela = v),
                    _addTipoTela,
                  ),
                  _buildDropdownWithAdd(
                    "Sucursal",
                    sucursales.map((e) => e.nombre).toList(),
                    _sucursal,
                    (v) => setState(() => _sucursal = v),
                    _addSucursal,
                  ),
                  _buildDropdownWithAdd(
                    "Empresa",
                    empresas.map((e) => e.nombre).toList(),
                    _empresa,
                    (v) => setState(() {
                      _empresa = v;
                      _autoFillCodigo();
                    }),
                    _addEmpresa,
                  ),
                  _buildDropdownWithAdd(
                    "Color",
                    colores.map((e) => e.nombre).toList(),
                    _color,
                    (v) => setState(() {
                      _color = v;
                      _autoFillCodigo();
                    }),
                    _addColor,
                  ),

                  // Código
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Código de Color *",
                      hintText: "Ej: AZ-001",
                    ),
                    initialValue: _codigoColor,
                    onChanged: (v) => _codigoColor = v,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),

                  // Metraje
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Metraje por Rollo (m) *",
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => _metraje = double.tryParse(v) ?? 0,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),

                  // Fecha
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Fecha de Ingreso",
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fecha == null
                              ? 'Seleccionar'
                              : Helpers.formatearFecha(_fecha),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      "Guardar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helpers para UI
  InputDecoration _buildInputDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
  Widget _buildInputDecorator({required Widget child}) => InputDecorator(
    decoration: const InputDecoration(border: OutlineInputBorder()),
    child: child,
  );

  Widget _buildDropdownWithAdd(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
    VoidCallback onAdd,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
              decoration: _buildInputDecoration(label),
              hint: Text("Seleccionar $label"),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_box_outlined),
            color: AppColors.primary,
            tooltip: "Nuevo $label",
          ),
        ],
      ),
    );
  }

  // Lógica
  void _autoFillCodigo() {
    if (_empresa != null && _color != null) {
      final asyncRollos = ref.read(rollosProvider);

      final rollos = asyncRollos.maybeWhen(
        data: (data) => data,
        orElse: () => [],
      );

      try {
        final lastRollo = rollos.firstWhere(
          (r) => r.empresa == _empresa && r.color == _color,
        );

        setState(() {
          _codigoColor = lastRollo.codigoColor;
        });
      } catch (_) {
        // No existe coincidencia
      }
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fecha = d);
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final rollosToCreate = List.generate(
        _cantidad,
        (i) => Rollo(
          id: Helpers.generarId(),
          sucursal: _sucursal,
          empresa: _empresa!,
          color: _color!,
          codigoColor: _codigoColor,
          tipoTela: _tipoTela ?? '',
          metraje: _metraje,
          fecha: _fecha?.toIso8601String(),
          fechaCreacion: DateTime.now(),
        ),
      );

      final ok = await ref
          .read(rollosProvider.notifier)
          .crearRollos(rollosToCreate);
      if (ok && mounted) Navigator.pop(context);
    }
  }

  // Agregadores rápidos
  void _addTipoTela() =>
      _showQuickAddDialog("Nuevo Tipo de Tela", (name) async {
        await ref
            .read(catalogServiceProvider)
            .addTipoTela(TipoTela(id: Helpers.generarId(), nombre: name));
        ref.refresh(tiposTelaProvider);
      });
  void _addSucursal() => _showQuickAddDialog("Nueva Sucursal", (name) async {
    await ref
        .read(catalogServiceProvider)
        .addSucursal(Sucursal(id: Helpers.generarId(), nombre: name));
    ref.refresh(sucursalesProvider);
  });
  void _addEmpresa() => _showQuickAddDialog("Nueva Empresa", (name) async {
    await ref
        .read(catalogServiceProvider)
        .addEmpresa(Empresa(id: Helpers.generarId(), nombre: name));
    ref.refresh(empresasProvider);
  });
  void _addColor() => _showQuickAddDialog("Nuevo Color", (name) async {
    await ref
        .read(catalogServiceProvider)
        .addColor(
          ColorTela(id: Helpers.generarId(), nombre: name, hex: '#3b82f6'),
        );
    ref.refresh(coloresProvider);
  });

  void _showQuickAddDialog(String title, Function(String) onSave) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Nombre"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                onSave(ctrl.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}

class _DetalleGrupoDialog extends ConsumerWidget {
  final Map<String, dynamic> grupo;
  const _DetalleGrupoDialog({required this.grupo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollos = grupo['rollos'] as List<Rollo>;

    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rollos: ${grupo['color']}",
                  style: AppTextStyles.heading2,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            // Resumen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoBox(label: "Rollos", value: "${grupo['cantidad']}"),
                _InfoBox(
                  label: "Metraje",
                  value:
                      "${(grupo['metrajeTotal'] as double).toStringAsFixed(1)} m",
                ),
                _InfoBox(
                  label: "Sucursales",
                  value: "${(grupo['sucursales'] as List).length}",
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: rollos.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final r = rollos[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        "${i + 1}",
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                    title: Text(
                      "${r.codigoColor} - ${r.sucursal ?? 'Sin Asignar'}",
                    ),
                    subtitle: Text("${r.metraje} m"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_location_alt,
                            color: Colors.blue,
                          ),
                          onPressed: () => _editSucursal(context, ref, r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(context, ref, r.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editSucursal(BuildContext context, WidgetRef ref, Rollo rollo) async {
    // Mostrar dialogo simple para cambiar sucursal
    final sucursales = ref.read(sucursalesProvider);
    String? selected = rollo.sucursal;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mover Rollo"),
        content: DropdownButtonFormField<String>(
          value: selected,
          items: sucursales
              .map(
                (s) => DropdownMenuItem(value: s.nombre, child: Text(s.nombre)),
              )
              .toList(),
          onChanged: (v) => selected = v,
          decoration: const InputDecoration(labelText: "Sucursal Destino"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(rollosProvider.notifier)
                  .actualizarSucursal(rollo.id, selected);
              Navigator.pop(ctx);
              // Refresh local dialog? Para simplicidad cerramos el principal
              Navigator.pop(context);
            },
            child: const Text("Mover"),
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      titulo: "¿Eliminar?",
      mensaje: "Esta acción no se puede deshacer",
      isDanger: true,
    );
    if (confirm == true) {
      await ref.read(rollosProvider.notifier).eliminarRollo(id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
