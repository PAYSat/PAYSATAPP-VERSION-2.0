import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/ListaTarjetaDebito.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/ListaTarjetaCredito.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/RecargarDesdeCuenta.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/SeleccionarPais.dart';

class RecargarDinero extends StatelessWidget {
  const RecargarDinero({Key? key}) : super(key: key);

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SeleccionarPais()),
            );
          },
        ),
        title: const Text(
          '¿Cual es tu opcion de recarga?',
          style: TextStyle(
            color: Color.fromARGB(255, 1, 1, 56),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildOption(
                      context,
                      'Tarjeta débito',
                      'Disponible al instante',
                      Icons.credit_card_outlined,
                    ),
                    _buildOption(
                      context,
                      'Tarjeta de Credito',
                      'Disponible al instante',
                      Icons.credit_card_outlined,
                    ),
                    _buildOption(
                      context,
                      'Cuentas bancarias',
                      'Desde cualquier banco',
                      Icons.account_balance,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildAutoRechargeCard(),
        ],
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[100],
          ),
          child: Icon(icon, color: const Color.fromARGB(255, 1, 1, 56)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (title == 'Tarjeta débito') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ListaTarjetaDebito()),
            );
          } else if (title == 'Tarjeta de Credito') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ListaTarjetaCredito()),
            );
          } else if (title == 'Cuentas bancarias') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RecargarDesdeCuentaPage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildAutoRechargeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '¡Ya puedes recargar saldo\nde forma automática!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: null,
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(
                    Color(0xFFFF6B6B),
                  ),
                ),
                child: Text(
                  'Conocer más',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
