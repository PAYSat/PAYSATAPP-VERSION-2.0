class Users {
  final int? id;
  final String nombres;
  final String apellidos;
  final String pasaporte;
  final String telefono;
  final String correo;
  final String? pais;
  final String? imageUrl;
  final String? password;
  final String rol;
  final bool activo;
  final String? token;
  final double saldo;
  final String? numeroCuenta;
  final String? direccionCasa;
  final String? comprobanteServicioBasico;
  final String? ubicacionActual;

  Users(
      {this.id,
      required this.nombres,
      required this.apellidos,
      required this.pasaporte,
      required this.telefono,
      required this.correo,
      this.pais,
      required this.imageUrl,
      this.password,
      this.rol = 'usuario',
      this.activo = true,
      this.token,
      this.saldo = 0.0,
      this.numeroCuenta,
      this.direccionCasa,
      this.comprobanteServicioBasico,
      this.ubicacionActual});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
        id: json['id'],
        nombres: json['nombres'],
        apellidos: json['apellidos'],
        pasaporte: json['pasaporte'],
        telefono: json['telefono'],
        correo: json['correo'],
        pais: json['pais'],
        imageUrl: json['imageUrl'],
        password: json['password'],
        rol: json['rol'] ?? 'usuario',
        activo: json['activo'] ?? true,
        token: json['token'],
        saldo: json['saldo']?.toDouble() ?? 0.0,
        numeroCuenta: json['numeroCuenta'],
        direccionCasa: json['direccionCasa'],
        comprobanteServicioBasico: json['comprobanteServicioBasico'],
        ubicacionActual: json['ubicacionActual']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'pasaporte': pasaporte,
      'telefono': telefono,
      'correo': correo,
      'pais': pais,
      'imageUrl': imageUrl,
      'password': password,
      'rol': rol,
      'activo': activo,
      'token': token,
      'saldo': saldo,
      'numeroCuenta': numeroCuenta,
      'direccionCasa': direccionCasa,
      'comprobanteServicioBasico': comprobanteServicioBasico,
      'ubicacionActual': ubicacionActual
    };
  }
}
