import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/models/lote.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/providers/lotes_providers.dart'; // Asegúrate que este provider exista
import 'package:inv_telas/screens/pending_screen.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/widgets.dart';
import 'package:flex_color_picker/flex_color_picker.dart' as flex;
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as flutter_picker;
import 'package:inv_telas/widgets/dialogs/new_currency_dialog.dart';

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
  final _loteController =
      TextEditingController(); // Texto libre si no es lote activo
  final _numeroRolloController = TextEditingController();
  final _observacionesController = TextEditingController();

  // Controladores manuales (para modo sin lote)
  final _precioManualController = TextEditingController();
  final _precioOriginalController = TextEditingController();
  final _tipoCambioManualController = TextEditingController();

  // Estado de selección
  String? _tipoTelaId;
  String? _sucursalId;
  String? _empresaId;
  String? _colorId;
  DateTime? _fecha;

  // Estado Lote
  String? _selectedLoteId;

  // Estado Checkboxes y Ancho
  bool _habilitarAncho = false;
  bool _habilitarNumRollo = false;
  String? _anchoId;

  // Moneda Manual (Modo sin Lote)
  String? _monedaSeleccionadaId;
  bool _isBs = true;

  bool _isSavingCatalog = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController();
    _metrajeController = TextEditingController();
    _fecha = DateTime.now();

    // Listeners para cálculo manual
    _precioOriginalController.addListener(_calcularPrecioBsManual);
    _tipoCambioManualController.addListener(_calcularPrecioBsManual);
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
    _precioOriginalController.dispose();
    _tipoCambioManualController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LÓGICA DE FILTRADO Y CÁLCULO
  // ==========================================================

  void _calcularPrecioBsManual() {
    // Solo calcular si estamos en modo manual, moneda extranjera
    if (_isBs || _selectedLoteId != null) return;

    final original = double.tryParse(_precioOriginalController.text) ?? 0;
    final tc = double.tryParse(_tipoCambioManualController.text) ?? 0;
    final total = original * tc;

    _precioManualController.text = total.toStringAsFixed(2);
    setState(() {});
  }

  // Retorna el objeto Lote seleccionado actualmente
  Lote? get _currentLote {
    if (_selectedLoteId == null) return null;
    final lotes = ref
        .read(lotesListProvider)
        .maybeWhen(data: (d) => d, orElse: () => <Lote>[]);
    try {
      return lotes.firstWhere((l) => l.id == _selectedLoteId);
    } catch (_) {
      return null;
    }
  }

  // Filtra las empresas disponibles según el Lote
  List<Empresa> _getAvailableEmpresas(List<Empresa> allEmpresas) {
    final lote = _currentLote;
    if (lote == null) return allEmpresas;

    // Obtener IDs únicos de empresas dentro de los items del lote
    final ids = lote.items.map((i) => i.empresaId).toSet();
    return allEmpresas.where((e) => ids.contains(e.id)).toList();
  }

  // Filtra los tipos de tela según Lote y Empresa seleccionada
  List<TipoTela> _getAvailableTelas(List<TipoTela> allTelas) {
    final lote = _currentLote;
    if (lote == null) return allTelas;
    if (_empresaId == null)
      return []; // Si hay lote pero no empresa, no mostrar nada aún

    final ids = lote.items
        .where((i) => i.empresaId == _empresaId)
        .map((i) => i.tipoTelaId)
        .toSet();

    return allTelas.where((t) => ids.contains(t.id)).toList();
  }

  /// Lógica combinada de Auto-llenado y Actualización de Estado
  void _updateDataAndAutoFill() {
    final lote = _currentLote;

    // 1. Sincronizar Fecha si hay lote
    if (lote != null) {
      _fecha = lote.fechaIngreso;
    } else {
      // Si se desactiva el lote, volvemos a hoy por defecto si no estaba definida
      if (_fecha == null) _fecha = DateTime.now();
    }

    // 2. Auto-detectar Ancho basado en historial (Lógica antigua)
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
          _habilitarAncho = withAncho.isNotEmpty;
          // Tomar el ancho más reciente o frecuente
          _anchoId = withAncho.isNotEmpty ? withAncho.first.anchoId : null;
        });
      } else {
        setState(() {
          _habilitarAncho = false;
          _anchoId = null;
        });
      }
    }

    // 3. Autollenado de código/metraje basado en Empresa+Tela+Color
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

    setState(() {}); // Forzar actualización visual
  }

  // ==========================================================
  // BUILD PRINCIPAL
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final tipos = ref.watch(tiposTelaProvider);
    final sucursales = ref.watch(sucursalesProvider);
    final empresas = ref.watch(empresasProvider);
    final colores = ref.watch(coloresProvider);
    final anchos = ref.watch(anchosProvider);
    final drafts = ref.watch(draftsProvider);
    final monedas = ref.watch(monedasProvider);
    final lotesActivos = ref
        .watch(lotesListProvider)
        .maybeWhen(data: (d) => d, orElse: () => <Lote>[]);

    // Listas filtradas según lote
    final availableEmpresas = _getAvailableEmpresas(empresas);
    final availableTelas = _getAvailableTelas(tipos);

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
                    // --- 1. LOTE Y CANTIDAD (Fila Superior) ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildLoteDropdown(lotesActivos),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCantidadSelectorCompact()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 2. EMPRESA (Arriba) ---
                    _buildDropdownWithAdd<Empresa>(
                      "Empresa",
                      availableEmpresas,
                      _empresaId,
                      (id) {
                        setState(() {
                          _empresaId = id;
                          _tipoTelaId = null; // Reset tela al cambiar empresa
                          _updateDataAndAutoFill();
                        });
                      },
                      (item) => item.id,
                      (item) => item.nombre,
                      () => _addEmpresa(empresas),
                      enabled:
                          _selectedLoteId == null ||
                          availableEmpresas.isNotEmpty,
                    ),

                    // --- 3. TIPO DE TELA (Abajo de Empresa) ---
                    _buildDropdownWithAdd<TipoTela>(
                      "Tipo de Tela",
                      availableTelas,
                      _tipoTelaId,
                      (id) {
                        setState(() {
                          _tipoTelaId = id;
                          _updateDataAndAutoFill();
                        });
                      },
                      (item) => item.id,
                      (item) => item.nombre,
                      () => _addTipoTela(tipos),
                      enabled:
                          _selectedLoteId == null ||
                          (_empresaId != null && availableTelas.isNotEmpty),
                    ),

                    // --- 4. SUCURSAL (Solo si NO hay Lote) ---
                    if (_selectedLoteId == null)
                      _buildDropdownWithAdd<Sucursal>(
                        "Sucursal",
                        sucursales,
                        _sucursalId,
                        (id) => setState(() => _sucursalId = id),
                        (item) => item.id,
                        (item) => item.nombre,
                        () => _addSucursal(sucursales),
                      ),

                    // --- 5. COLOR, CODIGO, METRAJE ---
                    _buildColorDropdownWithAdd("Color", colores, _colorId, (
                      id,
                    ) {
                      setState(() => _colorId = id);
                      _updateDataAndAutoFill();
                    }, () => _addColor(colores)),

                    TextFormField(
                      controller: _codigoController,
                      decoration: const InputDecoration(
                        labelText: "Código de Color *",
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 12),

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

                    const SizedBox(height: 16),

                    // --- 6. FECHA (Condicional) ---
                    if (_selectedLoteId != null && _currentLote != null)
                      _buildFechaLoteLabel(_currentLote!)
                    else
                      _buildDateSelector(),

                    const Divider(height: 32, thickness: 1),

                    // --- 7. MONEDA Y PRECIO (Condicional) ---
                    if (_selectedLoteId != null && _currentLote != null)
                      _buildLotePriceInfo(_currentLote!)
                    else
                      _buildManualCurrencySection(monedas),

                    const Divider(height: 32, thickness: 1),

                    // --- 8. OPCIONES ADICIONALES ---
                    _buildAdditionalOptions(anchos),

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

  // ==========================================================
  // WIDGETS DE UI ESPECÍFICOS
  // ==========================================================

  Widget _buildLoteDropdown(List<Lote> lotes) {
    return DropdownButtonFormField<String>(
      value: _selectedLoteId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: "Lote",
        fillColor: _selectedLoteId != null
            ? AppColors.primary.withOpacity(0.05)
            : null,
        filled: _selectedLoteId != null,
        border: const OutlineInputBorder(),
      ),
      hint: const Text("Seleccionar Lote"),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text(
            "Sin Lote (Manual)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...lotes.map(
          (lote) => DropdownMenuItem(
            value: lote.id,
            child: Text(lote.nombre, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (v) {
        setState(() {
          _selectedLoteId = v;
          // Resetear dependencias al cambiar lote
          _empresaId = null;
          _tipoTelaId = null;
          _sucursalId = null;
          _updateDataAndAutoFill();
        });
      },
    );
  }

  Widget _buildCantidadSelectorCompact() {
    return TextFormField(
      controller: _cantidadController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: "Cantidad",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFechaLoteLabel(Lote lote) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Fecha de Ingreso (Lote)",
        border: OutlineInputBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Helpers.formatearFecha(lote.fechaIngreso),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const Icon(Icons.lock, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLotePriceInfo(Lote lote) {
    // Buscar precio en los items del lote
    double precioUnit = 0;
    String nombreMoneda = "Bs";
    double tipoCambio = lote.tipoCambio;

    if (_empresaId != null && _tipoTelaId != null) {
      final item = lote.items.firstWhere(
        (i) => i.empresaId == _empresaId && i.tipoTelaId == _tipoTelaId,
        orElse: () =>
            LoteItem(empresaId: '', tipoTelaId: '', precioUnitario: 0),
      );
      precioUnit = item.precioUnitario;
      nombreMoneda = lote.esBoliviano ? "Bs" : "USD";
    }

    double totalBs = lote.esBoliviano ? precioUnit : precioUnit * tipoCambio;

    if (precioUnit == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "⚠️ Seleccione Empresa y Tela para ver precio.",
          style: TextStyle(color: Colors.orange),
        ),
      );
    }

    return Card(
      color: Colors.green[50],
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Información de Costo (Lote)", style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Precio Unitario:"),
                Text(
                  "$precioUnit $nombreMoneda",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (!lote.esBoliviano) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tipo de Cambio:"),
                  Text(
                    "$tipoCambio Bs",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total BS:", style: AppTextStyles.heading3),
                  Text(
                    "${totalBs.toStringAsFixed(2)} Bs",
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManualCurrencySection(List<Moneda> monedas) {
    final monedaSeleccionada = monedas
        .where((m) => m.id == _monedaSeleccionadaId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _monedaSeleccionadaId,
          decoration: const InputDecoration(
            labelText: "Moneda",
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: 'bs', child: Text("Boliviano (Bs)")),
            ...monedas
                .where((m) => m.id != 'bs')
                .map(
                  (m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)),
                ),
          ],
          onChanged: (v) {
            setState(() {
              _monedaSeleccionadaId = v;
              _isBs = v == 'bs';
              // Limpiar cálculos al cambiar moneda
              _precioManualController.clear();
              _precioOriginalController.clear();
            });
          },
        ),
        const SizedBox(height: 12),

        if (_isBs)
          TextFormField(
            controller: _precioManualController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Precio Compra (BS)",
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                _selectedLoteId == null && (v == null || v.isEmpty)
                ? 'Requerido'
                : null,
          )
        else
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _precioOriginalController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: "Monto ${monedaSeleccionada?.nombre ?? 'Ext'}",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _tipoCambioManualController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "T.C.",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        if (!_isBs) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Total Calculado: ${_precioManualController.text} Bs",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalOptions(List<Ancho> anchos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Opciones Adicionales", style: AppTextStyles.heading3),
        const SizedBox(height: 10),

        // Ancho Especial
        CheckboxListTile(
          title: const Text("Ancho Especial"),
          subtitle: _habilitarAncho
              ? const Text(
                  "Detectado automáticamente",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                )
              : null,
          value: _habilitarAncho,
          onChanged: (v) => setState(() => _habilitarAncho = v ?? false),
          contentPadding: EdgeInsets.zero,
        ),
        if (_habilitarAncho)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: _buildDropdownWithAdd<Ancho>(
              "Seleccionar Ancho",
              anchos,
              _anchoId,
              (id) => setState(() => _anchoId = id),
              (item) => item.id,
              (item) => item.nombre,
              () => _addAncho(anchos),
            ),
          ),

        // Numero de Rollo
        CheckboxListTile(
          title: const Text("Número de Rollo"),
          value: _habilitarNumRollo,
          onChanged: (v) => setState(() => _habilitarNumRollo = v ?? false),
          contentPadding: EdgeInsets.zero,
        ),
        if (_habilitarNumRollo)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: TextFormField(
              controller: _numeroRolloController,
              decoration: const InputDecoration(
                labelText: "N° de Rollo",
                border: OutlineInputBorder(),
              ),
            ),
          ),

        TextFormField(
          controller: _observacionesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: "Observaciones",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // WIDGETS AUXILIARES HEREDADOS Y ADAPTADOS
  // ==========================================================

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

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fecha = d);
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
                  ),
                ),
              ),
            ],
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
    VoidCallback onAdd, {
    bool enabled = true,
  }) {
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
              onChanged: enabled ? onChanged : null,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                filled: !enabled,
                fillColor: enabled ? null : Colors.grey[200],
              ),
            ),
          ),
          if (_selectedLoteId ==
              null) // Solo permitir agregar nuevo si no estamos en modo Lote
            IconButton(
              onPressed: enabled ? onAdd : null,
              icon: const Icon(Icons.add),
            ),
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
              ),
            ),
          ),
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  // ==========================================================
  // LÓGICA DE NEGOCIO Y ENVÍO
  // ==========================================================

  List<Rollo> _generarListaRollos() {
    final codigo = _codigoController.text.trim();
    final metraje = double.tryParse(_metrajeController.text) ?? 0;
    final cantidad = int.tryParse(_cantidadController.text) ?? 1;
    final lote = _currentLote;

    // Variables de precio
    String? loteId;
    double? precioUsd;
    double? tipoCambio;
    double? precioFinal;
    String? monedaId;

    if (lote != null && _empresaId != null && _tipoTelaId != null) {
      // LÓGICA LOTE
      loteId = lote.id;
      final item = lote.items.firstWhere(
        (i) => i.empresaId == _empresaId && i.tipoTelaId == _tipoTelaId,
        orElse: () =>
            LoteItem(empresaId: '', tipoTelaId: '', precioUnitario: 0),
      );

      precioFinal = item.precioUnitario;
      tipoCambio = lote.tipoCambio;
      monedaId = lote.esBoliviano ? 'bs' : lote.monedaExtranjeraId;

      if (!lote.esBoliviano) {
        precioUsd = item.precioUnitario; // El precio del item es USD
        precioFinal = item.precioUnitario * lote.tipoCambio; // Convertir a BS
      }
    } else {
      // LÓGICA MANUAL
      precioFinal = double.tryParse(_precioManualController.text) ?? 0;
      monedaId = _isBs ? 'bs' : _monedaSeleccionadaId;

      if (!_isBs) {
        precioUsd = double.tryParse(_precioOriginalController.text);
        tipoCambio = double.tryParse(_tipoCambioManualController.text);
      }
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
        lote: _loteController.text.trim().isEmpty
            ? null
            : _loteController.text.trim(),
        numeroRollo: _habilitarNumRollo
            ? _numeroRolloController.text.trim()
            : null,
        notas: _observacionesController.text.trim(),
        loteId: loteId,
        precioUsd: precioUsd,
        tipoCambio: tipoCambio,
        precioCompra: precioFinal,
        monedaId: monedaId,
      ),
    );
  }

  Future<void> _subirIndividual() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    // Validaciones específicas
    if (_selectedLoteId != null) {
      if (_empresaId == null || _tipoTelaId == null) {
        _mostrarError("Debe seleccionar Empresa y Tipo de Tela para el Lote.");
        return;
      }
    } else {
      // Validar precio manual si no hay lote
      if ((double.tryParse(_precioManualController.text) ?? 0) <= 0) {
        _mostrarError("Ingrese un precio válido.");
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final rollos = _generarListaRollos();
      final ok = await ref.read(rollosProvider.notifier).crearRollos(rollos);
      if (ok && mounted) {
        _mostrarExito("✅ ${rollos.length} rollos subidos");
        // Reset simple
        _codigoController.clear();
        _metrajeController.clear();
        _cantidadController.text = '1';
        setState(() {
          _colorId = null;
          _habilitarAncho = false;
          _anchoId = null;
        });
      }
    } catch (e) {
      _mostrarError("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _agregarALote() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final rollos = _generarListaRollos();
      for (var rollo in rollos) {
        await ref.read(draftsProvider.notifier).add(rollo);
      }
      if (mounted) {
        _mostrarExito("📦 ${rollos.length} rollos añadidos a pendientes");
        // Reset simple
        _codigoController.clear();
        _metrajeController.clear();
        _cantidadController.text = '1';
        setState(() {
          _colorId = null;
        });
      }
    } catch (e) {
      _mostrarError("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _mostrarExito(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  void _mostrarError(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

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

  String _normalize(String text) => text.trim().toLowerCase();

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
