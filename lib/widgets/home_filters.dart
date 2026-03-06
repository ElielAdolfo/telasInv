import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';

class HomeFilters extends ConsumerWidget {
  final String busqueda;
  final String filtroSucursal;
  final String filtroEmpresa;
  final String filtroColor;
  final String filtroTipoTela;
  final ValueChanged<String> onBusquedaChanged;
  final ValueChanged<String?> onSucursalChanged;
  final ValueChanged<String?> onEmpresaChanged;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<String?> onTipoChanged;

  const HomeFilters({
    super.key,
    required this.busqueda,
    required this.filtroSucursal,
    required this.filtroEmpresa,
    required this.filtroColor,
    required this.filtroTipoTela,
    required this.onBusquedaChanged,
    required this.onSucursalChanged,
    required this.onEmpresaChanged,
    required this.onColorChanged,
    required this.onTipoChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sucursales = ref.watch(sucursalesProvider);
    final empresas = ref.watch(empresasProvider);
    final colores = ref.watch(coloresProvider);
    final tipos = ref.watch(tiposTelaProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por color, código, empresa o tipo...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: onBusquedaChanged,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildDropdown(
                'Sucursal',
                filtroSucursal,
                sucursales, // Pasamos la lista de objetos
                (Sucursal s) => s.nombre, // Label
                (Sucursal s) => s.id, // Value (ID)
                onSucursalChanged,
              ),
              _buildDropdown(
                'Empresa',
                filtroEmpresa,
                empresas,
                (Empresa e) => e.nombre,
                (Empresa e) => e.id,
                onEmpresaChanged,
              ),
              _buildDropdown(
                'Color',
                filtroColor,
                colores,
                (ColorTela c) => c.nombre,
                (ColorTela c) => c.id,
                onColorChanged,
              ),
              _buildDropdown(
                'Tipo',
                filtroTipoTela,
                tipos,
                (TipoTela t) => t.nombre,
                (TipoTela t) => t.id,
                onTipoChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    String valueId,
    List<T> items,
    String Function(T) getLabel,
    String Function(T) getValue,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        value: valueId.isEmpty ? null : valueId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text("Todos")),
          ...items.map(
            (e) => DropdownMenuItem(
              value: getValue(e), // Aquí va el ID
              child: Text(getLabel(e)), // Aquí va el Nombre
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
