import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyectos_flutter/Page/User/ChatBoot/ChatBootPage.dart';
import 'package:proyectos_flutter/Page/User/Home/Ajustes/AjustesPage.dart';
import 'package:proyectos_flutter/Page/User/Home/Tarjetas/Tarjetas.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/Pedir%20Dinero/PedirDineroPage.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/SeleccionarPais.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/Trasferir%20Dinero/OpcionesTransferencia.dart';
import 'package:proyectos_flutter/Page/User/Home/Actividad/ActividadPage.dart';
import 'package:proyectos_flutter/Page/User/Home/HomePageController.dart';
import 'package:proyectos_flutter/Page/User/Login/loginPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final HomePageController _controller = HomePageController();
  late TabController _tabController;
  Map<String, String> _userData = {
    'nombres': '...',
    'apellidos': '...',
    'correo': 'Cargando',
    'saldo': '00.00',
    'numeroCuenta': 'Cargando',
  };
  bool _isBalanceHidden = true;
  bool _isWalletBalanceHidden = true;
  Timer? _timer;
  bool _showSecondPromotion = false;
  double _progressValue = 0.0;
  // ignore: unused_field
  Timer? _progressTimer;

  void _startProgressTimeline() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progressValue += 0.01; // Incremento gradual

        if (_progressValue >= 0.5 && !_showSecondPromotion) {
          _showSecondPromotion = true; // Cambiar a la segunda promoción
        } else if (_progressValue >= 1.0) {
          _progressValue = 0.0; // Reiniciar barra
          _showSecondPromotion = false; // Volver a la primera promoción
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startProgressTimeline();

    _tabController = TabController(length: 5, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _controller.getUserData();
      setState(() => _userData = data['userData'] as Map<String, String>);
    } catch (e) {
      _showErrorSnackbar('Error al cargar datos: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF04F4F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.5),
                ),
                child: Center(
                  child: Text(
                    // Aquí solo mostramos las iniciales del usuario
                    '${_userData['nombres']?.substring(0, 1) ?? ''}${_userData['apellidos']?.substring(0, 1) ?? ''}'
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 1, 1, 60), // Navy blue
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              const SizedBox(width: 10),
              Text(
                _userData['nombres'] != null
                    ? '¡Hola, ${_userData['nombres']?.split(' ')[0]}!'
                    : '¡Hola!',
                style: const TextStyle(
                  color: Color.fromARGB(255, 1, 1, 60), // Navy blue
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  _isBalanceHidden ? '\$ *.**' : '\$ ${_userData['saldo']}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 1, 1, 60), // Navy blue
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Saldo disponible',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 1, 1, 60), // Navy blue
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _isBalanceHidden = !_isBalanceHidden),
                      child: Icon(
                        _isBalanceHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 40,
                        color: const Color.fromARGB(
                            255, 1, 1, 60), // Color tomate suave
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B6B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionButton(
            icon: Icons.add_card,
            label: 'Recargar',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SeleccionarPais()),
            ),
          ),
          _buildQuickActionButton(
            icon: Icons.swap_horiz,
            label: 'Transferir',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Opcionestransferencia()),
            ),
          ),
          _buildQuickActionButton(
            icon: Icons.account_balance_wallet,
            label: 'Pedir',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PedirDineroPage()),
            ),
          ),
          _buildQuickActionButton(
            icon: Icons.payments,
            label: 'Retirar',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
          const SizedBox(height: 8), // Espaciado entre el icono y el texto
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isWalletBalanceHidden
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => setState(
                    () => _isWalletBalanceHidden = !_isWalletBalanceHidden),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Balance',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isWalletBalanceHidden ? 'USDT *.**' : 'USDT 1000.00',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPromotion(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Container(
      key: const ValueKey('card'),
      margin: EdgeInsets.all(size.width * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.width * 0.05,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF04F4F0),
        borderRadius: BorderRadius.circular(size.width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activa tu',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 1, 1, 60), // Navy blue
                  ),
                ),
                Text(
                  'Tarjeta de Crédito',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,

                    color: Color.fromARGB(255, 1, 1, 60), // Navy blue
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Aprovecha los beneficios exclusivos para ti. ¡Hazla tuya ahora!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: Color(0xFF5F5F8A), // Lighter navy blue
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                GestureDetector(
                  onTap: () {
                    // Navigate to CardPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CardPage()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.width * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.06),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Conoce cómo',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF6347), // Soft tomato color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/TarjetaHome.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralPromotion(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Container(
      key: const ValueKey('referral'),
      margin: EdgeInsets.all(size.width * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.width * 0.05,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF04F4F0),
        borderRadius: BorderRadius.circular(size.width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gana dinero por amigo',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold, // Bold text
                    color: const Color.fromARGB(255, 1, 1, 60), // Navy blue
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Comparte el link para obtener grandes beneficios',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18, // Smaller font size
                    color: const Color(0xFF5F5F8A), // Lighter navy blue
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size.width * 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Participar',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6347),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/amigosHome.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectAccess(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accesos directos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAccessButton(
                icon: Icons.receipt_long,
                label: 'Pago de\nservicios',
              ),
              _buildAccessButton(
                icon: Icons.phone_android,
                label: 'Recarga\ncelular',
              ),
              _buildAccessButton(
                icon: Icons.card_giftcard,
                label: 'Canjear\ncupón',
              ),
            ],
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();

                // Mostrar mensaje emergente personalizado
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // El usuario no puede cerrar el diálogo tocando fuera
                  builder: (BuildContext context) {
                    // Cerrar automáticamente después de 2 segundos
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      // Redirigir a la página de login
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    });

                    return Dialog(
                      backgroundColor: Colors.white,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sesión cerrada exitosamente',
                              style: TextStyle(
                                color:
                                    const Color(0xFF04F4F0), // Color turquesa
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } catch (e) {
                // Mostrar mensaje de error
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text(
                        'Error al cerrar sesión: $e',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  },
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.exit_to_app, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudes() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const SizedBox.shrink(); // Si no hay usuario, no mostramos nada
    }

    // Realizamos una consulta una sola vez, usando el Future
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('SolicitudDinero')
          .where('estado',
              isEqualTo: 'pendiente') // Solo solicitudes pendientes
          .where(Filter.or(
            Filter('emisorUid', isEqualTo: currentUser.uid),
            Filter('receptorUid', isEqualTo: currentUser.uid),
          ))
          .get(), // Esto obtiene los datos una sola vez
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text('Error al cargar las solicitudes',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          );
        }

        final solicitudes = snapshot.data?.docs ?? [];

        return Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Text(
                    'Solicitudes de dinero',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800]),
                  ),
                ),
              ),
              if (solicitudes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey, size: 48),
                        SizedBox(height: 8),
                        Text('No tienes solicitudes pendientes',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: solicitudes.length,
                  itemBuilder: (context, index) {
                    final solicitud = solicitudes[index];
                    final data = solicitud.data() as Map<String, dynamic>;
                    final isSender = data['emisorUid'] == currentUser.uid;
                    final estado = data['estado'] ?? 'pendiente';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: isSender
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              child: Icon(
                                  isSender
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: isSender ? Colors.red : Colors.green),
                            ),
                            title: Text(
                              isSender
                                  ? 'Pediste Dinero a : ${data['receptorNombre'] ?? ''}'
                                  : 'De: ${data['emisorNombre'] ?? ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            subtitle: Text(
                              data['razon'] ?? '',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${data['monto'] ?? 0}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                _buildEstadoChip(estado),
                              ],
                            ),
                          ),
                          if (estado == 'pendiente')
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isSender)
                                    ElevatedButton(
                                      onPressed: () =>
                                          _cancelarSolicitud(solicitud.id),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white),
                                      child: const Text('Cancelar'),
                                    )
                                  else ...[
                                    ElevatedButton(
                                      onPressed: () =>
                                          _aceptarSolicitud(solicitud.id),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white),
                                      child: const Text('Aceptar'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _rechazarSolicitud(solicitud.id),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white),
                                      child: const Text('Rechazar'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cancelarSolicitud(String solicitudId) async {
    try {
      await FirebaseFirestore.instance
          .collection('SolicitudDinero')
          .doc(solicitudId)
          .update({'estado': 'cancelada'});
    } catch (e) {
      print('Error al cancelar la solicitud: $e');
    }
  }

  Future<void> _aceptarSolicitud(String solicitudId) async {
    try {
      // Obtener datos de la solicitud
      final solicitudDoc = await FirebaseFirestore.instance
          .collection('SolicitudDinero')
          .doc(solicitudId)
          .get();

      if (!solicitudDoc.exists) {
        throw Exception('No se encontró la solicitud');
      }

      final solicitudData = solicitudDoc.data();
      if (solicitudData == null) return;

      // Obtener el UID del emisor (usuario actual que acepta)
      final emisorUid = FirebaseAuth.instance.currentUser!.uid;
      final receptorUid = solicitudData['emisorUid']; // Usuario que solicitó

      // Obtener el documento del emisor (usuario actual) desde Firestore
      final emisorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(emisorUid)
          .get();

      // Obtener el documento del receptor (quien solicitó el dinero) desde Firestore
      final receptorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receptorUid)
          .get();

      if (!emisorDoc.exists || !receptorDoc.exists) {
        throw Exception('No se encontraron los usuarios en la base de datos');
      }

      final emisorData = emisorDoc.data();
      final receptorData = receptorDoc.data();

      print('============= DATOS DE USUARIOS =============');
      print('Datos del emisor (quien acepta):');
      print(emisorData);
      print('Datos del receptor (quien solicitó):');
      print(receptorData);
      print('===========================================');

      final correoEmisor = emisorData?['correo'];
      final correoReceptor = receptorData?['correo'];

      if (correoEmisor == null ||
          correoEmisor.isEmpty ||
          correoReceptor == null ||
          correoReceptor.isEmpty) {
        throw Exception('Los correos de los usuarios no están disponibles');
      }

      // Mostrar diálogo de confirmación
      bool? confirmacion = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar transferencia'),
            content: Text(
                '¿Estás seguro que quieres enviar \$${solicitudData['monto']} a ${solicitudData['emisorNombre']}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );

      if (confirmacion == true) {
        // Realizar la transacción
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final emisorDoc = await transaction.get(
              FirebaseFirestore.instance.collection('users').doc(emisorUid));

          final receptorDoc = await transaction.get(
              FirebaseFirestore.instance.collection('users').doc(receptorUid));

          // Verificar saldo suficiente
          final saldoActual = emisorDoc.data()?['saldo'] ?? 0;
          final monto = solicitudData['monto'];

          if (saldoActual < monto) {
            throw Exception('No tienes saldo suficiente');
          }

          // Actualizar saldo del emisor (quien acepta)
          transaction
              .update(emisorDoc.reference, {'saldo': saldoActual - monto});

          // Actualizar saldo del receptor (quien solicitó)
          transaction.update(receptorDoc.reference,
              {'saldo': (receptorDoc.data()?['saldo'] ?? 0) + monto});

          // Actualizar estado de la solicitud
          transaction.update(solicitudDoc.reference, {
            'estado': 'aceptada',
            'fechaRespuesta': FieldValue.serverTimestamp()
          });
        });

        final url = Uri.parse(
            'https://us-central1-apppaysat-973fc.cloudfunctions.net/enviarConfirmacionSolicitud');

        final datosCorreo = {
          'correoReceptor': correoReceptor,
          'nombreReceptor': receptorData?['nombres'] ?? '',
          'apellidoReceptor': receptorData?['apellidos'] ?? '',
          'monto': solicitudData['monto'],
          'nombreEmisor': emisorData?['nombres'] ?? '',
          'apellidoEmisor': emisorData?['apellidos'] ?? ''
        };

        if (datosCorreo.values
            .any((value) => value == null || value.toString().isEmpty)) {
          print('Datos faltantes:');
          datosCorreo.forEach((key, value) {
            print('$key: $value');
          });
          throw Exception('Faltan datos necesarios para enviar el correo');
        }

        print('============= DATOS A ENVIAR =============');
        print(datosCorreo);
        print('========================================');

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(datosCorreo),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transferencia realizada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('Error response: ${response.statusCode}');
          print('Error body: ${response.body}');
          throw Exception('Error al enviar la confirmación de la solicitud');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString() == 'No tienes saldo suficiente'
              ? 'No tienes saldo suficiente para realizar esta transferencia'
              : 'Error al procesar la transferencia'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error al aceptar la solicitud: $e');
    }
  }

  Future<void> _rechazarSolicitud(String solicitudId) async {
    try {
      // Mostrar diálogo de confirmación
      bool? confirmacion = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmar rechazo'),
            content: const Text(
                '¿Estás seguro que quieres rechazar esta solicitud?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text('Rechazar'),
              ),
            ],
          );
        },
      );

      if (confirmacion == true) {
        // Actualizar estado de la solicitud
        await FirebaseFirestore.instance
            .collection('SolicitudDinero')
            .doc(solicitudId)
            .update({
          'estado': 'rechazada',
          'fechaRespuesta': FieldValue.serverTimestamp()
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud rechazada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al rechazar la solicitud'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error al rechazar la solicitud: $e');
    }
  }

  Widget _buildChatBoot(BuildContext context) {
    return Positioned(
      bottom: 20 + 197, // Ajuste de 7 cm más
      right: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotPage()),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(height: 10),
              Image.asset(
                'assets/chatBootAvatar.png',
                width: 70,
                height: 70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'completado':
        color = Colors.green;
        break;
      case 'rechazado':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAccessButton({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Evita retroceder
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildQuickActions(),
                    _buildWalletCard(),
                    AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      child: _showSecondPromotion
                          ? _buildReferralPromotion(context)
                          : _buildCardPromotion(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 40),
                      child: Stack(
                        children: [
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Container(
                                height: 5,
                                width: constraints.maxWidth * _progressValue,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF04F4F0), // Turquesa
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildSolicitudes(),
                    _buildDirectAccess(context),
                  ],
                ),
              ),
              Positioned(
                right: 20,
                bottom: 10,
                child: Container(
                  child: _buildChatBoot(context),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabController.index,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 245, 41, 68),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_outlined),
              activeIcon: Icon(Icons.credit_card),
              label: 'Tarjetas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_outlined),
              activeIcon: Icon(Icons.qr_code_scanner),
              label: 'QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Actividad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              activeIcon: Icon(Icons.menu),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) async {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = CardPage();
        break;
      case 3:
        page = const ActividadPage();
        break;
      case 4:
        page = const AjustesPage();
        break;
      default:
        return;
    }

    bool shouldUpdate = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ) ??
        false;

    if (shouldUpdate) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }
}
