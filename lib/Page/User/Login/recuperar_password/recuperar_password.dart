import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Page/User/Login/LoginController.dart';

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({Key? key}) : super(key: key);

  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isEmailValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      isEmailValid = emailRegex.hasMatch(emailController.text);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 228, 248),
        foregroundColor: Colors.black,
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vamos a recuperar tu contraseña',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Campo de entrada de correo
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0), // Color plomo suave
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {});
                    },
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Correo electrónico',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        suffixIcon: isEmailValid
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spacer para empujar el botón hacia abajo
          const Spacer(),

          // Botón Continuar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isEmailValid
                    ? () => LoginController.recoverPassword(
                        context, emailController.text)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEmailValid
                      ? const Color(0xFFFF5E5E) // Rojo cuando está activo
                      : const Color(
                          0xFFE0E0E0), // Gris suave cuando está inactivo
                  foregroundColor: isEmailValid
                      ? const Color(
                          0xFF1E1E2E) // Azul marino cuando está activo
                      : const Color(
                          0xFF9E9E9E), // Gris suave cuando está inactivo
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  disabledForegroundColor: const Color(0xFF9E9E9E),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Padding inferior para evitar el notch
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
