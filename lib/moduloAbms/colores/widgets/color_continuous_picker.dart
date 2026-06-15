import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorContinuousPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onChanged;

  const ColorContinuousPicker({
    super.key,
    required this.color,
    required this.onChanged,
  });

  @override
  State<ColorContinuousPicker> createState() => _ColorContinuousPickerState();
}

class _ColorContinuousPickerState extends State<ColorContinuousPicker> {
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
  void didUpdateWidget(covariant ColorContinuousPicker oldWidget) {
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
    return color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esPantallaAncha = constraints.maxWidth > 480;

        // Tamaños adaptables calculados matemáticamente para evitar cualquier desborde
        final tamanioMaximo = math.min(constraints.maxWidth * 0.75, constraints.maxHeight * 0.6);
        final wheelSize = tamanioMaximo.clamp(140.0, 200.0);
        final sliderWidth = 22.0;

        if (esPantallaAncha) {
          return Row(
            crossAxisAlignment: CenterAsymmetric.center,
            children: [
              Expanded(
                flex: 13,
                child: Center(child: _buildPickerCore(wheelSize, sliderWidth)),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 9,
                child: SingleChildScrollView(child: _buildPanelInfo()),
              ),
            ],
          );
        } else {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _buildPickerCore(wheelSize, sliderWidth),
                const SizedBox(height: 16),
                _buildPanelInfo(),
                const SizedBox(height: 8),
              ],
            ),
          );
        }
      },
    );
  }

  // Agrupa el disco cromático y el slider vertical uno al lado del otro de forma segura
  Widget _buildPickerCore(double wheelSize, double sliderWidth) {
    final center = wheelSize / 2;
    final radius = wheelSize / 2;

    // Cálculo de la posición del puntero de cruz (X, Y) basado en el Matiz y la Saturación
    final hueRad = hsv.hue * math.pi / 180;
    final dist = hsv.saturation * radius;
    final punteroX = center + dist * math.cos(hueRad);
    final punteroY = center + dist * math.sin(hueRad);

    // Posición vertical del indicador del Slider de Brillo (Value)
    final sliderHandleY = (1.0 - hsv.value) * wheelSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Círculo Cromático Continuo (Hue + Saturation)
        SizedBox(
          width: wheelSize,
          height: wheelSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onPanDown: (d) => _manejarToqueRueda(d.localPosition, radius),
                  onPanUpdate: (d) => _manejarToqueRueda(d.localPosition, radius),
                  child: CustomPaint(
                    painter: _ContinuousWheelPainter(),
                  ),
                ),
              ),
              // Puntero en forma de Mira / Cruz (Acorde a la imagen tradicional de diseño)
              Positioned(
                left: punteroX - 8,
                top: punteroY - 8,
                child: IgnorePointer(
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: hsv.value > 0.4 ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // 2. Slider de Brillo Vertical (Value) con flecha selectora
        SizedBox(
          width: sliderWidth + 12,
          height: wheelSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Barra con gradiente del negro al color puro seleccionado
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: sliderWidth,
                child: GestureDetector(
                  onPanDown: (d) => _manejarToqueSlider(d.localPosition, wheelSize),
                  onPanUpdate: (d) => _manejarToqueSlider(d.localPosition, wheelSize),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          HSVColor.fromAHSV(1.0, hsv.hue, hsv.saturation, 1.0).toColor(),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Indicador en forma de Triángulo / Flecha lateral
              Positioned(
                right: -2,
                top: sliderHandleY - 6,
                child: IgnorePointer(
                  child: Icon(
                    Icons.arrow_left,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _manejarToqueRueda(Offset localPos, double radius) {
    final dx = localPos.dx - radius;
    final dy = localPos.dy - radius;
    final distancia = math.sqrt(dx * dx + dy * dy);

    // Calcular la saturación basada en la distancia al centro
    final s = (distancia / radius).clamp(0.0, 1.0);

    // Calcular el matiz (Hue) basado en el ángulo polar
    double angulo = math.atan2(dy, dx);
    if (angulo < 0) angulo += 2 * math.pi;
    final hue = angulo * 180 / math.pi;

    _emitirColor(hsv.withHue(hue).withSaturation(s));
  }

  void _manejarToqueSlider(Offset localPos, double height) {
    final v = (1.0 - (localPos.dy / height)).clamp(0.0, 1.0);
    _emitirColor(hsv.withValue(v));
  }

  Widget _buildPanelInfo() {
    final c = hsv.toColor();
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
            _buildInfoRow("HSV", "${hsv.hue.round()}°, ${(hsv.saturation * 100).round()}%, ${(hsv.value * 100).round()}%"),
            const SizedBox(height: 4),
            _buildInfoRow("RGB", "${c.red}, ${c.green}, ${c.blue}"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: hexController,
                    decoration: InputDecoration(
                      labelText: 'Código HEX',
                      prefixText: '# ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    color: c,
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
        Text(etiqueta, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 12)),
        Text(valor, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// Pintor optimizado que dibuja la rueda continua de Hue y Saturation de manera ultra eficiente
class _ContinuousWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Dibujar el espectro completo de colores (Hue) usando un SweepGradient continuo
    final List<Color> coloresEspectro = List.generate(360, (index) {
      return HSVColor.fromAHSV(1.0, index.toDouble(), 1.0, 1.0).toColor();
    })..add(HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor());

    final paintHue = Paint()
      ..shader = SweepGradient(colors: coloresEspectro).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paintHue);

    // 2. Superponer un RadialGradient blanco inverso para matizar la Saturación hacia el centro
    final paintSaturation = Paint()
      ..shader = RadialGradient(
        colors: const [Colors.white, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paintSaturation);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper semántico interno para simplificar alineaciones en el LayoutBuilder
class CenterAsymmetric {
  static const center = CrossAxisAlignment.center;
}