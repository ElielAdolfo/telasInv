import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/catalogos.dart';
import 'package:inv_telas/models/precio_venta.dart';
import 'package:inv_telas/moduloPrecios/providers/precio_provider.dart';
import 'package:inv_telas/moduloPrecios/services/precio_service.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/confirm_dialog.dart';
import 'package:inv_telas/widgets/loading_overlay.dart';
import 'package:uuid/uuid.dart';

class PrecioFormScreen extends ConsumerStatefulWidget {
  final String? sucursalIdInicial; // Cambio: puede venir una o null
  final TipoTela? tela;
  final PrecioVenta? precioExistente;

  const PrecioFormScreen({
    super.key,
    this.sucursalIdInicial,
    this.tela,
    this.precioExistente,
  });

  @override
  ConsumerState<PrecioFormScreen> createState() => _PrecioFormScreenState();
}

class _PrecioFormScreenState extends ConsumerState<PrecioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  final _precioMetroCtrl = TextEditingController();
  final _precioMayorCtrl = TextEditingController();
  final _cantMinMayorCtrl = TextEditingController();
  final _precioRolloFijoCtrl = TextEditingController();
  final _precioRolloMetroCtrl = TextEditingController();
  final _rangoMinCtrl = TextEditingController();
  final _rangoMaxCtrl = TextEditingController();

  // Estado
  List<String> _selectedSucursalIds = [];
  bool _tieneMayor = false;
  bool _tieneRollo = false;
  String _tipoRollo = 'fijo'; // 'fijo' | 'dinamico'

  // CASO EXCEPCIONAL
  bool _separarPorEmpresa = false;
  String? _empresaSeleccionada;
  String? _selectedTelaId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final p = widget.precioExistente;

    // Si estamos editando, cargamos datos existentes
    if (p != null) {
      _selectedSucursalIds = [
        p.sucursalId,
      ]; // En edición, trabajamos sobre una sucursal
      _selectedTelaId = p.telaId;
      _precioMetroCtrl.text = p.precioMetro.toString();

      _tieneMayor = p.tienePrecioMayor;
      if (_tieneMayor) {
        _precioMayorCtrl.text = p.precioMayor?.toString() ?? '';
        _cantMinMayorCtrl.text = p.cantidadMinimaMayor?.toString() ?? '';
      }

      _tieneRollo = p.tienePrecioRollo;
      _tipoRollo = p.tipoPrecioRollo;

      if (_tieneRollo) {
        if (_tipoRollo == 'fijo') {
          _precioRolloFijoCtrl.text = p.precioRolloFijo?.toString() ?? '';
        } else {
          _precioRolloMetroCtrl.text = p.precioMetroRollo?.toString() ?? '';
          _rangoMinCtrl.text = p.rangoMinRollo?.toString() ?? '';
          _rangoMaxCtrl.text = p.rangoMaxRollo?.toString() ?? '';
        }
      }

      if (p.empresaId != null) {
        _separarPorEmpresa = true;
        _empresaSeleccionada = p.empresaId;
      }
    } else {
      // Si es nuevo, y viene una sucursal inicial (desde lista de stock), la preseleccionamos
      if (widget.sucursalIdInicial != null) {
        _selectedSucursalIds = [widget.sucursalIdInicial!];
      }
      _selectedTelaId = widget.tela?.id;
    }
  }

  @override
  void dispose() {
    _precioMetroCtrl.dispose();
    _precioMayorCtrl.dispose();
    _cantMinMayorCtrl.dispose();
    _precioRolloFijoCtrl.dispose();
    _precioRolloMetroCtrl.dispose();
    _rangoMinCtrl.dispose();
    _rangoMaxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empresas = ref.watch(empresasProvider);
    final tiposTela = ref.watch(tiposTelaProvider);
    final sucursales = ref.watch(sucursalesProvider);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              widget.precioExistente == null
                  ? "Configurar Precios"
                  : "Editar Precio",
            ),
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(icon: const Icon(Icons.save), onPressed: _submit),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SELECTOR MULTIPLE DE SUCURSALES
                  _buildSucursalSelector(sucursales),
                  const SizedBox(height: 15),

                  // 2. SELECTOR DE TELA
                  if (widget.tela != null)
                    Card(
                      color: Colors.blueGrey[50],
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2),
                        title: Text("Tela: ${widget.tela!.nombre}"),
                        subtitle: Text("ID: ${widget.tela!.id}"),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedTelaId,
                      hint: const Text("Seleccionar Tela"),
                      items: tiposTela
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(t.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTelaId = v),
                      validator: (v) => v == null ? "Requerido" : null,
                    ),

                  const SizedBox(height: 20),
                  _buildSeccionEmpresa(empresas),
                  const Divider(height: 40),

                  // 3. PRECIO METRO
                  TextFormField(
                    controller: _precioMetroCtrl,
                    decoration: const InputDecoration(
                      labelText: "Precio por Metro (Base) *",
                      prefixIcon: Icon(Icons.straighten),
                      suffixText: "Bs",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                    onChanged: (_) => setState(
                      () {},
                    ), // Para recalcular totales si es necesario
                  ),
                  const SizedBox(height: 15),

                  // 4. PRECIO MAYOR
                  _buildSeccionMayor(),
                  const SizedBox(height: 15),

                  // 5. PRECIO ROLLO (NUEVA LÓGICA)
                  _buildSeccionRollo(),
                  const SizedBox(height: 40),

                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save),
                    label: Text(
                      _selectedSucursalIds.length > 1
                          ? "GUARDAR EN ${_selectedSucursalIds.length} SUCURSALES"
                          : "GUARDAR PRECIO",
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }

  // Selector Múltiple de Sucursales
  Widget _buildSucursalSelector(List<Sucursal> sucursales) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: "Sucursales donde aplica *",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _selectedSucursalIds.map((id) {
              final s = sucursales.firstWhere(
                (e) => e.id == id,
                orElse: () => Sucursal(id: id, nombre: "ID: $id"),
              );
              return Chip(
                label: Text(s.nombre),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: widget.precioExistente != null
                    ? null // Si está editando un registro existente, no debería cambiar la sucursal (crear nuevo mejor)
                    : () => setState(() => _selectedSucursalIds.remove(id)),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              );
            }).toList(),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add_location_alt_outlined, size: 20),
            label: const Text("Agregar Sucursal"),
            onPressed: widget.precioExistente != null
                ? null
                : () => _showSucursalDialog(sucursales),
          ),
          if (widget.precioExistente == null && _selectedSucursalIds.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "El precio se replicará en todas las sucursales seleccionadas.",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
              ),
            ),
        ],
      ),
    );
  }

  void _showSucursalDialog(List<Sucursal> sucursales) {
    showDialog(
      context: context,
      builder: (ctx) {
        List<String> tempSelection = List.from(_selectedSucursalIds);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Seleccionar Sucursales"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: sucursales.map((s) {
                    final isSelected = tempSelection.contains(s.id);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(s.nombre),
                      onChanged: (v) {
                        setDialogState(() {
                          if (v == true) {
                            tempSelection.add(s.id);
                          } else {
                            tempSelection.remove(s.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CANCELAR"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedSucursalIds = tempSelection);
                    Navigator.pop(ctx);
                  },
                  child: const Text("CONFIRMAR"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSeccionEmpresa(List<Empresa> empresas) {
    // Mismo código que antes...
    return Card(
      elevation: 0,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text(
                "Caso Excepcional: Precio específico por Empresa",
              ),
              subtitle: const Text(
                "Active si esta tela tiene precios diferentes por empresa.",
              ),
              value: _separarPorEmpresa,
              onChanged: (v) => setState(() => _separarPorEmpresa = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (_separarPorEmpresa) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _empresaSeleccionada,
                hint: const Text("Seleccione la Empresa"),
                items: empresas
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.id, child: Text(e.nombre)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _empresaSeleccionada = v),
                validator: (v) => _separarPorEmpresa && v == null
                    ? "Seleccione empresa"
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionMayor() {
    return Card(
      elevation: 1,
      child: ExpansionTile(
        initiallyExpanded: _tieneMayor,
        title: Row(
          children: [
            if (_tieneMayor)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              "Precio por Mayor",
              style: TextStyle(
                fontWeight: _tieneMayor ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Habilitar Precio Mayor"),
                  value: _tieneMayor,
                  onChanged: (v) => setState(() => _tieneMayor = v),
                ),
                if (_tieneMayor) ...[
                  TextFormField(
                    controller: _cantMinMayorCtrl,
                    decoration: const InputDecoration(
                      labelText: "Cantidad Mínima (Mts)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _precioMayorCtrl,
                    decoration: const InputDecoration(
                      labelText: "Precio Mayor (Bs)",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (_tieneMayor &&
                          v!.isNotEmpty &&
                          _precioMetroCtrl.text.isNotEmpty) {
                        if (double.parse(v) >
                            double.parse(_precioMetroCtrl.text)) {
                          return "Debe ser <= Precio Metro";
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionRollo() {
    return Card(
      elevation: 1,
      child: ExpansionTile(
        initiallyExpanded: _tieneRollo,
        title: Row(
          children: [
            if (_tieneRollo)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              "Precio por Rollo",
              style: TextStyle(
                fontWeight: _tieneRollo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text("Habilitar Venta por Rollo"),
                  value: _tieneRollo,
                  onChanged: (v) => setState(() => _tieneRollo = v),
                ),
                if (_tieneRollo) ...[
                  const Text("Tipo de Precio Rollo:"),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'fijo',
                        label: Text("Precio Fijo"),
                        icon: Icon(Icons.price_check),
                      ),
                      ButtonSegment(
                        value: 'dinamico',
                        label: Text("Por Metraje"),
                        icon: Icon(Icons.straighten),
                      ),
                    ],
                    selected: {_tipoRollo},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() => _tipoRollo = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 15),

                  // Lógica Visual: FIJO
                  if (_tipoRollo == 'fijo')
                    TextFormField(
                      controller: _precioRolloFijoCtrl,
                      decoration: const InputDecoration(
                        labelText: "Precio Total del Rollo (Bs)",
                        prefixIcon: Icon(Icons.attach_money),
                        helperText:
                            "Monto fijo por rollo completo, sin importar metros.",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (_tipoRollo == 'fijo' && (v == null || v.isEmpty))
                          return "Requerido";
                        return null;
                      },
                    )
                  // Lógica Visual: DINAMICO
                  else ...[
                    TextFormField(
                      controller: _precioRolloMetroCtrl,
                      decoration: const InputDecoration(
                        labelText: "Precio por Metro (Rollo) (Bs)",
                        helperText: "Debe ser menor al precio mayor o metro.",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (_tipoRollo == 'dinamico' &&
                            (v == null || v.isEmpty))
                          return "Requerido";
                        // Validación negocio
                        double precioBase = _tieneMayor
                            ? (double.tryParse(_precioMayorCtrl.text) ??
                                  double.infinity)
                            : (double.tryParse(_precioMetroCtrl.text) ??
                                  double.infinity);
                        if (v != null &&
                            v.isNotEmpty &&
                            double.parse(v) > precioBase) {
                          return "Debe ser <= ${_tieneMayor ? 'Precio Mayor' : 'Precio Metro'}";
                        }
                        return null;
                      },
                      onChanged: (_) =>
                          setState(() {}), // Para recalcular total estimado
                    ),
                    const SizedBox(height: 10),
                    const Text("Rango de Metros (Informativo):"),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rangoMinCtrl,
                            decoration: const InputDecoration(
                              labelText: "Min Mts",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _rangoMaxCtrl,
                            decoration: const InputDecoration(
                              labelText: "Max Mts",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),

                    // Calculadora de Total Estimado
                    if (_precioRolloMetroCtrl.text.isNotEmpty &&
                        _rangoMinCtrl.text.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Cálculo Estimado (Referencial):",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Builder(
                              builder: (context) {
                                final precio =
                                    double.tryParse(
                                      _precioRolloMetroCtrl.text,
                                    ) ??
                                    0;
                                final min =
                                    double.tryParse(_rangoMinCtrl.text) ?? 0;
                                final max = double.tryParse(_rangoMaxCtrl.text);

                                String text;
                                if (max != null && max > 0) {
                                  text =
                                      "Entre ${min * precio} Bs y ${max * precio} Bs";
                                } else {
                                  text = "Mínimo estimado: ${min * precio} Bs";
                                }
                                return Text(
                                  text,
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSucursalIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe seleccionar al menos una sucursal."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        titulo: "¿Guardar Precio?",
        mensaje: _selectedSucursalIds.length > 1
            ? "Se replicará el precio en ${_selectedSucursalIds.length} sucursales."
            : "Se guardará la configuración de precios.",
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) throw Exception("No autenticado");

      // Crear modelo base (sin ID de documento ni sucursal específica, el servicio lo maneja)
      final precioModel = PrecioVenta(
        id: widget.precioExistente?.id ?? '',
        sucursalId: widget.precioExistente?.sucursalId ?? '',
        telaId: _selectedTelaId!,
        telaNombre: widget.tela?.nombre ?? "N/A",
        precioMetro: double.parse(_precioMetroCtrl.text),

        tienePrecioMayor: _tieneMayor,
        precioMayor: _tieneMayor
            ? double.tryParse(_precioMayorCtrl.text)
            : null,
        cantidadMinimaMayor: _tieneMayor
            ? double.tryParse(_cantMinMayorCtrl.text)
            : null,

        tienePrecioRollo: _tieneRollo,
        tipoPrecioRollo: _tipoRollo,
        precioRolloFijo: _tieneRollo && _tipoRollo == 'fijo'
            ? double.tryParse(_precioRolloFijoCtrl.text)
            : null,
        precioMetroRollo: _tieneRollo && _tipoRollo == 'dinamico'
            ? double.tryParse(_precioRolloMetroCtrl.text)
            : null,
        rangoMinRollo: _tieneRollo && _tipoRollo == 'dinamico'
            ? double.tryParse(_rangoMinCtrl.text)
            : null,
        rangoMaxRollo: _tieneRollo && _tipoRollo == 'dinamico'
            ? double.tryParse(_rangoMaxCtrl.text)
            : null,

        empresaId: _separarPorEmpresa ? _empresaSeleccionada : null,
        activo: true,
      );

      // Llamada al servicio con lista de sucursales
      await ref
          .read(precioServiceProvider)
          .guardarPrecio(
            sucursalIds: _selectedSucursalIds,
            precioBase: precioModel,
            usuarioId: user.id,
            usuarioNombre: user.nombre,
            telaNombre: widget.tela?.nombre,
          );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
