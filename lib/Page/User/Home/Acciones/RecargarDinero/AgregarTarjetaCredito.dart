import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:proyectos_flutter/Model/TarjetaVisa.dart';
import 'package:proyectos_flutter/Provider/CardVisaProvider.dart';

class AgregarTarjetaCredito extends StatefulWidget {
  const AgregarTarjetaCredito({Key? key}) : super(key: key);

  @override
  _AgregarTarjetaCreditoState createState() => _AgregarTarjetaCreditoState();
}

class _AgregarTarjetaCreditoState extends State<AgregarTarjetaCredito> {
  final _formKey = GlobalKey<FormState>();
  String _cardHolderName = '';
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  int _currentStep = 0;
  final TextEditingController _inputController = TextEditingController();

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Ingresa el nombre del titular de la tarjeta';
      case 1:
        return 'Ingresa el número de tu tarjeta Credito';
      case 2:
        return 'Ingresa la fecha de expiración';
      case 3:
        return 'Ingresa el código de seguridad (CVV)';
      default:
        return '';
    }
  }

  // Validación para el nombre del titular
  String? _validateCardHolder(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre del titular';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      return 'El nombre solo debe contener letras';
    }
    return null;
  }

// Validación del número de tarjeta (solo longitud de 16 dígitos)
  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el número de tarjeta';
    }
    String cleanNumber = value.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length != 16) {
      return 'El número debe tener 16 dígitos';
    }
    // Omite validación Luhn como prueba
    return null;
  }

// Validación de la fecha de expiración (solo formato y año mayor a 2025)
  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la fecha de expiración';
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Formato inválido (MM/YY)';
    }

    int month = int.parse(value.split('/')[0]);
    int year = int.parse(value.split('/')[1]);

    if (month < 1 || month > 12) {
      return 'Mes inválido';
    }
    if (year <= 25) {
      return 'Debe ser un año mayor al 2025';
    }
    return null;
  }

// Validación del CVV (solo longitud de 3 dígitos)
  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el CVV';
    }
    if (!RegExp(r'^\d{3}$').hasMatch(value)) {
      return 'El CVV debe tener 3 dígitos';
    }
    return null;
  }

  void _resetInputField() {
    _inputController.clear();
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildCardHolderInput();
      case 1:
        return _buildCardInput();
      case 2:
        return _buildExpiryDateInput();
      case 3:
        return _buildCVVInput();
      default:
        return Container();
    }
  }

  Widget _buildCardHolderInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _inputController,
        decoration: InputDecoration(
          hintText: 'Nombre del titular',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Colors.red),
        ),
        style: const TextStyle(fontSize: 16),
        textCapitalization: TextCapitalization.words,
        onChanged: (value) {
          setState(() {
            _cardHolderName = value;
          });
        },
        validator: _validateCardHolder,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildCardInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _inputController,
        decoration: const InputDecoration(
          hintText: 'Número de tarjeta',
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          errorStyle: TextStyle(color: Colors.red),
        ),
        style: const TextStyle(fontSize: 16),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
          _CardNumberFormatter(),
        ],
        onChanged: (value) {
          setState(() {
            _cardNumber = value;
          });
        },
        validator: _validateCardNumber,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildExpiryDateInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _inputController,
        decoration: const InputDecoration(
          hintText: 'MM/YY',
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          errorStyle: TextStyle(color: Colors.red),
        ),
        style: const TextStyle(fontSize: 16),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
          _ExpiryDateFormatter(),
        ],
        onChanged: (value) {
          setState(() {
            _expiryDate = value;
          });
        },
        validator: _validateExpiryDate,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildCVVInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _inputController,
        decoration: const InputDecoration(
          hintText: 'CVV',
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          errorStyle: TextStyle(color: Colors.red),
        ),
        style: const TextStyle(fontSize: 16),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        onChanged: (value) {
          setState(() {
            _cvv = value;
          });
        },
        validator: _validateCVV,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
          _resetInputField();
        });
      } else {
        final tarjetaCredito = CreditCardVisa(
          cardNumber: _cardNumber.replaceAll(' ', ''),
          cardHolderName: _cardHolderName,
          expirationDate: _expiryDate,
          cvv: _cvv,
          cardName: "Tarjeta Credito",
          bankProvider: "Banco Ejemplo",
          saldo: 0.0,
          cardType: "credit",
        );

        final cardProvider =
            Provider.of<CardVisaProvider>(context, listen: false);
        cardProvider.AddCardVisaCredito(tarjetaCredito, context,
            cardType: "credit");
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02ECE4),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000080)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Agregar nueva tarjeta',
          style: TextStyle(
            color: Color.fromARGB(255, 1, 1, 56),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getStepTitle(),
              style: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 1, 1, 56),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF495897),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 1, 1, 56),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 30,
                    top: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cardHolderName.isEmpty
                              ? 'TITULAR DE LA TARJETA'
                              : _cardHolderName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _cardNumber.isEmpty
                              ? '**** **** **** ****'
                              : _cardNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 2,
                          ),
                        ),
                        if (_currentStep >= 2) ...[
                          const SizedBox(height: 20),
                          Text(
                            _expiryDate.isEmpty ? 'MM/YY' : _expiryDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 40,
                    child: Container(
                      height: 40,
                      color: const Color(0xFF5B6AB1).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              child: _buildCurrentStep(),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: TextButton(
                onPressed: _nextStep,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF9FD5D1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  _currentStep == 3 ? 'Finalizar' : 'Continuar',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 1, 1, 56),
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

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}
