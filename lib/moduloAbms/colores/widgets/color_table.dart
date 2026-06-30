import 'package:flutter/material.dart';
import '../../../models/abmTiposTelas/color_tela.dart';

class ColorTable extends StatelessWidget {
  final List<ColorTela> colores;
  final Function(ColorTela) onEdit;
  final Function(ColorTela) onDelete;

  const ColorTable({
    super.key,
    required this.colores,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos el punto de quiebre responsivo para cambiar entre Celular y Web/Tablet
    final esCelular = MediaQuery.of(context).size.width < 700;

    if (colores.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No hay colores registrados en este momento.'),
        ),
      );
    }

    return esCelular ? _buildGridCelular() : _buildTablaWeb();
  }

  // --- DISEÑO MÓVIL: Grilla de Tarjetas ---
  Widget _buildGridCelular() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: colores.length,
      itemBuilder: (context, index) {
        final colorItem = colores[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorItem.toFlutterColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  colorItem.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '#${colorItem.hexadecimal}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () => onEdit(colorItem),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => onDelete(colorItem),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DISEÑO WEB / DESKTOP: Tabla Estilizada ---
  Widget _buildTablaWeb() {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5), // Muestra Visual
            1: FlexColumnWidth(3), // Nombre
            2: FlexColumnWidth(2), // Código Hex
            3: FlexColumnWidth(1.5), // Acciones
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Cabecera de la tabla
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Muestra',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Nombre del Color',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Código Hex',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Acciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Filas con la data de colores
            ...colores.map((colorItem) {
              return TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorItem.toFlutterColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(colorItem.nombre),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '#${colorItem.hexadecimal}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => onEdit(colorItem),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(colorItem),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
