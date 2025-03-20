import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Actividadprovider {
  Future<List<Map<String, dynamic>>?> getTransferencias() async {
    try {
      // Obtener el usuario autenticado
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      // Obtener transferencias donde el usuario es el emisor
      QuerySnapshot emisorSnapshot = await FirebaseFirestore.instance
          .collection('Transferencias')
          .where('uidEmisor', isEqualTo: firebaseUser.uid)
          .get();

      // Obtener transferencias donde el usuario es el receptor
      QuerySnapshot receptorSnapshot = await FirebaseFirestore.instance
          .collection('Transferencias')
          .where('uidReceptor', isEqualTo: firebaseUser.uid)
          .get();

      // Combinar ambas listas de documentos
      List<QueryDocumentSnapshot> combinedDocs = [
        ...emisorSnapshot.docs,
        ...receptorSnapshot.docs
      ];

      // Verificar si existen transferencias
      if (combinedDocs.isNotEmpty) {
        // Mapear cada documento a un mapa con los campos necesarios
        return combinedDocs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'numeroCuentaEmisor': data['numeroCuentaEmisor'],
            'numeroCuentaReceptor': data['numeroCuentaReceptor'],
            'monto': data['monto'],
            'fecha': data['fecha'],
            'descripcion': data['descripcion'],
            'exitoso': data['exitoso'],
            'uidEmisor': data['uidEmisor'],
            'uidReceptor': data['uidReceptor'],
            'nombreEmisor': data['nombreEmisor'],
            'apellidoEmisor': data['apellidoEmisor'],
            'nombreReceptor': data['nombreReceptor'],
            'apellidoReceptor': data['apellidoReceptor'],
            'correoReceptor': data['correoReceptor'],
            'tipoDeTransferencia': data['tipoDeTransferencia'],
          };
        }).toList();
      } else {
        return null; // No hay transferencias
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener transferencias: $e");
      }
      return null;
    }
  }
}
