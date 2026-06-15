import 'package:flutter/material.dart';

class ColorPalettePicker extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onChanged;

  const ColorPalettePicker({
    super.key,
    required this.color,
    required this.onChanged,
  });

  static const List<Color> colores = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Pinta 6 columnas en Web y 4 en Celulares para que no se compriman los cuadros
    final columnas = size.width > 650 ? 6 : 4;

    return GridView.builder(
      itemCount: colores.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        final c = colores[index];
        final esIgual = color.value == c.value;

        return GestureDetector(
          onTap: () => onChanged(c),
          child: Container(
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: esIgual ? 3 : 1,
                color: esIgual
                    ? (c.computeLuminance() > 0.5 ? Colors.black : Colors.amber)
                    : Colors.grey.shade300,
              ),
              boxShadow: esIgual
                  ? [const BoxShadow(color: Colors.black26, blurRadius: 4)]
                  : null,
            ),
            child: esIgual
                ? Icon(
                    Icons.check_circle,
                    color: c.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
        );
      },
    );
  }
}
