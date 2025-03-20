// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecargasProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> recargarSaldodesdeDebito(
      BuildContext context, String cardId, double amount) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No se ha encontrado al usuario');
    }

    // Mostrar el Loading Dialog
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
      // Obtener el saldo actual de la tarjeta
      final tarjetaDoc =
          await _firestore.collection('cardsVisa').doc(cardId).get();
      if (!tarjetaDoc.exists) {
        throw Exception('La tarjeta no existe');
      }

      final tarjetaData = tarjetaDoc.data();
      double saldoTarjeta = (tarjetaData?['saldo'] ?? 0.00).toDouble();

      // Verificar si el monto solicitado es válido
      if (amount <= 0 || amount > saldoTarjeta) {
        throw Exception('Monto no válido o insuficiente');
      }

      // Actualizar el saldo de la tarjeta
      await _firestore.collection('cardsVisa').doc(cardId).update({
        'saldo': saldoTarjeta - amount,
      });

      // Obtener el saldo actual del usuario
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      double saldoUsuario = (userData?['saldo'] ?? 0.00).toDouble();

      // Actualizar el saldo del usuario
      await _firestore.collection('users').doc(user.uid).update({
        'saldo': saldoUsuario + amount,
      });

      // Registrar la transacción en la colección "Transferencias"
      await _firestore.collection('Transferencias').add({
        'userId': user.uid,
        'cardId': cardId,
        'monto': amount,
        'tipoDeTransferencia': 'Recarga a Tarjeta de Débito',
        'fecha': FieldValue.serverTimestamp(),
      });

      // Cerrar el Loading Dialog
      Navigator.of(context).pop();

      // Mostrar diálogo de éxito personalizado
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 50,
                ),
                const SizedBox(height: 15),
                Text(
                  'Recarga Exitosa',
                  style: TextStyle(
                    color: Colors.teal[300],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se han recargado \$${amount.toStringAsFixed(2)} a tu cuenta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Cerrar el Loading Dialog
      Navigator.of(context).pop();

      // Mostrar diálogo de error personalizado
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF6B6B),
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Error en la Recarga',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFFFF6B6B)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> recargarSaldodesdeCredito(
      BuildContext context, String cardId, double amount) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No se ha encontrado al usuario');
    }

    // Mostrar el Loading Dialog
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
      // Obtener el saldo actual de la tarjeta
      final tarjetaDoc =
          await _firestore.collection('cardsVisa').doc(cardId).get();
      if (!tarjetaDoc.exists) {
        throw Exception('La tarjeta no existe');
      }

      final tarjetaData = tarjetaDoc.data();
      double saldoTarjeta = (tarjetaData?['saldo'] ?? 0.00).toDouble();

      // Verificar si el monto solicitado es válido
      if (amount <= 0 || amount > saldoTarjeta) {
        throw Exception('Monto no válido o insuficiente');
      }

      // Actualizar el saldo de la tarjeta
      await _firestore.collection('cardsVisa').doc(cardId).update({
        'saldo': saldoTarjeta - amount,
      });

      // Obtener el saldo actual del usuario
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      double saldoUsuario = (userData?['saldo'] ?? 0.00).toDouble();

      // Actualizar el saldo del usuario
      await _firestore.collection('users').doc(user.uid).update({
        'saldo': saldoUsuario + amount,
      });

      // Registrar la transacción en la colección "Transferencias"
      await _firestore.collection('Transferencias').add({
        'userId': user.uid,
        'cardId': cardId,
        'monto': amount,
        'tipoDeTransferencia': 'Recarga a Tarjeta de Crédito',
        'fecha': FieldValue.serverTimestamp(),
      });

      // Cerrar el Loading Dialog
      Navigator.of(context).pop();

      // Mostrar diálogo de éxito personalizado
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 50,
                ),
                const SizedBox(height: 15),
                Text(
                  'Recarga Exitosa',
                  style: TextStyle(
                    color: Colors.teal[300],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se han recargado \$${amount.toStringAsFixed(2)} a tu cuenta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Cerrar el Loading Dialog
      Navigator.of(context).pop();

      // Mostrar diálogo de error personalizado
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF6B6B),
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Error en la Recarga',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFFFF6B6B)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<Map<String, dynamic>> GetDatosBancarios() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No se ha encontrado al usuario');
    }

    try {
      // Obtener los datos del usuario desde la colección 'users'
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('No se encontraron datos bancarios para este usuario');
      }

      // Obtener los datos de la cuenta bancaria
      final userData = userDoc.data();
      final numeroCuenta = userData?['numeroCuenta'] ?? '';
      final nombres = userData?['nombres'] ?? '';
      final apellidos = userData?['apellidos'] ?? '';
      final pasaporte = userData?['pasaporte'] ?? '';

      // Retornar los datos en un mapa
      return {
        'numeroCuenta': numeroCuenta,
        'nombres': nombres,
        'apellidos': apellidos,
        'pasaporte': pasaporte,
      };
    } catch (e) {
      throw Exception('Error al obtener los datos bancarios: $e');
    }
  }

  Future<void> recargaSaldoDesdeCuentaBancaria(
      BuildContext context,
      String bancoEmisor,
      double amount,
      String numeroCuenta,
      String tipoCuenta) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No se ha encontrado al usuario');
    }

    // Mostrar el Loading Dialog
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
                const CircularProgressIndicator(),
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
      // Obtengo el documento del usuario
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      // Obtengo y actualizo el saldo del usuario
      double currentSaldo = userDoc.data()?['saldo'] ?? 0.0;
      double newSaldo = currentSaldo + amount;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'saldo': newSaldo,
      });

      // Registrar la transferencia en la colección "Transferencias"
      await FirebaseFirestore.instance.collection('Transferencias').add({
        'userId': user.uid,
        'bancoEmisor': bancoEmisor,
        'numeroCuentaBancaria': numeroCuenta,
        'tipoCuenta': tipoCuenta,
        'monto': amount,
        'tipoDeTransferencia': 'Recarga desde cuenta Bancaria',
        'fecha': FieldValue.serverTimestamp(),
      });

      // Cerrar el Loading Dialog
      Navigator.of(context).pop();

      // Mostrar diálogo de éxito
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 50,
                ),
                const SizedBox(height: 15),
                Text(
                  'Recarga Exitosa',
                  style: TextStyle(
                    color: Colors.teal[300],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se han recargado \$${amount.toStringAsFixed(2)} a tu cuenta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home',
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Cerrar el Loading Dialog
      Navigator.of(context).pop();

      // Mostrar diálogo de error
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF6B6B),
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Error en la Recarga',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFFFF6B6B)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
