import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificacionesPage extends StatefulWidget {
  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final String uidReceptor = FirebaseAuth.instance.currentUser!.uid;

  // Función para obtener el token FCM desde Firestore
  Future<String?> _getFirebaseTokenFromFirestore() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uidReceptor)
          .get();

      String? fcmToken = userDoc['fcmToken'];
      return fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener el token desde Firestore: $e');
      }
      return null;
    }
  }

  // Función para enviar la notificación push a través de FCM
  Future<void> enviarNotificacionPush(
      String token, String titulo, String descripcion) async {
    const String serverKey =
        'dqWTycr0TuOBmhVi9QHgMH:APA91bGfzPgbPGM1HLFSBOmltgC7a4U5x-iYJDgZdyum3SBK0gSrVRV-2MGSfY6zHxWoG38VuoF81IQzBQ0DhwodDpLdIOxkRs56k3ukNdCwjPMdOqg09K8';
    const String url = 'https://fcm.googleapis.com/fcm/send';

    // Estructura del mensaje
    final Map<String, dynamic> payload = {
      "to": token,
      "notification": {
        "title": titulo,
        "body": descripcion,
      },
    };

    // Realiza la solicitud HTTP a Firebase Cloud Messaging
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'key=$serverKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Notificación enviada');
      } else {
        print('Error al enviar la notificación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar la notificación: $e');
    }
  }

  // Función para crear la notificación en Firestore y enviar la notificación push
  Future<void> crearNotificacion(String titulo, String descripcion) async {
    try {
      // Guarda la notificación en Firestore
      final notificacionRef = FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(uidReceptor)
          .collection('notificaciones')
          .doc();

      await notificacionRef.set({
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': FieldValue.serverTimestamp(),
        'leido': false,
      });

      // Obtén el token FCM del receptor desde Firestore
      String? fcmToken = await _getFirebaseTokenFromFirestore();

      if (fcmToken != null) {
        // Enviar la notificación push
        await enviarNotificacionPush(fcmToken, titulo, descripcion);
      } else {
        print('Token FCM no encontrado');
      }
    } catch (e) {
      print('Error al crear la notificación: $e');
    }
  }

  Future<void> marcarTodasComoLeidas(
      List<QueryDocumentSnapshot> notifications) async {
    var batch = FirebaseFirestore.instance.batch();
    for (var doc in notifications) {
      var docRef = FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(uidReceptor)
          .collection('notificaciones')
          .doc(doc.id);
      batch.update(docRef, {'leido': true});
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection('notificaciones')
                  .doc(uidReceptor)
                  .collection('notificaciones')
                  .get();
              if (snapshot.docs.isNotEmpty) {
                await marcarTodasComoLeidas(snapshot.docs);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .doc(uidReceptor)
            .collection('notificaciones')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Error al cargar las notificaciones.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes notificaciones.'));
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification =
                  notifications[index].data() as Map<String, dynamic>;
              var titulo = notification['titulo'];
              var descripcion = notification['descripcion'];
              var fecha = (notification['fecha'] as Timestamp).toDate();
              var leido = notification['leido'];

              return ListTile(
                title: Text(titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(descripcion),
                    Text('Fecha: ${fecha.toLocal()}'),
                  ],
                ),
                trailing: Icon(
                  leido ? Icons.check : Icons.new_releases,
                  color: leido ? Colors.green : Colors.red,
                ),
                onTap: () async {
                  // Marcar como leída
                  await FirebaseFirestore.instance
                      .collection('notificaciones')
                      .doc(uidReceptor)
                      .collection('notificaciones')
                      .doc(notifications[index].id)
                      .update({'leido': true});
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí es donde crearías una nueva notificación
          crearNotificacion(
              "Nueva Notificación", "Descripción de la notificación");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
