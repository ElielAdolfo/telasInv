import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                sucursales.map((e) => e.nombre).toList(),
                onSucursalChanged,
              ),
              _buildDropdown(
                'Empresa',
                filtroEmpresa,
                empresas.map((e) => e.nombre).toList(),
                onEmpresaChanged,
              ),
              _buildDropdown(
                'Color',
                filtroColor,
                colores.map((e) => e.nombre).toList(),
                onColorChanged,
              ),
              _buildDropdown(
                'Tipo',
                filtroTipoTela,
                tipos.map((e) => e.nombre).toList(),
                onTipoChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
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
          ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
