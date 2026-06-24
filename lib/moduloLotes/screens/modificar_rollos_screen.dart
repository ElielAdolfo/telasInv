import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inv_telas/models/lotes/lote.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';

class GrupoRollo {
  GrupoRollo({
    required this.metraje,
    required this.color,
    required this.cantidad,
    this.confirmado = false,
  });

  double metraje;
  String color;
  double cantidad;
  bool confirmado;
}

class ModificarRollosScreen extends StatefulWidget {
  final Lote lote;
  final LoteDetalle detalle;

  const ModificarRollosScreen({
    super.key,
    required this.lote,
    required this.detalle,
  });

  @override
  State<ModificarRollosScreen> createState() => _ModificarRollosScreenState();
}

class _ModificarRollosScreenState extends State<ModificarRollosScreen> {
  final List<String> colores = [
    'Rojo',
    'Verde',
    'Azul',
    'Negro',
    'Blanco',
    'Gris',
  ];

  Set<int> seleccionados = {};
  bool modoSeleccion = false;

  List<GrupoRollo> todosLosGrupos = [];
  List<GrupoRollo> gruposRenderizados = [];

  final ScrollController _scrollController = ScrollController();
  final int _tamanoPagina = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    todosLosGrupos = [
      GrupoRollo(
        metraje: widget.detalle.metrosPorRollo.toDouble(),
        color: 'Rojo',
        cantidad: widget.detalle.cantidadRollos.toDouble(),
      ),
    ];

    _cargarMasDatos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  double get pendientes {
    return widget.detalle.cantidadRollos - totalDistribuido;
  }

  @override
  Widget build(BuildContext context) {
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
          child: const Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Proveedor: ---',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Tipo Tela: ---',
                      style: TextStyle(
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
        onPressed: _mostrarMenuAcciones,
        child: Icon(modoSeleccion ? Icons.close : Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Rollos: ${widget.detalle.cantidadRollos}'),
                ),
                Expanded(
                  child: Text('Mtrs/Rollo: ${widget.detalle.metrosPorRollo}'),
                ),
                Expanded(child: Text('Total: ${widget.detalle.totalMetros}')),
              ],
            ),
          ),

          // Indicador visual superior del estado de la distribución
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade700,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text('#', style: TextStyle(color: Colors.white)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Metraje', style: TextStyle(color: Colors.white)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Color', style: TextStyle(color: Colors.white)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Cantidad',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text('Acción', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // FILAS
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: gruposRenderizados.length,
              itemBuilder: (_, index) {
                final grupo = gruposRenderizados[index];

                return ItemFilaRollo(
                  key: ValueKey(grupo),
                  grupo: grupo,
                  colores: colores,
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
                  onStatusChanged: () {
                    setState(() {});
                  },
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
              'Se eliminarán sólo las ${deVerdadSePuedenEliminar.length} filas seleccionadas que no están confirmadas.',
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

  // ACCIÓN DE GUARDAR CON VALIDACIÓN ESTRICTA DE CANTIDADES
  Future<void> _guardarCambiosConConfirmacion() async {
    // 1. VALIDACIÓN MATEMÁTICA
    if (pendientes != 0) {
      final String mensajeError = pendientes > 0
          ? 'No puedes guardar. Faltan distribuir ${pendientes.toInt()} rollos.'
          : 'No puedes guardar. Has distribuido ${pendientes.abs().toInt()} rollos de más.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeError),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
      return; // Detiene por completo la ejecución y no abre el Dialog
    }

    // 2. DIÁLOGO SI LA VALIDACIÓN ES EXITOSA
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
          onConfirm: () async =>
              await Future.delayed(const Duration(seconds: 1)),
        );
      },
    );
  }

  Future<void> _mostrarMenuAcciones() async {
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
                    // 1. Creamos el nuevo registro
                    final nuevoGrupo = GrupoRollo(
                      metraje: widget.detalle.metrosPorRollo.toDouble(),
                      color: colores.first,
                      cantidad: 0,
                      confirmado: false,
                    );

                    // 2. Lo añadimos a la lista maestra
                    todosLosGrupos.add(nuevoGrupo);

                    // 3. Forzamos a que la lista visible sume uno más para que se pinte de inmediato
                    final siguienteTope = gruposRenderizados.length + 1;
                    gruposRenderizados = todosLosGrupos.sublist(
                      0,
                      siguienteTope,
                    );
                  });

                  // 4. Opcional: Desplazar el scroll automáticamente al final para ver la nueva fila
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
                  _convertirATodosIndividuales();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _convertirATodosIndividuales() {
    final totalRollos = widget.detalle.cantidadRollos;
    setState(() {
      todosLosGrupos = List.generate(
        totalRollos,
        (index) => GrupoRollo(
          metraje: widget.detalle.metrosPorRollo.toDouble(),
          color: colores.first,
          cantidad: 1,
          confirmado: false,
        ),
      );
      gruposRenderizados.clear();
      _cargarMasDatos();
    });
  }
}

// --- ITEM FILA (Mantiene tu lógica de optimización) ---
class ItemFilaRollo extends StatefulWidget {
  final GrupoRollo grupo;
  final List<String> colores;
  final bool modoSeleccion;
  final bool estaSeleccionado;
  final int index;
  final ValueChanged<bool?> onSeleccionChanged;
  final VoidCallback onEliminar;
  final VoidCallback onStatusChanged;

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
  });

  @override
  State<ItemFilaRollo> createState() => _ItemFilaRolloState();
}

class _ItemFilaRolloState extends State<ItemFilaRollo> {
  TextEditingController? metrajeController;
  TextEditingController? cantidadController;

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
  }

  void _limpiarControllers() {
    metrajeController?.dispose();
    cantidadController?.dispose();
    metrajeController = null;
    cantidadController = null;
  }

  @override
  void dispose() {
    _limpiarControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirmado = widget.grupo.confirmado;

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

          // COLOR
          Expanded(
            flex: 2,
            child: isConfirmado
                ? Chip(
                    label: Text(
                      widget.grupo.color,
                      style: const TextStyle(fontSize: 12),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                : DropdownButtonFormField<String>(
                    value: widget.grupo.color,
                    isDense: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: widget.colores
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      widget.grupo.color = v;
                    },
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
}
