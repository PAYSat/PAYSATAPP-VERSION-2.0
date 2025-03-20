import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Provider/recargasProvider.dart';

class RecargarDesdeCuentaPage extends StatefulWidget {
  const RecargarDesdeCuentaPage({Key? key}) : super(key: key);

  @override
  State<RecargarDesdeCuentaPage> createState() => _RecargarCuentaState();
}

class _RecargarCuentaState extends State<RecargarDesdeCuentaPage> {
  final RecargasProvider _recargasProvider = RecargasProvider();
  final _formKey = GlobalKey<FormState>();
  String _banco = '';
  String _numeroCuenta = '';
  String _tipoCuenta = 'Ahorros';
  double _monto = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF04F4F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000080)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Recarga Banco',
          style: TextStyle(
            color: Color.fromARGB(255, 1, 1, 56),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Banco',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _banco = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Número de Cuenta',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _numeroCuenta = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _tipoCuenta,
                    items: const [
                      DropdownMenuItem(
                        value: 'Ahorros',
                        child: Text('Ahorros'),
                      ),
                      DropdownMenuItem(
                        value: 'Corriente',
                        child: Text('Corriente'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Cuenta',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _tipoCuenta = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(
                        Icons.attach_money,
                        color: Colors.grey,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _monto = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      // Ajustar la llamada al método según la firma correcta
                      await _recargasProvider.recargaSaldoDesdeCuentaBancaria(
                        context,
                        _banco, // String
                        _monto, // double
                        _numeroCuenta, // String
                        _tipoCuenta, // String
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Recarga realizada con éxito')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Recargar',
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
  }
}
