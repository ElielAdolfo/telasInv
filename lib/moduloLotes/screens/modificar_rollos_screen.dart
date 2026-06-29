//observaciones para mejorar
//falta configuraciones especiales
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
import 'package:inv_telas/widgets/confirm_action_dialog.dart';
import 'package:uuid/uuid.dart';

class GrupoRollo {
  final String uid;

  double metraje;
  String color;
  double cantidad;
  bool confirmado;

  Map<String, dynamic> atributosEspeciales;

  GrupoRollo({
    String? uid,
    required this.metraje,
    required this.color,
    required this.cantidad,
    this.confirmado = false,
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
              metraje: r.metraje,
              color: r.colorId,
              cantidad: r.cantidad.toDouble(),
              confirmado: true,
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
            ),
          ];

          gruposRenderizados.clear();
        });

        _cargarMasDatos();
      }
    } catch (e) {
      debugPrint("Error cargando distribución: $e");
    }
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final empresaId = session.empresaActual?.id ?? '';

    // Consumo directo del nuevo provider reactivo optimizado por combinaciones
    final asyncColoresFiltrados = ref.watch(
      coloresFiltradosProvider((
        empresaId: empresaId,
        proveedorId: widget.proveedor.id,
        tipoTelaId: widget.tipoTela.id,
      )),
    );

    return Scaffold(
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
          // Mapeamos los datos cruzados al formato esperado por el Widget de UI
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
                        'Mtrs/Rollo: ${widget.detalle.metrosPorRollo}',
                      ),
                    ),
                    Expanded(
                      child: Text('Total: ${widget.detalle.totalMetros}'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Distribuido: ${totalDistribuido.toInt()}'),
                    Text(
                      pendientes == 0
                          ? 'Distribución Perfecta ✔'
                          : pendientes > 0
                          ? 'Faltan: ${pendientes.toInt()} rollos'
                          : 'Sobran: ${pendientes.abs().toInt()} rollos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: pendientes == 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ENCABEZADO TABLA
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
                    const SizedBox(
                      width: 40,
                      child: Text('#', style: TextStyle(color: Colors.white)),
                    ),

                    // 👇 CAMPOS DINÁMICOS (AQUÍ ESTÁ LA CLAVE)
                    ...camposEspeciales.map((campo) {
                      return Expanded(
                        flex: 2,
                        child: Text(
                          campo.nombre,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }),

                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Color',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Cantidad',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Acción',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // FILAS
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
              // BOTÓN GUARDAR CAMBIOS
              Container(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                    onPressed: _guardarCambiosConConfirmacion,
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
                        onPressed: () => setState(() => seleccionados.clear()),
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _actualizarVistaPaginada() {
    final totalActualVisible = gruposRenderizados.length;
    final fin = totalActualVisible > todosLosGrupos.length
        ? todosLosGrupos.length
        : totalActualVisible;
    gruposRenderizados = todosLosGrupos.sublist(0, fin > 0 ? fin : 1);
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
    if (pendientes != 0) {
      // ... (Mantienes tu validación de error intacta)
      return;
    }

    final notifier = ref.read(loteDetallesProvider(widget.lote.id).notifier);

    final resultado = await showDialog<bool>(
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
            // 1. Ya NO aplanamos a 88 registros. Guardamos la estructura agrupada.
            final List<RolloInfo> rollosAPersistir = todosLosGrupos
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final grupo = entry.value;

                  return RolloInfo(
                    id: '',
                    loteDetalleId: widget.detalle.id,

                    orden: index,

                    metraje: grupo.metraje,
                    colorId: grupo.color,
                    cantidad: grupo.cantidad.toInt(),

                    sucursalActualId: widget.lote.sucursalId ?? '',
                    estado: 'DISPONIBLE',
                    atributosEspeciales: grupo.atributosEspeciales,
                  );
                })
                .toList();

            // 2. Ejecutamos la inserción atómica
            final exito = await notifier.guardarRollos(
              loteDetalleId: widget.detalle.id,
              rollos: rollosAPersistir,
            );

            if (!exito) {
              throw Exception("No se pudo guardar la distribución de rollos.");
            }
          },
        );
      },
    );

    // 3. ... (Mantienes tu snackbar de éxito y el pop del Navigator)
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
                      cantidad: 0,
                      atributosEspeciales: {},
                      confirmado: false,
                    );

                    todosLosGrupos.add(nuevoGrupo);
                    final siguienteTope = gruposRenderizados.length + 1;
                    gruposRenderizados = todosLosGrupos.sublist(
                      0,
                      siguienteTope,
                    );
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
        ),
      );
      gruposRenderizados.clear();
      _cargarMasDatos();
    });
  }
}

// --- ITEM FILA OPTIMIZADO ---
class ItemFilaRollo extends StatefulWidget {
  final GrupoRollo grupo;
  final List<DropdownColor> colores; // Cambiado a List<DropdownColor>
  final bool modoSeleccion;
  final bool estaSeleccionado;
  final int index;
  final ValueChanged<bool?> onSeleccionChanged;
  final VoidCallback onEliminar;
  final VoidCallback onStatusChanged;
  final List<CampoConfigurable> camposEspeciales;

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

  @override
  void dispose() {
    _limpiarControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirmado = widget.grupo.confirmado;

    // Buscamos si hay un color seleccionado para mostrar su nombre o indicador en modo lectura
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
          if (widget.modoSeleccion)
            Checkbox(
              value: widget.estaSeleccionado,
              onChanged: widget.onSeleccionChanged,
            )
          else
            SizedBox(width: 30, child: Text('${widget.index + 1}')),

          // METRAJE
          // ⚠️ CAMPO BASE (NO CONFIGURABLE - SIEMPRE EXISTE EN GRUPO)
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
                      widget.grupo.metraje = double.tryParse(value) ?? 0;
                      widget.onStatusChanged();
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
          ),
          const SizedBox(width: 8),

          // COLOR (CON CÓDIGO PROVEEDOR VISIBLE)
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: widget.grupo.color.isEmpty
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
                                overflow: TextOverflow.ellipsis,
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

          // CANTIDAD
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

          // 👇 INSERTAR DESPUÉS DE CANTIDAD Y ANTES DE ACCIONES
          ...widget.camposEspeciales.map((campo) {
            final controller = atributosControllers[campo.id]!;

            return Expanded(
              flex: 2,
              child: isConfirmado
                  ? Text(
                      widget.grupo.atributosEspeciales[campo.id]?.toString() ??
                          '-',
                      style: const TextStyle(fontWeight: FontWeight.w500),
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
            );
          }).toList(),
          // ACCIONES
          SizedBox(
            width: 85,
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
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.delete,
                    color: isConfirmado ? Colors.grey.shade300 : Colors.red,
                  ),
                  onPressed: isConfirmado ? null : widget.onEliminar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextInputType _keyboardForType(TipoCampo tipo) {
    switch (tipo) {
      case TipoCampo.entero:
        return TextInputType.number;
      case TipoCampo.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _inputFormattersForType(TipoCampo tipo) {
    switch (tipo) {
      case TipoCampo.entero:
        return [FilteringTextInputFormatter.digitsOnly];

      case TipoCampo.decimal:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))];

      default:
        return null;
    }
  }

  dynamic _parseValue(String value, TipoCampo tipo) {
    switch (tipo) {
      case TipoCampo.entero:
        return int.tryParse(value) ?? 0;

      case TipoCampo.decimal:
        return double.tryParse(value) ?? 0.0;

      case TipoCampo.booleano:
        return value.toLowerCase() == 'true';

      case TipoCampo.texto:
      default:
        return value;
    }
  }

  Color _hexToColor(String hex) {
    if (hex.isEmpty) return Colors.transparent;
    final String cleanHex = hex.replaceFirst('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('0xff$cleanHex'));
    }
    return Color(int.parse('0x$cleanHex'));
  }
}
