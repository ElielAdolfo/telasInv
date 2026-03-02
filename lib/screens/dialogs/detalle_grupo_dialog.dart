import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../../constants/constants.dart';
import 'mover_rollos_dialog.dart';

class DetalleGrupoDialog extends StatefulWidget {
  final GrupoRollosModel grupo;
  const DetalleGrupoDialog({super.key, required this.grupo});

  @override
  State<DetalleGrupoDialog> createState() => _DetalleGrupoDialogState();
}

class _DetalleGrupoDialogState extends State<DetalleGrupoDialog> {
  String? _filtroSucursal;
  String? _rolloEditandoId;
  String? _sucursalEditando;

  List<RolloModel> get _rollosFiltrados {
    final provider = context.read<InventarioProvider>();
    var rollos = provider.getRollosGrupo(widget.grupo.color, widget.grupo.empresa, widget.grupo.codigoColor, widget.grupo.tipoTela);
    if (_filtroSucursal != null) {
      if (_filtroSucursal == '__sin__') rollos = rollos.where((r) => r.sucursal.isEmpty).toList();
      else rollos = rollos.where((r) => r.sucursal == _filtroSucursal).toList();
    }
    return rollos;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventarioProvider>(
      builder: (context, provider, child) {
        final rollos = _rollosFiltrados;
        final colorData = provider.getColorByNombre(widget.grupo.color);
        final metrajeTotal = rollos.fold(0.0, (sum, r) => sum + r.metraje);

        return CustomModal(
          title: widget.grupo.color, maxWidth: 700, maxHeight: 700,
          subtitle: Text('${widget.grupo.empresa} • ${widget.grupo.codigoColor}${widget.grupo.tipoTela.isNotEmpty ? ' • ${widget.grupo.tipoTela}' : ''}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          onClose: () => Navigator.of(context).pop(),
          content: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                ColorPreview(hexColor: colorData?.hex ?? '#94a3b8', size: 48),
                const SizedBox(width: 16),
                Expanded(child: Text('${widget.grupo.tipoTela.isNotEmpty ? '${widget.grupo.tipoTela} • ' : ''}${widget.grupo.empresa}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
              ]),
              const SizedBox(height: 20),
              _buildResumen(rollos.length, metrajeTotal, widget.grupo.sucursales.length),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Filtrar:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filtroSucursal, hint: const Text('Todas'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todas')),
                        const DropdownMenuItem(value: '__sin__', child: Text('Sin asignar')),
                        ...provider.sucursales.map((s) => DropdownMenuItem(value: s.nombre, child: Text(s.nombre))),
                      ],
                      onChanged: (v) => setState(() => _filtroSucursal = v),
                      decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ],
              ),
              if (provider.cantidadSeleccionados > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(child: Text('${provider.cantidadSeleccionados} rollos seleccionados - ${provider.metrajeSeleccionados.toStringAsFixed(2)} m',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))),
                      TextButton.icon(onPressed: () => _mostrarMoverRollos(provider), icon: const Icon(Icons.swap_horiz, size: 18), label: const Text('Mover')),
                      TextButton(onPressed: () => provider.limpiarSeleccion(), child: const Text('Cancelar')),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Flexible(child: ListView.separated(
                shrinkWrap: true, itemCount: rollos.length, separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final rollo = rollos[index];
                  final isEditing = _rolloEditandoId == rollo.id;
                  final sucursal = rollo.sucursal.isNotEmpty ? provider.getSucursalByNombre(rollo.sucursal) : null;

                  return RolloListItem(
                    rollo: rollo, isSelected: provider.estaSeleccionado(rollo.id), isEditing: isEditing,
                    onSelect: () => provider.toggleSeleccion(rollo.id),
                    onEdit: () => setState(() { _rolloEditandoId = rollo.id; _sucursalEditando = rollo.sucursal; }),
                    onDelete: () => _confirmarEliminar(rollo, provider),
                    editWidget: isEditing ? DropdownButton<String>(
                      value: _sucursalEditando, hint: const Text('Sin asignar'), underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                        ...provider.sucursales.map((s) => DropdownMenuItem(value: s.nombre, child: Text(s.nombre))),
                      ],
                      onChanged: (v) => setState(() => _sucursalEditando = v),
                    ) : null,
                    sucursal: sucursal,
                  );
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumen(int cantidad, double metraje, int sucursales) {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumenItem(cantidad.toString(), 'Rollos', const Color(0xFF3B82F6)),
          _buildResumenItem('${metraje.toStringAsFixed(2)} m', 'Metraje', const Color(0xFF10B981)),
          _buildResumenItem(sucursales.toString(), 'Sucursales', const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String value, String label, Color color) {
    return Column(children: [Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))]);
  }

  Future<void> _confirmarEliminar(RolloModel rollo, InventarioProvider provider) async {
    final confirmado = await DeleteConfirmationDialog.show(context, itemName: rollo.codigoColor,
      details: '${rollo.color} - ${rollo.metraje.toStringAsFixed(2)}m | ${rollo.sucursal.isNotEmpty ? rollo.sucursal : 'Sin sucursal'}');
    if (confirmado == true) {
      await provider.eliminarRollo(rollo.id);
      final restantes = provider.getRollosGrupo(widget.grupo.color, widget.grupo.empresa, widget.grupo.codigoColor, widget.grupo.tipoTela);
      if (restantes.isEmpty && mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _mostrarMoverRollos(InventarioProvider provider) async {
    final destino = await showDialog<String>(context: context, barrierDismissible: false,
      builder: (context) => MoverRollosDialog(cantidad: provider.cantidadSeleccionados, metraje: provider.metrajeSeleccionados, sucursales: provider.sucursales));
    if (destino != null) await provider.moverRollosSeleccionados(destino);
  }
}
