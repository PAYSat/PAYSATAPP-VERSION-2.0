import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/RecargarDineroPage.dart';

class ListBancosPage extends StatelessWidget {
  final Map<String, String> paisSeleccionado;

  const ListBancosPage({
    Key? key,
    required this.paisSeleccionado,
  }) : super(key: key);

  // Función para obtener los bancos según el país
  List<Map<String, String>> getBancosPorPais(String pais) {
    final Map<String, List<Map<String, String>>> bancosPorPais = {
      'Estados Unidos': [
        {'nombre': 'JPMorgan Chase', 'tipo': 'Banco Nacional'},
        {'nombre': 'Bank of America', 'tipo': 'Banco Nacional'},
        {'nombre': 'Wells Fargo', 'tipo': 'Banco Nacional'},
        {'nombre': 'Citibank', 'tipo': 'Banco Internacional'},
      ],
      'China': [
        {
          'nombre': 'Industrial and Commercial Bank of China',
          'tipo': 'Banco Estatal'
        },
        {'nombre': 'China Construction Bank', 'tipo': 'Banco Estatal'},
        {'nombre': 'Agricultural Bank of China', 'tipo': 'Banco Estatal'},
      ],
      'Ecuador': [
        {'nombre': 'Banco Pichincha', 'tipo': 'Banco Privado Nacional'},
        {'nombre': 'Banco Guayaquil', 'tipo': 'Banco Privado Nacional'},
        {'nombre': 'Banco del Pacífico', 'tipo': 'Banco Público'},
        {'nombre': 'Produbanco', 'tipo': 'Banco Privado Nacional'},
      ],
      'España': [
        {'nombre': 'Banco Santander', 'tipo': 'Banco Internacional'},
        {'nombre': 'BBVA', 'tipo': 'Banco Internacional'},
        {'nombre': 'CaixaBank', 'tipo': 'Banco Nacional'},
      ],
    };

    return bancosPorPais[pais] ??
        [
          {'nombre': 'Banco Principal 1', 'tipo': 'Banco Nacional'},
          {'nombre': 'Banco Principal 2', 'tipo': 'Banco Internacional'},
          {'nombre': 'Banco Principal 3', 'tipo': 'Banco Regional'},
        ];
  }

  @override
  Widget build(BuildContext context) {
    final bancos = getBancosPorPais(paisSeleccionado['name']!);

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para el resto
      appBar: AppBar(
        backgroundColor: const Color(0xFF04F4F0), // Turquesa para el título
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 1, 1, 56)), // Azul marino
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              '${paisSeleccionado['flag']} ',
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              '${paisSeleccionado['name']}',
              style: const TextStyle(
                color: Color.fromARGB(255, 1, 1, 56), // Azul marino
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white, // Asegura fondo blanco
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: bancos.length,
                itemBuilder: (context, index) {
                  return _buildBankOption(
                    bancos[index]['nombre']!,
                    bancos[index]['tipo']!,
                    context,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankOption(String nombre, String tipo, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecargarDinero()),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: const Icon(Icons.account_balance,
                color: Color.fromARGB(255, 1, 1, 56)),
          ),
          title: Text(
            nombre,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            tipo,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
