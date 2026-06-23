import 'package:flutter/material.dart';
import 'package:inv_telas/models/abmTiposTelas/color_tela.dart';

class CodigoColorTable extends StatefulWidget {
  final List<ColorTela> colores;

  /// Ahora ya no usamos CodigoColorTela, sino ColorTela con campo extra en memoria
  final Map<String, String> valores;

  final ValueChanged<Map<String, String>> onChanged;

  const CodigoColorTable({
    super.key,
    required this.colores,
    required this.valores,
    required this.onChanged,
  });

  @override
  State<CodigoColorTable> createState() => _CodigoColorTableState();
}

class _CodigoColorTableState extends State<CodigoColorTable> {
  late Map<String, String> _valores;

  @override
  void initState() {
    super.initState();

    // copia inicial
    _valores = Map.from(widget.valores);

    // asegurar que todos los colores tengan valor
    for (final color in widget.colores) {
      _valores.putIfAbsent(color.id, () => '');
    }
  }

  void _actualizarCodigo(String colorId, String codigo) {
    setState(() {
      _valores[colorId] = codigo.trim();
    });

    widget.onChanged(_valores);
  }

  String _obtenerCodigo(String colorId) {
    return _valores[colorId] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            columns: const [
              DataColumn(
                label: Text(
                  'Color',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Código',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: widget.colores.map((color) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: color.toFlutterColor,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(color.nombre),
                      ],
                    ),
                  ),

                  DataCell(
                    SizedBox(
                      width: 180,
                      child: TextFormField(
                        initialValue: _obtenerCodigo(color.id),
                        decoration: const InputDecoration(
                          hintText: 'Ej. 103-11-8',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _actualizarCodigo(color.id, value);
                        },
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
