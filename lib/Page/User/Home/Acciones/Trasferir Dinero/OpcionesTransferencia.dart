import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/Trasferir%20Dinero/EnviarDineroPage.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/Trasferir%20Dinero/OpcionCuentaTarjeta.dart';
import 'package:proyectos_flutter/Page/User/Home/HomePage.dart';

class Opcionestransferencia extends StatelessWidget {
  const Opcionestransferencia({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Cuando el botón de atrás sea presionado, navegamos hacia HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        return false; // Retorna false para evitar la acción predeterminada del sistema
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF04F4F0),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF000080)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          title: const Text(
            '¿Opciones de transferencia?',
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
                        'Entre cuentas PAYSat',
                        'Disponible al instante',
                        Icons.credit_card_outlined,
                      ),
                      _buildOption(
                        context,
                        'Desde Cuenta o Tarjeta PAYSat',
                        'Disponible al instante',
                        Icons.credit_card_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildAutoRechargeCard(),
          ],
        ),
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
          if (title == 'Entre cuentas PAYSat') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EnviarDineroPage()),
            );
          } else if (title == 'Desde Cuenta o Tarjeta PAYSat') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const OpcionCuentaTarjeta()),
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
