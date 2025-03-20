import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:proyectos_flutter/Model/User.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

class UserProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  static final LocalAuthentication _localAuth = LocalAuthentication();

  Future<String> _uploadImage(String imagePath) async {
    try {
      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      String fileName = path.basename(imagePath);
      firebase_storage.Reference ref =
          storage.ref().child('user_images/$fileName');

      File file = File(imagePath);
      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir imagen: $e");
      throw Exception("Error al subir imagen: $e");
    }
  }

  // Diálogo de éxito (color turquesa)
  Future<void> showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF40E0D0), // Color Turquesa
          title: const Text(
            '¡Usuario registrado exitosamente!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF40E0D0),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // Diálogo de error (color rojo)
  Future<void> showErrorDialog(
      BuildContext context, String errorMessage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red, // Color Rojo
          title: const Text(
            'Error al registrar usuario',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para registrar usuario
  Future<void> register(Users user, BuildContext context) async {
    try {
      // Verifica que los campos obligatorios estén completos
      if (user.correo == null || user.correo.isEmpty) {
        throw 'Correo es obligatorio';
      }
      if (user.password == null || user.password!.isEmpty) {
        throw 'Contraseña es obligatoria';
      }
      if (user.nombres == null || user.nombres!.isEmpty) {
        throw 'Nombre es obligatorio';
      }
      if (user.apellidos == null || user.apellidos!.isEmpty) {
        throw 'Apellidos son obligatorios';
      }
      if (user.telefono == null || user.telefono!.isEmpty) {
        throw 'Teléfono es obligatorio';
      }

      // Mostrar loading con logo
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const CircularProgressIndicator(
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
            ),
          );
        },
      );

      // Si la imagen no es null, subirla (únicamente si existe)
      String imageUrl = '';
      if (user.imageUrl != null && user.imageUrl!.isNotEmpty) {
        imageUrl = await _uploadImage(user.imageUrl!);
      }

      // Realizar el registro
      firebase_auth.UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.correo!,
        password: user.password!,
      );

      firebase_auth.User? newUser = userCredential.user;
      String uid = newUser!.uid;

      String iniciales =
          '${user.nombres![0]}${user.apellidos![0]}'.toUpperCase();
      String numeroAleatorio =
          (1000 + (9999 - 1000) * (DateTime.now().millisecond % 1000))
              .toString();
      String numeroCuenta = '$iniciales$numeroAleatorio';

      // Guardar los datos en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nombres': user.nombres,
        'apellidos': user.apellidos,
        'pasaporte': user.pasaporte ?? '', // Puede ser null
        'telefono': user.telefono,
        'correo': user.correo,
        'pais': user.pais ?? '', // Puede ser null
        'imageUrl': imageUrl, // Imagen es opcional
        'rol': user.rol ?? 'usuario', // Rol predeterminado si es null
        'activo': user.activo ?? true, // Predeterminado a 'true' si es null
        'saldo': user.saldo ?? 0.0, // Predeterminado a 0 si es null
        'numeroCuenta': numeroCuenta,
        'ubicacionActual': null,
        'comprobanteServicioBasico': null,
        'direccionCasa': null,
      });

      // Cerrar loading
      Navigator.pop(context);

      // Mostrar diálogo de éxito
      await showSuccessDialog(context);
    } catch (e) {
      // Cerrar loading si hay error
      Navigator.pop(context);

      String errorMessage = e.toString();

      // Manejo específico para el error 'email-already-in-use'
      if (errorMessage.contains('email-already-in-use')) {
        errorMessage = 'El correo electrónico ya está en uso. Inicie sesión.';
        // Mostrar diálogo de error
        await showErrorDialog(context, errorMessage);
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Mostrar el mensaje de error genérico
        await showErrorDialog(context, errorMessage);
      }
    }
  }

  // Obtener el usuario actual
  Future<Users?> getCurrentUser() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return Users(
          nombres: data['nombres'],
          apellidos: data['apellidos'],
          pasaporte: data['pasaporte'],
          telefono: data['telefono'],
          correo: data['correo'],
          pais: data['pais'],
          imageUrl: data['imageUrl'],
          rol: data['rol'],
          activo: data['activo'],
          saldo: data['saldo'],
        );
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener usuario: $e");
      }
      return null;
    }
  }

  static Future<bool> verifyFingerprint(BuildContext context) async {
    //boton llama a este metod
    try {
      bool isBiometricAvailable = await _localAuth.canCheckBiometrics;

      if (!isBiometricAvailable) {
        await _showMessageDialog(
          context,
          'No hay biometría disponible en este dispositivo.',
        );
        return false;
      }

      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Escanea tu huella digital para continuar.',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      return isAuthenticated;
    } catch (e) {
      await _showMessageDialog(
        context,
        'Error al autenticar: $e',
      );
      return false;
    }
  }

  static Future<void> _showMessageDialog(
      BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Autenticación Biométrica'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
