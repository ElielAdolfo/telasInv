import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/widgets.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

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

  void _addColor(List<ColorTela> lista) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: AlertDialog(
            title: const Text("Nuevo Color"),
            content: StatefulBuilder(
              builder: (context, setStateDialog) {
                return SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🔹 Nombre del color
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre del color",
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// 🔹 NAVS
                      const TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.palette), text: "Base"),
                          Tab(icon: Icon(Icons.color_lens), text: "Rueda"),
                          Tab(icon: Icon(Icons.tune), text: "Picker"),
                        ],
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          children: [
                            /// NAV 1
                            _navColoresBase(selectedColor, (color) {
                              setStateDialog(() {
                                selectedColor = color;
                              });
                            }),

                            /// NAV 2
                            _navRuedaColor(selectedColor, (color) {
                              setStateDialog(() {
                                selectedColor = color;
                              });
                            }),

                            /// NAV 3
                            _navColorPickerAvanzado(selectedColor, (color) {
                              setStateDialog(() {
                                selectedColor = color;
                              });
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔹 Vista previa
                      Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final hex =
                      '#${selectedColor.value.toRadixString(16).substring(2)}';

                  await ref
                      .read(catalogServiceProvider)
                      .addColor(
                        ColorTela(
                          id: Helpers.generarId(),
                          nombre: name,
                          hex: hex,
                        ),
                      );

                  ref.refresh(coloresProvider);

                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navColoresBase(Color selectedColor, Function(Color) onColorChanged) {
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
          onTap: () => onColorChanged(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selectedColor == color
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

  Widget _navRuedaColor(Color selectedColor, Function(Color) onColorChanged) {
    return ColorPicker(
      color: selectedColor,
      onColorChanged: onColorChanged,
      enableShadesSelection: false,
      pickersEnabled: const {
        ColorPickerType.wheel: true,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
      },
    );
  }

  Widget _navColorPickerAvanzado(
    Color selectedColor,
    Function(Color) onColorChanged,
  ) {
    return ColorPicker(
      color: selectedColor,
      onColorChanged: onColorChanged,
      enableShadesSelection: true,
      showColorCode: true,
      pickersEnabled: const {
        ColorPickerType.wheel: true,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
      },
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
