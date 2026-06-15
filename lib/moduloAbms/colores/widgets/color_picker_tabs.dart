import 'package:flutter/material.dart';

import 'color_palette_picker.dart';
import 'color_mixer_picker.dart';
import 'color_wheel_picker.dart';
import 'color_continuous_picker.dart';

class ColorPickerTabs extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerTabs({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerTabs> createState() => _ColorPickerTabsState();
}

class _ColorPickerTabsState extends State<ColorPickerTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Color _selectedColor;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _tabController = TabController(length: 4, vsync: this);
    _textController = TextEditingController(
      text: _formatColorToHex(_selectedColor),
    );
  }

  @override
  void didUpdateWidget(covariant ColorPickerTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialColor != oldWidget.initialColor) {
      _selectedColor = widget.initialColor;
      _textController.text = _formatColorToHex(_selectedColor);
    }
  }

  // Helper a prueba de fallos usando padLeft
  String _formatColorToHex(Color color) {
    final hexRaw = color.value.toRadixString(16).padLeft(8, '0');
    return '#${hexRaw.substring(2).toUpperCase()}';
  }

  // Convertidor robusto: Valida longitudes correctas antes de parsear
  Color? _hexToColor(String hex) {
    String cleanHex = hex.replaceFirst('#', '').trim();

    if (cleanHex.length == 6) {
      cleanHex =
          'FF$cleanHex'; // Agrega opacidad por defecto si ponen 6 dígitos
    } else if (cleanHex.length != 8) {
      return null; // Rechaza longitudes inválidas (como tus 4 dígitos "0000")
    }

    try {
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  void _updateColor(Color color) {
    setState(() {
      _selectedColor = color;
      final newHex = _formatColorToHex(color);
      if (_textController.text != newHex) {
        _textController.text = newHex;
      }
    });
    widget.onColorChanged(color);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _textController,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _selectedColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            // CAMBIO CLAVE: Actualiza dinámicamente si escribe un HEX válido de 6 u 8 dígitos
            onChanged: (value) {
              String clean = value.replaceFirst('#', '').trim();
              if (clean.length == 6 || clean.length == 8) {
                final color = _hexToColor(clean);
                if (color != null) {
                  setState(() {
                    _selectedColor = color;
                  });
                  widget.onColorChanged(color);
                }
              }
            },
            // Al presionar Enter, limpia el formato o revierte si era inválido
            onSubmitted: (value) {
              final color = _hexToColor(value);
              if (color != null) {
                _updateColor(color);
              } else {
                // Si puso "0000", vuelve automáticamente al último color válido
                _textController.text = _formatColorToHex(_selectedColor);
              }
            },
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(icon: Icon(Icons.palette, size: 20), text: 'Paleta'),
            Tab(icon: Icon(Icons.adjust, size: 20), text: 'Disco'),
            Tab(icon: Icon(Icons.tune, size: 20), text: 'Mezclar'),
            Tab(icon: Icon(Icons.color_lens, size: 20), text: 'Rueda'),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBarView(
              controller: _tabController,
              children: [
                ColorPalettePicker(
                  color: _selectedColor,
                  onChanged: _updateColor,
                ),
                ColorContinuousPicker(
                  color: _selectedColor,
                  onChanged: _updateColor,
                ),
                ColorMixerPicker(
                  color: _selectedColor,
                  onChanged: _updateColor,
                ),
                ColorWheelPicker(
                  color: _selectedColor,
                  onChanged: _updateColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
