import 'package:flutter/material.dart';
import 'package:proyectos_flutter/Page/User/Crear/CrearUserPage.dart';

class CheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomCheckBox extends StatelessWidget {
  final bool isChecked;
  final Function(bool?) onChanged;

  const CustomCheckBox(
      {Key? key, required this.isChecked, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color.fromARGB(255, 1, 13, 40),
            width: 1.5,
          ),
        ),
        child: isChecked
            ? CustomPaint(
                size: const Size(24, 24),
                painter: CheckmarkPainter(),
              )
            : null,
      ),
    );
  }
}

class InfoCreateUserPage extends StatefulWidget {
  const InfoCreateUserPage({super.key});

  @override
  _InfoCreateUserPageState createState() => _InfoCreateUserPageState();
}

class _InfoCreateUserPageState extends State<InfoCreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.phone_android,
                                size: size.width * 0.3,
                                color: const Color(0xFFFF5252),
                              ),
                              Positioned(
                                top: 0,
                                right: -size.width * 0.04,
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.green,
                                  size: size.width * 0.06,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: -size.width * 0.04,
                                child: Icon(
                                  Icons.favorite,
                                  color: const Color(0xFFFF5252),
                                  size: size.width * 0.06,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.04),
                          Text(
                            '¡El registro es muy simple!',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 13, 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    _buildStep(1, 'Carga tus datos personales', isSmallScreen),
                    SizedBox(height: size.height * 0.02),
                    _buildStep(2, 'Crea una contraseña y valida tu identidad',
                        isSmallScreen),
                    SizedBox(height: size.height * 0.02),
                    _buildStep(
                        3,
                        'Ten a la mano y envía en formato PDF un comprobante de pago de agua, luz, internet o un documento de dirección fiscal como RUC o RIP.',
                        isSmallScreen),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCheckBox(
                      isChecked: _acceptTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          children: const [
                            TextSpan(text: 'Acepto los '),
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: TextStyle(
                                color: Color.fromARGB(255, 1, 13, 40),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' y el '),
                            TextSpan(
                              text: 'Tratamiento de datos personales',
                              style: TextStyle(
                                color: Color.fromARGB(255, 1, 13, 40),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _acceptTerms
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CrearUsuarioPage(),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _acceptTerms
                          ? const Color(0xFFFF5252)
                          : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.015,
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(
                      'Continuar',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 1, 13, 40),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFF5252),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
