import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:proyectos_flutter/Page/Splash/splashPage.dart';
import 'package:proyectos_flutter/Page/User/Crear/CrearUserDireccion.dart';
import 'package:proyectos_flutter/Page/User/Home/HomePage.dart';
import 'package:http/http.dart' as http;
import 'package:proyectos_flutter/Page/User/Login/loginPage.dart';

class LoginController {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<void> navigateToPage(BuildContext context, Widget page) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    });
  }

  static Future<void> sendLoginNotification(User user) async {
    String currentDateTime = DateTime.now().toString();

    final url = Uri.parse(
        'https://us-central1-apppaysat-973fc.cloudfunctions.net/sendLoginNotification');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'correoReceptor': user.email,
          'fechaHora': currentDateTime,
        }),
      );

      if (response.statusCode == 200) {
        print('Correo de inicio de sesión enviado correctamente');
      } else {
        print(
            'Error al enviar el correo de inicio de sesión: ${response.statusCode}');
      }
    } catch (e) {
      print(
          'Error al hacer la solicitud para enviar el correo de inicio de sesión: $e');
    }
  }

  static Future<void> checkLoginStatus(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Consultar el documento del usuario en Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        bool codigoVerificado = userData['codigoVerificado'] ?? false;

        // Verificar el estado del código y los campos de dirección
        if (codigoVerificado) {
          if (userData['direccionCasa'] == null ||
              userData['comprobanteServicioBasico'] == null ||
              userData['ubicacionActual'] == null) {
            navigateToPage(
              // ignore: use_build_context_synchronously
              context,
              const LoginPage(),
            );
          } else {
            // Si todo está completo, redirigir a HomePage
            navigateToPage(context, const HomePage());
          }
        } else {
          navigateToPage(context, const SplashPage());
        }
      } else {
        navigateToPage(context, const SplashPage());
      }
    } else {
      navigateToPage(context, const SplashPage());
    }
  }

  static Future<void> authenticateWithBiometrics(BuildContext context) async {
    bool isAuthenticated = false;

    try {
      bool isBiometricAvailable = await _localAuth.canCheckBiometrics;
      if (!isBiometricAvailable) {
        await _showMessageDialog(
            context,
            'No hay credenciales de seguridad disponibles en este dispositivo.',
            true);
        return;
      }

      isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentíquese para acceder a su cuenta.',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        String? correo = await _secureStorage.read(key: 'correo');
        String? password = await _secureStorage.read(key: 'password');

        if (correo != null && password != null) {
          login(context, correo, password);
        } else {
          await _showMessageDialog(
              context, 'No se encontraron credenciales guardadas.', true);
        }
      } else {
        await _showMessageDialog(
            context, 'Autenticación fallida. Intente nuevamente.', true);
      }
    } catch (e) {
      await _showMessageDialog(
          context, 'Error en la autenticación biométrica: $e', true);
    }
  }

  static Future<void> _showMessageDialog(
      BuildContext context, String message, bool isError) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      isError
                          ? Icons.cancel_outlined
                          : Icons.check_circle_outline,
                      color: isError ? Colors.red : const Color(0xFF40E0D0),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.contains('verifica tu correo')
                          ? 'Revisa la bandeja de tu correo si no te sale debe estar en la carpeta SPAM'
                          : (isError
                              ? 'Vuelve a intentarlo, puede que hayas ingresado mal algún caracter.'
                              : ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isError ? Colors.red[400] : const Color(0xFF40E0D0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isError ? 'Reintentar' : 'Aceptar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> sendVerificationCode(String email) async {
    final url = Uri.parse(
        'https://us-central1-apppaysat-973fc.cloudfunctions.net/Verficacion_Codigo_IniciarSesion');

    try {
      // Generar un código de verificación (6 dígitos aleatorios)
      String codigoVerificacion =
          (100000 + (999999 - 100000) * (DateTime.now().millisecond / 1000))
              .toStringAsFixed(0);

      // Obtener el usuario actual de Firebase
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Almacenar el código de verificación en Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'codigoVerificacion':
              codigoVerificacion, // Guardamos el código en el campo 'codigoVerificacion'
        });
      }

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'correoReceptor': email,
          'codigoVerificacion': codigoVerificacion,
        }),
      );

      if (response.statusCode == 200) {
        print('Código de verificación enviado correctamente');
      } else {
        print(
            'Error al enviar el código de verificación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud para enviar el código de verificación: $e');
    }
  }

  static Future<void> login(
      BuildContext context, String correo, String password) async {
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
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      if (userCredential.user != null) {
        await _secureStorage.write(key: 'correo', value: correo);
        await _secureStorage.write(key: 'password', value: password);

        // Obtener los datos del usuario desde Firebase
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        var userData = userDoc.data() as Map<String, dynamic>;

        bool codigoVerificado = userData['codigoVerificado'] ?? false;

        if (codigoVerificado) {
          // Comprobar si los campos necesarios están completos
          if (userData['direccionCasa'] == null ||
              userData['comprobanteServicioBasico'] == null ||
              userData['ubicacionActual'] == null) {
            // Si faltan datos, redirigir a RegistroDireccionPage
            navigateToPage(
              context,
              RegistroDireccionPage(uid: userCredential.user!.uid),
            );
          } else {
            // Si todos los datos están completos, enviar notificación y redirigir
            await sendLoginNotification(userCredential.user!);
            navigateToPage(context, const HomePage());
          }
        } else {
          await sendVerificationCode(correo);

          String? codigoIngresado = await _showVerificationDialog(context);

          if (codigoIngresado != null) {
            await verifyCodeAndUpdateStatus(
                context, userCredential.user!, codigoIngresado);

            if (userData['direccionCasa'] == null ||
                userData['comprobanteServicioBasico'] == null ||
                userData['ubicacionActual'] == null) {
              navigateToPage(
                context,
                RegistroDireccionPage(uid: userCredential.user!.uid),
              );
            } else {
              navigateToPage(context, const HomePage());
              await sendLoginNotification(userCredential.user!);
            }
          } else {
            await _showMessageDialog(
                context, 'El código de verificación no fue ingresado.', true);
          }
        }
      } else {
        await _showMessageDialog(context, 'Error en las credenciales', true);
      }
    } catch (e) {
      Navigator.of(context).pop();

      String errorMessage = 'Error desconocido';
      if (e is FirebaseAuthException) {
        errorMessage = handleFirebaseAuthError(e);
      }
      await _showMessageDialog(context, errorMessage, true);
      print("Error: $e");
    }
  }

  static Future<void> verifyCodeAndUpdateStatus(
      BuildContext context, User user, String codigoIngresado) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      var userData = userDoc.data() as Map<String, dynamic>;

      String? codigoVerificacion = userData['codigoVerificacion'];

      if (codigoVerificacion != null && codigoVerificacion == codigoIngresado) {
        // Si el código ingresado es correcto, actualizar el estado en Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'codigoVerificado': true,
        });

        // Cerrar el diálogo de verificación
        Navigator.of(context).pop(true);

        // Verificar si los datos de dirección están completos
        if (userData['direccionCasa'] == null ||
            userData['comprobanteServicioBasico'] == null ||
            userData['ubicacionActual'] == null) {
          // Si faltan datos, redirigir a RegistroDireccionPage
          navigateToPage(
            context,
            RegistroDireccionPage(uid: user.uid),
          );
        } else {
          // Si todos los datos están completos, ir a HomePage
          navigateToPage(context, const HomePage());
        }
      } else {
        // Si el código es incorrecto, mostrar el mensaje de error pero mantener el diálogo abierto
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Código de verificación incorrecto. Por favor, inténtelo nuevamente.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Mostrar error pero mantener el diálogo abierto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al verificar el código: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return null;
  }

  static Future<String?> _showVerificationDialog(BuildContext context) async {
    TextEditingController codigoController = TextEditingController();
    bool isVerifying = false;
    String? errorMessage;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> verificarCodigo() async {
              setState(() {
                isVerifying = true;
                errorMessage = null;
              });

              try {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();
                  var userData = userDoc.data() as Map<String, dynamic>;
                  String? codigoVerificacion = userData['codigoVerificacion'];

                  if (codigoVerificacion != null &&
                      codigoVerificacion == codigoController.text) {
                    // Código correcto - actualizar estado
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({
                      'codigoVerificado': true,
                    });

                    // Cerrar el diálogo y retornar el código
                    Navigator.of(context).pop(codigoController.text);

                    // Verificar dirección y navegar
                    if (userData['direccionCasa'] == null ||
                        userData['comprobanteServicioBasico'] == null ||
                        userData['ubicacionActual'] == null) {
                      navigateToPage(
                        context,
                        RegistroDireccionPage(uid: user.uid),
                      );
                    } else {
                      navigateToPage(context, const HomePage());
                    }
                  } else {
                    // Código incorrecto - mostrar error dentro del diálogo
                    setState(() {
                      errorMessage =
                          'Código de verificación incorrecto. Por favor, inténtelo nuevamente.';
                      codigoController.clear();
                    });
                  }
                }
              } catch (e) {
                setState(() {
                  errorMessage = 'Error al verificar el código: $e';
                });
              } finally {
                setState(() {
                  isVerifying = false;
                });
              }
            }

            // Obtener dimensiones de la pantalla
            double screenWidth = MediaQuery.of(context).size.width;
            double dialogWidth =
                screenWidth * 0.8; // 80% del ancho de la pantalla
            double textFieldWidth =
                screenWidth * 0.6; // 60% del ancho de la pantalla
            double buttonPadding =
                screenWidth * 0.05; // Ajustar el padding de los botones

            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                backgroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Color(0xFF04F4F0),
                    width: 2,
                  ),
                ),
                title: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF04F4F0).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Ingrese el código de verificación enviado al Correo Registrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF003366), // Azul marino
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                content: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: dialogWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: textFieldWidth,
                        child: TextField(
                          controller: codigoController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF003366), // Azul marino
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: 'CODIGO',
                            hintStyle: TextStyle(
                              color: Color(0xFF003366)
                                  .withOpacity(0.5), // Azul marino
                              fontSize: 16,
                            ),
                            counterStyle: TextStyle(
                              color: Color(0xFF003366)
                                  .withOpacity(0.7), // Azul marino
                            ),
                            filled: true,
                            fillColor: Color(0xFF003366).withOpacity(0.1),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Color(0xFF003366)
                                    .withOpacity(0.5), // Azul marino
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Color(0xFF003366), // Azul marino
                                width: 3,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actionsPadding: EdgeInsets.symmetric(
                  horizontal:
                      buttonPadding, // Asegurando que los botones se ajusten
                  vertical: 20,
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Cancelar
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  15, // Ajustado para hacer el botón más pequeño
                              vertical:
                                  10, // Ajustado para hacer el botón más pequeño
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 14, // Tamaño de letra más pequeño
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Botón Verificar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isVerifying ? null : verificarCodigo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF98FB98),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  15, // Ajustado para hacer el botón más pequeño
                              vertical:
                                  10, // Ajustado para hacer el botón más pequeño
                            ),
                            elevation: 3,
                            shadowColor: Color(0xFF98FB98).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Verificar',
                                  style: TextStyle(
                                    fontSize: 14, // Tamaño de letra más pequeño
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Por favor, verifica tus credenciales.';
      case 'user-not-found':
        return 'No se encontró la cuenta.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'Correo electrónico inválido.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'user-disabled':
        return 'Cuenta deshabilitada.';
      default:
        return 'Error al iniciar sesión.';
    }
  }

  static Future<bool> recoverPassword(
      BuildContext context, String correo) async {
    try {
      // Mostrar el dialogo de carga
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

      // Enviar el correo de recuperación
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);

      // Cerrar el dialogo de carga
      Navigator.of(context, rootNavigator: true).pop();

      // Mostrar mensaje de éxito
      await _showMessageDialog(
        context,
        'Enlace de recuperación enviado. Revisa tu correo.',
        false,
      );

      // Navegar a LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      return true;
    } catch (e) {
      // Cerrar el dialogo de carga si ocurre un error
      Navigator.of(context, rootNavigator: true).pop();

      String errorMessage = 'Error desconocido';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'El correo electrónico no tiene un formato válido.';
            break;
          case 'user-not-found':
            errorMessage = 'El correo no está registrado en el sistema.';
            break;
          case 'network-request-failed':
            errorMessage =
                'No se pudo conectar con el servidor. Verifica tu conexión.';
            break;
          default:
            errorMessage =
                'Ocurrió un error al enviar el enlace. Intenta nuevamente más tarde.';
        }
      } else {
        errorMessage = 'Error: $e';
      }

      await _showMessageDialog(context, errorMessage, true);
      return false;
    }
  }

  static Future<void> sendVerificationEmail(User user) async {
    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        print("Correo de verificación enviado.");
      }
    } catch (e) {
      print("Error al enviar correo de verificación: $e");
    }
  }
}
