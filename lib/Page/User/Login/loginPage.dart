import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:proyectos_flutter/Page/User/Crear/infoCrearUser.dart';
import 'package:proyectos_flutter/Page/User/Login/recuperar_password/inforecuperar_password.dart';
import 'LoginController.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isUserStored = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isPasswordValid = false;
  final FocusNode _correoFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkIfUserExists();
    _setupAnimations();

    _passwordController.addListener(() {
      setState(() {
        _isPasswordValid = _passwordController.text.length > 6;
      });
    });

    _correoFocusNode.addListener(() {
      if (_correoFocusNode.hasFocus && _isUserStored && !_isLoading) {
        setState(() => _isLoading = true);
        LoginController.authenticateWithBiometrics(context);
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
  }

  void _checkIfUserExists() async {
    String? storedEmail =
        await const FlutterSecureStorage().read(key: 'correo');
    setState(() => _isUserStored = storedEmail != null);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _correoFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: MediaQuery.of(context).padding.top + 30,
              bottom: 30,
            ),
            color: const Color(0xFF04F4F0),
            child: const Text(
              '¡Hola de nuevo!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 11, 4, 89),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          'Inicia sesión en tu cuenta PAYSat',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildLoginForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            controller: _correoController,
            focusNode: _correoFocusNode,
            hintText: 'Correo Electrónico',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          _buildPasswordField(),
          const SizedBox(height: 40),
          _buildActionButtons(),
          const SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Contraseña',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color.fromARGB(255, 168, 167, 176),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 8),
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const InfoRecuperarPassword()),
              );
            },
            child: const Text(
              'Olvidé mi contraseña',
              style: TextStyle(
                color: Color.fromARGB(255, 11, 4, 89),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildLoginButton(),
        if (_isUserStored) ...[
          const SizedBox(height: 20),
          _buildBiometricButton(),
        ],
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _isPasswordValid ? const Color(0xFFFF6347) : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: MaterialButton(
        onPressed: _isPasswordValid
            ? () {
                if (_formKey.currentState!.validate()) {
                  LoginController.login(
                    context,
                    _correoController.text.trim(),
                    _passwordController.text.trim(),
                  );
                }
              }
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Text(
          'Iniciar sesión',
          style: TextStyle(
            color:
                _isPasswordValid ? const Color(0xFF1a237e) : Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6347),
        borderRadius: BorderRadius.circular(12),
      ),
      child: MaterialButton(
        onPressed: () => LoginController.authenticateWithBiometrics(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Text(
          'Ingreso Biometrico',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            '¿Aún no tienes cuenta?',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 20,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InfoCreateUserPage()),
              );
            },
            child: const Text(
              'Regístrate',
              style: TextStyle(
                color: Color(0xFF1a237e),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
