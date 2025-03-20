class Transaccion {
  final String numeroCuentaEmisor;
  final String numeroCuentaReceptor;
  final double monto;
  final DateTime fecha;
  final String descripcion;
  final bool exitoso;
  final String uidEmisor;
  final String uidReceptor;
  final String? nombreEmisor;
  final String? apellidoEmisor;
  final String? nombreReceptor;
  final String? apellidoReceptor;

  Transaccion({
    required this.numeroCuentaEmisor,
    required this.numeroCuentaReceptor,
    required this.monto,
    required this.fecha,
    required this.descripcion,
    required this.exitoso,
    required this.uidEmisor,
    required this.uidReceptor,
    this.nombreEmisor,
    this.apellidoEmisor,
    this.nombreReceptor,
    this.apellidoReceptor,
  });

  Map<String, dynamic> toJson() {
    return {
      'numeroCuentaEmisor': numeroCuentaEmisor,
      'numeroCuentaReceptor': numeroCuentaReceptor,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
      'exitoso': exitoso,
      'uidEmisor': uidEmisor,
      'uidReceptor': uidReceptor,
      'nombreEmisor': nombreEmisor,
      'apellidoEmisor': apellidoEmisor,
      'nombreReceptor': nombreReceptor,
      'apellidoReceptor': apellidoReceptor,
    };
  }
}
