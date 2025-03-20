import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Provider/ActividadProvider.dart';

// Definición de colores personalizados
const colorTurquesa = Color(0xFF04F4F0); // Turquesa principal
const colorTurquesaClaro =
    Color.fromARGB(255, 245, 241, 241); // Turquesa claro para fondos
const colorTomate = Color(0xFFFF6347); // Tomate suave para detalles
const colorTomateClaro = Color(0xFFFFE5E0); // Tomate claro para fondos suaves

class ActividadPage extends StatefulWidget {
  const ActividadPage({Key? key}) : super(key: key);

  @override
  _ActividadPageState createState() => _ActividadPageState();
}

class _ActividadPageState extends State<ActividadPage> {
  final Actividadprovider _actividadProvider = Actividadprovider();
  late Future<List<Map<String, dynamic>>?> _transferencias;

  @override
  void initState() {
    super.initState();
    _loadTransferencias();
  }

  void _loadTransferencias() {
    _transferencias = _actividadProvider.getTransferencias();
  }

  Widget _buildTransferCard(Map<String, dynamic> transferencia) {
    final bool esExitoso = transferencia['exitoso'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: colorTurquesa.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              colorTurquesaClaro.withOpacity(0.2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorTomateClaro,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorTomate.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '\$${transferencia['monto']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorTomate,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: esExitoso ? colorTurquesaClaro : colorTomateClaro,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      esExitoso ? Icons.check_circle : Icons.error,
                      color: esExitoso ? colorTurquesa : colorTomate,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Emisor',
                '${transferencia['nombreEmisor']} ${transferencia['apellidoEmisor']}',
                Icons.person_outline,
              ),
              _buildInfoRow(
                'Receptor',
                '${transferencia['nombreReceptor']} ${transferencia['apellidoReceptor']}',
                Icons.person,
              ),
              _buildInfoRow(
                'Fecha',
                _formatDate(transferencia['fecha'].toDate()),
                Icons.calendar_today,
              ),
              _buildInfoRow(
                'Descripción',
                transferencia['descripcion'],
                Icons.description_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorTomate,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorTurquesa.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorTomate.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: colorTomate.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Actividad de Transferencias",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 5, 1, 40),
          ),
        ),
        backgroundColor: colorTurquesa,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 5, 1, 40),
            ),
            onPressed: () {
              setState(() {
                _loadTransferencias();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorTurquesaClaro,
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>?>(
          future: _transferencias,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: colorTomate,
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorMessage(
                "Error al cargar las transferencias:\n${snapshot.error}",
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildErrorMessage("No se encontraron transferencias.");
            }

            return RefreshIndicator(
              color: colorTurquesa,
              backgroundColor: Colors.white,
              onRefresh: () async {
                setState(() {
                  _loadTransferencias();
                });
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => _buildTransferCard(
                  snapshot.data![index],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
