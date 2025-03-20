import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBotProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getChatBotResponse(String message) async {
    message = message.toLowerCase();

    if (_auth.currentUser == null) {
      print("Usuario no autenticado");
      return 'Por favor, inicia sesión primero';
    }

    print("ID de usuario autenticado: ${_auth.currentUser?.uid}");

    // Consulta de saldo de cuenta
    if (message.contains('saldo') && !message.contains('tarjeta')) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (!userDoc.exists) {
          return 'No existe el documento del usuario';
        }

        var userData = userDoc.data() as Map<String, dynamic>;
        if (!userData.containsKey('saldo')) {
          return 'Campo "saldo" no encontrado';
        }

        double saldo = userData['saldo']?.toDouble() ?? 0.0;
        return 'Tu saldo actual es: \$${saldo.toStringAsFixed(2)}';
      } catch (e) {
        print('Error al consultar saldo: $e');
        return 'Error al consultar saldo';
      }
    }

    // Consulta de saldo de tarjeta de crédito
    if ((message.contains('tarjeta') ||
            (message.contains('tarjeta') && message.contains('credito'))) &&
        message.contains('saldo')) {
      try {
        // Primero imprimimos el ID del usuario para verificar
        print("Buscando tarjetas para usuario: ${_auth.currentUser!.uid}");

        QuerySnapshot cardsDocs = await _firestore
            .collection('cardsPaysat')
            .where('uid',
                isEqualTo: _auth.currentUser!.uid) // Cambiado de userId a uid
            .get();

        print("Número de tarjetas encontradas: ${cardsDocs.docs.length}");

        if (cardsDocs.docs.isEmpty) {
          return 'No se encontraron tarjetas registradas para tu usuario';
        }

        String response = 'Información de tus tarjetas:\n\n';
        for (var card in cardsDocs.docs) {
          var cardData = card.data() as Map<String, dynamic>;
          print("Datos de la tarjeta encontrada: $cardData");

          String cardHolderName = cardData['cardHolderName'] ?? 'No disponible';
          String cardNumber = cardData['cardNumber'] ?? 'No disponible';
          String cardType = cardData['cardType'] ?? 'No disponible';
          double saldo = cardData['saldo']?.toDouble() ?? 0.0;

          // Mostrar solo los últimos 4 dígitos de la tarjeta
          String maskedNumber = cardNumber.length > 4
              ? '**** **** **** ' + cardNumber.substring(cardNumber.length - 4)
              : cardNumber;

          response += '👤 Titular: $cardHolderName\n';
          response += '💳 Tarjeta: $maskedNumber\n';
          response += '📎 Tipo: $cardType\n';
          response += '💰 Saldo: \$${saldo.toStringAsFixed(2)}\n\n';
        }

        return response.trim();
      } catch (e) {
        print('Error al consultar tarjetas: $e');
        return 'Error al consultar las tarjetas. Por favor, intenta más tarde.';
      }
    }

    // Respuestas básicas
    if (message.contains('hola')) return '¡Hola! ¿En qué puedo ayudarte?';
    if (message.contains('gracias')) return '¡De nada!';
    if (message.contains('adios')) return '¡Hasta luego!';
    if (message.contains('servicio')) return 'Ofrecemos servicios bancarios';
    if (message.contains('pago')) return '¿Necesitas ayuda con algún pago?';
    if (message.contains('problema')) return 'Por favor, describe el problema';
    if (message.contains('contacto')) return 'Contacto: support@paysat.com';
    if (message.contains('horario')) return 'Horario: Lun-Vie 9:00-18:00';

    return 'Puedo ayudarte con:\n- Consultar saldo de cuenta\n- Consultar saldo de tarjeta de crédito\n- Información de servicios\n- Horarios de atención\n¿Qué necesitas saber?';
  }
}
