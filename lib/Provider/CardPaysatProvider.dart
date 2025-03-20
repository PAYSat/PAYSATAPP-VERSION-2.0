import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyectos_flutter/Model/TarjetaPaysat.dart';

class CardProviderPaysat with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  CreditCardPaysat? _selectedCard;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  CreditCardPaysat? get selectedCard => _selectedCard;

  void setSelectedCard(CreditCardPaysat card) {
    _selectedCard = card;
    notifyListeners();
  }

  Future<void> showCreateCardDialog(
      BuildContext context, CreditCardPaysat card) async {
    // Definimos los colores personalizados
    final turquoiseColor = Color(0xFF40E0D0); // Color turquesa
    final softTomatoColor = Color(0xFFFF6347).withOpacity(0.8); // Tomate suave

    bool proceed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "AVISO",
            style: TextStyle(
              color: turquoiseColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.credit_card,
                  size: 48,
                  color: turquoiseColor,
                ),
                SizedBox(height: 16),
                Text(
                  "La tarjeta cuesta 35 dólares.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Se le restará esa cantidad de su saldo.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: softTomatoColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: turquoiseColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Confirmar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 5,
        );
      },
    );

    // Si el usuario acepta, proceder con la creación de la tarjeta
    if (proceed == true) {
      await createCardPaysatDirect(context, card);
    }
  }

  Future<void> createCardPaysatDirect(
      BuildContext context, CreditCardPaysat card) async {
    try {
      double userBalance = await getUserBalance();
      print("Saldo obtenido en createCardPaysatDirect: $userBalance");

      if (userBalance >= 35) {
        // Restar 35 dólares del saldo del usuario
        double newBalance = userBalance - 35;
        await updateUserBalance(newBalance);

        // Si el saldo es suficiente, proceder con la creación de la tarjeta
        String userName = await getUserNameAndLastName();
        String cardNumber = generateCardNumber();
        String cvv = generateCVV();
        String expirationDate = generateExpirationDate();

        String uid = FirebaseAuth.instance.currentUser!.uid;

        // Asignar el saldo como 0 por defecto
        final cardWithBalance = CreditCardPaysat(
          id: card.id,
          cardNumber: cardNumber,
          cardHolderName: userName,
          expirationDate: expirationDate,
          cvv: cvv,
          cardType: card.cardType,
          isValid: card.isValid,
          uid: uid,
          saldo: 0.0, // Saldo por defecto en 0
        );

        // Guardamos la tarjeta en Firestore
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('cardsPaysat')
            .add(cardWithBalance.toMap());

        cardWithBalance.id = docRef.id;

        // Crear un estado de solicitud "en trámite"
        await FirebaseFirestore.instance
            .collection('estadoSolicitudTarjetaPAYSat')
            .add({
          'uid': uid,
          'estadoSolicitud': 'Aprobado',
        });

        _selectedCard = cardWithBalance;

        _isLoading = false;
        _successMessage = "Tarjeta creada exitosamente, en trámite.";
        notifyListeners();

        // Mostrar ventana emergente de éxito
        _showSuccessDialog(context);
      } else {
        // Si el saldo es insuficiente, mostrar un diálogo de error
        _isLoading = false;
        _errorMessage =
            "Saldo insuficiente en su cuenta Paysat. Por favor, recargue.";
        notifyListeners();

        // Mostrar ventana emergente de error
        _showErrorDialog(context); // Pasa el contexto aquí
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      // Mostrar ventana emergente de error por cualquier otro fallo
      _showErrorDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    // Definimos los colores personalizados
    final turquoiseColor = Color(0xFF40E0D0);
    final softTomatoColor = Color(0xFFFF6347).withOpacity(0.8);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: turquoiseColor.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: turquoiseColor,
                  size: 64,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '¡Felicidades!',
                style: TextStyle(
                  color: turquoiseColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¡Obtuviste tu',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'TARJETA DE CRÉDITO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: turquoiseColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'PAYSat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: softTomatoColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'con éxito!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Solo cerramos el diálogo
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: turquoiseColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          elevation: 5,
        );
      },
    );
  }

// Función para mostrar la ventana emergente de error
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
              'Hubo un problema al procesar tu solicitud. Por favor, intenta de nuevo o recarga tu cuenta Paysat.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Método para restar el saldo del usuario
  Future<void> updateUserBalance(double newBalance) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Actualizar el saldo del usuario en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'saldo': newBalance,
      });
      print("Saldo actualizado: $newBalance");
    } catch (e) {
      print("Error al actualizar saldo: $e");
    }
  }

  // Método para generar un número de tarjeta aleatorio de 16 dígitos
  String generateCardNumber() {
    Random random = Random();
    String cardNumber = '';
    for (int i = 0; i < 4; i++) {
      cardNumber += random.nextInt(10000).toString().padLeft(4, '0');
    }
    return cardNumber;
  }

  // Método para generar un código CVV aleatorio de 3 dígitos
  String generateCVV() {
    Random random = Random();
    return random.nextInt(900).toString().padLeft(3, '0');
  }

  // Método para generar una fecha de expiración aleatoria (por ejemplo, entre 1 y 5 años en el futuro)
  String generateExpirationDate() {
    Random random = Random();
    int year = DateTime.now().year +
        random.nextInt(5) +
        1; // Año futuro entre 1 y 5 años
    int month = random.nextInt(12) + 1; // Mes aleatorio entre 1 y 12
    return '$month/${year.toString().substring(2)}'; // Formato MM/YY
  }

  // Método para obtener el saldo del usuario
  Future<double> getUserBalance() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Asegúrate de obtener siempre los datos más actualizados desde el servidor
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(GetOptions(source: Source.server));

      if (userSnapshot.exists) {
        // Asegúrate de que el saldo se convierte a double si no lo es
        double balance = userSnapshot['saldo']?.toDouble() ?? 0.0;
        print(
            "Saldo del usuario desde Firestore: $balance"); // Verificación en consola
        return balance;
      } else {
        return 0.0;
      }
    } catch (e) {
      print("Error al obtener saldo: $e");
      return 0.0;
    }
  }

  // Método para obtener el nombre y apellido del usuario
  Future<String> getUserNameAndLastName() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        String nombres = userSnapshot['nombres'] ?? '';
        String apellidos = userSnapshot['apellidos'] ?? '';

        return '$nombres $apellidos';
      } else {
        return 'Usuario no encontrado';
      }
    } catch (e) {
      return 'Error al obtener los datos: $e';
    }
  }

  // Método para obtener solo la tarjeta del usuario logueado
  Future<CreditCardPaysat?> getUserCard() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Consultar Firestore para obtener la tarjeta del usuario logueado
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cardsPaysat')
          .where('uid', isEqualTo: uid)
          .limit(1) // Limitar a una tarjeta
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Obtener la primera tarjeta (suponiendo que solo haya una)
        CreditCardPaysat card = CreditCardPaysat.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>);
        card.id = snapshot.docs.first.id; // Asignar el ID de la tarjeta
        return card;
      } else {
        // Si no se encuentra ninguna tarjeta
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Método para actualizar una tarjeta
  Future<void> updateCard(String cardId, CreditCardPaysat updatedCard) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('cardsPaysat')
          .doc(cardId)
          .update(updatedCard.toMap());

      _isLoading = false;
      _successMessage = "Tarjeta actualizada exitosamente";
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Eliminar tarjeta
  Future<void> deleteCardPaysat(String cardId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('cards').doc(cardId).delete();

      _isLoading = false;
      _successMessage = "Tarjeta eliminada exitosamente";
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Limpiar mensajes
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
