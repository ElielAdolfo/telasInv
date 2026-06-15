import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorMixerPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onChanged;

  const ColorMixerPicker({
    super.key,
    required this.color,
    required this.onChanged,
  });

  @override
  State<ColorMixerPicker> createState() => _ColorMixerPickerState();
}

class _ColorMixerPickerState extends State<ColorMixerPicker> {
  late HSVColor hsv;
  late TextEditingController hexController;
  bool _bloquearSincronizacionTexto = false;

  @override
  void initState() {
    super.initState();
    hsv = HSVColor.fromColor(widget.color);
    hexController = TextEditingController(text: _colorToHex(widget.color));
  }

  @override
  void didUpdateWidget(covariant ColorMixerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.color != oldWidget.color) {
      hsv = HSVColor.fromColor(widget.color);

      if (!_bloquearSincronizacionTexto) {
        final nuevoHex = _colorToHex(widget.color);
        if (hexController.text != nuevoHex) {
          hexController.text = nuevoHex;
        }
      }
    }
  }

  @override
  void dispose() {
    hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return color.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
  }

  void _emitirColor(HSVColor nuevo) {
    setState(() {
      hsv = nuevo;
    });
    widget.onChanged(nuevo.toColor());
  }

  void _updateDesdeHex(String valor) {
    if (valor.length != 6) return;

    try {
      final color = Color(int.parse("FF$valor", radix: 16));
      _bloquearSincronizacionTexto = true;
      _emitirColor(HSVColor.fromColor(color));
      _bloquearSincronizacionTexto = false;
    } catch (_) {}
  }

  String _rgbText() {
    final c = hsv.toColor();
    return "${c.red}, ${c.green}, ${c.blue}";
  }

  String _hsvText() {
    return "${hsv.hue.round()}°, ${(hsv.saturation * 100).round()}%, ${(hsv.value * 100).round()}%";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esPantallaAncha = constraints.maxWidth > 480;

        if (esPantallaAncha) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 12, child: _buildColorSelector(constraints, true)),
              const SizedBox(width: 16),
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildPanelInfo(),
                ),
              ),
            ],
          );
        } else {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorSelector(constraints, false),
                const SizedBox(height: 16),
                _buildPanelInfo(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildColorSelector(BoxConstraints constraints, bool esPantallaAncha) {
    // Calculamos el espacio real disponible de forma ultra-segura
    final anchoDisponible = esPantallaAncha
        ? constraints.maxWidth * 0.5
        : constraints.maxWidth;
    final altoDisponible = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : 220.0;

    // Ajustamos dinámicamente el diámetro para que quepa en cualquier celda o diálogo pequeño
    double tamaniooIdeal = math.min(anchoDisponible, altoDisponible) * 0.85;
    final wheelSize = tamaniooIdeal.clamp(130.0, 220.0);

    // Proporciones matemáticas perfectas para que el cuadrado quede siempre DENTRO del círculo
    final squareSize = wheelSize * 0.52;
    final center = wheelSize / 2;
    final radius = wheelSize / 2;
    final strokeWidth = wheelSize * 0.11; // Grosor óptimo de la rueda de color

    // Coordenadas del indicador de Matiz (Hue) exactamente en el centro del anillo de color
    final hueAnguloRad = hsv.hue * math.pi / 180;
    final hueRadioDistancia = radius - (strokeWidth / 2);
    final hueIndicadorX = center + hueRadioDistancia * math.cos(hueAnguloRad);
    final hueIndicadorY = center + hueRadioDistancia * math.sin(hueAnguloRad);

    // Coordenadas del indicador de Saturación y Valor dentro de su propio cuadro
    final squareLeft = center - (squareSize / 2);
    final squareTop = center - (squareSize / 2);
    final svIndicadorX = squareLeft + (hsv.saturation * squareSize);
    final svIndicadorY = squareTop + ((1 - hsv.value) * squareSize);

    // El Center aquí es VITAL: evita que los Layouts padres estiren el Stack y rompan las coordenadas
    return Center(
      child: SizedBox(
        width: wheelSize,
        height: wheelSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Rueda de Color (Hue)
            Positioned.fill(
              child: GestureDetector(
                onPanDown: (d) =>
                    _manejarToqueHue(d.localPosition, wheelSize, strokeWidth),
                onPanUpdate: (d) =>
                    _manejarToqueHue(d.localPosition, wheelSize, strokeWidth),
                child: CustomPaint(
                  size: Size(wheelSize, wheelSize),
                  painter: _HueWheelPainter(strokeWidth: strokeWidth),
                ),
              ),
            ),

            // 2. Cuadrado de Saturación y Valor (Garantizado adentro)
            Positioned(
              left: squareLeft,
              top: squareTop,
              child: GestureDetector(
                onPanDown: (d) => _manejarToqueSV(d.localPosition, squareSize),
                onPanUpdate: (d) =>
                    _manejarToqueSV(d.localPosition, squareSize),
                child: Container(
                  width: squareSize,
                  height: squareSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24, width: 1),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Puntero/Indicador de la rueda (Hue Handle)
            Positioned(
              left: hueIndicadorX - 7,
              top: hueIndicadorY - 7,
              child: IgnorePointer(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Puntero/Indicador del Cuadrado Interno (SV Handle)
            Positioned(
              left: svIndicadorX - 7,
              top: svIndicadorY - 7,
              child: IgnorePointer(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: hsv.value > 0.5 ? Colors.black : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hsv.value > 0.5 ? Colors.white : Colors.black,
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _manejarToqueHue(Offset localPos, double wheelSize, double strokeWidth) {
    final center = wheelSize / 2;
    final dx = localPos.dx - center;
    final dy = localPos.dy - center;
    final distancia = math.sqrt(dx * dx + dy * dy);

    // Margen de tolerancia táctil para el anillo de color
    if (distancia < (center - strokeWidth - 16) || distancia > (center + 16))
      return;

    double angulo = math.atan2(dy, dx);
    if (angulo < 0) angulo += 2 * math.pi;

    _emitirColor(hsv.withHue(angulo * 180 / math.pi));
  }

  void _manejarToqueSV(Offset localPos, double squareSize) {
    final s = (localPos.dx / squareSize).clamp(0.0, 1.0);
    final v = (1 - (localPos.dy / squareSize)).clamp(0.0, 1.0);
    _emitirColor(hsv.withSaturation(s).withValue(v));
  }

  Widget _buildPanelInfo() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoRow("HSV", _hsvText()),
            const SizedBox(height: 4),
            _buildInfoRow("RGB", _rgbText()),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: hexController,
                    decoration: InputDecoration(
                      labelText: 'Código HEX',
                      prefixText: '# ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
                    ],
                    onChanged: _updateDesdeHex,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hsv.toColor(),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String etiqueta, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HueWheelPainter extends CustomPainter {
  final double strokeWidth;

  _HueWheelPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final minDimension = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = minDimension / 2;

    for (double i = 0; i < 360; i++) {
      final paint = Paint()
        ..color = HSVColor.fromAHSV(1, i, 1, 1).toColor()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        i * math.pi / 180,
        (math.pi / 180) +
            0.03, // Pequeño solapamiento para evitar líneas blancas de renderizado
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
