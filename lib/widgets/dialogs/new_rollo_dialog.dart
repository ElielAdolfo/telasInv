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
  String? _tipoTelaId;
  String? _sucursalId;
  String? _empresaId;
  String? _colorId;
  DateTime? _fecha;

  bool _isSavingCatalog = false;
  bool _isSaving = false; // Bandera para bloquear botones durante operaciones

  late TextEditingController _codigoController;
  late TextEditingController _metrajeController;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController();
    _metrajeController = TextEditingController();
    _fecha = DateTime.now();
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
            child: AbsorbPointer(
              absorbing: _isSaving,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildCantidadSelector(),
                    const SizedBox(height: 12),

                    _buildDropdownWithAdd<TipoTela>(
                      "Tipo de Tela",
                      tipos,
                      _tipoTelaId,
                      (id) {
                        setState(() => _tipoTelaId = id);
                        _autoFillData();
                      },
                      (item) => item.id,
                      (item) => item.nombre,
                      () => _addTipoTela(tipos),
                    ),

                    _buildDropdownWithAdd<Sucursal>(
                      "Sucursal",
                      sucursales,
                      _sucursalId,
                      (id) => setState(() => _sucursalId = id),
                      (item) => item.id,
                      (item) => item.nombre,
                      () => _addSucursal(sucursales),
                    ),

                    _buildDropdownWithAdd<Empresa>(
                      "Empresa",
                      empresas,
                      _empresaId,
                      (id) {
                        setState(() => _empresaId = id);
                        _autoFillData();
                      },
                      (item) => item.id,
                      (item) => item.nombre,
                      () => _addEmpresa(empresas),
                    ),

                    _buildColorDropdownWithAdd("Color", colores, _colorId, (
                      id,
                    ) {
                      setState(() => _colorId = id);
                      _autoFillData();
                    }, () => _addColor(colores)),

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
          ),
          _buildActions(), // Llamada al nuevo método de acciones
        ],
      ),
    );
  }

  // --- LÓGICA DE AUTOCOMPLETADO CON IDs ---

  void _autoFillData() {
    if (_empresaId != null && _tipoTelaId != null && _colorId != null) {
      final rollos = ref
          .read(rollosProvider)
          .maybeWhen(data: (d) => d, orElse: () => <Rollo>[]);

      final matches = rollos
          .where(
            (r) =>
                r.empresaId == _empresaId &&
                r.tipoTelaId == _tipoTelaId &&
                r.colorId == _colorId,
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

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Nuevo Rollo de Tela", style: AppTextStyles.heading2),
          IconButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
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

  // --- MODIFICADO: Acciones con dos botones ---
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de carga
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: LinearProgressIndicator(minHeight: 4),
            ),

          Row(
            children: [
              // BOTÓN 1: AÑADIR A LOTE (Local)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _agregarALote,
                  icon: const Icon(Icons.save_alt),
                  label: const Text("Añadir a Lote"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // BOTÓN 2: SUBIR INDIVIDUAL (Firebase)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _subirIndividual,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text("Subir Individual"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Lote: Guarda localmente si no hay internet.",
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Dropdown Genérico
  Widget _buildDropdownWithAdd<T>(
    String label,
    List<T> items,
    String? selectedId,
    ValueChanged<String?> onChanged,
    String Function(T) getId,
    String Function(T) getLabel,
    VoidCallback onAdd,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedId,
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: getId(e), // ID
                      child: Text(getLabel(e)), // Nombre
                    ),
                  )
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

  // Dropdown de Color con Vista Previa
  Widget _buildColorDropdownWithAdd(
    String label,
    List<ColorTela> colores,
    String? selectedId,
    ValueChanged<String?> onChanged,
    VoidCallback onAdd,
  ) {
    Color? backgroundColor;
    Color textColor = Colors.black;

    if (selectedId != null) {
      final selected = colores.firstWhere(
        (c) => c.id == selectedId,
        orElse: () => ColorTela(id: '', nombre: '', hex: '#FFFFFF'),
      );
      backgroundColor = Helpers.hexToColorFlutter(selected.hex);
      textColor = _getTextColorForBackground(backgroundColor);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedId,
              dropdownColor: Colors.white,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              items: colores
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id, // ID
                      child: Text(
                        e.nombre,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: textColor),
                filled: true,
                fillColor: backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: backgroundColor ?? Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Color _getTextColorForBackground(Color background) {
    final brightness = background.computeLuminance();
    return brightness < 0.5 ? Colors.white : Colors.black;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fecha = d);
  }

  // --- NUEVAS FUNCIONES DE GUARDADO ---

  Future<void> _subirIndividual() async {
    if (_isSaving) return; // Evitar doble clic
    if (!_formKey.currentState!.validate()) return;

    final confirmar = await ConfirmDialog.show(
      context: context,
      titulo: "¿Subir a Firebase?",
      mensaje: "Se crearán $_cantidad rollos directamente en la nube.",
      textoConfirmar: "Subir Ahora",
    );

    if (confirmar != true) return;

    setState(() => _isSaving = true);

    try {
      final rollos = _generarListaRollos();
      // Llama al servicio original que sube a Firebase
      final ok = await ref.read(rollosProvider.notifier).crearRollos(rollos);

      if (ok && mounted) {
        Navigator.pop(context);
        _mostrarExito("Rollos subidos a Firebase correctamente");
      } else {
        throw Exception("Error al guardar en Provider");
      }
    } catch (e) {
      _mostrarError("Error al subir: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _agregarALote() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final confirmar = await ConfirmDialog.show(
      context: context,
      titulo: "¿Añadir a Pendientes?",
      mensaje: "Se guardarán $_cantidad rollos localmente para subir después.",
      textoConfirmar: "Guardar Local",
    );

    if (confirmar != true) return;

    setState(() => _isSaving = true);

    try {
      final rollos = _generarListaRollos();

      // Agregar al proveedor de borradores (Local)
      for (var rollo in rollos) {
        await ref.read(draftsProvider.notifier).add(rollo);
      }

      if (mounted) {
        Navigator.pop(context);
        _mostrarExito("Rollos agregados a la lista pendiente");
      }
    } catch (e) {
      _mostrarError("Error al guardar local: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<Rollo> _generarListaRollos() {
    final codigo = _codigoController.text.trim();
    final metraje = double.tryParse(_metrajeController.text) ?? 0;

    return List.generate(
      _cantidad,
      (index) => Rollo(
        id: Helpers.generarId(),
        sucursalId: _sucursalId,
        empresaId: _empresaId ?? '',
        colorId: _colorId ?? '',
        codigoColor: codigo,
        tipoTelaId: _tipoTelaId ?? '',
        metraje: metraje,
        fecha: _fecha?.toIso8601String(),
        fechaCreacion: DateTime.now(),
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= QUICK ADD PROFESIONAL =================

  void _addTipoTela(List<TipoTela> lista) => _quickAddGeneric<TipoTela>(
    title: "Nuevo Tipo de Tela",
    existingItems: lista,
    getName: (t) => t.nombre,
    onCreate: (name) async {
      final newId = Helpers.generarId();
      await ref
          .read(catalogServiceProvider)
          .addTipoTela(TipoTela(id: newId, nombre: name));
      ref.refresh(tiposTelaProvider);
      return newId;
    },
    onSelected: (id) => setState(() => _tipoTelaId = id),
  );

  void _addSucursal(List<Sucursal> lista) => _quickAddGeneric<Sucursal>(
    title: "Nueva Sucursal",
    existingItems: lista,
    getName: (s) => s.nombre,
    onCreate: (name) async {
      final newId = Helpers.generarId();
      await ref
          .read(catalogServiceProvider)
          .addSucursal(Sucursal(id: newId, nombre: name));
      ref.refresh(sucursalesProvider);
      return newId;
    },
    onSelected: (id) => setState(() => _sucursalId = id),
  );

  void _addEmpresa(List<Empresa> lista) => _quickAddGeneric<Empresa>(
    title: "Nueva Empresa",
    existingItems: lista,
    getName: (e) => e.nombre,
    onCreate: (name) async {
      final newId = Helpers.generarId();
      await ref
          .read(catalogServiceProvider)
          .addEmpresa(Empresa(id: newId, nombre: name));
      ref.refresh(empresasProvider);
      return newId;
    },
    onSelected: (id) => setState(() => _empresaId = id),
  );

  void _addColor(List<ColorTela> lista) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        ref: ref,
        existingColors: lista,
        onColorCreated: (id) {
          setState(() {
            _colorId = id;
          });
        },
      ),
    );
  }

  Future<void> _quickAddGeneric<T>({
    required String title,
    required List<T> existingItems,
    required String Function(T) getName,
    required Future<String> Function(String name) onCreate,
    required void Function(String id) onSelected,
  }) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(hintText: "Ingrese nombre"),
                ),
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

                        final exists = existingItems.any(
                          (e) => _normalize(getName(e)) == input,
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

                        final newId = await onCreate(ctrl.text.trim());

                        setStateDialog(() => _isSavingCatalog = false);

                        onSelected(newId);

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
  final Function(String id) onColorCreated;

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

  final Map<int, double> _heightFactors = {0: 0.36, 1: 0.42, 2: 0.6};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
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

  bool useWhiteForeground(Color background) {
    double luminance =
        (0.299 * background.red +
            0.587 * background.green +
            0.114 * background.blue) /
        255;
    return luminance < 0.5;
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

                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.palette), text: "Base"),
                    Tab(icon: Icon(Icons.color_lens), text: "Rueda"),
                    Tab(icon: Icon(Icons.tune), text: "Picker"),
                  ],
                ),
                const SizedBox(height: 10),

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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

                        final exists = widget.existingColors.any(
                          (c) => c.nombre.toLowerCase() == name.toLowerCase(),
                        );
                        if (exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Este color ya existe"),
                            ),
                          );
                          return;
                        }

                        final hex =
                            '#${_selectedColor.value.toRadixString(16).substring(2)}';
                        final newId = Helpers.generarId();

                        await widget.ref
                            .read(catalogServiceProvider)
                            .addColor(
                              ColorTela(id: newId, nombre: name, hex: hex),
                            );

                        widget.ref.refresh(coloresProvider);

                        widget.onColorCreated(newId);
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
          hexInputBar: true,
        );
      },
    );
  }
}
