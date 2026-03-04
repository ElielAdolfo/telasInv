import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/widgets.dart';
import 'package:flex_color_picker/flex_color_picker.dart' as flex;
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as flutter_picker;

class NewRolloDialog extends ConsumerStatefulWidget {
  const NewRolloDialog({super.key});

  @override
  ConsumerState<NewRolloDialog> createState() => _NewRolloDialogState();
}

class _NewRolloDialogState extends ConsumerState<NewRolloDialog> {
  final _formKey = GlobalKey<FormState>();

  int _cantidad = 1;
  String? _tipoTela;
  String? _sucursal;
  String? _empresa;
  String? _color;
  DateTime? _fecha;

  bool _isSavingCatalog = false;

  late TextEditingController _codigoController;
  late TextEditingController _metrajeController;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController();
    _metrajeController = TextEditingController();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _metrajeController.dispose();
    super.dispose();
  }

  String _normalize(String text) {
    return text.trim().toLowerCase();
  }

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
          _buildHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildCantidadSelector(),
                  const SizedBox(height: 12),

                  _buildDropdownWithAdd(
                    "Tipo de Tela",
                    tipos.map((e) => e.nombre).toList(),
                    _tipoTela,
                    (v) {
                      setState(() => _tipoTela = v);
                      _autoFillData();
                    },
                    () => _addTipoTela(tipos),
                  ),

                  _buildDropdownWithAdd(
                    "Sucursal",
                    sucursales.map((e) => e.nombre).toList(),
                    _sucursal,
                    (v) => setState(() => _sucursal = v),
                    () => _addSucursal(sucursales),
                  ),

                  _buildDropdownWithAdd(
                    "Empresa",
                    empresas.map((e) => e.nombre).toList(),
                    _empresa,
                    (v) {
                      setState(() => _empresa = v);
                      _autoFillData();
                    },
                    () => _addEmpresa(empresas),
                  ),

                  _buildDropdownWithAdd(
                    "Color",
                    colores.map((e) => e.nombre).toList(),
                    _color,
                    (v) {
                      setState(() => _color = v);
                      _autoFillData();
                    },
                    () => _addColor(colores),
                  ),

                  TextFormField(
                    controller: _codigoController,
                    decoration: const InputDecoration(
                      labelText: "Código de Color *",
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),

                  TextFormField(
                    controller: _metrajeController,
                    decoration: const InputDecoration(
                      labelText: "Metraje por Rollo (m) *",
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),

                  _buildDateSelector(),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  void _autoFillData() {
    if (_empresa != null && _tipoTela != null && _color != null) {
      final rollos = ref
          .read(rollosProvider)
          .maybeWhen(data: (d) => d, orElse: () => <Rollo>[]);

      final matches = rollos
          .where(
            (r) =>
                r.empresa == _empresa &&
                r.tipoTela == _tipoTela &&
                r.color == _color,
          )
          .toList();

      if (matches.isNotEmpty) {
        final codigo = matches.first.codigoColor;
        final metraje = _calcularMetrajeMasFrecuente(matches);

        setState(() {
          _codigoController.text = codigo;
          if (metraje != null) {
            _metrajeController.text = metraje % 1 == 0
                ? metraje.toInt().toString()
                : metraje.toString();
          }
        });
      }
    }
  }

  double? _calcularMetrajeMasFrecuente(List<Rollo> rollos) {
    if (rollos.isEmpty) return null;
    final Map<double, int> frecuencias = {};
    for (var r in rollos) {
      frecuencias[r.metraje] = (frecuencias[r.metraje] ?? 0) + 1;
    }
    return frecuencias.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Nuevo Rollo de Tela", style: AppTextStyles.heading2),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildCantidadSelector() {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Row(
        children: [
          const Expanded(child: Text("Cantidad de Rollos")),
          IconButton(
            onPressed: () => setState(() => _cantidad++),
            icon: const Icon(Icons.add),
          ),
          Text("$_cantidad"),
          IconButton(
            onPressed: () {
              if (_cantidad > 1) setState(() => _cantidad--);
            },
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: "Fecha de Ingreso"),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_fecha == null ? 'Seleccionar' : Helpers.formatearFecha(_fecha)),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(onPressed: _guardar, child: const Text("Guardar")),
    );
  }

  Widget _buildDropdownWithAdd(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
    VoidCallback onAdd,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
        ],
      ),
    );
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
    if (!_formKey.currentState!.validate()) return;

    final codigo = _codigoController.text.trim();
    final metraje = double.tryParse(_metrajeController.text) ?? 0;

    final rollos = List.generate(
      _cantidad,
      (_) => Rollo(
        id: Helpers.generarId(),
        sucursal: _sucursal,
        empresa: _empresa!,
        color: _color!,
        codigoColor: codigo,
        tipoTela: _tipoTela ?? '',
        metraje: metraje,
        fecha: _fecha?.toIso8601String(),
        fechaCreacion: DateTime.now(),
      ),
    );

    final ok = await ref.read(rollosProvider.notifier).crearRollos(rollos);

    if (ok && mounted) Navigator.pop(context);
  }

  // ================= QUICK ADD PROFESIONAL =================

  void _addTipoTela(List<TipoTela> lista) => _quickAddGeneric<TipoTela>(
    title: "Nuevo Tipo de Tela",
    existingNames: lista.map((e) => e.nombre).toList(),
    onCreate: (name) async {
      await ref
          .read(catalogServiceProvider)
          .addTipoTela(TipoTela(id: Helpers.generarId(), nombre: name));
      ref.refresh(tiposTelaProvider);
    },
    onSelected: (name) => setState(() => _tipoTela = name),
  );

  void _addSucursal(List<Sucursal> lista) => _quickAddGeneric<Sucursal>(
    title: "Nueva Sucursal",
    existingNames: lista.map((e) => e.nombre).toList(),
    onCreate: (name) async {
      await ref
          .read(catalogServiceProvider)
          .addSucursal(Sucursal(id: Helpers.generarId(), nombre: name));
      ref.refresh(sucursalesProvider);
    },
    onSelected: (name) => setState(() => _sucursal = name),
  );

  void _addEmpresa(List<Empresa> lista) => _quickAddGeneric<Empresa>(
    title: "Nueva Empresa",
    existingNames: lista.map((e) => e.nombre).toList(),
    onCreate: (name) async {
      await ref
          .read(catalogServiceProvider)
          .addEmpresa(Empresa(id: Helpers.generarId(), nombre: name));
      ref.refresh(empresasProvider);
    },
    onSelected: (name) => setState(() => _empresa = name),
  );

  // MODIFICADO: Usamos el nuevo Widget separado para el diálogo de color
  void _addColor(List<ColorTela> lista) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        ref: ref,
        existingColors: lista,
        onColorCreated: (name) {
          setState(() {
            _color = name;
          });
        },
      ),
    );
  }

  void _quickAddGeneric<T>({
    required String title,
    required List<String> existingNames,
    required Future<void> Function(String name) onCreate,
    required void Function(String name) onSelected,
  }) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: ctrl),
                if (_isSavingCatalog)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isSavingCatalog ? null : () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: _isSavingCatalog
                    ? null
                    : () async {
                        final input = _normalize(ctrl.text);
                        if (input.isEmpty) return;

                        final exists = existingNames.any(
                          (e) => _normalize(e) == input,
                        );

                        if (exists) {
                          _showAlert(
                            title: "Registro duplicado",
                            message: "Ya existe este registro en el catálogo.",
                            icon: Icons.error_outline,
                            color: Colors.red,
                          );
                          return;
                        }

                        setStateDialog(() => _isSavingCatalog = true);

                        await onCreate(ctrl.text.trim());

                        setStateDialog(() => _isSavingCatalog = false);

                        onSelected(ctrl.text.trim());

                        if (mounted) Navigator.pop(ctx);
                      },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAlert({
    required String title,
    required String message,
    IconData icon = Icons.warning_amber_rounded,
    Color color = Colors.orange,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}

// ================= DIALOG DE COLOR REFACTORIZADO =================

class _ColorPickerDialog extends StatefulWidget {
  final WidgetRef ref;
  final List<ColorTela> existingColors;
  final Function(String) onColorCreated;

  const _ColorPickerDialog({
    required this.ref,
    required this.existingColors,
    required this.onColorCreated,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  String get _hexColor =>
      '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  // Mapa de alturas por índice de tab
  final Map<int, double> _heightFactors = {
    0: 0.36, // Base
    1: 0.42, // Rueda
    2: 0.53, // Avanzado
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // Forzamos redibujar para que AnimatedContainer tome la nueva altura
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentHeightFactor = _heightFactors[_tabController.index] ?? 0.36;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nuevo Color",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                /// TABS
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.palette), text: "Base"),
                    Tab(icon: Icon(Icons.color_lens), text: "Rueda"),
                    Tab(icon: Icon(Icons.tune), text: "Picker"),
                  ],
                ),
                const SizedBox(height: 10),

                /// CONTENIDO DINÁMICO
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: screenHeight * currentHeightFactor,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _navColoresBase(),
                      _navRuedaColor(),
                      _navColorPickerAvanzado(),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                /// Vista previa
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Separar los elementos
                    children: [
                      // Campo de texto para el nombre del color
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Nombre del color",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Código hexadecimal
                      Text(
                        '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(
                          color: useWhiteForeground(_selectedColor)
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final name = _nameController.text.trim();
                        if (name.isEmpty) return;

                        final hex =
                            '#${_selectedColor.value.toRadixString(16).substring(2)}';

                        await widget.ref
                            .read(catalogServiceProvider)
                            .addColor(
                              ColorTela(
                                id: Helpers.generarId(),
                                nombre: name,
                                hex: hex,
                              ),
                            );

                        widget.ref.refresh(coloresProvider);

                        widget.onColorCreated(name);
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navColoresBase() {
    final colores = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.black,
      Colors.white,
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: colores.length,
      itemBuilder: (context, index) {
        final color = colores[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _selectedColor == color
                    ? Colors.black
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navRuedaColor() {
    return flex.ColorPicker(
      color: _selectedColor,
      onColorChanged: (color) => setState(() => _selectedColor = color),
      enableShadesSelection: false,
      pickersEnabled: const {
        flex.ColorPickerType.wheel: true,
        flex.ColorPickerType.primary: false,
        flex.ColorPickerType.accent: false,
      },
    );
  }

  Widget _navColorPickerAvanzado() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;
        return flutter_picker.ColorPicker(
          pickerColor: _selectedColor,
          onColorChanged: (color) => setState(() => _selectedColor = color),
          enableAlpha: true,
          displayThumbColor: true,
          showLabel: false,
          paletteType: isMobile
              ? flutter_picker.PaletteType.hsv
              : flutter_picker.PaletteType.hsvWithHue,
          pickerAreaHeightPercent: isMobile ? 0.6 : 0.7,
          hexInputBar: false,
        );
      },
    );
  }

  Widget _buildHexInfo() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            _hexColor,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// Retorna true si conviene texto blanco sobre el color [background]
  bool useWhiteForeground(Color background) {
    // Calcula la luminancia percibida
    double luminance =
        (0.299 * background.red +
            0.587 * background.green +
            0.114 * background.blue) /
        255;
    return luminance < 0.5;
  }
}
