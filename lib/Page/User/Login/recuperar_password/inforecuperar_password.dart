import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Page/User/Login/recuperar_password/recuperar_password.dart';

class InfoRecuperarPassword extends StatelessWidget {
  const InfoRecuperarPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.all(0),
                alignment: Alignment.centerLeft,
              ),

              // Spacer
              const Spacer(flex: 1),

              // Lock Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.shade100,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: Colors.amber.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Center(
                child: Text(
                  '¡Estás por crear una nueva contraseña!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E2E),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Center(
                child: Text(
                  'Ten en cuenta que por razones de seguridad cerraremos la sesión en todos los dispositivos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecuperarPasswordPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5E5E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Empezar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
