import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyectos_flutter/Model/TarjetaVisa.dart';
import 'package:proyectos_flutter/Provider/recargasProvider.dart';

class ConfirmacionRecargarCredito extends StatefulWidget {
  final CreditCardVisa selectedCard;

  const ConfirmacionRecargarCredito({
    Key? key,
    required this.selectedCard,
  }) : super(key: key);

  @override
  _ConfirmacionRecargarCreditoState createState() =>
      _ConfirmacionRecargarCreditoState();
}

class _ConfirmacionRecargarCreditoState
    extends State<ConfirmacionRecargarCredito> {
  final TextEditingController _amountController = TextEditingController();
  double amount = 0.00;
  final RecargasProvider _recargasProvider = RecargasProvider();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        amount = double.tryParse(_amountController.text) ?? 0.00;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _recargar() async {
    try {
      if (amount > 0) {
        await _recargasProvider.recargarSaldodesdeCredito(
          context,
          widget.selectedCard.id!,
          amount,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monto no válido')),
        );
      }
    } catch (e) {
      // Error handling managed by RecargasProvider
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF40E0D0), // Color turquesa
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Desde tarjeta de Credito',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ingresa el monto ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      Text('💵', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      color: Color(0xFF40E0D0),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      prefixText: '\$',
                      border: InputBorder.none,
                      hintText: '0.00',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Implementar la funcionalidad de ver saldo
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ver saldo disponible ',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.remove_red_eye_outlined,
                            size: 16, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'El monto máximo a recargar es de \$140',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El monto máximo en cuenta es \$1880',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: amount > 0 ? _recargar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9ED4CD),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
