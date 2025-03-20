import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:path/path.dart' as path;

class RegistroDireccionPage extends StatefulWidget {
  final String uid;

  const RegistroDireccionPage({Key? key, required this.uid}) : super(key: key);

  @override
  _RegistroDireccionPageState createState() => _RegistroDireccionPageState();
}

class _RegistroDireccionPageState extends State<RegistroDireccionPage>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _ubicacionUsuarioController =
      TextEditingController();
  final TextEditingController _direccionDomicilioController =
      TextEditingController();

  // Variables de estado
  File? _pdfFile;
  bool _isLoading = false;
  GoogleMapController? _mapController;
  LatLng _currentLatLng = const LatLng(37.7749, -122.4194);
  String? _pdfPath; // Variable para almacenar la ruta del archivo PDF

  // Variables para animaciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeLocation(); // Verifica los permisos cuando la app se inicia
  }

  Future<void> _initializeLocation() async {
    await checkPermissions();
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

  Future<void> checkPermissions() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      status = await Permission.location.request();
      if (status.isGranted) {
        await _getCurrentLocation();
      } else {
        _handlePermissionDenied(status);
      }
    }
  }

  Future<void> _pickPdf() async {
    try {
      // Usar el directorio de documentos en lugar del general
      String documentsPath = (await getApplicationDocumentsDirectory()).path;

      // Usar FilePicker para seleccionar el archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType
            .custom, // Cambié a 'custom' para asegurarme que se seleccionen tipos específicos
        allowedExtensions: [
          'pdf'
        ], // Asegura que solo se puedan seleccionar archivos PDF
        initialDirectory:
            documentsPath, // Inicia en el directorio de documentos
        onFileLoading: (FilePickerStatus status) {
          print(status);
        },
      );

      // Verificar si se seleccionó un archivo
      if (result != null) {
        String filePath = result.files.single.path!;

        // Verificar la extensión del archivo (aunque ya está limitado por 'allowedExtensions')
        if (filePath.toLowerCase().endsWith('.pdf')) {
          setState(() {
            _pdfFile = File(filePath);
            _pdfPath =
                filePath; // Asegúrate de tener una variable para la ruta del archivo
          });
        } else {
          _showSnackBar("Por favor, seleccione solo archivos PDF.");
        }
      } else {
        _showSnackBar("No se seleccionó ningún archivo.");
      }
    } catch (e) {
      _showSnackBar("Error al seleccionar el archivo: $e");
    }
  }

  // Método para actualizar datos del usuario
  Future<void> _updateUserData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Por favor, completa todos los campos");
      return;
    }

    if (_pdfFile == null) {
      _showSnackBar("Por favor, selecciona un comprobante de servicio básico");
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/SatLogoSplash.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    setState(() => _isLoading = true);

    try {
      String pdfUrl = await _uploadPdf(_pdfFile!);

      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (!doc.exists) {
        throw Exception("El documento no existe");
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'ubicacionActual': _ubicacionUsuarioController.text,
        'comprobanteServicioBasico': pdfUrl,
        'direccionCasa': _direccionDomicilioController.text,
      });

      // Cerrar loading y mostrar éxito
      Navigator.pop(context);
      _showSuccessDialog(context);
    } catch (e) {
      // Cerrar loading y mostrar error
      Navigator.pop(context);
      _showErrorDialog(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF40E0D0), // Solo color turquesa
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 70,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Datos actualizados exitosamente!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF40E0D0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
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
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Método para subir PDF
  Future<String> _uploadPdf(File pdfFile) async {
    // Mostrar loading mientras se sube el archivo PDF
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/SatLogoSplash.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(pdfFile.path)}';
      Reference ref = FirebaseStorage.instance.ref().child('pdfs/$fileName');
      UploadTask uploadTask = ref.putFile(pdfFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Cerrar el loading dialog
      Navigator.pop(context);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // Cerrar el loading dialog en caso de error
      Navigator.pop(context);
      throw Exception("No se pudo subir el archivo PDF: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = loc.Location();
      final hasPermission = await location.hasPermission();

      if (hasPermission == loc.PermissionStatus.granted) {
        setState(() {
          _isLoading = true;
        });

        final locationData = await location.getLocation();
        final newLatLng =
            LatLng(locationData.latitude!, locationData.longitude!);

        setState(() {
          _currentLatLng = newLatLng; // Actualiza la latitud y longitud
        });

        // Mueve la cámara al nuevo lugar
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(newLatLng),
        );

        await _updateAddressFromCoordinates(newLatLng);
      }
    } catch (e) {
      _showSnackBar('Error al obtener la ubicación: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAddressFromCoordinates(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.locality}, ${place.country}';

        setState(() {
          _ubicacionUsuarioController.text = address;
        });
      }
    } catch (e) {
      _showSnackBar('Error al obtener la dirección: $e');
    }
  }

  void _handlePermissionDenied(PermissionStatus status) async {
    if (await Permission.location.isPermanentlyDenied) {
      _showSnackBar(
        'Permiso denegado permanentemente. Por favor, habilite la ubicación en la configuración.',
      );
      openAppSettings();
    } else {
      _showSnackBar('Se requiere acceso a la ubicación para continuar.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refreshScreen() async {
    setState(() {
      _pdfPath = null; // Puedes reiniciar datos si es necesario
      _ubicacionUsuarioController.clear();
      _direccionDomicilioController.clear();
    });

    await _getCurrentLocation(); // Opcional, vuelve a obtener la ubicación

    // Simulación de carga para UX (puedes eliminar esto en producción)
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ubicacionUsuarioController.dispose();
    _direccionDomicilioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Evitar que el usuario regrese
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            // Header estilizado
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
                'Registro de Dirección',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a237e),
                ),
              ),
            ),
            Expanded(
                child: RefreshIndicator(
              onRefresh: _refreshScreen,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Mapa
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 200,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _currentLatLng,
                                    zoom: 14,
                                  ),
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                    _getCurrentLocation();
                                  },
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  zoomControlsEnabled: true,
                                  markers: {},
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo de ubicación
                            _buildInputField(
                              controller: _ubicacionUsuarioController,
                              label: 'Ubicación Actual',
                              enabled: false,
                              icon: Icons.location_on,
                            ),
                            const SizedBox(height: 20),

                            // Instrucciones
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instrucciones',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Ten a la mano y envía en formato PDF un comprobante de pago de agua, luz, internet o un documento de dirección fiscal como RUC o RIP.",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Botón de selección de PDF
                            _buildStyledButton(
                              onPressed: _pickPdf,
                              text: 'Seleccionar Servicio Básico',
                            ),
                            const SizedBox(height: 20), // Separación común

                            _pdfPath == null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.upload_file_outlined,
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            'No se ha seleccionado ningún archivo',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 15,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.blue[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.blue[700],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Archivo seleccionado:',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _pdfPath!.split('/').last,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.blue[900],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.blue[700],
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _pdfPath =
                                                  null; // Elimina el archivo seleccionado
                                            });
                                          },
                                          tooltip: 'Eliminar selección',
                                        ),
                                      ],
                                    ),
                                  ),

                            const SizedBox(height: 20), // Separación común

                            // Campo de dirección
                            _buildInputField(
                              controller: _direccionDomicilioController,
                              label: 'Dirección del Domicilio',
                            ),
                            const SizedBox(height: 20),

                            // Botón de guardar
                            _buildStyledButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _updateUserData(context),
                              text: 'Guardar Datos',
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es requerido';
          }
          return null;
        },
      ),
    );
  }
}

Widget _buildStyledButton({
  required VoidCallback? onPressed,
  required String text,
  bool isLoading = false,
}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      color: const Color(0xFFFF6347),
      borderRadius: BorderRadius.circular(12),
    ),
    child: MaterialButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading
          ? const CircularProgressIndicator(
              color: Color(0xFF1a237e),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1a237e),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}
