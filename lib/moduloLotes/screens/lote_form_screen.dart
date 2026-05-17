import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/catalogos.dart';
import 'package:inv_telas/models/lote.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/providers/lotes_providers.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/utils/helpers.dart'; // Asegúrate de tener este import para formatear fechas
import 'package:uuid/uuid.dart';

class LoteFormScreen extends ConsumerStatefulWidget {
  final String? loteId;

  const LoteFormScreen({super.key, this.loteId});

  @override
  ConsumerState<LoteFormScreen> createState() => _LoteFormScreenState();
}

class _LoteFormScreenState extends ConsumerState<LoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _vigenciaCtrl = TextEditingController(text: '5');
  final _tipoCambioCtrl = TextEditingController(text: '1.0');

  bool _isLoading = false;
  bool _esBoliviano = true;
  String? _selectedMonedaId;
  String? _selectedResponsableId;

  late DateTime _fechaIngreso;

  // ✅ Estado para la lista de items del lote
  List<LoteItem> _items = [];

  // ✅ Controladores para el formulario de "Agregar Item"
  final _precioInputCtrl = TextEditingController();
  String? _selectedAddEmpresaId;
  String? _selectedAddTelaId;

  @override
  void initState() {
    super.initState();
    _fechaIngreso = DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    _precioInputCtrl.dispose();
    super.dispose();
  }

  void _loadData() {
    if (widget.loteId != null) {
      Future.microtask(() {
        final lote = ref.read(lotePorIdProvider(widget.loteId!));
        if (lote != null && mounted) {
          setState(() {
            _nombreCtrl.text = lote.nombre;
            _vigenciaCtrl.text = lote.vigenciaDias.toString();
            _tipoCambioCtrl.text = lote.tipoCambio.toString();
            _esBoliviano = lote.esBoliviano;
            _selectedMonedaId = lote.monedaExtranjeraId;
            _selectedResponsableId = lote.usuarioResponsableId;
            _items = lote.items;
            _fechaIngreso = lote.fechaIngreso;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresas = ref.watch(empresasProvider);
    final tiposTela = ref.watch(tiposTelaProvider);
    final monedas = ref.watch(monedasProvider);
    final usuarios = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loteId == null ? "Nuevo Lote" : "Editar Lote"),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. CONFIGURACIÓN GENERAL ---
                    _sectionTitle("Datos del Lote"),
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nombre del Lote",
                      ),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    ),
                    _buildFechaIngresoSelector(),
                    TextFormField(
                      controller: _vigenciaCtrl,
                      decoration: const InputDecoration(
                        labelText: "Vigencia (Días)",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Responsable
                    DropdownButtonFormField<String>(
                      value: _selectedResponsableId,
                      decoration: const InputDecoration(
                        labelText: "Usuario Responsable",
                      ),
                      items: usuarios.value != null
                          ? [
                              DropdownMenuItem(
                                value: usuarios.value!.id,
                                child: Text(usuarios.value!.nombre),
                              ),
                            ]
                          : [],
                      onChanged: (v) =>
                          setState(() => _selectedResponsableId = v),
                    ),
                    const SizedBox(height: 20),

                    // --- 2. MONEDA ---
                    _sectionTitle("Configuración Monetaria"),
                    SwitchListTile(
                      title: const Text("Compra en Bolivianos"),
                      value: _esBoliviano,
                      onChanged: (v) => setState(() => _esBoliviano = v),
                    ),
                    if (!_esBoliviano) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedMonedaId,
                        hint: const Text("Seleccione Moneda"),
                        items: monedas
                            .where((m) => m.nombre.toUpperCase() != 'BOLIVIANO')
                            .map(
                              (m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(m.nombre),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedMonedaId = v),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tipoCambioCtrl,
                        decoration: const InputDecoration(
                          labelText: "Tipo de Cambio a Bs",
                          suffixText: "Bs",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 20),

                    // --- 3. AGREGAR ITEMS (EMPRESA + TELA + PRECIO) ---
                    _sectionTitle("Agregar Productos al Lote"),
                    Text(
                      "Añada combinaciones de Empresa y Tela con su precio específico.",
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 12),

                    // Formulario interno para agregar item
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            // Fila 1: Empresa y Tela
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedAddEmpresaId,
                                    hint: const Text("Empresa"),
                                    items: empresas
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.id,
                                            child: Text(e.nombre),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setState(
                                      () => _selectedAddEmpresaId = v,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedAddTelaId,
                                    hint: const Text("Tipo Tela"),
                                    items: tiposTela
                                        .map(
                                          (t) => DropdownMenuItem(
                                            value: t.id,
                                            child: Text(t.nombre),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedAddTelaId = v),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Fila 2: Precio y Botón
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _precioInputCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                      labelText: "Precio",
                                      // ✅ Cambio: No muestra 0.00, muestra vacío o la moneda
                                      suffixText: _esBoliviano ? "Bs" : "Ext",
                                    ),
                                    // ✅ Validación en tiempo real o al agregar
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: AppColors.primary,
                                    size: 30,
                                  ),
                                  onPressed: () => _addItemToList(),
                                  tooltip: "Agregar a la lista",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- 4. LISTA DE ITEMS AGREGADOS ---
                    if (_items.isNotEmpty) ...[
                      const Divider(),
                      _sectionTitle("Productos en el Lote (${_items.length})"),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final emp = empresas.firstWhere(
                            (e) => e.id == item.empresaId,
                            orElse: () => Empresa(id: '', nombre: 'N/A'),
                          );
                          final tela = tiposTela.firstWhere(
                            (t) => t.id == item.tipoTelaId,
                            orElse: () => TipoTela(id: '', nombre: 'N/A'),
                          );

                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.only(
                              left: 8,
                              right: 0,
                            ),
                            leading: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            title: Text("${emp.nombre} - ${tela.nombre}"),
                            subtitle: Text("Precio: ${item.precioUnitario}"),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("GUARDAR LOTE"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ✅ WIDGET SELECTOR DE FECHA DE INGRESO
  Widget _buildFechaIngresoSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),

        onTap: _pickFechaIngreso,

        child: IgnorePointer(
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: "Fecha de Ingreso",
              border: UnderlineInputBorder(),

              suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            ),

            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),

              child: Text(
                Helpers.formatearFecha(_fechaIngreso),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODO PARA SELECCIONAR FECHA
  Future<void> _pickFechaIngreso() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'), // Para mostrar el calendario en español
    );

    if (picked != null && picked != _fechaIngreso) {
      setState(() {
        _fechaIngreso = picked;
      });
    }
  }

  // Lógica para agregar item a la lista temporal
  void _addItemToList() {
    // Validación manual antes de agregar
    if (_selectedAddEmpresaId == null || _selectedAddTelaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione Empresa y Tipo de Tela")),
      );
      return;
    }

    final precio = double.tryParse(_precioInputCtrl.text);
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingrese un precio válido")));
      return;
    }

    // Validar duplicados
    final exists = _items.any(
      (i) =>
          i.empresaId == _selectedAddEmpresaId &&
          i.tipoTelaId == _selectedAddTelaId,
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Esta combinación ya existe en el lote")),
      );
      return;
    }

    setState(() {
      _items.add(
        LoteItem(
          empresaId: _selectedAddEmpresaId!,
          tipoTelaId: _selectedAddTelaId!,
          precioUnitario: precio,
        ),
      );
      // Resetear selects
      _precioInputCtrl.clear();
      // Opcional: resetear dropdowns
      // _selectedAddEmpresaId = null;
      // _selectedAddTelaId = null;
    });
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(title, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agregue al menos un producto al lote")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).value;
      final now = DateTime.now();

      final nuevoLote = Lote(
        id: widget.loteId ?? const Uuid().v4(),
        nombre: _nombreCtrl.text,
        fechaCreacion: widget.loteId != null
            ? ref.read(lotePorIdProvider(widget.loteId!))?.fechaCreacion ?? now
            : now,
        fechaIngreso: _fechaIngreso,
        vigenciaDias: int.tryParse(_vigenciaCtrl.text) ?? 5,
        activo: true,
        usuarioResponsableId: _selectedResponsableId ?? '',
        esBoliviano: _esBoliviano,
        monedaExtranjeraId: _esBoliviano ? null : _selectedMonedaId,
        tipoCambio: double.tryParse(_tipoCambioCtrl.text) ?? 1.0,
        items: _items, // ✅ Guardamos la lista de items
      );

      if (widget.loteId == null) {
        await ref.read(lotesServiceProvider).crearLote(nuevoLote);
      } else {
        await ref.read(lotesServiceProvider).actualizarLote(nuevoLote);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
