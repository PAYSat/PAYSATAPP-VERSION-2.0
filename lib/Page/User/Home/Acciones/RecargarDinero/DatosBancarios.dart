import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyectos_flutter/Provider/recargasProvider.dart';
import 'package:share_plus/share_plus.dart';

class DatosBancariosPage extends StatefulWidget {
  const DatosBancariosPage({Key? key}) : super(key: key);

  @override
  State<DatosBancariosPage> createState() => _DatosBancariosPageState();
}

class _DatosBancariosPageState extends State<DatosBancariosPage> {
  final RecargasProvider _recargasProvider = RecargasProvider();
  Map<String, dynamic> _datosBancarios = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatosBancarios();
  }

  Future<void> _loadDatosBancarios() async {
    try {
      final datos = await _recargasProvider.GetDatosBancarios();
      setState(() {
        _datosBancarios = datos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _compartirDatos() async {
    final String textToShare = '''
Datos bancarios para transferencia:

N° de cuenta: ${_datosBancarios['numeroCuenta']}
Nombres y apellidos: ${_datosBancarios['apellidos']} ${_datosBancarios['nombres']}
Cédula: ${_datosBancarios['pasaporte']}
Banco: PAYSat
Tipo de cuenta: Cuenta de PAYSat
''';

    await Share.share(textToShare);
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copiado al portapapeles')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF04F4F0),
        elevation: 0,
        title: const Text(
          'Datos de cuenta',
          style: TextStyle(color: Color.fromARGB(221, 3, 1, 49)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF04F4F0),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Para Transferencias Bancarias',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildInfoRow(
                          'N° de cuenta',
                          _datosBancarios['numeroCuenta'] ?? '',
                        ),
                        _buildInfoRow(
                          'Apellidos y nombres',
                          '${_datosBancarios['apellidos'] ?? ''} ${_datosBancarios['nombres'] ?? ''}',
                        ),
                        _buildInfoRow(
                          'Cédula',
                          _datosBancarios['pasaporte'] ?? '',
                        ),
                        _buildInfoRow(
                          'Banco',
                          'Banco PAYSat',
                        ),
                        _buildInfoRow(
                          'Tipo de cuenta',
                          'Cuenta PAYSat',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _compartirDatos,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.red),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text(
            'Compartir datos',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
