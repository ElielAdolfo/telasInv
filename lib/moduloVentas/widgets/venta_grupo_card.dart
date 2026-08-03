// lib/moduloVentas/widgets/venta_grupo_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/color_tela.dart';
import 'package:inv_telas/models/codigosTelaProveedor/color_codigo.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import 'package:inv_telas/providers/precio_venta_provider.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/providers/color_provider.dart';
// NUEVO IMPORT: Para acceder a los providers del código único de proveedor
import 'package:inv_telas/providers/codigo_unico_tela_proveedor_provider.dart';
import '../../models/ventas/stock_actual.dart';
import 'detalle_rollo_dialog.dart';
import 'vender_rollo_dialog.dart';
import '../screens/ventas_pos_screen.dart';

class VentaGrupoCard extends ConsumerWidget {
  final String tipoTelaId;
  final String? colorId;
  final String loteId;
  final List<StockActual> rollosGrupo;
  final String nombreTela;

  const VentaGrupoCard({
    super.key,
    required this.tipoTelaId,
    required this.colorId,
    required this.loteId,
    required this.rollosGrupo,
    required this.nombreTela,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(carritoVentasProvider);
    final filtroActual = ref.watch(filtroEstadoProvider);

    // Obtenemos el ID de la empresa actual de la sesión
    final session = ref.watch(sessionProvider);
    final empresaId = session.empresaActual?.id ?? '';

    // Escuchamos la lista de colores de la empresa actual
    final coloresAsync = ref.watch(coloresProvider(empresaId));

    // Verificamos si este tipo de tela cuenta con precio en la sucursal actual
    final precioConfig = ref.watch(precioPorTipoTelaProvider(tipoTelaId));
    final bool tienePrecioAsignado = precioConfig != null;

    final rollosActivos = rollosGrupo
        .where((r) => r.estado != StockRolloEstado.vendido)
        .toList();

    final rollosFiltrados = rollosActivos.where((rollo) {
      switch (filtroActual) {
        case FiltroRolloEstado.cerrado:
          return rollo.estado == StockRolloEstado.cerrado;
        case FiltroRolloEstado.abierto:
          return rollo.estado == StockRolloEstado.abierto;
        case FiltroRolloEstado.todos:
        default:
          return true;
      }
    }).toList();

    if (rollosFiltrados.isEmpty) {
      return const SizedBox.shrink();
    }

    // =========================================================================
    // NUEVO: OBTENER EL CÓDIGO DE COLOR DEL PROVEEDOR
    // =========================================================================
    // Tomamos el primer rollo para extraer su proveedorId.
    final primerRollo = rollosFiltrados.first;
    final proveedorId = primerRollo.proveedorId;

    // Buscamos la relación única usando el provider de tipo 'family' con un Record de parámetros
    final codigoProveedorAsync = ref.watch(
      codigoUnicoTelaProveedorByProveedorTipoProvider((
        empresaId: empresaId,
        proveedorId: proveedorId,
        tipoTelaId: tipoTelaId,
      )),
    );
    // =========================================================================

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: tienePrecioAsignado ? null : Colors.red.shade50.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...rollosFiltrados.map((rollo) {
              double metrosEnCarrito = 0.0;
              for (var item in cartState.items) {
                for (var sel in item.rollosSeleccionados) {
                  if (sel.rolloId == rollo.id) {
                    metrosEnCarrito += sel.metrosExtraidos;
                  }
                }
              }

              final bool estaRealmenteCerrado =
                  rollo.estado == StockRolloEstado.cerrado;
              final bool tieneMetrosEnCarrito = metrosEnCarrito > 0;

              final bool mostrarBotonVentaCompleta =
                  tienePrecioAsignado &&
                  estaRealmenteCerrado &&
                  !tieneMetrosEnCarrito;
              final bool mostrarBotonAbrirManualmente =
                  tienePrecioAsignado &&
                  estaRealmenteCerrado &&
                  !tieneMetrosEnCarrito;

              // --- LÓGICA DE DETECCIÓN Y PARSEO DEL COLOR REAL ---
              Widget widgetColorEsfera = const SizedBox.shrink();
              String nombreColorTexto = "Sin color asignado";

              if (rollo.colorId != null && rollo.colorId!.isNotEmpty) {
                widgetColorEsfera = coloresAsync.when(
                  data: (listaColores) {
                    final colorEncontrado = listaColores.firstWhere(
                      (c) => c.id == rollo.colorId,
                      orElse: () => ColorTela(
                        id: '',
                        empresaId: empresaId,
                        nombre: 'N/A',
                        hexadecimal: 'CCCCCC',
                      ),
                    );

                    nombreColorTexto = colorEncontrado.nombre;

                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorEncontrado.toFlutterColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              } else {
                widgetColorEsfera = Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                );
              }

              // =========================================================================
              // NUEVO: BUSCAR EL CÓDIGO DE COLOR DEL PROVEEDOR PARA ESTE ROLLO INDIVIDUAL
              // =========================================================================
              String? codigoColorProveedor;
              codigoProveedorAsync.whenData((relacion) {
                if (relacion != null && rollo.colorId != null) {
                  // Buscamos en la lista de colores de la relación el que coincida con el colorId del rollo
                  final colorCodigoMatch = relacion.colores.firstWhere(
                    (c) => c.colorId == rollo.colorId,
                    orElse: () =>
                        const ColorCodigo(colorId: '', codigoColor: ''),
                  );
                  if (colorCodigoMatch.codigoColor.isNotEmpty) {
                    codigoColorProveedor = colorCodigoMatch.codigoColor;
                  }
                }
              });
              // =========================================================================

              return ListTile(
                dense: true,
                leading: widgetColorEsfera,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        nombreColorTexto.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),

                    // =========================================================================
                    // NUEVO: MUESTRA EL CÓDIGO DE COLOR DE MANERA VISUAL SI EXISTE
                    // =========================================================================
                    if (codigoColorProveedor != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'Cód: $codigoColorProveedor',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],

                    // =========================================================================
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rollo #${rollo.numeroFisico} (${tieneMetrosEnCarrito ? "PROV. ABIERTO" : rollo.estado.nombre})',
                        style: TextStyle(
                          fontWeight: tieneMetrosEnCarrito
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: tienePrecioAsignado
                              ? null
                              : Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                subtitle: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    children: [
                      TextSpan(
                        text:
                            '${rollo.metrajeActual.toStringAsFixed(2)} m restantes',
                      ),
                      if (tieneMetrosEnCarrito)
                        TextSpan(
                          text:
                              ' - ${metrosEnCarrito.toStringAsFixed(2)} m carrito',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (!tienePrecioAsignado)
                        const TextSpan(
                          text: ' - No se puede vender Sin Precio asignado',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mostrarBotonVentaCompleta)
                      IconButton(
                        icon: const Icon(Icons.archive, color: Colors.blueGrey),
                        tooltip: 'Vender Rollo Completo',
                        onPressed: () => ref
                            .read(carritoVentasProvider.notifier)
                            .agregarRolloCompleto(
                              rollo: rollo,
                              nombre: nombreTela,
                              precio: precioConfig.precioVentaMetro,
                            ),
                      ),
                    if (mostrarBotonAbrirManualmente)
                      IconButton(
                        icon: const Icon(Icons.lock_open, color: Colors.amber),
                        tooltip: 'Cambiar Estado a Abierto en Mesa',
                        onPressed: () {
                          debugPrint(
                            'Forzando cambio de estado a ABIERTO para el rollo ID: ${rollo.id}',
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Ver Info',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => DetalleRolloDialog(rollo: rollo),
                      ),
                    ),
                    if (tienePrecioAsignado)
                      IconButton(
                        icon: const Icon(Icons.cut, color: Colors.red),
                        tooltip: 'Vender metraje de este rollo',
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => VenderRolloDialog(
                            rollo: rollo,
                            nombreTela: nombreTela,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
