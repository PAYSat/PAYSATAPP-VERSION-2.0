import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:proyectos_flutter/Model/TarjetaPaysat.dart';
import 'package:proyectos_flutter/Page/User/Home/HomePage.dart';


class TransferirDineroProvider extends ChangeNotifier{
  final _numeroCuentaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  bool _isLoading = false;
  String? nombre;
  String? apellidos;
  String? correo;
  String? telefono;
  double? montoAEnviar;
  double? saldoUsuarioLogueado;
  String? userNumeroCuenta;
  BuildContext context;

  TransferirDineroProvider(this.context);

  TextEditingController get numeroCuentaController => _numeroCuentaController;
  TextEditingController get descripcionController => _descripcionController;
  TextEditingController get montoController => _montoController;

  bool get isLoading => _isLoading;

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // ignore: non_constant_identifier_names
  Future<bool> TransferirSaldoATarjeta(
      BuildContext context, String numeroTarjeta, double monto) async {
    try {
      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/SatLogoSplash.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      await Future.delayed(const Duration(seconds: 5));

      // Validar el formato de la tarjeta (remover espacios)
      numeroTarjeta = numeroTarjeta.replaceAll(' ', '');
      if (numeroTarjeta.length != 16) {
        throw Exception('Número de tarjeta inválido');
      }

      // Obtener el usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario logueado.');
      }

      // Referencia al documento del usuario
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Obtener el documento actual
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        throw Exception('El documento del usuario no existe.');
      }

      // Obtener el saldo actual y convertirlo a double
      double saldoActual = userDoc['saldo'] is String
          ? double.tryParse(userDoc['saldo']) ?? 0.0
          : (userDoc['saldo'] is double || userDoc['saldo'] is int
              ? userDoc['saldo'].toDouble()
              : 0.0);

      // Verificar si hay saldo suficiente
      if (saldoActual < monto) {
        Navigator.pop(context); // Cerrar diálogo de carga
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Saldo insuficiente para realizar la transferencia a tarjeta.'),
              backgroundColor: Colors.red[100], // Color tomate suave
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return false;
      }

      // Calcular el nuevo saldo
      double nuevoSaldo = saldoActual - monto;

      // Actualizar el saldo en Firestore
      await userRef.update({'saldo': nuevoSaldo});

      // Registrar la transacción en el historial
      await _registrarTransaccionTarjeta(
        monto: monto,
        numeroTarjeta: numeroTarjeta,
        saldoResultante: nuevoSaldo,
        userDoc: userDoc,
      );

      // Cerrar diálogo de carga
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Éxito', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Transferencia a tarjeta realizada con éxito.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                const Color.fromARGB(243, 5, 237, 229), // Color turquesa suave
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          );
        },
      );

      return true;
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo de carga en caso de error
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error en la transferencia a tarjeta: $e'),
            backgroundColor: Colors.red[100], // Color tomate suave
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }
  }

  Future<void> _registrarTransaccionTarjeta({
    required double monto,
    required String numeroTarjeta,
    required double saldoResultante,
    required DocumentSnapshot userDoc,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Obtener información del usuario
      String nombres = userDoc['nombres'] ?? '';
      String apellidos = userDoc['apellidos'] ?? '';
      String numeroCuenta = userDoc['numeroCuenta'] ?? '';

      // Crear el registro de la transacción
      await FirebaseFirestore.instance.collection('Transferencias').add({
        'uid': user.uid,
        'tipoDeTransferencia': 'Transferencia de Cuenta Paysat a Tarjeta',
        'monto': monto,
        'numeroTarjeta': numeroTarjeta,
        'saldoResultante': saldoResultante,
        'fecha': DateTime.now(),
        'estado': 'completado',
        'nombres': nombres,
        'apellidos': apellidos,
        'numeroCuenta': numeroCuenta,
        'ultimosDigitos': numeroTarjeta.substring(numeroTarjeta.length - 4),
      });
    } catch (e) {
      print('Error al registrar la transacción de tarjeta: $e');
      throw Exception('Error al registrar la transacción de tarjeta: $e');
    }
  }

  Future<Map<String, dynamic>?> obtenerInformacionDeUsuarioLogueado() async {
    try {
      // Obtener el usuario logueado
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el documento del usuario en Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Obtener la información del usuario
          var saldo = userDoc['saldo'];
          var numeroCuenta = userDoc['numeroCuenta'];

          // Procesar el saldo y convertirlo a double si es necesario
          double? saldoUsuarioLogueado;
          if (saldo is String) {
            saldoUsuarioLogueado = double.tryParse(saldo);
          } else if (saldo is double || saldo is int) {
            saldoUsuarioLogueado = saldo.toDouble();
          }

          if (saldoUsuarioLogueado == null) {
            throw const FormatException('El saldo no es un número válido');
          }

          // Crear un mapa con la información que queremos retornar
          return {
            'nombres': userDoc['nombres'],
            'apellidos': userDoc['apellidos'],
            'numeroCuenta': numeroCuenta,
            'saldo': saldoUsuarioLogueado,
          };
        } else {
          throw Exception('El documento del usuario no existe.');
        }
      }
    } catch (e) {
      // Manejo de errores
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al obtener la información del usuario: $e')),
      );
    }

    // Si hay algún error o el usuario no está logueado, retorna null
    return null;
  }

  Future<void> obtenerSaldoUsuarioLogueado() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          var saldo = userDoc['saldo'];
          var numeroCuenta = userDoc['numeroCuenta'];

          if (saldo is String) {
            saldoUsuarioLogueado = double.tryParse(saldo);
          } else if (saldo is double || saldo is int) {
            saldoUsuarioLogueado = saldo.toDouble();
          }

          setState(() {
            nombre = userDoc['nombres'];
            apellidos = userDoc['apellidos'];
            correo = userDoc['correo'];
            telefono = userDoc['telefono'];
            montoAEnviar = 0.0;
            if (numeroCuenta != null) {
              userNumeroCuenta = numeroCuenta;
            }
          });

          if (saldoUsuarioLogueado == null) {
            throw const FormatException('El saldo no es un número válido');
          }
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener el saldo del usuario: $e')),
      );
    }
  }

  Future<void> buscarUsuarioPorNumeroCuenta() async {
    String numeroCuenta = _numeroCuentaController.text.trim();

    if (numeroCuenta.isEmpty) {
      setState(() {
        nombre = null;
        apellidos = null;
        correo = null;
        telefono = null;
        userNumeroCuenta = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese el número de cuenta.'),
        ),
      );
      return; // Detener la función aquí si el campo está vacío.
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('numeroCuenta', isEqualTo: numeroCuenta)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          nombre = null;
          apellidos = null;
          correo = null;
          telefono = null;
          userNumeroCuenta = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Número de cuenta no encontrado.')),
        );
        return;
      }

      var userDoc = querySnapshot.docs.first.data() as Map<String, dynamic>;

      setState(() {
        _isLoading = false;
        nombre = userDoc['nombres'];
        apellidos = userDoc['apellidos'];
        correo = userDoc['correo'];
        telefono = userDoc['telefono'];
        userNumeroCuenta = numeroCuenta;
      });

      print('Usuario encontrado: $nombre $apellidos');
    } catch (e) {
      setState(() {
        _isLoading = false;
        nombre = null;
        apellidos = null;
        correo = null;
        telefono = null;
        userNumeroCuenta = null;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar el número de cuenta: $e')),
      );
    }
  }

  Future<void> enviarDineroEntreCuentasPaysat() async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/SatLogoSplash.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (_numeroCuentaController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _montoController.text.isEmpty) {
      Navigator.pop(context); // Cerrar el loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    double monto = double.parse(_montoController.text);

    if (monto <= 0 || monto > saldoUsuarioLogueado!) {
      Navigator.pop(context); // Cerrar el loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido o saldo insuficiente.')),
      );
      return;
    }

    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      String uidEmisor = FirebaseAuth.instance.currentUser!.uid;

      // Obtener datos del emisor
      DocumentSnapshot remitenteDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uidEmisor)
          .get();
      String nombreEmisor = remitenteDoc['nombres'];
      String apellidoEmisor = remitenteDoc['apellidos'];
      String numeroCuentaEmisor = remitenteDoc['numeroCuenta'];

      // Obtener datos del receptor
      QuerySnapshot receptorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('numeroCuenta', isEqualTo: userNumeroCuenta)
          .get();

      if (receptorSnapshot.docs.isEmpty) {
        throw Exception('El receptor no existe.');
      }

      var receptorData =
          receptorSnapshot.docs.first.data() as Map<String, dynamic>;
      String uidReceptor = receptorSnapshot.docs.first.id;
      String nombreReceptor = receptorData['nombres'];
      String apellidoReceptor = receptorData['apellidos'];
      String correoReceptor = receptorData['correo'];

      // Crear transacción
      DocumentReference transaccionRef =
          FirebaseFirestore.instance.collection('Transferencias').doc();

      batch.set(
        transaccionRef,
        {
          'numeroCuentaEmisor': numeroCuentaEmisor,
          'numeroCuentaReceptor': userNumeroCuenta!,
          'monto': monto,
          'fecha': DateTime.now(),
          'descripcion': _descripcionController.text,
          'exitoso': true,
          'uidEmisor': uidEmisor,
          'uidReceptor': uidReceptor,
          'nombreEmisor': nombreEmisor,
          'apellidoEmisor': apellidoEmisor,
          'nombreReceptor': nombreReceptor,
          'apellidoReceptor': apellidoReceptor,
          'correoReceptor': correoReceptor,
          'tipoDeTransferencia':
              'Transferencia Entre Cuentas Paysat', // Campo agregado
        },
      );

      // Crear notificación para el receptor
      DocumentReference notificacionRef = FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(uidReceptor)
          .collection('notificaciones')
          .doc();

      batch.set(
        notificacionRef,
        {
          'titulo': 'Nueva Transacción Recibida',
          'descripcion':
              'Has recibido \$${monto.toStringAsFixed(2)} de $nombreEmisor $apellidoEmisor.',
          'fecha': DateTime.now(),
          'leido': false,
        },
      );

      // Commit batch
      await batch.commit();

      // Actualizar saldos
      await actualizarSaldoUsuarios();

      // Notificar al correo del receptor
      await enviarNotificacionPorCorreo(
          correoReceptor,
          nombreReceptor,
          apellidoReceptor,
          monto,
          numeroCuentaEmisor,
          nombreEmisor,
          apellidoEmisor,
          userNumeroCuenta!);

      Navigator.pop(context); // Cerrar loading

      // Mostrar ventana emergente de éxito
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.teal,
            title: const Text(
              'Transferencia Exitosa',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'La transferencia se ha realizado con éxito.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar loading

      // En caso de error, mostrar mensaje
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: const Text(
              'Error',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Error al enviar el dinero: $e',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
    // Generar comprobante
    await generarComprobante();
  }

  Future<void> enviarNotificacionPorCorreo(
    String correoReceptor,
    String nombreReceptor,
    String apellidoReceptor,
    double monto,
    String numeroCuentaEmisor,
    String nombreEmisor,
    String apellidoEmisor,
    String numeroCuentaReceptor,
  ) async {
    const url =
        'https://us-central1-apppaysat-973fc.cloudfunctions.net/enviarCorreoNotificacion';

    // Los parámetros que deseas enviar
    final Map<String, dynamic> data = {
      'correoReceptor': correoReceptor,
      'nombreReceptor': nombreReceptor,
      'apellidoReceptor': apellidoReceptor,
      'monto': monto,
      'numeroCuentaEmisor': numeroCuentaEmisor,
      'nombreEmisor': nombreEmisor,
      'apellidoEmisor': apellidoEmisor,
      'numeroCuentaReceptor': numeroCuentaReceptor,
    };

    try {
      // Haciendo la solicitud POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Correo enviado con éxito');
      } else {
        print('Error al enviar correo: ${response.statusCode}');
      }
    } catch (e) {
      print("Error al enviar correo: $e");
    }
  }

  void setState(VoidCallback fn) {
    // ignore: unnecessary_null_comparison
    if (context != null) {
      fn();
    }
  }

  Future<void> actualizarSaldoUsuarios() async {
    try {
      if (userNumeroCuenta == null) {
        throw Exception('Número de cuenta del receptor no válido.');
      }
      String uidEmisor = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference remitenteRef =
          FirebaseFirestore.instance.collection('users').doc(uidEmisor);
      DocumentSnapshot remitenteDoc = await remitenteRef.get();
      if (!remitenteDoc.exists) {
        throw Exception('El documento del remitente no existe.');
      }

      double saldoEmisorActual = remitenteDoc['saldo'] is String
          ? double.tryParse(remitenteDoc['saldo']) ?? 0.0
          : (remitenteDoc['saldo'] is double || remitenteDoc['saldo'] is int
              ? remitenteDoc['saldo'].toDouble()
              : 0.0);

      double monto = double.parse(_montoController.text);
      saldoEmisorActual -= monto;

      if (saldoEmisorActual < 0) {
        throw Exception('El saldo del emisor no puede ser negativo.');
      }
      await remitenteRef.update({'saldo': saldoEmisorActual});
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('numeroCuenta', isEqualTo: userNumeroCuenta)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception(
            'El receptor con el número de cuenta ingresado no se encontró.');
      }
      String uidReceptor = querySnapshot.docs.first.id;
      DocumentReference destinatarioRef =
          FirebaseFirestore.instance.collection('users').doc(uidReceptor);

      DocumentSnapshot destinatarioDoc = await destinatarioRef.get();
      if (!destinatarioDoc.exists) {
        throw Exception('El documento del receptor no existe.');
      }
      double saldoReceptorActual = destinatarioDoc['saldo'] is String
          ? double.tryParse(destinatarioDoc['saldo']) ?? 0.0
          : (destinatarioDoc['saldo'] is double ||
                  destinatarioDoc['saldo'] is int
              ? destinatarioDoc['saldo'].toDouble()
              : 0.0);
      saldoReceptorActual += monto;
      await destinatarioRef.update({'saldo': saldoReceptorActual});
      print('Saldo actualizado:');
      print('Saldo emisor: $saldoEmisorActual');
      print('Saldo receptor: $saldoReceptorActual');
    } catch (e) {
      throw Exception('Error al actualizar los saldos: $e');
    }
  }

  Future<void> generarComprobante() async {
    final pdf = pw.Document();

    final monto = double.parse(_montoController.text);
    final descripcion = _descripcionController.text;
    final fecha = DateTime.now().toString();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Comprobante de Transacción',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Monto: \$${monto.toStringAsFixed(2)}'),
              pw.Text('Descripción: $descripcion'),
              pw.Text('Fecha: $fecha'),
              pw.Text('Receptor: $nombre $apellidos'),
              pw.Text('Número de cuenta: $userNumeroCuenta'),
            ],
          );
        },
      ),
    );
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'comprobante_transaccion.pdf',
    );
  }

 Future<void> transferirMonto(
    BuildContext context, CreditCardPaysat card, double amount) async {
  // Mostrar el diálogo de carga
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/SatLogoSplash.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  try {
    // Simular un pequeño retraso para mostrar el loading
    await Future.delayed(const Duration(milliseconds: 800));

    // Buscar la tarjeta en Firebase por su uid
    var cardQuery = await _firebaseFirestore
        .collection('cardsPaysat')
        .where('uid', isEqualTo: card.uid)
        .limit(1)
        .get();

    // Cerrar el diálogo de carga
    Navigator.pop(context);

    if (cardQuery.docs.isEmpty) {
      await _mostrarMensajeError(
        context,
        'Tarjeta no encontrada',
        'No se pudo encontrar la tarjeta en el sistema.'
      );
      return;
    }

    var cardDoc = cardQuery.docs.first;
    double saldoActual = (cardDoc['saldo'] as num).toDouble();

    if (saldoActual < amount) {
      await _mostrarMensajeError(
        context,
        'Saldo insuficiente',
        'No hay suficiente saldo disponible en la tarjeta para realizar esta transferencia.'
      );
      return;
    }

    double nuevoSaldo = saldoActual - amount;
    
    // Actualizar el saldo en Firebase
    await _firebaseFirestore
        .collection('cardsPaysat')
        .doc(cardDoc.id)
        .update({'saldo': nuevoSaldo});

    // Crear la transacción
    await _firebaseFirestore.collection('transacciones').add({
      'cardUid': card.uid,
      'amount': amount,
      'transactionDate': FieldValue.serverTimestamp(),
      'transactionType': 'transfer',
      'balanceAfter': nuevoSaldo,
    });

    // Mostrar mensaje de éxito y navegar al home
    await _mostrarMensajeExito(
      context,
      'Transferencia exitosa',
      'La transferencia se ha realizado correctamente.'
    );
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );

  } catch (e) {
    // Cerrar el diálogo de carga si aún está abierto
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    await _mostrarMensajeError(
      context,
      'Error en la transferencia',
      'Ocurrió un error al procesar la transferencia. Por favor, intente nuevamente.'
    );
  }
}

Future<void> _mostrarMensajeExito(BuildContext context, String titulo, String mensaje) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        backgroundColor: Colors.teal[50],
        titleTextStyle: const TextStyle(
          color: Colors.teal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Colors.teal,
          fontSize: 16,
        ),
        actions: [
          TextButton(
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

Future<void> _mostrarMensajeError(BuildContext context, String titulo, String mensaje) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        backgroundColor: Colors.red[50],
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 16,
        ),
        actions: [
          TextButton(
            child: const Text('OK', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}


}
