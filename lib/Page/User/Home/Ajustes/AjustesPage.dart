import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  Future<Map<String, dynamic>> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return {
            'nombres': userDoc['nombres'] ?? 'No disponible',
            'numeroCuenta': userDoc['numeroCuenta'] ?? 'No disponible',
            'pasaporte': userDoc['pasaporte'] ?? 'No disponible',
          };
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo los datos del usuario: $e");
    }
    return {};
  }

  void _showAccountDetails(
      BuildContext context, Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountDetailsPage(userData: userData),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(userData['fullName'] ?? ''),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F71),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['nombres'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F71),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showAccountDetails(context, userData),
            child: Row(
              children: const [
                Icon(Icons.remove_red_eye_outlined,
                    color: Color(0xFF1A1F71), size: 20),
                SizedBox(width: 8),
                Text(
                  'Ver datos de la cuenta',
                  style: TextStyle(
                    color: Color(0xFF1A1F71),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1A1F71), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1F71),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF1A1F71),
        ),
        onTap: onTap,
      ),
    );
  }

  String _getInitials(String fullName) {
    List<String> names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            color: Color(0xFF1A1F71),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF1A1F71),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF00F2E5),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error al cargar los datos'));
          }

          final userData = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(userData),
                const SizedBox(height: 16),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Información personal',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Configuración',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Ayuda',
                  onTap: () {},
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      // Reemplaza la ruta de inicio de sesión y elimina todas las rutas anteriores
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Color(0xFF1A1F71),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.logout,
                          color: Color(0xFF1A1F71),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AccountDetailsPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AccountDetailsPage({Key? key, required this.userData})
      : super(key: key);

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F71),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              onPressed: () => Share.share(value),
              color: Colors.grey,
            ),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Datos de cuenta',
          style: TextStyle(
            color: Color(0xFF1A1F71),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF1A1F71),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF00F2E5),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para Transferencias Bancarias',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F71),
                ),
              ),
              const SizedBox(height: 32),
              _buildDetailItem('N° de cuenta', userData['numeroCuenta'] ?? ''),
              _buildDetailItem(
                  'Apellidos y nombres', userData['nombres'] ?? ''),
              _buildDetailItem('Pasaporte', userData['pasaporte'] ?? ''),
              _buildDetailItem('Banco', 'PAYSat'),
              _buildDetailItem('Tipo de cuenta', 'Cuenta de Ahorro '),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final String accountDetails = '''
Banco: Banco PAYSat
Tipo de Cuenta: Cuenta de Ahorro
Nombres: ${userData['nombres']}
Pasaporte: ${userData['pasaporte']}
Número de Cuenta: ${userData['numeroCuenta']}
''';
                    Share.share(accountDetails);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1F71),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF1A1F71),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Compartir datos',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
