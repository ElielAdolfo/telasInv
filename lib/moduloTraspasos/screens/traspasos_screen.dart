import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/providers/traspaso_grupos_provider.dart';
import '../../providers/traspaso_provider.dart';
import '../../providers/sucursal_provider.dart';
import '../widgets/traspasar_dialog.dart';

class TraspasosScreen extends ConsumerStatefulWidget {
  const TraspasosScreen({super.key});

  @override
  ConsumerState<TraspasosScreen> createState() => _TraspasosPageState();
}

class _TraspasosPageState extends ConsumerState<TraspasosScreen> {
  String _sucursalFiltro = 'INICIAL';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(traspasoProvider.notifier).limpiarSeleccion();
    });
  }

  @override
  Widget build(BuildContext context) {
    // CORRECCIÓN 1: Usar 'watch' en lugar de 'read' para el sessionProvider dentro de build
    final session = ref.watch(sessionProvider);
    final empresa = session.empresaActual;
    final state = ref.watch(traspasoProvider);

    if (empresa == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró una empresa activa.')),
      );
    }

    final sucursalesAsync = ref.watch(sucursalesProvider(empresa.id));
    final gruposArmadosAsync = ref.watch(
      traspasoGruposProcesadosProvider(empresa.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Traspasos de Stock'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _sucursalFiltro == 'INICIAL'
                ? null
                : () => ref
                      .read(traspasoProvider.notifier)
                      .cargarStock(_sucursalFiltro),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de Sucursal de Origen
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade100,
            child: sucursalesAsync.when(
              data: (sucursales) => DropdownButtonFormField<String>(
                value: _sucursalFiltro == 'INICIAL' ? null : _sucursalFiltro,
                hint: const Text('SELECCIONAR SUCURSAL DE ORIGEN'),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.storefront),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'SIN_SUCURSAL',
                    child: Text('Sin Sucursal (Almacén General)'),
                  ),
                  ...sucursales.map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.nombre)),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _sucursalFiltro = val);
                    ref.read(traspasoProvider.notifier).cargarStock(val);
                  }
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error al cargar filtros: $e'),
            ),
          ),

          // Contenedor principal de la lista usando AsyncValue limpio
          Expanded(
            child: _sucursalFiltro == 'INICIAL'
                ? const Center(
                    child: Text(
                      'Por favor, selecciona una sucursal de origen arriba.',
                    ),
                  )
                : gruposArmadosAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Text('Error al procesar datos maestros: $err'),
                    ),
                    data: (grupos) {
                      if (grupos.isEmpty) {
                        return const Center(
                          child: Text(
                            'No se encontraron rollos cerrados disponibles para traspaso.',
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: grupos.length,
                        itemBuilder: (context, index) {
                          final grupo = grupos[index];

                          // CORRECCIÓN 2: Extracción a un widget independiente para evitar pérdida de foco y fugas de memoria
                          return TraspasoGrupoCard(
                            key: ValueKey(grupo.groupKey),
                            grupo: grupo,
                            sucursalFiltro: _sucursalFiltro,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: state.seleccionadosIds.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.local_shipping),
                label: Text(
                  'Traspasar Seleccionados (${state.seleccionadosIds.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TraspasarDialog(
                      stockIds: state.seleccionadosIds.toList(),
                      onTraspasoExitoso: () {
                        ref.read(traspasoProvider.notifier).limpiarSeleccion();
                        ref
                            .read(traspasoProvider.notifier)
                            .cargarStock(_sucursalFiltro);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ==========================================
// COMPONENTE EXTRAÍDO Y OPTIMIZADO POR GRUPO
// ==========================================
class TraspasoGrupoCard extends ConsumerStatefulWidget {
  final dynamic
  grupo; // Reemplaza 'dynamic' por tu modelo específico (ej. TraspasoGrupoUi)
  final String sucursalFiltro;

  const TraspasoGrupoCard({
    super.key,
    required this.grupo,
    required this.sucursalFiltro,
  });

  @override
  ConsumerState<TraspasoGrupoCard> createState() => _TraspasoGrupoCardState();
}

class _TraspasoGrupoCardState extends ConsumerState<TraspasoGrupoCard> {
  late TextEditingController _cantidadController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _cantidadController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(traspasoProvider);

    // Sincronizar el TextField si las casillas de verificación (checkboxes) cambian externamente
    final idsGrupo = widget.grupo.rollos.map((r) => r.id).toSet();
    final seleccionadosDelGrupo = state.seleccionadosIds
        .where((id) => idsGrupo.contains(id))
        .length;

    // Solo actualiza el texto si el usuario NO está escribiendo activamente en este campo
    if (!_focusNode.hasFocus) {
      if (seleccionadosDelGrupo == 0) {
        if (_cantidadController.text.isNotEmpty) _cantidadController.clear();
      } else {
        if (_cantidadController.text != seleccionadosDelGrupo.toString()) {
          _cantidadController.text = seleccionadosDelGrupo.toString();
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.indigo.shade50,
        iconColor: Colors.indigo,
        collapsedIconColor: Colors.indigo,
        title: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: widget.grupo.flutterColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tela: ${widget.grupo.tipoTelaNombre}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.grupo.codigoUnicoProveedor != null)
                    Container(
                      margin: const EdgeInsets.only(top: 2, bottom: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.teal.shade200,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'Cód. Color: ${widget.grupo.codigoUnicoProveedor}',
                        style: TextStyle(
                          color: Colors.teal.shade900,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    'Color: ${widget.grupo.colorNombre} (${widget.grupo.rollos.length} rollos)',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  if (widget.grupo.valoresDiferenciadoresGrupo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: widget.grupo.valoresDiferenciadoresGrupo.entries
                          .map<Widget>((entry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Cant: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              _buildCantidadInput(state),
              const SizedBox(width: 4),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.grupo.rollos.length,
            itemBuilder: (context, index) {
              final rollo = widget.grupo.rollos[index];
              final isSelected = state.seleccionadosIds.contains(rollo.id);

              return CheckboxListTile(
                value: isSelected,
                title: Text(
                  'Rollo #${rollo.numeroFisico} - Lote: ${rollo.loteId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: widget.grupo.flutterColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Metraje: ${rollo.metrajeActual}m / ${rollo.metrajeOriginal}m',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (rollo.atributosEspeciales.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: rollo.atributosEspeciales.entries
                            .where((entry) {
                              final nombreCampo = widget
                                  .grupo
                                  .nombresCamposConfigurables[entry.key];
                              return !widget.grupo.valoresDiferenciadoresGrupo
                                  .containsKey(nombreCampo);
                            })
                            .map<Widget>((entry) {
                              final nombreCampo =
                                  widget.grupo.nombresCamposConfigurables[entry
                                      .key] ??
                                  entry.key;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.amber.shade300,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  '$nombreCampo: ${entry.value}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.amber.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ],
                  ],
                ),
                secondary: IconButton(
                  icon: const Icon(Icons.send_and_archive, color: Colors.teal),
                  tooltip: 'Traspasar individual',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => TraspasarDialog(
                        stockIds: [rollo.id],
                        onTraspasoExitoso: () => ref
                            .read(traspasoProvider.notifier)
                            .cargarStock(widget.sucursalFiltro),
                      ),
                    );
                  },
                ),
                activeColor: Colors.indigo,
                onChanged: (bool? checked) {
                  // Si el usuario tenía escrito un número, limpiamos para que use el conteo real al hacer toggle manual
                  if (_cantidadController.text.isNotEmpty &&
                      !_focusNode.hasFocus) {
                    _cantidadController.clear();
                  }
                  ref.read(traspasoProvider.notifier).toggleSeleccion(rollo.id);
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCantidadInput(dynamic state) {
    return SizedBox(
      width: 50,
      height: 35,
      child: TextField(
        controller: _cantidadController,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          final nuevos = Set<String>.from(state.seleccionadosIds);
          for (var r in widget.grupo.rollos) {
            nuevos.remove(r.id);
          }
          final int? cantASeleccionar = int.tryParse(value);
          if (cantASeleccionar != null && cantASeleccionar > 0) {
            final limite = cantASeleccionar > widget.grupo.rollos.length
                ? widget.grupo.rollos.length
                : cantASeleccionar;
            for (int i = 0; i < limite; i++) {
              nuevos.add(widget.grupo.rollos[i].id);
            }
          }

          // NOTA DE MEJORA: Lo ideal en Riverpod es invocar un método del Notifier, por ejemplo:
          // ref.read(traspasoProvider.notifier).cambiarSeleccionMasiva(nuevos);
          // Si tu Notifier actual no dispone de esa función, modificamos el state mediante reasignación controlada:
          ref.read(traspasoProvider.notifier).state = state.copyWith(
            seleccionadosIds: nuevos,
          );
        },
      ),
    );
  }
}
