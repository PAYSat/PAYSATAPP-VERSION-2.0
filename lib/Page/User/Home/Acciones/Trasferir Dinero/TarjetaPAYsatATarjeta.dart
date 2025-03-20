import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectos_flutter/Model/TarjetaPaysat.dart';
import 'package:proyectos_flutter/Provider/CardPaysatProvider.dart';
import 'package:proyectos_flutter/Provider/TransferirDineroProvider.dart';

class TarjetaPaysatATarjeta extends StatefulWidget {
  @override
  _TarjetaPaysatATarjetaState createState() => _TarjetaPaysatATarjetaState();
}

class _TarjetaPaysatATarjetaState extends State<TarjetaPaysatATarjeta> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Define custom colors
  final Color turquoiseColor = Color(0xFF40E0D0);
  final Color softTomatoColor = Color(0xFFFF7F6B);
  final Color blueColor = Color.fromARGB(255, 5, 48, 178);

  Widget _buildCreditCard(CreditCardPaysat card) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blueColor, Color.fromRGBO(4, 40, 180, 1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 4, 3, 3),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Card background design elements
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Card type and chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PAYSAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.credit_card, color: Colors.white, size: 40),
                  ],
                ),
                // Card number
                Text(
                  card.cardNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                ),
                // Card holder name and balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TITULAR',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          card.cardHolderName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SALDO',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '\$${card.saldo?.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Tarjeta Paysat'),
        backgroundColor: turquoiseColor,
      ),
      body: FutureBuilder<CreditCardPaysat?>(
        future: Provider.of<CardProviderPaysat>(context, listen: false).getUserCard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: turquoiseColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No se encontró ninguna tarjeta.'));
          } else {
            CreditCardPaysat? card = snapshot.data;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildCreditCard(card!),
                    SizedBox(height: 30),
                    Text(
                      'Transferir dinero',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Número de tarjeta destino',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: turquoiseColor, width: 2),
                        ),
                        prefixIcon: Icon(Icons.credit_card, color: turquoiseColor),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Monto a transferir',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: turquoiseColor, width: 2),
                        ),
                        prefixIcon: Icon(Icons.attach_money, color: turquoiseColor),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softTomatoColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          String cardNumber = _cardNumberController.text;
                          double amount = double.tryParse(_amountController.text) ?? 0.0;

                          if (cardNumber.isNotEmpty && amount > 0) {
                            Provider.of<TransferirDineroProvider>(context, listen: false)
                                .transferirMonto(context, card, amount);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Por favor, ingrese los datos correctamente.'),
                                backgroundColor: softTomatoColor,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Confirmar Transferencia',
                          style: TextStyle(
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
          }
        },
      ),
    );
  }
}