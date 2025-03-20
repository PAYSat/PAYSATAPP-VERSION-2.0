import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:proyectos_flutter/Provider/TransferirDineroProvider.dart';

const Color primaryColor = Color(0xFF04F4F0); // Turquoise
const Color accentColor = Color(0xFFFF6347); // Soft tomato
const Color backgroundColor = Colors.white;
const Color textColor = Color(0xFF424242); // Dark grey for text

class EnviarDineroPage extends StatefulWidget {
  const EnviarDineroPage({super.key});

  @override
  _EnviarDineroPageState createState() => _EnviarDineroPageState();
}

// Rest of the code remains the same, just updating color references
class _EnviarDineroPageState extends State<EnviarDineroPage> {
  TransferirDineroProvider? _controller;
  bool _usuarioBuscado = false;
  bool _hasAccountNumber = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TransferirDineroProvider(context);
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller?.obtenerSaldoUsuarioLogueado();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Entre Cuentas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchSection(),
              if (_usuarioBuscado && _controller?.nombre != null) ...[
                _buildBeneficiaryInfo(),
                _buildTransferAmount(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            'Saldo disponible',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            NumberFormat.currency(locale: 'es', symbol: '\$')
                .format(_controller?.saldoUsuarioLogueado ?? 0.0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _controller?.numeroCuentaController,
            onChanged: (value) {
              setState(() {
                _hasAccountNumber = value.isNotEmpty;
              });
            },
            decoration: InputDecoration(
              labelText: 'Número de cuenta',
              prefixIcon: const Icon(Icons.account_circle, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Ingrese un número de cuenta' : null,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasAccountNumber
                  ? () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _controller?.buscarUsuarioPorNumeroCuenta();
                        setState(() {
                          _usuarioBuscado = _controller?.nombre != null;
                        });
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasAccountNumber
                    ? accentColor // Tomate suave cuando está activo
                    : Colors.grey, // Plomo cuando está inactivo
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Buscar',
                style: TextStyle(
                  fontSize: 16,
                  color: _hasAccountNumber
                      ? const Color(0xFF000080) // Azul marino
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaryInfo() {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beneficiario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 15),
            _buildInfoRow(Icons.person,
                '${_controller?.nombre} ${_controller?.apellidos}'),
            _buildInfoRow(Icons.email, _controller?.correo ?? ''),
            _buildInfoRow(Icons.phone, _controller?.telefono ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferAmount() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: _controller?.montoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto a transferir',
              prefixIcon: const Icon(Icons.attach_money, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Ingrese un monto' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _controller?.descripcionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descripción',
              prefixIcon: const Icon(Icons.description, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Ingrese una descripción' : null,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _controller?.enviarDineroEntreCuentasPaysat();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor, // Using accent color for buttons
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Transferir',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
