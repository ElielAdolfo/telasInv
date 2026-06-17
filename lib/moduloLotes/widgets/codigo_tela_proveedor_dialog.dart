import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/lotes/codigo_tela_proveedor.dart';
import 'package:inv_telas/models/lotes/precio_config.dart';
import 'package:inv_telas/models/lotes/precio_sucursal_config.dart';
import 'package:inv_telas/models/sucursal.dart';
import 'package:inv_telas/models/moneda.dart';
import 'package:inv_telas/providers/codigo_tela_proveedor_provider.dart';
import 'package:inv_telas/providers/sucursal_provider.dart';
import 'package:inv_telas/providers/moneda_provider.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';
import 'package:uuid/uuid.dart';

class CodigoTelaProveedorDialog extends ConsumerStatefulWidget {
  final String empresaId;
  final String proveedorId;
  final String tipoTelaId;
  final String proveedorNombre;
  final String tipoTelaNombre;

  final CodigoTelaProveedor? relacion;

  const CodigoTelaProveedorDialog({
    super.key,
    required this.empresaId,
    required this.proveedorId,
    required this.tipoTelaId,
    required this.proveedorNombre,
    required this.tipoTelaNombre,
    this.relacion,
  });

  @override
  ConsumerState<CodigoTelaProveedorDialog> createState() =>
      _CodigoTelaProveedorDialogState();
}

class _CodigoTelaProveedorDialogState
    extends ConsumerState<CodigoTelaProveedorDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _datosCargados = false;

  // ---- ESTADO DE VINCULACIÓN DE METRAJES ----
  bool _metrajesVinculados = true;
  bool _isSyncingMetraje = false;

  // ---- CONTROLES GLOBAL IMPORTACIÓN ----
  String? monedaImpId;
  final impMetroCtrl = TextEditingController();
  final impRolloCtrl = TextEditingController();
  final impMetrajeFijoCtrl = TextEditingController(text: '50.0');

  // ---- CONTROLES GLOBAL LOCAL ----
  String? monedaLocGenId;
  final locGenMetroCtrl = TextEditingController();
  final locGenRolloCtrl = TextEditingController();
  final locGenMetrajeFijoCtrl = TextEditingController(text: '50.0');

  // ---- CONTROLES DINÁMICOS POR SUCURSAL ----
  final Map<String, bool> _usaPrecioEspecifico = {};
  final Map<String, String> _sucursalMonedaIds = {};
  final Map<String, TextEditingController> _sucursalMetroCtrls = {};
  final Map<String, TextEditingController> _sucursalRolloCtrls = {};
  final Map<String, TextEditingController> _sucursalMetrajeCtrls = {};

  @override
  void initState() {
    super.initState();
    // Escuchamos los cambios en ambos controladores para la sincronización en tiempo real
    impMetrajeFijoCtrl.addListener(_onImpMetrajeChanged);
    locGenMetrajeFijoCtrl.addListener(_onLocGenMetrajeChanged);
  }

  void _onImpMetrajeChanged() {
    if (!_metrajesVinculados || _isSyncingMetraje) return;
    _isSyncingMetraje = true;
    locGenMetrajeFijoCtrl.text = impMetrajeFijoCtrl.text;
    _isSyncingMetraje = false;
  }

  void _onLocGenMetrajeChanged() {
    if (!_metrajesVinculados || _isSyncingMetraje) return;
    _isSyncingMetraje = true;
    impMetrajeFijoCtrl.text = locGenMetrajeFijoCtrl.text;
    _isSyncingMetraje = false;
  }

  void _toggleVinculacion() {
    setState(() {
      _metrajesVinculados = !_metrajesVinculados;
      if (_metrajesVinculados) {
        // Al volver a vincular, igualamos el costo local al de importación por defecto
        locGenMetrajeFijoCtrl.text = impMetrajeFijoCtrl.text;
      }
    });
  }

  // Método unificado para inicializar los estados base usando los datos reales de la DB
  void _inicializarControles(List<Sucursal> sucursales, List<Moneda> monedas) {
    if (_datosCargados || monedas.isEmpty) return;

    final monedaBase = monedas.firstWhere(
      (m) => m.esMonedaBase,
      orElse: () => monedas.first,
    );

    final monedaUsd = monedas.firstWhere(
      (m) => m.codigo.toUpperCase() == 'USD',
      orElse: () => monedaBase,
    );

    // Inicializar estructuras de sucursales una sola vez
    for (final suc in sucursales) {
      _usaPrecioEspecifico[suc.id] = false;

      _sucursalMonedaIds[suc.id] = monedaBase.id;

      _sucursalMetroCtrls[suc.id] = TextEditingController();

      _sucursalRolloCtrls[suc.id] = TextEditingController();

      _sucursalMetrajeCtrls[suc.id] = TextEditingController(text: '50.0');
    }

    final relacion = widget.relacion;

    if (relacion != null) {
      // ================= IMPORTACIÓN =================

      monedaImpId = relacion.precioImportacion.monedaId;

      impMetroCtrl.text = relacion.precioImportacion.precioMetro.toString();

      impRolloCtrl.text = relacion.precioImportacion.precioRollo.toString();

      impMetrajeFijoCtrl.text = relacion.precioImportacion.metrajeFijo
          .toString();

      // ================= LOCAL GENERAL =================

      monedaLocGenId = relacion.precioLocalGeneral.monedaId;

      locGenMetroCtrl.text = relacion.precioLocalGeneral.precioMetro.toString();

      locGenRolloCtrl.text = relacion.precioLocalGeneral.precioRollo.toString();

      locGenMetrajeFijoCtrl.text = relacion.precioLocalGeneral.metrajeFijo
          .toString();

      // ================= SUCURSALES PERSONALIZADAS =================

      for (final precioSuc in relacion.preciosLocalPorSucursal) {
        _usaPrecioEspecifico[precioSuc.sucursalId] = true;

        _sucursalMonedaIds[precioSuc.sucursalId] = precioSuc.precio.monedaId;

        _sucursalMetroCtrls[precioSuc.sucursalId]?.text = precioSuc
            .precio
            .precioMetro
            .toString();

        _sucursalRolloCtrls[precioSuc.sucursalId]?.text = precioSuc
            .precio
            .precioRollo
            .toString();

        _sucursalMetrajeCtrls[precioSuc.sucursalId]?.text = precioSuc
            .precio
            .metrajeFijo
            .toString();
      }
    } else {
      // ================= NUEVO REGISTRO =================

      monedaImpId = monedaUsd.id;

      monedaLocGenId = monedaBase.id;
    }

    _datosCargados = true;
  }

  void _sincronizarPrecios({
    required String valor,
    required bool esPorMetro,
    required TextEditingController metroCtrl,
    required TextEditingController rolloCtrl,
    required TextEditingController fijoCtrl,
  }) {
    final double input = double.tryParse(valor) ?? 0.0;
    final double metrajeFijo = double.tryParse(fijoCtrl.text) ?? 50.0;

    if (input == 0.0 || metrajeFijo == 0.0) return;

    if (esPorMetro) {
      rolloCtrl.text = (input * metrajeFijo).toStringAsFixed(2);
    } else {
      metroCtrl.text = (input / metrajeFijo).toStringAsFixed(4);
    }
  }

  @override
  void dispose() {
    impMetrajeFijoCtrl.removeListener(_onImpMetrajeChanged);
    locGenMetrajeFijoCtrl.removeListener(_onLocGenMetrajeChanged);

    impMetroCtrl.dispose();
    impRolloCtrl.dispose();
    impMetrajeFijoCtrl.dispose();
    locGenMetroCtrl.dispose();
    locGenRolloCtrl.dispose();
    locGenMetrajeFijoCtrl.dispose();
    for (var c in _sucursalMetroCtrls.values) {
      c.dispose();
    }
    for (var c in _sucursalRolloCtrls.values) {
      c.dispose();
    }
    for (var c in _sucursalMetrajeCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sucursalesAsync = ref.watch(sucursalesProvider(widget.empresaId));
    final monedasAsync = ref.watch(monedasProvider(widget.empresaId));

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: sucursalesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text("Error al cargar sucursales: $err")),
            data: (sucursales) {
              return monedasAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text("Error al cargar monedas: $err")),
                data: (monedas) {
                  _inicializarControles(sucursales, monedas);

                  return DefaultTabController(
                    length: 1 + sucursales.length,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 10),
                          TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              const Tab(text: "🌎 Global (Base)"),
                              ...sucursales.map(
                                (s) => Tab(text: "🏢 ${s.nombre}"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildGlobalTab(monedas),
                                ...sucursales.map(
                                  (s) => _buildSucursalTab(s, monedas),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          _buildActionButtons(monedas),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Configuración Avanzada de Costos",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Proveedor: ${widget.proveedorNombre}",
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          "Tipo Tela: ${widget.tipoTelaNombre}",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGlobalTab(List<Moneda> monedas) {
    // Construimos el botón de vinculación reutilizable con los iconos correspondientes
    final Widget botonVinculo = IconButton(
      icon: Icon(
        _metrajesVinculados ? Icons.link : Icons.link_off,
        color: _metrajesVinculados
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
      onPressed: _toggleVinculacion,
      tooltip: _metrajesVinculados
          ? "Desvincular Metrajes"
          : "Vincular Metrajes",
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeccionTitulo(
            "🚢 COSTO DE IMPORTACIÓN (Aplica a todas las sucursales)",
          ),
          _buildFormularioPrecios(
            monedaSeleccionada: monedaImpId!,
            monedas: monedas,
            metroCtrl: impMetroCtrl,
            rolloCtrl: impRolloCtrl,
            fijoCtrl: impMetrajeFijoCtrl,
            onMonedaChanged: (v) => setState(() => monedaImpId = v!),
            suffixIconMetraje: botonVinculo,
          ),
          const SizedBox(height: 25),
          _buildSeccionTitulo(
            "🏠 COSTO LOCAL GENERAL (Fallback de sucursales)",
          ),
          _buildFormularioPrecios(
            monedaSeleccionada: monedaLocGenId!,
            monedas: monedas,
            metroCtrl: locGenMetroCtrl,
            rolloCtrl: locGenRolloCtrl,
            fijoCtrl: locGenMetrajeFijoCtrl,
            onMonedaChanged: (v) => setState(() => monedaLocGenId = v!),
            suffixIconMetraje: botonVinculo,
          ),
        ],
      ),
    );
  }

  Widget _buildSucursalTab(Sucursal sucursal, List<Moneda> monedas) {
    final bool usaEspecifico = _usaPrecioEspecifico[sucursal.id] ?? false;

    return SingleChildScrollView(
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(
              "¿Fijar precio local personalizado para ${sucursal.nombre}?",
            ),
            subtitle: const Text(
              "Si se desmarca, heredará los valores del costo Local General.",
            ),
            value: usaEspecifico,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              setState(() {
                _usaPrecioEspecifico[sucursal.id] = value ?? false;
              });
            },
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: usaEspecifico ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !usaEspecifico,
              child: _buildFormularioPrecios(
                monedaSeleccionada: _sucursalMonedaIds[sucursal.id]!,
                monedas: monedas,
                metroCtrl: _sucursalMetroCtrls[sucursal.id]!,
                rolloCtrl: _sucursalRolloCtrls[sucursal.id]!,
                fijoCtrl: _sucursalMetrajeCtrls[sucursal.id]!,
                onMonedaChanged: (v) =>
                    setState(() => _sucursalMonedaIds[sucursal.id] = v!),
                validarCampos: usaEspecifico,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioPrecios({
    required String monedaSeleccionada,
    required List<Moneda> monedas,
    required TextEditingController metroCtrl,
    required TextEditingController rolloCtrl,
    required TextEditingController fijoCtrl,
    required ValueChanged<String?> onMonedaChanged,
    bool validarCampos = true,
    Widget? suffixIconMetraje, // Nuevo parámetro opcional
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: monedaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: "Moneda",
                    border: OutlineInputBorder(),
                  ),
                  items: monedas.map((m) {
                    return DropdownMenuItem<String>(
                      value: m.id,
                      child: Text("${m.simbolo} (${m.codigo})"),
                    );
                  }).toList(),
                  onChanged: onMonedaChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: fijoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Mts por Rollo",
                    border: const OutlineInputBorder(),
                    suffixIcon:
                        suffixIconMetraje, // Asignamos el botón de vínculo aquí
                  ),
                  validator: (v) => validarCampos && (v == null || v.isEmpty)
                      ? "Obligatorio"
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: metroCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Caso 1: Precio x Metro",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => _sincronizarPrecios(
                    valor: v,
                    esPorMetro: true,
                    metroCtrl: metroCtrl,
                    rolloCtrl: rolloCtrl,
                    fijoCtrl: fijoCtrl,
                  ),
                  validator: (v) => validarCampos && (v == null || v.isEmpty)
                      ? "Requerido"
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: rolloCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Caso 2: Precio x Rollo",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => _sincronizarPrecios(
                    valor: v,
                    esPorMetro: false,
                    metroCtrl: metroCtrl,
                    rolloCtrl: rolloCtrl,
                    fijoCtrl: fijoCtrl,
                  ),
                  validator: (v) => validarCampos && (v == null || v.isEmpty)
                      ? "Requerido"
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildActionButtons(List<Moneda> monedas) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => Navigator.pop(context, false),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            widget.relacion == null ? "Crear Relación" : "Actualizar Relación",
          ),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            final confirmed = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => ConfirmActionDialog(
                title: "Confirmar Cambios",
                message:
                    "¿Deseas salvar la estructura transaccional de costos mapeada?",
                icon: Icons.save_as_rounded,
                iconColor: Colors.blue,
                confirmText: "Escribir en DB",
                onConfirm: () async {
                  final notifier = ref.read(
                    codigoTelaProveedorNotifierProvider.notifier,
                  );

                  final List<PrecioSucursalConfig> listadoSucursalesDB = [];
                  _usaPrecioEspecifico.forEach((sucId, usaPrecio) {
                    if (usaPrecio) {
                      listadoSucursalesDB.add(
                        PrecioSucursalConfig(
                          sucursalId: sucId,
                          precio: PrecioConfig(
                            monedaId: _sucursalMonedaIds[sucId]!,
                            precioMetro: double.parse(
                              _sucursalMetroCtrls[sucId]!.text,
                            ),
                            precioRollo: double.parse(
                              _sucursalRolloCtrls[sucId]!.text,
                            ),
                            metrajeFijo: double.parse(
                              _sucursalMetrajeCtrls[sucId]!.text,
                            ),
                          ),
                        ),
                      );
                    }
                  });
                  final usuario = ref.read(sessionProvider).usuario;
                  if (usuario == null) {
                    throw Exception('Usuario no autenticado');
                  }
                  final entidad = CodigoTelaProveedor(
                    id: widget.relacion?.id ?? const Uuid().v4(),

                    activo: widget.relacion?.activo ?? true,
                    eliminado: widget.relacion?.eliminado ?? false,

                    usuarioCreacion:
                        widget.relacion?.usuarioCreacion ?? usuario.id,

                    fechaCreacion:
                        widget.relacion?.fechaCreacion ?? DateTime.now(),

                    usuarioModificacion: widget.relacion == null
                        ? null
                        : usuario.id,

                    fechaModificacion: widget.relacion == null
                        ? null
                        : DateTime.now(),

                    empresaId: widget.empresaId,
                    proveedorId: widget.proveedorId,
                    tipoTelaId: widget.tipoTelaId,

                    precioImportacion: PrecioConfig(
                      monedaId: monedaImpId!,
                      precioMetro: double.tryParse(impMetroCtrl.text) ?? 0,
                      precioRollo: double.tryParse(impRolloCtrl.text) ?? 0,
                      metrajeFijo:
                          double.tryParse(impMetrajeFijoCtrl.text) ?? 50,
                    ),

                    precioLocalGeneral: PrecioConfig(
                      monedaId: monedaLocGenId!,
                      precioMetro: double.tryParse(locGenMetroCtrl.text) ?? 0,
                      precioRollo: double.tryParse(locGenRolloCtrl.text) ?? 0,
                      metrajeFijo:
                          double.tryParse(locGenMetrajeFijoCtrl.text) ?? 50,
                    ),

                    preciosLocalPorSucursal: listadoSucursalesDB,
                  );

                  if (widget.relacion == null) {
                    await notifier.create(entidad);
                  } else {
                    await notifier.update(entidad);
                  }
                },
              ),
            );

            if (confirmed != true) return;
            if (mounted) Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
