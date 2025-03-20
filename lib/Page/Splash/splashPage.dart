import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

// CustomClipper para la forma curva
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.80);

    path.cubicTo(size.width * 0.25, size.height * 0.95, size.width * 0.75,
        size.height * 0.95, size.width, size.height * 0.80);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Painter para el patrón de fondo
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final spacing = size.width * 0.1;

    for (var i = 0; i < size.height; i += spacing.toInt()) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    for (var i = 0; i < size.width; i += spacing.toInt()) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            // Fondo con gradiente
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF04F4F0),
                    Color(0xFF03D4D0),
                  ],
                ),
              ),
            ),
            // Patrón de fondo
            Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: BackgroundPatternPainter(),
                size: Size(screenWidth, screenHeight),
              ),
            ),
            // Contenido principal
            Column(
              children: [
                Container(
                  height: screenHeight * 0.45,
                  child: SafeArea(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'PAY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    'Sat',
                                    style: TextStyle(
                                      color: Color(0xFFFF7F6B),
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(duration: 800.ms).move(
                                    duration: 800.ms,
                                    delay: 100.ms,
                                    begin: const Offset(-30, 0),
                                  ),
                              const Text(
                                'E-CONEXION BANK',
                                style: TextStyle(
                                  color: Color(0xFFFF7F6B),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ).animate().fadeIn(duration: 800.ms).move(
                                    duration: 800.ms,
                                    delay: 100.ms,
                                    begin: const Offset(30, 0),
                                  ),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: Hero(
                                tag: 'logo',
                                child: Image.asset(
                                  'assets/criptologo.png',
                                  width: screenWidth * 0.85,
                                  fit: BoxFit.contain,
                                )
                                    .animate()
                                    .fadeIn(duration: 1200.ms)
                                    .scale(
                                      duration: 1000.ms,
                                      begin: const Offset(0.8, 0.8),
                                    )
                                    .shimmer(duration: 1800.ms, delay: 800.ms),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2A9DF4),
                                Color.fromARGB(255, 3, 107, 186),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.08,
                            horizontal: screenWidth * 0.06,
                          ),
                          child: Text(
                            '¡Un banco , en cualquier parte del mundo!',
                            style: TextStyle(
                              fontSize: screenWidth * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms, delay: 400.ms)
                            .move(
                              duration: 800.ms,
                              begin: const Offset(0, 20),
                            ),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'El futuro de tu dinero, hoy ',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'Digitaliza tu dinero , prepaga tu mundo, tu primera VISA PAYSat facil y accesible',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.042,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.08),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6F6F)
                                          .withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/infocreate'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFFFF6F6F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.045,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Registrarme',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 800.ms, delay: 1000.ms)
                                  .scale(
                                    duration: 600.ms,
                                    begin: const Offset(0.9, 0.9),
                                  ),
                              SizedBox(height: screenHeight * 0.03),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '¿Ya tienes cuenta? ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        Navigator.pushNamed(context, '/login'),
                                    child: Text(
                                      'Inicia sesión',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.w600,
                                        color: const Color.fromARGB(
                                            255, 1, 13, 40),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(duration: 800.ms, delay: 1200.ms),
                              SizedBox(height: screenHeight * 0.04),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
