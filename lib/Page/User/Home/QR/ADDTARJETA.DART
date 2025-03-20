import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_provider.dart';

class AddCardPage extends StatelessWidget {
  final _cardNumberController = TextEditingController();
  final _expirationDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Tarjeta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(labelText: 'Número de tarjeta'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _expirationDateController,
              decoration: InputDecoration(labelText: 'Fecha de expiración (MM/YY)'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _cvvController,
              decoration: InputDecoration(labelText: 'CVV'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'ID de Usuario'),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Obtener la instancia del Provider
                final cardProvider = Provider.of<CardProvider>(context, listen: false);

                // Llamar al método validateCard
                cardProvider.validateCard(
                  _cardNumberController.text,
                  _expirationDateController.text,
                  _cvvController.text,
                  _userIdController.text,
                );
              },
              child: Text('Validar y Agregar Tarjeta'),
            ),
            SizedBox(height: 20),
            Consumer<CardProvider>(
              builder: (context, cardProvider, child) {
                if (cardProvider.message.isNotEmpty) {
                  return Text(
                    cardProvider.message,
                    style: TextStyle(
                      color: cardProvider.isValid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
