import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/abmTiposTelas/campo_configurable.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/models/lotes/lote.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/models/lotes/rollo_info.dart';
import 'package:inv_telas/providers/color_provider.dart';
import 'package:inv_telas/providers/lote_detalle_provider.dart';
import 'package:inv_telas/providers/moneda_provider.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class GrupoRollo {
  final String uid;

  double metraje;
  String color;
  double cantidad;
  bool confirmado;

  double costoMetroOrigen;
  double costoRolloOrigen;

  Map<String, dynamic> atributosEspeciales;

  GrupoRollo({
    String? uid,
    required this.metraje,
    required this.color,
    required this.cantidad,
    this.confirmado = false,
    this.costoMetroOrigen = 0.0,
    this.costoRolloOrigen = 0.0,
    Map<String, dynamic>? atributosEspeciales,
  }) : uid = uid ?? const Uuid().v4(),
       atributosEspeciales = atributosEspeciales != null
           ? Map<String, dynamic>.from(atributosEspeciales)
           : {};
}

class DropdownColor {
  final String id;
  final String nombre;
  final String codigo;
  final String hex;

  DropdownColor({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.hex,
  });
}

class ModificarRollosScreen extends ConsumerStatefulWidget {
  final Lote lote;
  final LoteDetalle detalle;
  final Proveedor proveedor;
  final TipoTela tipoTela;

  const ModificarRollosScreen({
    super.key,
    required this.lote,
    required this.detalle,
    required this.proveedor,
    required this.tipoTela,
  });

  @override
  ConsumerState<ModificarRollosScreen> createState() =>
      _ModificarRollosScreenState();
}

class _ModificarRollosScreenState extends ConsumerState<ModificarRollosScreen> {
  Set<int> seleccionados = {};
  bool modoSeleccion = false;

  List<GrupoRollo> todosLosGrupos = [];
  List<GrupoRollo> gruposRenderizados = [];

  String _estadoOriginalSerializado = '';

  final ScrollController _scrollController = ScrollController();
  final int _tamanoPagina = 20;

  late final List<CampoConfigurable> camposEspeciales;

  @override
  void initState() {
    super.initState();
    camposEspeciales = widget.tipoTela.camposConfigurables
        .where((c) => !c.esDiferenciador)
        .toList();

    _scrollController.addListener(_scrollListener);
    _cargarDistribucionGuardada();
  }

  Future<void> _cargarDistribucionGuardada() async {
    try {
      final notifier = ref.read(loteDetallesProvider(widget.lote.id).notifier);
      final rollos = await notifier.obtenerRollosPorDetalle(
        loteDetalleId: widget.detalle.id,
      );

      if (!mounted) return;

      if (rollos.isNotEmpty) {
        setState(() {
          todosLosGrupos = rollos.map((r) {
            return GrupoRollo(
              uid: r.id,
              metraje: r.metraje,
              color: r.colorId,
              cantidad: r.cantidad.toDouble(),
              confirmado: true,
              costoMetroOrigen: r.costoMetroOrigen > 0
                  ? r.costoMetroOrigen
                  : widget.detalle.costoMetroOrigen,

              costoRolloOrigen: r.costoRolloOrigen > 0
                  ? r.costoRolloOrigen
                  : (r.metraje *
                        (r.costoMetroOrigen > 0
                            ? r.costoMetroOrigen
                            : widget.detalle.costoMetroOrigen)),
              atributosEspeciales: Map<String, dynamic>.from(
                r.atributosEspeciales,
              ),
            );
          }).toList();
          gruposRenderizados.clear();
        });
        _cargarMasDatos();
      } else {
        setState(() {
          todosLosGrupos = [
            GrupoRollo(
              metraje: widget.detalle.metrosPorRollo.toDouble(),
              color: '',
              cantidad: widget.detalle.cantidadRollos.toDouble(),
              costoMetroOrigen: widget.detalle.costoMetroOrigen,
              costoRolloOrigen: widget.detalle.costoRolloOrigen,
            ),
          ];
          gruposRenderizados.clear();
        });
        _cargarMasDatos();
      }
      _capturarEstadoOriginal();
    } catch (e) {
      debugPrint("Error cargando distribución: $e");
    }
  }

  void _capturarEstadoOriginal() {
    final mapped = todosLosGrupos
        .map(
          (g) => {
            'm': g.metraje,
            'c': g.color,
            'q': g.cantidad,
            'f': g.confirmado,
            'pM': g.costoMetroOrigen,
            'pR': g.costoRolloOrigen,
            'at': g.atributosEspeciales,
          },
        )
        .toList();
    _estadoOriginalSerializado = jsonEncode(mapped);
  }

  bool get _hayCambiosSinGuardar {
    final mapped = todosLosGrupos
        .map(
          (g) => {
            'm': g.metraje,
            'c': g.color,
            'q': g.cantidad,
            'f': g.confirmado,
            'pM': g.costoMetroOrigen,
            'pR': g.costoRolloOrigen,
            'at': g.atributosEspeciales,
          },
        )
        .toList();
    return _estadoOriginalSerializado != jsonEncode(mapped);
  }

  Future<bool> _intentarSalir() async {
    if (!_hayCambiosSinGuardar) return true;

    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Cambios sin guardar'),
          ],
        ),
        content: const Text(
          'Tienes modificaciones locales en los metrajes o precios. ¿Estás seguro de que deseas salir sin guardar los cambios?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SALIR SIN GUARDAR'),
          ),
        ],
      ),
    );
    return salir ?? false;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (gruposRenderizados.length < todosLosGrupos.length) {
        _cargarMasDatos();
      }
    }
  }

  void _cargarMasDatos() {
    final siguienteTope = gruposRenderizados.length + _tamanoPagina;
    final fin = siguienteTope > todosLosGrupos.length
        ? todosLosGrupos.length
        : siguienteTope;

    setState(() {
      gruposRenderizados = todosLosGrupos.sublist(0, fin);
    });
  }

  double get totalDistribuido {
    return todosLosGrupos.fold(0, (sum, item) => sum + item.cantidad);
  }

  double get pendientes => widget.detalle.cantidadRollos - totalDistribuido;

  int get cantidadColoresUnicos {
    return todosLosGrupos
        .map((g) => g.color)
        .where((c) => c.isNotEmpty)
        .toSet()
        .length;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final empresaId = session.empresaActual?.id ?? '';

    final asyncColoresFiltrados = ref.watch(
      coloresFiltradosProvider((
        empresaId: empresaId,
        proveedorId: widget.proveedor.id,
        tipoTelaId: widget.tipoTela.id,
      )),
    );

    final asyncMonedas = ref.watch(monedasProvider(empresaId));

    String simboloMoneda = '';
    if (asyncMonedas.hasValue &&
        asyncMonedas.value != null &&
        asyncMonedas.value!.isNotEmpty) {
      final mEncontrada = asyncMonedas.value!.firstWhere(
        (m) => m.id == widget.detalle.monedaId,
        orElse: () => asyncMonedas.value!.first,
      );
      simboloMoneda = mEncontrada.simbolo;
    }

    double totalMetrosDisponibles = todosLosGrupos.fold(
      0,
      (sum, item) => sum + (item.metraje * item.cantidad),
    );
    double costoTotalGeneral = todosLosGrupos.fold(
      0,
      (sum, item) => sum + (item.costoRolloOrigen * item.cantidad),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final deberiaSalir = await _intentarSalir();
        if (deberiaSalir && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Proveedor: ${widget.proveedor.nombre}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tipo Tela: ${widget.tipoTela.nombre}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              _mostrarMenuAcciones(asyncColoresFiltrados.value ?? []),
          child: Icon(modoSeleccion ? Icons.close : Icons.add),
        ),
        body: asyncColoresFiltrados.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error al cargar colores: $err')),
          data: (coloresFiltrados) {
            final coloresDisponibles = coloresFiltrados.map((c) {
              return DropdownColor(
                id: c.color.id,
                nombre: c.color.nombre,
                codigo: c.codigoColorProveedor,
                hex: c.color.hexadecimal,
              );
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Rollos: ${widget.detalle.cantidadRollos}'),
                      ),
                      Expanded(
                        child: Text(
                          'Total Metros: ${totalMetrosDisponibles.toStringAsFixed(0)} mtrs',
                        ),
                      ),
                      Text(
                        'colores : $cantidadColoresUnicos',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 4, 255),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${costoTotalGeneral.toStringAsFixed(0)} $simboloMoneda',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        pendientes == 0
                            ? 'Distribución Perfecta ✔'
                            : pendientes > 0
                            ? 'Deben ser: ${widget.detalle.cantidadRollos} Faltan: ${pendientes.toInt()} rollos'
                            : 'Deben ser: ${widget.detalle.cantidadRollos} Sobran: ${pendientes.abs().toInt()} rollos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: pendientes == 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: modoSeleccion ? 48 : 30,
                        child: Text(
                          modoSeleccion ? '' : '#',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Metraje',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Color',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cantidad (${totalDistribuido.toInt()})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ...camposEspeciales.map((campo) {
                        return Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              campo.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.values.first,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Precio ${simboloMoneda.isNotEmpty ? "($simboloMoneda)" : ""}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 125,
                        child: Text(
                          'Acción',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    scrollController: _scrollController,
                    itemCount: gruposRenderizados.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex--;
                        }

                        final item = todosLosGrupos.removeAt(oldIndex);
                        todosLosGrupos.insert(newIndex, item);

                        _actualizarVistaPaginada();
                      });
                    },
                    itemBuilder: (_, index) {
                      final grupo = gruposRenderizados[index];

                      return Container(
                        key: ValueKey(grupo.uid),
                        child: ItemFilaRollo(
                          grupo: grupo,
                          colores: coloresDisponibles,
                          camposEspeciales: camposEspeciales,
                          detalle: widget.detalle,
                          simboloMoneda: simboloMoneda,
                          modoSeleccion: modoSeleccion,
                          estaSeleccionado: seleccionados.contains(index),
                          index: index,
                          onSeleccionChanged: (v) {
                            setState(() {
                              if (v == true) {
                                seleccionados.add(index);
                              } else {
                                seleccionados.remove(index);
                              }
                            });
                          },
                          onEliminar: () {
                            if (todosLosGrupos.length == 1) return;

                            setState(() {
                              todosLosGrupos.removeAt(index);
                              seleccionados.clear();
                              _actualizarVistaPaginada();
                            });
                          },
                          onStatusChanged: () => setState(() {}),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                      onPressed: pendientes == 0
                          ? _guardarCambiosConConfirmacion
                          : null,
                    ),
                  ),
                ),
                if (modoSeleccion)
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Text(
                          'Seleccionados: ${seleccionados.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar'),
                          onPressed: seleccionados.isEmpty
                              ? null
                              : _eliminarSeleccionados,
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () =>
                              setState(() => seleccionados.clear()),
                          child: const Text('Limpiar'),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _actualizarVistaPaginada() {
    final totalActualVisible = gruposRenderizados.length;
    final fin = totalActualVisible > todosLosGrupos.length
        ? todosLosGrupos.length
        : totalActualVisible;
    setState(() {
      gruposRenderizados = todosLosGrupos.sublist(0, fin > 0 ? fin : 1);
    });
  }

  Future<void> _eliminarSeleccionados() async {
    final deVerdadSePuedenEliminar = seleccionados
        .where(
          (idx) =>
              idx < todosLosGrupos.length && !todosLosGrupos[idx].confirmado,
        )
        .toList();

    if (deVerdadSePuedenEliminar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No puedes eliminar filas confirmadas. Primero edítalas.',
          ),
        ),
      );
      return;
    }

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmActionDialog(
          title: '¿Eliminar filas?',
          message:
              'Se eliminarán sólo las ${deVerdadSePuedenEliminar.length} filas seleccionadas no confirmadas.',
          icon: Icons.delete_forever,
          iconColor: Colors.red,
          confirmText: 'Eliminar',
          onConfirm: () async =>
              await Future.delayed(const Duration(milliseconds: 100)),
        );
      },
    );

    if (resultado == true) {
      setState(() {
        todosLosGrupos = List.generate(todosLosGrupos.length, (i) => i)
            .where((i) => !deVerdadSePuedenEliminar.contains(i))
            .map((i) => todosLosGrupos[i])
            .toList();

        seleccionados.clear();
        modoSeleccion = false;
        _actualizarVistaPaginada();
      });
    }
  }

  Future<void> _guardarCambiosConConfirmacion() async {
    if (pendientes != 0) return;

    final notifier = ref.read(loteDetallesProvider(widget.lote.id).notifier);

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmActionDialog(
          title: 'Guardar Cambios',
          message:
              'La cantidad coincide perfectamente (${totalDistribuido.toInt()} rollos). ¿Deseas guardar los cambios?',
          icon: Icons.save,
          iconColor: Colors.blueGrey,
          confirmText: 'Guardar',
          onConfirm: () async {
            final List<RolloInfo> rollosAPersistir = todosLosGrupos
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final grupo = entry.value;

                  return RolloInfo(
                    id: grupo.uid ?? '',
                    loteDetalleId: widget.detalle.id,
                    orden: index,
                    metraje: grupo.metraje,
                    colorId: grupo.color,
                    cantidad: grupo.cantidad.toInt(),
                    sucursalActualId: widget.lote.sucursalId ?? '',
                    estado: 'DISPONIBLE',
                    atributosEspeciales: grupo.atributosEspeciales,
                    costoMetroOrigen: grupo.costoMetroOrigen,
                    costoRolloOrigen: grupo.costoRolloOrigen,
                  );
                })
                .toList();

            final exito = await notifier.guardarRollos(
              loteDetalleId: widget.detalle.id,
              rollos: rollosAPersistir,
            );

            if (exito) {
              setState(() {
                _capturarEstadoOriginal();
              });

              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            } else {
              throw Exception("No se pudo guardar la distribución de rollos.");
            }
          },
        );
      },
    );
  }

  Future<void> _mostrarMenuAcciones(
    List<ColorFiltrado> coloresFiltrados,
  ) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Modo selección'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    modoSeleccion = !modoSeleccion;
                    seleccionados.clear();
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.call_split),
                title: const Text('Agregar División'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    final nuevoGrupo = GrupoRollo(
                      metraje: widget.detalle.metrosPorRollo.toDouble(),
                      color: coloresFiltrados.isNotEmpty
                          ? coloresFiltrados.first.color.id
                          : '',
                      cantidad: 1.0,
                      atributosEspeciales: {},
                      confirmado: false,
                      costoMetroOrigen: widget.detalle.costoMetroOrigen,
                      costoRolloOrigen:
                          widget.detalle.costoMetroOrigen *
                          widget.detalle.metrosPorRollo,
                    );

                    todosLosGrupos.add(nuevoGrupo);
                    _actualizarVistaPaginada();
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Todos Individuales'),
                onTap: () {
                  Navigator.pop(context);
                  _convertirATodosIndividuales(coloresFiltrados);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _convertirATodosIndividuales(List<ColorFiltrado> coloresFiltrados) {
    final totalRollos = widget.detalle.cantidadRollos;
    final defaultColor = coloresFiltrados.isNotEmpty
        ? coloresFiltrados.first.color.id
        : '';
    setState(() {
      todosLosGrupos = List.generate(
        totalRollos,
        (index) => GrupoRollo(
          metraje: widget.detalle.metrosPorRollo.toDouble(),
          color: defaultColor,
          cantidad: 1,
          confirmado: false,
          costoMetroOrigen: widget.detalle.costoMetroOrigen,
          costoRolloOrigen:
              widget.detalle.costoMetroOrigen * widget.detalle.metrosPorRollo,
        ),
      );
      gruposRenderizados.clear();
      _cargarMasDatos();
    });
  }
}

// --- ITEM FILA CORREGIDO Y ALINEADO SIMÉTRICAMENTE ---
class ItemFilaRollo extends StatefulWidget {
  final GrupoRollo grupo;
  final List<DropdownColor> colores;
  final bool modoSeleccion;
  final bool estaSeleccionado;
  final int index;
  final ValueChanged<bool?> onSeleccionChanged;
  final VoidCallback onEliminar;
  final VoidCallback onStatusChanged;
  final List<CampoConfigurable> camposEspeciales;
  final LoteDetalle detalle;
  final String simboloMoneda;

  const ItemFilaRollo({
    super.key,
    required this.grupo,
    required this.colores,
    required this.modoSeleccion,
    required this.estaSeleccionado,
    required this.index,
    required this.onSeleccionChanged,
    required this.onEliminar,
    required this.onStatusChanged,
    required this.camposEspeciales,
    required this.detalle,
    required this.simboloMoneda,
  });

  @override
  State<ItemFilaRollo> createState() => _ItemFilaRolloState();
}

class _ItemFilaRolloState extends State<ItemFilaRollo> {
  TextEditingController? metrajeController;
  TextEditingController? cantidadController;
  final Map<String, TextEditingController> atributosControllers = {};

  @override
  void initState() {
    super.initState();
    _inicializarControllers();
  }

  @override
  void didUpdateWidget(covariant ItemFilaRollo oldWidget) {
    super.didUpdateWidget(oldWidget);

    for (final campo in widget.camposEspeciales) {
      atributosControllers.putIfAbsent(
        campo.id,
        () => TextEditingController(
          text: widget.grupo.atributosEspeciales[campo.id]?.toString() ?? '',
        ),
      );
    }
  }

  void _inicializarControllers() {
    if (!widget.grupo.confirmado) {
      metrajeController = TextEditingController(
        text: widget.grupo.metraje == 0
            ? ''
            : widget.grupo.metraje.toStringAsFixed(2),
      );
      cantidadController = TextEditingController(
        text: widget.grupo.cantidad == 0
            ? ''
            : widget.grupo.cantidad.toInt().toString(),
      );
    }
    for (final campo in widget.camposEspeciales) {
      atributosControllers[campo.id] = TextEditingController(
        text: widget.grupo.atributosEspeciales[campo.id]?.toString() ?? '',
      );
    }
  }

  void _limpiarControllers() {
    metrajeController?.dispose();
    cantidadController?.dispose();
    metrajeController = null;
    cantidadController = null;
    for (final c in atributosControllers.values) {
      c.dispose();
    }
    atributosControllers.clear();
  }

  void _abrirModalModificarPrecios() {
    final metroController = TextEditingController(
      text: widget.grupo.costoMetroOrigen.toStringAsFixed(2),
    );
    final rolloController = TextEditingController(
      text: widget.grupo.costoRolloOrigen.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      barrierDismissible: false, // Bloquea clics en el fondo negro exterior
      builder: (context) {
        return PopScope(
          canPop:
              false, // Impide el botón nativo de retroceso del celular en Android/Web
          child: AlertDialog(
            title: Text('Modificar Precio - Rollo #${widget.index + 1}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: metroController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Precio por Metro (${widget.simboloMoneda})',
                    prefixIcon: const Icon(Icons.linear_scale),
                  ),
                  onChanged: (value) {
                    double precioMetro = double.tryParse(value) ?? 0.0;
                    double nuevoPrecioRollo =
                        precioMetro * widget.grupo.metraje;
                    rolloController.text = nuevoPrecioRollo.toStringAsFixed(2);
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: rolloController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        'Precio por Rollo Total (${widget.simboloMoneda})',
                    prefixIcon: const Icon(Icons.layers),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  metroController.text = '0.00';
                  rolloController.text = '0.00';
                },
                child: const Text(
                  'LIMPIAR',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.grupo.costoMetroOrigen =
                        double.tryParse(metroController.text) ?? 0.0;
                    widget.grupo.costoRolloOrigen =
                        double.tryParse(rolloController.text) ?? 0.0;
                  });
                  widget.onStatusChanged();
                  Navigator.pop(context);
                },
                child: const Text('GUARDAR'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _limpiarControllers();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.transparent;
    }
  }

  TextInputType _keyboardForType(TipoCampo tipo) {
    switch (tipo) {
      case TipoCampo.entero:
        return TextInputType.number;

      case TipoCampo.decimal:
        return const TextInputType.numberWithOptions(decimal: true);

      case TipoCampo.booleano:
        return TextInputType.text;

      case TipoCampo.texto:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _inputFormattersForType(TipoCampo tipo) {
    switch (tipo) {
      case TipoCampo.entero:
        return [FilteringTextInputFormatter.digitsOnly];

      case TipoCampo.decimal:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];

      default:
        return [];
    }
  }

  dynamic _parseValue(String valor, TipoCampo tipo) {
    switch (tipo) {
      case TipoCampo.entero:
        return int.tryParse(valor) ?? 0;

      case TipoCampo.decimal:
        return double.tryParse(valor) ?? 0.0;

      case TipoCampo.booleano:
        return valor.toLowerCase() == 'true';

      case TipoCampo.texto:
        return valor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirmado = widget.grupo.confirmado;

    final colorSeleccionado = widget.colores.firstWhere(
      (c) => c.id == widget.grupo.color,
      orElse: () =>
          DropdownColor(id: '', nombre: 'Sin color', codigo: '', hex: 'FFFFFF'),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isConfirmado
            ? Colors.green.shade50.withOpacity(0.4)
            : Colors.white,
        border: Border.all(
          color: isConfirmado ? Colors.green.shade200 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // 1. Selector / Numero (#)
          if (widget.modoSeleccion)
            SizedBox(
              width: 48,
              child: Checkbox(
                value: widget.estaSeleccionado,
                onChanged: widget.onSeleccionChanged,
              ),
            )
          else
            SizedBox(width: 30, child: Text('${widget.index + 1}')),
          const SizedBox(width: 8),

          // 2. METRAJE
          Expanded(
            flex: 2,
            child: isConfirmado
                ? Text(
                    '${widget.grupo.metraje.toStringAsFixed(2)} mtrs',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )
                : TextFormField(
                    controller: metrajeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        widget.grupo.metraje = double.tryParse(value) ?? 0;
                        // Recalcula el precio por rollo base dinámicamente si cambia el metraje
                        widget.grupo.costoRolloOrigen =
                            widget.grupo.costoMetroOrigen *
                            widget.grupo.metraje;
                      });
                      widget.onStatusChanged();
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
          ),
          const SizedBox(width: 8),

          // 3. COLOR
          Expanded(
            flex: 2,
            child: isConfirmado
                ? Chip(
                    avatar: CircleAvatar(
                      backgroundColor: _hexToColor(colorSeleccionado.hex),
                      radius: 8,
                    ),
                    label: Text(
                      colorSeleccionado.codigo.isNotEmpty
                          ? '${colorSeleccionado.nombre} (${colorSeleccionado.codigo})'
                          : colorSeleccionado.nombre,
                      overflow: TextOverflow.values.first,
                    ),
                  )
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: widget.grupo.color.isEmpty
                        ? null
                        : widget.grupo.color,
                    items: widget.colores.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _hexToColor(c.hex),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                c.codigo.isNotEmpty
                                    ? '${c.nombre} [${c.codigo}]'
                                    : c.nombre,
                                overflow: TextOverflow.values.first,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        widget.grupo.color = v;
                      });
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
          ),
          const SizedBox(width: 8),

          Expanded(
            flex: 2,
            child: isConfirmado
                ? Text(
                    '${widget.grupo.cantidad.toInt()} und.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )
                : TextFormField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      widget.grupo.cantidad = (double.tryParse(value) ?? 0);
                      widget.onStatusChanged();
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
          ),
          const SizedBox(width: 4),

          ...widget.camposEspeciales.map((campo) {
            final controller = atributosControllers.putIfAbsent(
              campo.id,
              () => TextEditingController(
                text:
                    widget.grupo.atributosEspeciales[campo.id]?.toString() ??
                    '',
              ),
            );

            return Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: isConfirmado
                    ? Text(
                        widget.grupo.atributosEspeciales[campo.id]
                                ?.toString() ??
                            '-',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.values.first,
                      )
                    : TextFormField(
                        controller: controller,
                        keyboardType: _keyboardForType(campo.tipo),
                        inputFormatters: _inputFormattersForType(campo.tipo),
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: campo.nombre,
                        ),
                        onChanged: (value) {
                          widget.grupo.atributosEspeciales[campo.id] =
                              _parseValue(value, campo.tipo);
                          widget.onStatusChanged();
                        },
                      ),
              ),
            );
          }),
          const SizedBox(width: 4),

          Expanded(
            flex: 2,
            child: InkWell(
              onTap: _abrirModalModificarPrecios,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withOpacity(0.6),
                  border: Border.all(color: Colors.red.shade200, width: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mtr: ${widget.grupo.costoMetroOrigen.toStringAsFixed(2)} ${widget.simboloMoneda}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                        height: 1.1,
                      ),
                      // overflow: TextOverflow.values.first,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Rollo: ${widget.grupo.costoRolloOrigen.toStringAsFixed(2)} ${widget.simboloMoneda}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade700,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.values.first,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(
            width: 125,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isConfirmado ? Icons.edit_note : Icons.check_circle,
                    color: isConfirmado ? Colors.blueGrey : Colors.green,
                    size: 26,
                  ),
                  onPressed: () {
                    setState(() {
                      if (!isConfirmado) {
                        widget.grupo.confirmado = true;
                        _limpiarControllers();
                      } else {
                        widget.grupo.confirmado = false;
                        _inicializarControllers();
                      }
                    });
                    widget.onStatusChanged();
                  },
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  onPressed: widget.onEliminar,
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
