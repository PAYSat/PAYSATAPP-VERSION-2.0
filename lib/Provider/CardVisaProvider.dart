import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Model/TarjetaVisa.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/ListaTarjetaCredito.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/ListaTarjetaDebito.dart';

class CardVisaProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userCollection => 'users';
  String get _cardCollection => 'CardsVisa';

  String? get currentUserId => _auth.currentUser?.uid;

  void _showMessage(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<String> AddCardVisaCredito(
    CreditCardVisa card,
    BuildContext context, {
    required String cardType,
  }) async {
    String message = "";

    try {
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

      // Wait for 4 seconds before proceeding
      await Future.delayed(const Duration(seconds: 4));

      if (currentUserId == null) {
        throw Exception("Usuario no autenticado");
      }

      // Add card type to the card information
      card.cardType = cardType;

      final cardRef = await _firestore
          .collection(_userCollection)
          .doc(currentUserId)
          .collection(_cardCollection)
          .add(card.toMap());

      await _firestore.collection('cardsVisa').add({
        'uid': currentUserId,
        'cardId': cardRef.id,
        'cardNumber': card.cardNumber,
        'cardHolderName': card.cardHolderName,
        'expirationDate': card.expirationDate,
        'cvv': card.cvv,
        'cardName': card.cardName,
        'bankProvider': card.bankProvider,
        'createdAt': FieldValue.serverTimestamp(),
        'saldo': card.saldo,
        'cardType': cardType, // Save card type
      });

      message = "Tarjeta $cardType creada con éxito";
    } catch (e) {
      print("Error al crear tarjeta: $e");
      message = "Error al crear tarjeta: $e";
    } finally {
      // Dismiss the loading dialog
      Navigator.pop(context);

      // Show success or error message in a dialog with custom colors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // Set dialog colors based on success or error
          Color titleColor = message.startsWith("Tarjeta")
              ? Colors.teal
              : Color(0xFFFF6F61); // Soft Tomato
          Color contentColor = message.startsWith("Tarjeta")
              ? Colors.teal[100]!
              : Color(0xFFFF6F61).withOpacity(0.7);

          return AlertDialog(
            title: Text(
              message.startsWith("Tarjeta") ? "Éxito" : "Error",
              style: TextStyle(color: titleColor),
            ),
            content: Text(
              message,
              style: TextStyle(color: contentColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  if (message.startsWith("Tarjeta")) {
                    // Navigate to ListaTarjetaDebito if success
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListaTarjetaCredito()),
                    );
                  }
                },
                child: Text('OK', style: TextStyle(color: titleColor)),
              ),
            ],
          );
        },
      );

      // Return the message
      return message;
    }
  }

  Future<String> AddCardVisaDebito(
    CreditCardVisa card,
    BuildContext context, {
    required String cardType,
  }) async {
    String message = "";

    try {
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

      await Future.delayed(Duration(seconds: 4));

      if (currentUserId == null) {
        throw Exception("Usuario no autenticado");
      }

      // Add card type to the card information
      card.cardType = cardType;

      final cardRef = await _firestore
          .collection(_userCollection)
          .doc(currentUserId)
          .collection(_cardCollection)
          .add(card.toMap());

      await _firestore.collection('cardsVisa').add({
        'uid': currentUserId,
        'cardId': cardRef.id,
        'cardNumber': card.cardNumber,
        'cardHolderName': card.cardHolderName,
        'expirationDate': card.expirationDate,
        'cvv': card.cvv,
        'cardName': card.cardName,
        'bankProvider': card.bankProvider,
        'createdAt': FieldValue.serverTimestamp(),
        'saldo': card.saldo,
        'cardType': cardType, // Save card type
      });

      message = "Tarjeta $cardType creada con éxito";
    } catch (e) {
      print("Error al crear tarjeta: $e");
      // Set error message if an error occurs
      message = "Error al crear tarjeta: $e";
    } finally {
      // Dismiss the loading dialog
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Círculo con icono
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF03F5E5).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF03F5E5),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título ¡Felicidades!
                  const Text(
                    '¡Felicidades!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mensaje principal
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ),
                      children: [
                        const TextSpan(text: '¡Agregaste tu\n'),
                        TextSpan(
                          text: message.contains('débito')
                              ? 'TARJETA DE DÉBITO'
                              : 'TARJETA DE CRÉDITO',
                          style: const TextStyle(
                            color: Color(0xFF03F5E5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: '\nPAYSat'),
                        const TextSpan(text: '\ncon éxito!'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón OK
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (message.startsWith("Tarjeta")) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ListaTarjetaDebito(),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF03F5E5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
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
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      // Return the message
      return message;
    }
  }

  Future<List<CreditCardVisa>> getCardsVisaDebito(
      {String? bankNameFilter, String? cardType, BuildContext? context}) async {
    try {
      if (currentUserId == null) {
        throw Exception("Usuario no autenticado");
      }
      var query = _firestore
          .collection('cardsVisa')
          .where('uid', isEqualTo: currentUserId);

      if (bankNameFilter != null) {
        query = query.where('bankProvider', isEqualTo: bankNameFilter);
      }

      if (cardType != null) {
        query = query.where('cardType', isEqualTo: cardType);
      }

      final querySnapshot = await query.get();

      // Convertimos los documentos obtenidos en objetos CreditCardVisa
      List<CreditCardVisa> cards = querySnapshot.docs.map((doc) {
        return CreditCardVisa.fromMap(doc.data(), id: doc.id);
      }).toList();

      // Mostrar mensaje de éxito si se obtuvieron tarjetas
      if (context != null && cards.isNotEmpty) {
        // Mensaje de éxito (si lo necesitas)
      }

      return cards;
    } catch (e) {
      print("Error al obtener tarjetas: $e");
      // Mostrar mensaje de error
      if (context != null) {
        _showMessage(context, "Error al obtener tarjetas: $e", isError: true);
      }
      return [];
    }
  }

  Future<void> deleteCardVisaDebito(String cardId, BuildContext context) async {
    try {
      if (currentUserId == null) {
        throw Exception("Usuario no autenticado");
      }

      // Show the loading dialog
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

      // Perform the delete operations
      await _firestore
          .collection(_userCollection)
          .doc(currentUserId)
          .collection(_cardCollection)
          .doc(cardId)
          .delete();

      await _firestore.collection('cardsVisa').doc(cardId).delete();

      // Dismiss the loading dialog
      Navigator.pop(context);

      // Navigate to the updated card list screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListaTarjetaDebito()),
      );

      notifyListeners();
    } catch (e) {
      // Dismiss the loading dialog in case of an error
      Navigator.pop(context);

      if (kDebugMode) {
        print("Error al eliminar tarjeta: $e");
      }

      // Show error message
      _showMessage(context, "Error al eliminar tarjeta: $e", isError: true);
    }
  }

  Future<void> deleteCardVisaCredito(
      String cardId, BuildContext context) async {
    try {
      if (currentUserId == null) {
        throw Exception("Usuario no autenticado");
      }

      // Show the loading dialog
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

      // Perform the delete operations
      await _firestore
          .collection(_userCollection)
          .doc(currentUserId)
          .collection(_cardCollection)
          .doc(cardId)
          .delete();

      await _firestore.collection('cardsVisa').doc(cardId).delete();

      // Dismiss the loading dialog
      Navigator.pop(context);

      // Navigate to the updated card list screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListaTarjetaCredito()),
      );

      notifyListeners();
    } catch (e) {
      // Dismiss the loading dialog in case of an error
      Navigator.pop(context);

      if (kDebugMode) {
        print("Error al eliminar tarjeta: $e");
      }

      // Show error message
      _showMessage(context, "Error al eliminar tarjeta: $e", isError: true);
    }
  }
}
