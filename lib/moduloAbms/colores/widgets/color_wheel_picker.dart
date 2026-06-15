import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorWheelPicker extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onChanged;

  const ColorWheelPicker({
    super.key,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final esWeb = size.width > 650;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: ColorPicker(
        pickerColor: color,
        onColorChanged: onChanged,
        enableAlpha: false,
        paletteType: PaletteType.hsv,
        pickerAreaHeightPercent: esWeb ? 0.7 : 0.45,
        displayThumbColor: true,
        portraitOnly: true, // <--- ESTA LINEA FORZA EL DISEÑO VERTICAL ABAJO
        labelTypes: const [],
      ),
    );
  }
}
