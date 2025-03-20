import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:proyectos_flutter/Model/User.dart';
import 'package:proyectos_flutter/Provider/UserProvider.dart';

class ActualizarUsuarioPage extends StatefulWidget {
  const ActualizarUsuarioPage({super.key});

  @override
  State<ActualizarUsuarioPage> createState() => _ActualizarUsuarioPageState();
}

class _ActualizarUsuarioPageState extends State<ActualizarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _pasaporteController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  String? _paisSeleccionado;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Obtener la instancia del proveedor de usuarios
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Llamar a `getCurrentUser` para obtener los datos del usuario actual
    final user = await userProvider.getCurrentUser();

    if (user != null) {
      setState(() {
        _nombresController.text = user.nombres;
        _apellidosController.text = user.apellidos;
        _pasaporteController.text = user.pasaporte;
        _telefonoController.text = user.telefono;
        _correoController.text = user.correo;
        _paisSeleccionado = user.pais;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Usuario'),
        backgroundColor: const Color.fromARGB(255, 244, 20, 4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextFormField(_nombresController, 'Nombres'),
                _buildTextFormField(_apellidosController, 'Apellidos'),
                _buildTextFormField(_pasaporteController, 'Pasaporte'),
                _buildTextFormField(_telefonoController, 'Teléfono'),
                _buildTextFormField(_correoController, 'Correo electrónico'),
                _buildCountryPicker(context),
                const SizedBox(height: 20),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return ElevatedButton(
                      onPressed: userProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() &&
                                  _paisSeleccionado != null) {
                                // Verifica si la imagen es nula antes de pasarla
                                final updatedUser = Users(
                                  nombres: _nombresController.text,
                                  apellidos: _apellidosController.text,
                                  pasaporte: _pasaporteController.text,
                                  telefono: _telefonoController.text,
                                  correo: _correoController.text,
                                  pais: _paisSeleccionado,
                                  // Verifica si la imagen es nula
                                  imageUrl: _selectedImage != null
                                      ? _selectedImage!.path
                                      : '',
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 244, 20, 4),
                      ),
                      child: userProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Actualizar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 244, 20, 4)),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 244, 20, 4)),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCountryPicker(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showCountryPicker(
          context: context,
          onSelect: (Country country) {
            setState(() {
              _paisSeleccionado = country.name;
            });
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      child: Text(_paisSeleccionado ?? 'Seleccionar País'),
    );
  }
}
