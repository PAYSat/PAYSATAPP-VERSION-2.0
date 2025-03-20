import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:proyectos_flutter/Page/User/Home/Tarjetas/Tarjetas.dart';
import 'package:proyectos_flutter/Page/User/Crear/CrearUserPage.dart';
import 'package:proyectos_flutter/Page/User/Crear/infoCrearUser.dart';
import 'package:proyectos_flutter/Page/User/Login/LoginController.dart';
import 'package:proyectos_flutter/Page/User/Login/loginPage.dart';
import 'package:proyectos_flutter/Page/Splash/splashPage.dart';
import 'package:proyectos_flutter/Page/User/Home/HomePage.dart';
import 'package:proyectos_flutter/Page/User/Login/recuperar_password/recuperar_password.dart';
import 'package:proyectos_flutter/Provider/CardVisaProvider.dart';
import 'package:proyectos_flutter/Provider/TransferirDineroProvider.dart';
import 'package:proyectos_flutter/Provider/UserProvider.dart';
import 'package:proyectos_flutter/Provider/CardPaysatProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  const firebaseConfig = FirebaseOptions(
      apiKey: "AIzaSyAZ6rSRSFRWoZH7waU7wOxDsuRaiElr9cw",
      authDomain: "apppaysat-973fc.firebaseapp.com",
      projectId: "apppaysat-973fc",
      storageBucket: "apppaysat-973fc.firebasestorage.app",
      messagingSenderId: "25866980355",
      appId: "1:25866980355:web:2e5e0d2706327835b0d236",
      measurementId: "G-V1KT0HYV39");

  // Inicializa Firebase antes de cualquier otro uso
  await Firebase.initializeApp(options: firebaseConfig);

  // Solicita permisos de usuario
  await _requestPermissions();

  // Configura notificaciones
  await _initializeNotifications();

  // Configura Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Obtén el token de Firebase
  await _getFirebaseToken();

  runApp(const MyApp());
}

// Solicitar permisos
Future<void> _requestPermissions() async {
  // Solicitar permisos de notificaciones
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("Permisos de notificación concedidos");
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("Permisos de notificación denegados");
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print("Permisos provisionales de notificación");
  }

  // Verifica si la plataforma no es web antes de solicitar el permiso de galería
  if (!kIsWeb) {
    PermissionStatus galleryPermission = await Permission.photos.request();
    if (galleryPermission.isGranted) {
      print("Permiso de galería concedido");
    } else {
      print("Permiso de galería denegado");
    }
  } else {
    print("No se solicita permiso de galería en la web.");
  }
}

// Handler para las notificaciones cuando la app está en segundo plano o cerrada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Notificación en segundo plano: ${message.notification!.title}");
  // Aquí puedes personalizar cómo manejar la notificación en segundo plano
}

Future<void> _getFirebaseToken() async {
  try {
    // Obtén el token de Firebase Messaging
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("Firebase Messaging Token: $token");
      // Aquí puedes almacenar o utilizar el token como sea necesario
    } else {
      print("No se pudo obtener el token de Firebase Messaging");
    }
  } catch (e) {
    print("Error al obtener el token: $e");
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CardProviderPaysat()),
        ChangeNotifierProvider(create: (context) => CardVisaProvider()),
        ChangeNotifierProvider<TransferirDineroProvider>(
          create: (context) => TransferirDineroProvider(context),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PAYMENT APP',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/register': (context) => const CrearUsuarioPage(),
          '/recuperar_password': (context) => const RecuperarPasswordPage(),
          '/cardpage': (context) => CardPage(),
          '/infocreate': (context) => const InfoCreateUserPage(),
        },
        home: Builder(
          builder: (context) {
            LoginController.checkLoginStatus(context);
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
