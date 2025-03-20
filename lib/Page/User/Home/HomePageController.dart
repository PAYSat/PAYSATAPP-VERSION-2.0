import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Model/TarjetaPaysat.dart';
import 'package:proyectos_flutter/Page/Splash/splashPage.dart';

class HomePageController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<Map<String, dynamic>> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        Map<String, String> userData = {
          'nombres': 'No disponible',
          'apellidos': 'No disponible',
          'correo': user.email ?? 'No disponible',
          'saldo': '00.00',
          'numeroCuenta': 'No disponible',
        };

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;

          userData = {
            'nombres': data['nombres'] ?? 'No disponible',
            'apellidos': data['apellidos'] ?? 'No disponible',
            'correo': user.email ?? 'No disponible',
            'saldo': data['saldo']?.toString() ?? '00.00',
            'numeroCuenta': data['numeroCuenta'] ?? 'No disponible',
          };
        }
        QuerySnapshot tarjetasQuery = await FirebaseFirestore.instance
            .collection('cardsPaysat')
            .where('uid', isEqualTo: user.uid)
            .get();

        List<CreditCardPaysat> tarjetas = tarjetasQuery.docs.map((doc) {
          return CreditCardPaysat.fromMap(doc.data() as Map<String, dynamic>,
              id: doc.id);
        }).toList();

        return {
          'userData': userData,
          'tarjetas': tarjetas.map((tarjeta) => tarjeta.toMap()).toList(),
        };
      }

      return {
        'userData': {
          'nombres': 'No disponible',
          'apellidos': 'No disponible',
          'correo': 'No disponible',
          'saldo': '00.00',
          'numeroCuenta': 'No disponible',
        },
        'tarjetas': [],
      };
    } catch (e) {
      return {
        'userData': {
          'nombres': 'Error',
          'apellidos': 'Error',
          'correo': 'Error',
          'saldo': '00.00',
          'numeroCuenta': 'Error',
        },
        'tarjetas': [],
      };
    }
  }

  static Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}
