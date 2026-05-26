import 'package:flutter/material.dart';
import 'package:inv_telas/utils/icon_mapper.dart';

class IconPickerDialog extends StatefulWidget {
  final String selectedIcon;

  const IconPickerDialog({super.key, required this.selectedIcon});

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  final TextEditingController _searchCtrl = TextEditingController();

  late List<String> filteredIcons;

  @override
  void initState() {
    super.initState();

    filteredIcons = IconMapper.availableIcons;

    _searchCtrl.addListener(_filter);
  }

  void _filter() {
    final query = _searchCtrl.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredIcons = IconMapper.availableIcons;
      } else {
        filteredIcons = IconMapper.availableIcons
            .where((icon) => icon.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 850,
        height: 650,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Seleccionar icono',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar icono... ej: user, sale, chart',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('${filteredIcons.length} iconos encontrados'),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive (celular/tablet/web)
                      int crossAxisCount = 6;

                      if (constraints.maxWidth < 500) {
                        crossAxisCount = 3; // celular
                      } else if (constraints.maxWidth < 800) {
                        crossAxisCount = 4; // tablet
                      }

                      return GridView.builder(
                        itemCount: filteredIcons.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,

                          // 🔥 corregido overflow
                          childAspectRatio: 1.15,

                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final iconName = filteredIcons[index];

                          final selected = widget.selectedIcon == iconName;

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pop(context, iconName);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(.12)
                                    : null,
                                border: Border.all(
                                  color: selected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Icon(
                                      IconMapper.getIcon(iconName),
                                      size: 26,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Flexible(
                                    child: Text(
                                      iconName,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
