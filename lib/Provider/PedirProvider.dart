import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PedirProvider extends ChangeNotifier {
  Contact? selectedContact;
  double amount = 0.0;
  String reason = '';
  bool isLoading = false;
  String nombres = '';
  String apellidos = '';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Getters
  Contact? get getSelectedContact => selectedContact;
  double get getAmount => amount;
  String get getReason => reason;
  bool get getIsLoading => isLoading;
  String get getNombres => nombres;
  String get getApellidos => apellidos;

  // Solicitar permisos para acceder a los contactos
  Future<bool> requestContactPermission() async {
    final permission = await FlutterContacts.requestPermission();
    return permission;
  }

  // Mostrar diálogo de éxito

  // Seleccionar contacto y validar contra Firebase
  Future<void> selectContact(BuildContext context) async {
    try {
      final hasPermission = await FlutterContacts.requestPermission();
      if (!hasPermission) {
        return;
      }

      final contact = await FlutterContacts.openExternalPick();

      if (contact != null) {
        // Cargar los detalles completos del contacto
        final fullContact = await FlutterContacts.getContact(contact.id);

        if (fullContact != null && fullContact.phones.isNotEmpty) {
          String phoneNumber =
              _formatPhoneNumber(fullContact.phones.first.number);

          final userData = await _getUserDataByPhone(phoneNumber);
          if (userData != null) {
            selectedContact = contact;
            nombres = userData['nombres'];
            apellidos = userData['apellidos'];
            notifyListeners();
          } else {
            _showErrorDialog(context, 'Contacto no registrado',
                'Este contacto no está registrado en PAYSat');
          }
        }
      }
    } catch (e) {
      debugPrint('Error selecting contact: $e');
      _showErrorDialog(
          context, 'Error', 'Ocurrió un error al seleccionar el contacto');
    }
  }

  // Obtener datos del usuario según el número de teléfono
  Future<Map<String, dynamic>?> _getUserDataByPhone(String phoneNumber) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (var doc in querySnapshot.docs) {
      String telefono = doc['telefono'] ?? '';
      telefono = telefono.replaceAll(RegExp(r'[^\d]'), '');

      if (telefono == phoneNumber) {
        return {
          'nombres': doc['nombres'] ?? 'Desconocido',
          'apellidos': doc['apellidos'] ?? 'Desconocido',
        };
      }
    }
    return null;
  }

  // Actualizar monto
  void updateAmount(String value) {
    amount =
        double.tryParse(value.replaceAll('\$', '').replaceAll(',', '')) ?? 0.0;
    notifyListeners();
  }

  // Actualizar razón
  void updateReason(String value) {
    reason = value;
    notifyListeners();
  }

  // Validar si todos los campos están completos
  bool isFormValid() {
    return selectedContact != null && amount > 0 && reason.isNotEmpty;
  }

  // Formatear número de teléfono
  String _formatPhoneNumber(String phone) {
    // Eliminar caracteres especiales y espacios
    String phoneNumber = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Si empieza con prefijo de país +593, lo removemos
    if (phoneNumber.startsWith('593')) {
      phoneNumber = '0${phoneNumber.substring(3)}';
    }

    return phoneNumber;
  }

  // Mostrar diálogo de error
  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Limpiar el state
  void clear() {
    selectedContact = null;
    amount = 0.0;
    reason = '';
    nombres = '';
    apellidos = '';
    notifyListeners();
  }

  Stream<QuerySnapshot> getAllMoneyRequests() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no logueado');
    }

    return FirebaseFirestore.instance
        .collection('SolicitudDinero')
        .where(Filter.or(Filter('emisorUid', isEqualTo: user.uid),
            Filter('receptorUid', isEqualTo: user.uid)))
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Future<void> createMoneyRequest(BuildContext context) async {
    final Color turquoise = const Color(0xFF40E0D0); // Color turquesa
    final Color tomato = const Color(0xFFFF6347); // Color tomate suave

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
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no logueado');
      }

      final emisorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!emisorDoc.exists) {
        throw Exception('No se encontró la información del usuario emisor');
      }

      final emisorData = emisorDoc.data()!;
      final emisorNombre = emisorData['nombres'] ?? '';
      final emisorApellidos = emisorData['apellidos'] ?? '';

      String phoneNumber =
          _formatPhoneNumber(selectedContact!.phones.first.number);
      final receptorQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('telefono', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (receptorQuery.docs.isEmpty) {
        throw Exception('No se encontró la información del usuario receptor');
      }

      final receptorDoc = receptorQuery.docs.first;
      final receptorData = receptorDoc.data();
      final receptorUid = receptorDoc.id;
      final receptorCorreo = receptorData['correo'] ?? '';

      // Guardar la solicitud en Firestore
      await FirebaseFirestore.instance.collection('SolicitudDinero').add({
        'emisorUid': user.uid,
        'emisorNombre': emisorNombre,
        'emisorApellidos': emisorApellidos,
        'receptorUid': receptorUid,
        'receptorNombre': receptorData['nombres'] ?? '',
        'receptorApellidos': receptorData['apellidos'] ?? '',
        'monto': amount,
        'razon': reason,
        'fecha': FieldValue.serverTimestamp(),
        'estado': 'pendiente',
      });

      final emailData = {
        'emisorNombre': emisorNombre,
        'emisorApellido': emisorApellidos,
        'receptorCorreo': receptorCorreo,
        'monto': amount.toString(),
        'razon': reason,
      };

      final response = await http.post(
        Uri.parse(
            'https://us-central1-apppaysat-973fc.cloudfunctions.net/enviarSolicitudDinero'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(emailData),
      );

      // Cerrar el diálogo de carga
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Mostrar diálogo de éxito con colores personalizados
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: turquoise,
            title: const Text(
              'Solicitud Enviada',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Se envió la solicitud y se notificó por correo.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Error enviando el correo: ${response.body}');
      }

      clear();
    } catch (e) {
      // Cerrar el diálogo de carga
      Navigator.pop(context);

      // Mostrar diálogo de error con colores personalizados
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: tomato,
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          content: Text(
            'Ocurrió un error: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
}
