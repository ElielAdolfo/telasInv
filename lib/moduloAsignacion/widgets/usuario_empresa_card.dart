import 'package:flutter/material.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/moduloAsignacion/widgets/usuario_sucursales_card.dart';

class UsuarioEmpresaCard extends StatefulWidget {
  final Empresa empresa;
  final Usuario usuario;

  final VoidCallback onAsignarSucursal;

  const UsuarioEmpresaCard({
    super.key,
    required this.empresa,
    required this.usuario,
    required this.onAsignarSucursal,
  });

  @override
  State<UsuarioEmpresaCard> createState() => _UsuarioEmpresaCardState();
}

class _UsuarioEmpresaCardState extends State<UsuarioEmpresaCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final permiso = widget.empresa.usuariosPermitidos.firstWhere(
      (e) => e.usuarioId == widget.usuario.id,
    );

    return Card(
      child: ExpansionTile(
        initiallyExpanded: expanded,
        title: Text(widget.usuario.nombre),
        subtitle: Text(widget.usuario.email),
        trailing: Wrap(
          spacing: 10,
          children: [
            Chip(label: Text("${permiso.sucursales.length} sucursales")),
            IconButton(
              icon: const Icon(Icons.add_business),
              onPressed: widget.onAsignarSucursal,
            ),
          ],
        ),
        children: [
          UsuarioSucursalesCard(
            empresa: widget.empresa,
            usuario: widget.usuario,
          ),
        ],
      ),
    );
  }
}
