import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:proyectos_flutter/Model/User.dart';
import 'package:proyectos_flutter/Page/User/Crear/infoCrearUser.dart';
import 'package:proyectos_flutter/Provider/UserProvider.dart';
import 'package:country_picker/country_picker.dart';

class CrearUsuarioPage extends StatefulWidget {
  const CrearUsuarioPage({Key? key}) : super(key: key);

  @override
  _CrearUsuarioPageState createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  Country? _selectedCountry;
  bool _isUsernameValid = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Controladores para los campos
  final _usernameController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _pasaporteController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordController = TextEditingController();

  // FocusNodes para manejar el enfoque
  final _telefonoFocusNode = FocusNode();
  final _pasaporteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _pasaporteController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _telefonoFocusNode.dispose();
    _pasaporteFocusNode.dispose();
    super.dispose();
  }

  void _validateUsername() {
    setState(() {
      _isUsernameValid = _usernameController.text.length > 5;
    });
  }

  // Estilo constante para los TextFormField
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: const Color(0xFFF5F7FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 82, 97, 97), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  // Estilo constante para los botones
  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    bool isPrimary = true,
  }) {
    Color buttonColor = isPrimary
        ? (_isUsernameValid ? const Color(0xFFFF6347) : const Color(0xFF94C8C3))
        : Colors.transparent;

    return Container(
      height: 55,
      width: 120,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary
                ? (onPressed == null ? Colors.grey : const Color(0xFF000080))
                : Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) return;

      // Procesamiento de imagen
      File imageFile = File(pickedFile.path);

      // Intentar validar la imagen
      bool isFaceValid = await _validateFace(imageFile);

      setState(() {
        if (isFaceValid) {
          _imageFile = imageFile; // Actualizar con la nueva imagen válida
        } else {
          _imageFile =
              null; // Eliminar cualquier imagen previa si la nueva no es válida
        }
      });
    } catch (e) {
      setState(() {
        _imageFile = null; // En caso de error, eliminar cualquier imagen previa
      });
    }
  }

  Future<bool> _validateFace(File imageFile) async {
    final InputImage inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          enableTracking: true),
    );

    final List<Face> faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();

    if (faces.isEmpty) {
      _showNotification('No se detectó ningún rostro en la imagen', false);
      return false;
    }

    for (Face face in faces) {
      if (face.leftEyeOpenProbability == null ||
          face.rightEyeOpenProbability == null ||
          face.leftEyeOpenProbability! < 0.8 ||
          face.rightEyeOpenProbability! < 0.8) {
        _showNotification(
            'Por favor, asegurate estar en espacio iluminado para  reconocer tu rostro ',
            false);
        return false;
      }

      if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() > 15.0) {
        _showNotification('Por favor, mira directamente a la cámara', false);
        return false;
      }
    }

    _showNotification('VALIDACION DE IDENTIDAD EXITOSA', true);
    return true;
  }

  void _showNotification(String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                isSuccess ? const Color(0xFF40E0D0) : const Color(0xFFFF6347),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? '¡Éxito!' : 'Error',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor:
                      isSuccess ? Color(0xFF40E0D0) : Color(0xFFFF6347),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(15),
        inputDecoration: InputDecoration(
          hintText: 'Buscar país',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFFF5F7FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStep0() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : screenSize.width * 0.1,
          vertical: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'VALIDACIÓN DE IDENTIDAD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 13, 40),
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Necesitamos verificar tu identidad',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          height: isSmallScreen ? 240 : 280,
                          width: isSmallScreen ? 240 : 280,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF04F4F0),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.face_retouching_natural,
                                      size: isSmallScreen ? 60 : 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Captura tu rostro',
                                      style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF04F4F0),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: isSmallScreen ? 28 : 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF04F4F0),
                        size: isSmallScreen ? 18 : 20,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Text(
                        'Asegúrate de tener buena iluminación',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 0 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: isSmallScreen ? 8 : 16),
                  Expanded(
                    child: _buildButton(
                      text: 'Continuar',
                      onPressed: _imageFile != null
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _currentStep++;
                                });
                              }
                            }
                          : null,
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        TextFormField(
          controller: _nombresController,
          autofocus: true, // Coloca el cursor automáticamente aquí
          decoration: _buildInputDecoration('Nombres'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese sus nombres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _apellidosController,
          decoration: _buildInputDecoration('Apellidos'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese sus apellidos';
            }
            return null;
          },
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton(
              text: 'Atrás',
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              isPrimary: false,
            ),
            _buildButton(
              text: 'Continuar',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _currentStep++;
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        FocusScope(
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: [
                TextFormField(
                  controller: _pasaporteController,
                  decoration: _buildInputDecoration('Cédula o Pasaporte'),
                  autofocus:
                      true, // Asegura que este campo sea activado primero
                  keyboardType: TextInputType.number, // Solo permite números
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Restringe a solo dígitos
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _telefonoController,
                  decoration: _buildInputDecoration('Teléfono'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Restringe a solo dígitos
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su número de teléfono';
                    }
                    if (value.length > 10) {
                      return 'El número de teléfono no debe exceder 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButton(
                      text: 'Atrás',
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      isPrimary: false,
                    ),
                    _buildButton(
                      text: 'Continuar',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isValidEmail = false;

  Widget _buildStep3() {
    return Column(
      children: [
        TextFormField(
          controller: _correoController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            labelStyle: const TextStyle(
              color: Color(0xFF757575),
            ),
            hintText: 'ejemplo@correo.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF757575)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF757575)),
            ),
            suffixIcon: _correoController.text.isNotEmpty
                ? Icon(
                    _isValidEmail ? Icons.check : Icons.close,
                    color: _isValidEmail ? Colors.green : Colors.red,
                  )
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                _isValidEmail = false;
                return;
              }

              final emailParts = value.split('@');
              if (emailParts.length != 2) {
                _isValidEmail = false;
                return;
              }

              final domainParts = emailParts[1].split('.');
              String domain = emailParts[1].toLowerCase();

              // Validar que el dominio tenga al menos dos partes y ninguna esté vacía
              bool hasValidDomain = domainParts.length >= 2 &&
                  !domainParts.any((part) => part.isEmpty);

              // Validar el formato general del correo
              bool hasValidFormat = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$',
              ).hasMatch(value);

              // Validar que todas las extensiones sean válidas
              List<String> validExtensions = [
                'com',
                'net',
                'org',
                'edu',
                'gov',
                'co',
                'us',
                'uk'
              ];
              bool allExtensionsValid = domainParts
                  .skip(1)
                  .every((ext) => validExtensions.contains(ext));

              // Validar que las extensiones no se repitan consecutivamente
              bool noRepeatedExtensions = true;
              for (int i = 1; i < domainParts.length - 1; i++) {
                if (domainParts[i] == domainParts[i + 1]) {
                  noRepeatedExtensions = false;
                  break;
                }
              }

              _isValidEmail = hasValidFormat &&
                  hasValidDomain &&
                  allExtensionsValid &&
                  noRepeatedExtensions;
            });
          },
        ),
        const SizedBox(height: 8),
        if (!_isValidEmail && _correoController.text.isNotEmpty)
          const Text(
            'Por favor ingrese un correo electrónico válido',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        const SizedBox(height: 20),
        InkWell(
          onTap: _showCountryPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                if (_selectedCountry != null) ...[
                  Text(_selectedCountry!.flagEmoji),
                  const SizedBox(width: 8),
                  Text(_selectedCountry!.name),
                ] else
                  const Text('Seleccionar País'),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton(
              text: 'Atrás',
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              isPrimary: false,
            ),
            _buildButton(
              text: 'Siguiente',
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _selectedCountry != null &&
                    _isValidEmail) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  if (_selectedCountry == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor seleccione un país'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Map<String, bool> _isPasswordValid = {
    'length': false,
    'uppercase': false,
    'specialChar': false,
    'number': false,
  };

  bool _isFingerprintRegistered = false;

  Widget _buildStep4() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          decoration: _buildInputDecoration('Contraseña').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
          onChanged: (value) {
            setState(() {
              _isPasswordValid = {
                'length': value.length >= 8,
                'uppercase': RegExp(r'[A-Z]').hasMatch(value),
                'specialChar': RegExp(r'[!@#\$&*~]').hasMatch(value),
                'number': RegExp(r'[0-9]').hasMatch(value),
              };
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese una contraseña';
            }
            if (value.length < 8) {
              return 'La contraseña debe tener al menos 8 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordCriteria(
                '- 8 caracteres', _isPasswordValid['length']),
            _buildPasswordCriteria('- Al menos una letra mayúscula',
                _isPasswordValid['uppercase']),
            _buildPasswordCriteria('- Al menos un carácter especial',
                _isPasswordValid['specialChar']),
            _buildPasswordCriteria(
                '- Al menos un número', _isPasswordValid['number']),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: _buildInputDecoration('Repetir Contraseña').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isConfirmPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor confirme su contraseña';
            }
            if (value != _passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFingerprintRegistered
                ? Colors.green.shade500
                : const Color(0xFF04F4F0),
            foregroundColor: Colors.red[200],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
          ),
          onPressed: _isFingerprintRegistered
              ? null
              : () async {
                  bool isFingerprintRegistered =
                      await UserProvider.verifyFingerprint(context);

                  if (isFingerprintRegistered) {
                    setState(() {
                      _isFingerprintRegistered = true;
                    });

                    // Mostrar ventana emergente de éxito
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green.shade500,
                                    size: 64,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Registro Exitoso',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'La huella digital se ha registrado correctamente.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade500,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Aceptar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // Mostrar ventana emergente de error
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade200,
                                    size: 64,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Error de Registro',
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No se pudo registrar la huella digital.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade200,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Aceptar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint,
                size: 32,
                color: Colors.red[200],
              ),
              const SizedBox(width: 12),
              Text(
                _isFingerprintRegistered
                    ? 'Huella registrada'
                    : 'Registrar Huella Digital',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.red[200],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton(
              text: 'Atrás',
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              isPrimary: false,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF000080),
                backgroundColor: (_passwordController.text !=
                            _confirmPasswordController.text ||
                        !_isPasswordValid.values
                            .every((valid) => valid == true))
                    ? Colors
                        .grey // Color gris cuando el botón está deshabilitado
                    : Color(0xFFFF6347), // Color de texto en azul marino
              ),
              onPressed: (!_isFingerprintRegistered ||
                      !_isPasswordValid.values
                          .every((valid) => valid == true) ||
                      _passwordController.text !=
                          _confirmPasswordController.text)
                  ? null // Si no está habilitado, no hace nada
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        Users user = Users(
                          nombres: _nombresController.text,
                          apellidos: _apellidosController.text,
                          pasaporte: _pasaporteController.text,
                          telefono: _telefonoController.text,
                          correo: _correoController.text,
                          password: _passwordController.text,
                          pais: _selectedCountry?.name ?? '',
                          imageUrl: _imageFile?.path,
                          rol: 'usuario',
                          activo: true,
                          saldo: 0.0,
                        );

                        final usersProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        await usersProvider.register(user, context);
                      }
                    },
              child: const Text('Registrarse'), // Texto en el botón
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordCriteria(String text, bool? isValid) {
    return Row(
      children: [
        Icon(
          isValid == true ? Icons.check_circle : Icons.cancel,
          color: isValid == true ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid == true ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const InfoCreateUserPage(),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStep(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'CREACIÓN DE USUARIO',
        style: TextStyle(
          color: Color(0xFF010D28),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF04F4F0),
      elevation: 2,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Color(0xFF010D28),
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const InfoCreateUserPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }
}
