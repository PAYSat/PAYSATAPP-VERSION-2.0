import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/ListaBanco.dart';

class SeleccionarPais extends StatefulWidget {
  SeleccionarPais({super.key});

  @override
  State<SeleccionarPais> createState() => _SeleccionarPaisState();
}

class _SeleccionarPaisState extends State<SeleccionarPais> {
  final List<Map<String, String>> paises = [
    // Principales potencias mundiales
    {'name': 'Estados Unidos', 'flag': '🇺🇸'},
    {'name': 'China', 'flag': '🇨🇳'},
    {'name': 'Rusia', 'flag': '🇷🇺'},
    {'name': 'Alemania', 'flag': '🇩🇪'},
    {'name': 'Reino Unido', 'flag': '🇬🇧'},
    {'name': 'Francia', 'flag': '🇫🇷'},
    {'name': 'Japón', 'flag': '🇯🇵'},
    // Países importantes de América Latina
    {'name': 'Brasil', 'flag': '🇧🇷'},
    {'name': 'México', 'flag': '🇲🇽'},
    {'name': 'Argentina', 'flag': '🇦🇷'},
    {'name': 'Colombia', 'flag': '🇨🇴'},
    {'name': 'Chile', 'flag': '🇨🇱'},
    {'name': 'Perú', 'flag': '🇵🇪'},
    {'name': 'Ecuador', 'flag': '🇪🇨'},
    {'name': 'Venezuela', 'flag': '🇻🇪'},
    {'name': 'Uruguay', 'flag': '🇺🇾'},
    {'name': 'Paraguay', 'flag': '🇵🇾'},
    {'name': 'Bolivia', 'flag': '🇧🇴'},
    {'name': 'Panamá', 'flag': '🇵🇦'},
    // Otros países relevantes
    {'name': 'España', 'flag': '🇪🇸'},
    {'name': 'Italia', 'flag': '🇮🇹'},
    {'name': 'India', 'flag': '🇮🇳'},
    {'name': 'Canadá', 'flag': '🇨🇦'},
    {'name': 'Australia', 'flag': '🇦🇺'},
    {'name': 'Corea del Sur', 'flag': '🇰🇷'},
    {'name': 'Arabia Saudita', 'flag': '🇸🇦'},
  ];

  List<Map<String, String>> _filteredPaises = [];

  @override
  void initState() {
    super.initState();
    _filteredPaises = List.from(paises);
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPaises = List.from(paises);
      } else {
        _filteredPaises = paises
            .where((pais) =>
                pais['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Método para manejar el botón de atrás
  Future<bool> _onWillPop() async {
    // Navegar hacia la página principal cuando se presione el botón atrás
    Navigator.pushReplacementNamed(context, '/home');
    return Future.value(
        false); // Evitar el comportamiento predeterminado de volver atrás
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercepta la acción de volver atrás
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 1, 1, 56)),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          title: const Text(
            'Seleccionar País',
            style: TextStyle(
              color: Color.fromARGB(255, 1, 1, 56),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF04F4F0),
          centerTitle: true,
          elevation: 4,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              color: const Color.fromARGB(255, 247, 249, 249),
              child: TextField(
                onChanged: _filterCountries,
                decoration: InputDecoration(
                  hintText: 'Buscar país...',
                  prefixIcon:
                      Icon(Icons.search, color: Color.fromARGB(255, 1, 1, 56)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF40E0D0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF40E0D0), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Color(0xFFF5F5F5),
                child: ListView.builder(
                  itemCount: _filteredPaises.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        tileColor: Colors.white,
                        leading: Text(
                          _filteredPaises[index]['flag'] ?? '',
                          style: TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          _filteredPaises[index]['name'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF000080),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListBancosPage(
                                paisSeleccionado: {
                                  'name': _filteredPaises[index]['name']!,
                                  'flag': _filteredPaises[index]['flag']!
                                },
                              ),
                            ),
                          );
                        },
                        hoverColor: const Color(0xFFFFE5B4),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
