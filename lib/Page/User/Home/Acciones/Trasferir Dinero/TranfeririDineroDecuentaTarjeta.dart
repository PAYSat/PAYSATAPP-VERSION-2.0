import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyectos_flutter/Provider/TransferirDineroProvider.dart';

class TransferirDineroDeCuentaTarjeta extends StatefulWidget {
  const TransferirDineroDeCuentaTarjeta({Key? key}) : super(key: key);

  @override
  State<TransferirDineroDeCuentaTarjeta> createState() =>
      _TransferirDineroDeCuentaTarjetaState();
}

class _TransferirDineroDeCuentaTarjetaState
    extends State<TransferirDineroDeCuentaTarjeta> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Definiendo los colores personalizados
  static const Color turquoise = Color(0xFF04F4F0);
  static const Color softTomato = Color(0xFFFF6347);

  @override
  void initState() {
    super.initState();
    _cargarInformacionUsuario();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _cargarInformacionUsuario() async {
    try {
      final provider = TransferirDineroProvider(context);
      final info = await provider.obtenerInformacionDeUsuarioLogueado();

      // Verificar si el widget sigue montado antes de hacer un setState
      if (mounted) {
        setState(() {
          userInfo = info;
          isLoading = false;
        });
      }
    } catch (e) {
      // Verificar si el widget sigue montado antes de mostrar un Snackbar
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la información: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'A Tarjeta de Credito o Debito',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: turquoise,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userInfo == null
              ? const Center(
                  child: Text('No se pudo cargar la información del usuario'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 20),
                        _buildSaldoCard(),
                        const SizedBox(height: 20),
                        _buildCardInputCard(),
                        const SizedBox(height: 20),
                        _buildAccionesCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Personal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: turquoise,
              ),
            ),
            const Divider(color: turquoise),
            const SizedBox(height: 10),
            _buildInfoRow('Nombres:', userInfo!['nombres']),
            _buildInfoRow('Apellidos:', userInfo!['apellidos']),
            _buildInfoRow('Número de Cuenta:', userInfo!['numeroCuenta']),
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Card(
      elevation: 4,
      color: turquoise,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Saldo Disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${userInfo!['saldo'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInputCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Tarjeta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: turquoise,
              ),
            ),
            const Divider(color: turquoise),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Número de Tarjeta',
                labelStyle: const TextStyle(color: turquoise),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: turquoise, width: 2),
                ),
                prefixIcon: const Icon(Icons.credit_card, color: turquoise),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el número de tarjeta';
                }
                if (value.replaceAll(' ', '').length < 16) {
                  return 'Número de tarjeta inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              decoration: InputDecoration(
                labelText: 'Monto a Transferir',
                labelStyle: const TextStyle(color: turquoise),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: turquoise, width: 2),
                ),
                prefixIcon: const Icon(Icons.attach_money, color: turquoise),
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el monto';
                }
                final monto = double.tryParse(value);
                if (monto == null) {
                  return 'Monto inválido';
                }
                if (monto <= 0) {
                  return 'El monto debe ser mayor a 0';
                }
                if (monto > userInfo!['saldo']) {
                  return 'Saldo insuficiente';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccionesCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    // Mostrar indicador de carga
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    final provider = TransferirDineroProvider(context);
                    String numeroTarjeta =
                        _cardNumberController.text.replaceAll(' ', '');
                    double monto = double.parse(_montoController.text);

                    bool exitoso = await provider.TransferirSaldoATarjeta(
                      context, // Asegúrate de que el contexto esté disponible aquí
                      numeroTarjeta,
                      monto,
                    );

                    // Cerrar el indicador de carga
                    Navigator.pop(context);

                    if (exitoso) {
                      // Limpiar los campos
                      _cardNumberController.clear();
                      _montoController.clear();
                    }
                  } catch (e) {
                    // Cerrar el indicador de carga si hay un error
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: softTomato,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Realizar Transferencia',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: turquoise,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
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
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll(' ', '');
    StringBuffer newText = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        newText.write(' ');
      }
      newText.write(text[i]);
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
