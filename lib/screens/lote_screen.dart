import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/models/lote.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:intl/intl.dart';

class LoteScreen extends ConsumerStatefulWidget {
  const LoteScreen({super.key});

  @override
  ConsumerState<LoteScreen> createState() => _LoteScreenState();
}

class _LoteScreenState extends ConsumerState<LoteScreen> {
  @override
  Widget build(BuildContext context) {
    final lotes = ref.watch(lotesProvider);
    final activeLote = ref.watch(loteActivoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Lotes")),
      body: lotes.isEmpty
          ? const Center(
              child: Text(
                "No hay lotes creados.\nUse el botón + para crear uno.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: lotes.length,
              itemBuilder: (context, index) {
                final lote = lotes[index];
                final isCurrentlyActive = activeLote?.id == lote.id;

                // Verificar expiración
                bool isExpired = false;
                if (lote.activo && lote.fechaActivacion != null) {
                  final hoy = DateTime.now();
                  isExpired =
                      !(lote.fechaActivacion!.year == hoy.year &&
                          lote.fechaActivacion!.month == hoy.month &&
                          lote.fechaActivacion!.day == hoy.day);
                }

                return Card(
                  elevation: isCurrentlyActive ? 4 : 1,
                  color: isCurrentlyActive
                      ? AppColors.primary.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    leading: Checkbox(
                      value: isCurrentlyActive,
                      activeColor: isExpired ? Colors.grey : AppColors.primary,
                      onChanged: (val) {
                        if (val == true) {
                          ref
                              .read(lotesProvider.notifier)
                              .setActiveLote(lote.id);
                        } else {
                          ref.read(lotesProvider.notifier).setActiveLote(null);
                        }
                      },
                    ),
                    title: Text(
                      lote.nombre,
                      style: TextStyle(
                        fontWeight: isCurrentlyActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        decoration: isExpired
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      "Encargado: ${lote.encargado}\n"
                      "TC: ${lote.tipoCambio} BS | Items: ${lote.items.length}",
                      style: TextStyle(color: isExpired ? Colors.red : null),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.edit),
                    onTap: () => _navigateToForm(lote),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(null),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToForm(Lote? lote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoteFormScreen(lote: lote),
        fullscreenDialog: true,
      ),
    );
  }
}

// ==========================================
// FORM SCREEN (Crear / Editar Lote)
// ==========================================
class LoteFormScreen extends ConsumerStatefulWidget {
  final Lote? lote;
  const LoteFormScreen({super.key, this.lote});

  @override
  ConsumerState<LoteFormScreen> createState() => _LoteFormScreenState();
}

class _LoteFormScreenState extends ConsumerState<LoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _tipoCambioController = TextEditingController();
  final _encargadoController = TextEditingController();
  DateTime _fecha = DateTime.now();
  List<LoteItem> _itemsTemp = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.lote != null) {
      _nombreController.text = widget.lote!.nombre;
      _tipoCambioController.text = widget.lote!.tipoCambio.toString();
      _encargadoController.text = widget.lote!.encargado;
      _fecha = widget.lote!.fecha;
      _itemsTemp = List.from(widget.lote!.items);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoCambioController.dispose();
    _encargadoController.dispose();
    super.dispose();
  }

  Future<void> _saveLote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_itemsTemp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Agregue al menos una tela"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final nuevoLote = Lote(
      id: widget.lote?.id ?? Helpers.generarId(),
      nombre: _nombreController.text.trim(),
      fecha: _fecha,
      tipoCambio: double.tryParse(_tipoCambioController.text) ?? 0,
      encargado: _encargadoController.text.trim(),
      items: _itemsTemp,
      // Mantener estado activo si ya estaba activo
      activo: widget.lote?.activo ?? false,
      fechaActivacion: widget.lote?.fechaActivacion,
    );

    if (widget.lote == null) {
      await ref.read(lotesProvider.notifier).add(nuevoLote);
    } else {
      await ref.read(lotesProvider.notifier).update(nuevoLote);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lote == null ? "Nuevo Lote" : "Editar Lote"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveLote,
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre del Lote *",
                  ),
                  validator: (v) => v!.isEmpty ? "Requerido" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _encargadoController,
                  decoration: const InputDecoration(
                    labelText: "Encargado de Compra *",
                  ),
                  validator: (v) => v!.isEmpty ? "Requerido" : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tipoCambioController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Tipo de Cambio (BS) *",
                        ),
                        validator: (v) => v!.isEmpty ? "Requerido" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: "Fecha"),
                        child: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Telas en el Lote",
                      style: AppTextStyles.heading3,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _addItem(),
                      icon: const Icon(Icons.add),
                      label: const Text("Agregar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_itemsTemp.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No hay telas agregadas"),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _itemsTemp.length,
                    itemBuilder: (context, index) {
                      final item = _itemsTemp[index];
                      return _buildItemCard(item, index);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddLoteItemSheet(
        onAdd: (item) {
          if (_itemsTemp.any((e) => e.comboKey == item.comboKey)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Combinación duplicada"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          setState(() => _itemsTemp.add(item));
        },
      ),
    );
  }

  Widget _buildItemCard(LoteItem item, int index) {
    final tipos = ref.read(tiposTelaProvider);
    final empresas = ref.read(empresasProvider);
    final anchos = ref.read(anchosProvider);

    final tipoName = tipos
        .firstWhere(
          (t) => t.id == item.tipoTelaId,
          orElse: () => TipoTela(id: '', nombre: '?'),
        )
        .nombre;
    final empresaName = empresas
        .firstWhere(
          (e) => e.id == item.empresaId,
          orElse: () => Empresa(id: '', nombre: '?'),
        )
        .nombre;
    String anchoName = item.anchoId != null
        ? anchos
              .firstWhere(
                (a) => a.id == item.anchoId,
                orElse: () => Ancho(id: '', nombre: ''),
              )
              .nombre
        : 'N/A';

    return Card(
      child: ListTile(
        title: Text("$tipoName - $empresaName ($anchoName)"),
        subtitle: Text("Precio: \$${item.precioUSD.toStringAsFixed(2)}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => setState(() => _itemsTemp.removeAt(index)),
        ),
      ),
    );
  }
}

// ================= SHEET PARA AGREGAR ITEM =================
class _AddLoteItemSheet extends ConsumerStatefulWidget {
  final Function(LoteItem) onAdd;
  const _AddLoteItemSheet({required this.onAdd});

  @override
  ConsumerState<_AddLoteItemSheet> createState() => _AddLoteItemSheetState();
}

class _AddLoteItemSheetState extends ConsumerState<_AddLoteItemSheet> {
  String? _tipoTelaId;
  String? _empresaId;
  String? _anchoId;
  final _precioController = TextEditingController();
  bool _tieneAnchoEspecial = false;
  bool _isSavingCatalog = false;

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  void _checkAnchoLogic() {
    if (_empresaId != null && _tipoTelaId != null) {
      final rollos = ref
          .read(rollosProvider)
          .maybeWhen(data: (d) => d, orElse: () => <Rollo>[]);
      final matches = rollos
          .where(
            (r) => r.empresaId == _empresaId && r.tipoTelaId == _tipoTelaId,
          )
          .toList();

      if (matches.isNotEmpty) {
        final withAncho = matches.where((r) => r.anchoId != null).toList();
        setState(() {
          _tieneAnchoEspecial = withAncho.isNotEmpty;
          if (_tieneAnchoEspecial) {
            final freq = <String, int>{};
            for (var r in withAncho) {
              freq[r.anchoId!] = (freq[r.anchoId!] ?? 0) + 1;
            }
            _anchoId = freq.entries
                .reduce((a, b) => a.value >= b.value ? a : b)
                .key;
          } else {
            _anchoId = null;
          }
        });
      } else {
        setState(() {
          _tieneAnchoEspecial = false;
          _anchoId = null;
        });
      }
    }
  }

  Future<void> _addAncho() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const Text("Nuevo Ancho"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(hintText: "Ej: 1.50m"),
                ),
                if (_isSavingCatalog)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isSavingCatalog ? null : () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: _isSavingCatalog
                    ? null
                    : () async {
                        final name = ctrl.text.trim();
                        if (name.isEmpty) return;
                        setStateDialog(() => _isSavingCatalog = true);
                        final id = Helpers.generarId();
                        await ref
                            .read(catalogServiceProvider)
                            .addAncho(Ancho(id: id, nombre: name));
                        ref.refresh(anchosProvider);
                        setStateDialog(() => _isSavingCatalog = false);
                        setState(() => _anchoId = id);
                        if (mounted) Navigator.pop(ctx);
                      },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipos = ref.watch(tiposTelaProvider);
    final empresas = ref.watch(empresasProvider);
    final anchos = ref.watch(anchosProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Agregar Tela al Lote", style: AppTextStyles.heading2),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _tipoTelaId,
              items: tipos
                  .map(
                    (t) => DropdownMenuItem(value: t.id, child: Text(t.nombre)),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => _tipoTelaId = v);
                _checkAnchoLogic();
              },
              decoration: const InputDecoration(labelText: "Tipo de Tela"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _empresaId,
              items: empresas
                  .map(
                    (e) => DropdownMenuItem(value: e.id, child: Text(e.nombre)),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => _empresaId = v);
                _checkAnchoLogic();
              },
              decoration: const InputDecoration(labelText: "Empresa"),
            ),
            const SizedBox(height: 12),
            if (_tieneAnchoEspecial)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _anchoId,
                        items: anchos
                            .map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.nombre),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _anchoId = v),
                        decoration: const InputDecoration(
                          labelText: "Ancho Especial *",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addAncho,
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Precio Compra USD *",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_tipoTelaId == null ||
                    _empresaId == null ||
                    _precioController.text.isEmpty)
                  return;
                if (_tieneAnchoEspecial && _anchoId == null) return;

                final item = LoteItem(
                  id: Helpers.generarId(),
                  tipoTelaId: _tipoTelaId!,
                  empresaId: _empresaId!,
                  anchoId: _anchoId,
                  precioUSD: double.tryParse(_precioController.text) ?? 0,
                );
                widget.onAdd(item);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: const Text("AGREGAR"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
