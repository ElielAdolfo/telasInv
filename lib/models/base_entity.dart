abstract class BaseEntity {
  final String id;

  final bool activo;
  final bool eliminado;

  final String usuarioCreacion;
  final String? usuarioModificacion;
  final String? usuarioEliminacion;

  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final DateTime? fechaEliminacion;

  const BaseEntity({
    required this.id,
    required this.activo,
    required this.eliminado,
    required this.usuarioCreacion,
    this.usuarioModificacion,
    this.usuarioEliminacion,
    required this.fechaCreacion,
    this.fechaModificacion,
    this.fechaEliminacion,
  });
}
