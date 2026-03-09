import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/models/lote.dart'; // ✅ Importar modelo Lote
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/screens/pending_screen.dart';
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

  // Controladores
  final _cantidadController = TextEditingController(text: '1');
  late TextEditingController _codigoController;
  late TextEditingController _metrajeController;
  final _loteController = TextEditingController();
  final _numeroRolloController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _precioManualController = TextEditingController(); // ✅ NUEVO

  // Estado de selección
  String? _tipoTelaId;
  String? _sucursalId;
  String? _empresaId;
  String? _colorId;
  DateTime? _fecha;

  // Estado Checkboxes y Ancho
  bool _habilitarAncho = false;
  bool _habilitarLote = false;
  bool _habilitarNumRollo = false;
  String? _anchoId;

  // ✅ Estado para precio calculado
  double _precioCalculadoBS = 0.0;
  double _precioCalculadoUSD = 0.0;
  bool _precioEncontradoEnLote = false;

  bool _isSavingCatalog = false;
  bool _isSaving = false;

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
    _cantidadController.dispose();
    _loteController.dispose();
    _numeroRolloController.dispose();
    _observacionesController.dispose();
    _precioManualController.dispose();
    super.dispose();
  }

  String _normalize(String text) => text.trim().toLowerCase();

  void _resetFieldsForNextInput() {
    _codigoController.clear();
    _metrajeController.clear();
    _cantidadController.text = '1';
    _loteController.clear();
    _numeroRolloController.clear();
    _observacionesController.clear();
    _precioManualController.clear();
    setState(() {
      _colorId = null;
      _anchoId = null;
      _precioCalculadoBS = 0.0;
      _precioCalculadoUSD = 0.0;
      _precioEncontradoEnLote = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tipos = ref.watch(tiposTelaProvider);
    final sucursales = ref.watch(sucursalesProvider);
    final empresas = ref.watch(empresasProvider);
    final colores = ref.watch(coloresProvider);
    final anchos = ref.watch(anchosProvider);
    final drafts = ref.watch(draftsProvider);

    // ✅ OBSERVAR LOTE ACTIVO
    final loteActivo = ref.watch(loteActivoProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(drafts.length),
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

                    const Divider(height: 32, thickness: 1),

                    // ✅ SECCIÓN DE LOTE Y PRECIO
                    if (loteActivo != null) ...[
                      _buildActiveLoteBanner(loteActivo),
                      const SizedBox(height: 12),
                      if (_precioEncontradoEnLote)
                        _buildPriceDisplay()
                      else if (_tipoTelaId != null && _empresaId != null)
                        const Text(
                          "⚠️ Esta tela no está en el lote activo.",
                          style: TextStyle(color: Colors.red),
                        ),
                    ] else ...[
                      TextFormField(
                        controller: _precioManualController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Precio Compra (BS) *",
                        ),
                      ),
                    ],

                    const Divider(height: 32, thickness: 1),

                    // Sección Opciones Adicionales
                    const Text(
                      "Opciones Adicionales",
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 10),

                    // 1. ANCHO (Lógica Inteligente)
                    _buildCheckboxTile(
                      title: "Ancho Especial",
                      subtitle: "Se detecta automáticamente según empresa/tela",
                      value: _habilitarAncho,
                      onChanged: (v) {
                        setState(() => _habilitarAncho = v ?? false);
                        _autoFillData(); // Recalcular precio si cambia ancho
                      },
                    ),
                    if (_habilitarAncho)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          bottom: 16,
                          top: 4,
                        ),
                        child: _buildDropdownWithAdd<Ancho>(
                          "Seleccionar Ancho",
                          anchos,
                          _anchoId,
                          (id) {
                            setState(() => _anchoId = id);
                            _autoFillData(); // Recalcular precio si cambia ancho
                          },
                          (item) => item.id,
                          (item) => item.nombre,
                          () => _addAncho(anchos),
                        ),
                      ),

                    // 2. LOTE
                    _buildCheckboxTile(
                      title: "Lote",
                      subtitle: "Identificador de lote",
                      value: _habilitarLote,
                      onChanged: (v) =>
                          setState(() => _habilitarLote = v ?? false),
                    ),
                    if (_habilitarLote)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          bottom: 16,
                          top: 4,
                        ),
                        child: TextFormField(
                          controller: _loteController,
                          decoration: const InputDecoration(
                            labelText: "Número de Lote",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                    // 3. NUMERO DE ROLLO
                    _buildCheckboxTile(
                      title: "Número de Rollo",
                      subtitle: "Identificador único del rollo",
                      value: _habilitarNumRollo,
                      onChanged: (v) =>
                          setState(() => _habilitarNumRollo = v ?? false),
                    ),
                    if (_habilitarNumRollo)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          bottom: 16,
                          top: 4,
                        ),
                        child: TextFormField(
                          controller: _numeroRolloController,
                          decoration: const InputDecoration(
                            labelText: "N° de Rollo",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _observacionesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Observaciones",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  // ✅ WIDGETS DE UI PARA LOTE
  Widget _buildActiveLoteBanner(Lote lote) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Lote Activo: ${lote.nombre}",
              style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
            ),
          ),
          Text(
            "TC: ${lote.tipoCambio}",
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDisplay() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Precio Compra:", style: AppTextStyles.body),
            Text(
              "${_precioCalculadoBS.toStringAsFixed(2)} BS",
              style: AppTextStyles.heading3.copyWith(color: Colors.green[700]),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
    );
  }

  /// ✅ LÓGICA DE AUTODETECCIÓN Y AUTOLLENADO (ACTUALIZADO)
  void _autoFillData() {
    final loteActivo = ref.read(loteActivoProvider);

    // 1. Lógica de Ancho (Igual que antes)
    if (_empresaId != null && _tipoTelaId != null) {
      final rollos = ref
          .read(rollosProvider)
          .maybeWhen(data: (d) => d, orElse: () => <Rollo>[]);

      final matches = rollos
          .where(
            (r) => r.empresaId == _empresaId && r.tipoTelaId == _tipoTelaId,
          )
          .toList();

      if (matches.isNotEmpty) {
        final withAncho = matches.where((r) => r.anchoId != null).toList();

        setState(() {
          if (withAncho.isNotEmpty) {
            _habilitarAncho = true;
            final freq = <String, int>{};
            for (var r in withAncho) {
              freq[r.anchoId!] = (freq[r.anchoId!] ?? 0) + 1;
            }
            _anchoId = freq.entries
                .reduce((a, b) => a.value >= b.value ? a : b)
                .key;
          } else {
            _habilitarAncho = false;
            _anchoId = null;
          }
        });
      } else {
        setState(() {
          _habilitarAncho = false;
          _anchoId = null;
        });
      }
    }

    // 2. Lógica de Precio (Si hay Lote Activo)
    if (loteActivo != null && _empresaId != null && _tipoTelaId != null) {
      final item = loteActivo.items.firstWhere(
        (i) =>
            i.tipoTelaId == _tipoTelaId &&
            i.empresaId == _empresaId &&
            (i.anchoId == _anchoId || (!_habilitarAncho && i.anchoId == null)),
        orElse: () => LoteItem(
          id: '',
          tipoTelaId: '',
          empresaId: '',
          precioUSD: 0,
        ),
      );

      setState(() {
        if (item.precioUSD > 0) {
          _precioCalculadoUSD = item.precioUSD;
          _precioCalculadoBS = item.precioUSD * loteActivo.tipoCambio;
          _precioEncontradoEnLote = true;
        } else {
          _precioCalculadoBS = 0;
          _precioEncontradoEnLote = false;
        }
      });
    } else {
      setState(() {
        _precioEncontradoEnLote = false;
      });
    }

    // 3. Lógica de autollenado de código/metraje
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
        final last = matches.first;
        setState(() {
          _codigoController.text = last.codigoColor;
          if (last.metraje > 0) {
            _metrajeController.text = last.metraje % 1 == 0
                ? last.metraje.toInt().toString()
                : last.metraje.toString();
          }
        });
      }
    }
  }

  Widget _buildHeader(int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Nuevo Rollo de Tela", style: AppTextStyles.heading2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PendingScreen()),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined, size: 26),
                  ),
                  if (pendingCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCantidadSelector() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Cantidad de Rollos",
        border: OutlineInputBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              int c = int.tryParse(_cantidadController.text) ?? 1;
              if (c > 1) _cantidadController.text = (c - 1).toString();
              setState(() {});
            },
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _cantidadController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.heading2,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                if (val.isEmpty) _cantidadController.text = '1';
              },
            ),
          ),
          IconButton(
            onPressed: () {
              int c = int.tryParse(_cantidadController.text) ?? 0;
              _cantidadController.text = (c + 1).toString();
              setState(() {});
            },
            icon: const Icon(Icons.add_circle_outline),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: LinearProgressIndicator(minHeight: 4),
            ),
          Row(
            children: [
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
            "Campos opcionales y observaciones incluidos.",
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
                      value: getId(e),
                      child: Text(getLabel(e)),
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

  Widget _buildColorDropdownWithAdd(
    String label,
    List<ColorTela> colores,
    String? selectedId,
    ValueChanged<String?> onChanged,
    VoidCallback onAdd,
  ) {
    Color? bgColor;
    Color txtColor = Colors.black;
    if (selectedId != null) {
      final s = colores.firstWhere(
        (c) => c.id == selectedId,
        orElse: () => ColorTela(id: '', nombre: '', hex: '#FFFFFF'),
      );
      bgColor = Helpers.hexToColorFlutter(s.hex);
      txtColor = bgColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedId,
              dropdownColor: Colors.white,
              style: TextStyle(color: txtColor, fontWeight: FontWeight.w600),
              items: colores
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
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
                labelStyle: TextStyle(color: txtColor),
                filled: true,
                fillColor: bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: bgColor ?? Colors.grey),
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

  // --- LÓGICA DE NEGOCIO ---

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fecha = d);
  }

  List<Rollo> _generarListaRollos() {
    final codigo = _codigoController.text.trim();
    final metraje = double.tryParse(_metrajeController.text) ?? 0;
    final cantidad = int.tryParse(_cantidadController.text) ?? 1;
    final loteActivo = ref.read(loteActivoProvider);

    // Variables de precio
    String? loteId;
    double? precioUsd;
    double? tipoCambio;
    double? precioFinal;

    if (loteActivo != null && _precioEncontradoEnLote) {
      // Si hay lote activo y encontramos precio
      loteId = loteActivo.id;
      precioUsd = _precioCalculadoUSD;
      tipoCambio = loteActivo.tipoCambio;
      precioFinal = _precioCalculadoBS;
    } else {
      // Si no hay lote, usar precio manual
      precioFinal = double.tryParse(_precioManualController.text) ?? 0;
    }

    return List.generate(
      cantidad,
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
        anchoId: _habilitarAncho ? _anchoId : null,
        lote: _habilitarLote ? _loteController.text.trim() : null,
        numeroRollo: _habilitarNumRollo
            ? _numeroRolloController.text.trim()
            : null,
        notas: _observacionesController.text.trim(),
        loteId: loteId,
        precioUsd: precioUsd,
        tipoCambio: tipoCambio,
        precioCompra: precioFinal,
      ),
    );
  }

  Future<void> _subirIndividual() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    // Validar precio
    final loteActivo = ref.read(loteActivoProvider);
    if (loteActivo == null &&
        (double.tryParse(_precioManualController.text) ?? 0) <= 0) {
      _mostrarError("Ingrese un precio válido.");
      return;
    }

    setState(() => _isSaving = true);
    try {
      final rollos = _generarListaRollos();
      final ok = await ref.read(rollosProvider.notifier).crearRollos(rollos);
      if (ok && mounted) {
        _mostrarExito("✅ ${rollos.length} rollos subidos a Firebase");
        _resetFieldsForNextInput();
      } else {
        throw Exception("Error al guardar");
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
    // Validar precio
    final loteActivo = ref.read(loteActivoProvider);
    if (loteActivo == null &&
        (double.tryParse(_precioManualController.text) ?? 0) <= 0) {
      _mostrarError("Ingrese un precio válido.");
      return;
    }

    setState(() => _isSaving = true);
    try {
      final rollos = _generarListaRollos();
      for (var rollo in rollos) {
        await ref.read(draftsProvider.notifier).add(rollo);
      }
      if (mounted) {
        _mostrarExito("📦 ${rollos.length} rollos añadidos a pendientes");
        _resetFieldsForNextInput();
      }
    } catch (e) {
      _mostrarError("Error al guardar local: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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

  // --- QUICK ADDS ---

  void _addAncho(List<Ancho> lista) => _quickAddGeneric<Ancho>(
        title: "Nuevo Ancho",
        existingItems: lista,
        getName: (a) => a.nombre,
        onCreate: (name) async {
          final id = Helpers.generarId();
          await ref
              .read(catalogServiceProvider)
              .addAncho(Ancho(id: id, nombre: name));
          ref.refresh(anchosProvider);
          return id;
        },
        onSelected: (id) => setState(() => _anchoId = id),
      );

  void _addTipoTela(List<TipoTela> lista) => _quickAddGeneric<TipoTela>(
        title: "Nuevo Tipo de Tela",
        existingItems: lista,
        getName: (t) => t.nombre,
        onCreate: (name) async {
          final id = Helpers.generarId();
          await ref
              .read(catalogServiceProvider)
              .addTipoTela(TipoTela(id: id, nombre: name));
          ref.refresh(tiposTelaProvider);
          return id;
        },
        onSelected: (id) => setState(() => _tipoTelaId = id),
      );

  void _addSucursal(List<Sucursal> lista) => _quickAddGeneric<Sucursal>(
        title: "Nueva Sucursal",
        existingItems: lista,
        getName: (s) => s.nombre,
        onCreate: (name) async {
          final id = Helpers.generarId();
          await ref
              .read(catalogServiceProvider)
              .addSucursal(Sucursal(id: id, nombre: name));
          ref.refresh(sucursalesProvider);
          return id;
        },
        onSelected: (id) => setState(() => _sucursalId = id),
      );

  void _addEmpresa(List<Empresa> lista) => _quickAddGeneric<Empresa>(
        title: "Nueva Empresa",
        existingItems: lista,
        getName: (e) => e.nombre,
        onCreate: (name) async {
          final id = Helpers.generarId();
          await ref
              .read(catalogServiceProvider)
              .addEmpresa(Empresa(id: id, nombre: name));
          ref.refresh(empresasProvider);
          return id;
        },
        onSelected: (id) => setState(() => _empresaId = id),
      );

  void _addColor(List<ColorTela> lista) => showDialog(
        context: context,
        builder: (context) => _ColorPickerDialog(
          ref: ref,
          existingColors: lista,
          onColorCreated: (id) => setState(() => _colorId = id),
        ),
      );

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
                            title: "Duplicado",
                            message: "Ya existe este registro.",
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

// ================= DIALOG DE COLOR =================

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

  final Map<int, double> _heightFactors = {0: 0.36, 1: 0.42, 2: 0.6};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool useWhiteForeground(Color background) =>
      (0.299 * background.red +
              0.587 * background.green +
              0.114 * background.blue) /
          255 <
      0.5;

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
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Nombre",
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

                        if (widget.existingColors.any(
                          (c) => c.nombre.toLowerCase() == name.toLowerCase(),
                        )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Este color ya existe"),
                            ),
                          );
                          return;
                        }

                        final hex =
                            '#${_selectedColor.value.toRadixString(16).substring(2)}';
                        final id = Helpers.generarId();

                        await widget.ref
                            .read(catalogServiceProvider)
                            .addColor(
                              ColorTela(id: id, nombre: name, hex: hex),
                            );
                        widget.ref.refresh(coloresProvider);

                        widget.onColorCreated(id);
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
      itemBuilder: (ctx, i) => GestureDetector(
        onTap: () => setState(() => _selectedColor = colores[i]),
        child: Container(
          decoration: BoxDecoration(
            color: colores[i],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _selectedColor == colores[i]
                  ? Colors.black
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navRuedaColor() => flex.ColorPicker(
        color: _selectedColor,
        onColorChanged: (c) => setState(() => _selectedColor = c),
        enableShadesSelection: false,
        pickersEnabled: const {
          flex.ColorPickerType.wheel: true,
          flex.ColorPickerType.primary: false,
          flex.ColorPickerType.accent: false,
        },
      );

  Widget _navColorPickerAvanzado() => LayoutBuilder(
        builder: (ctx, constraints) => flutter_picker.ColorPicker(
          pickerColor: _selectedColor,
          onColorChanged: (c) => setState(() => _selectedColor = c),
          enableAlpha: true,
          displayThumbColor: true,
          showLabel: false,
          paletteType: constraints.maxWidth < 400
              ? flutter_picker.PaletteType.hsv
              : flutter_picker.PaletteType.hsvWithHue,
          pickerAreaHeightPercent: constraints.maxWidth < 400 ? 0.6 : 0.7,
          hexInputBar: true,
        ),
      );
}