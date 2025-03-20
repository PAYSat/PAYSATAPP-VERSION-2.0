import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyectos_flutter/Page/User/Home/HomePageController.dart';

class InformacionUsuarioPage extends StatefulWidget {
  const InformacionUsuarioPage({super.key});

  @override
  _InformacionUsuarioPageState createState() => _InformacionUsuarioPageState();
}

class _InformacionUsuarioPageState extends State<InformacionUsuarioPage> {
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;

  @override
  void initState() {
    super.initState();
    _telefonoController = TextEditingController();
    _correoController = TextEditingController();
  }

  // Método para obtener los datos del usuario
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
            'username': userDoc['nombreUsuario'],
            'pasaporte': userDoc['pasaporte'],
            'telefono': userDoc['telefono'],
            'correo': user.email,
          };
        }
      }
    } catch (e) {
      print("Error obteniendo los datos del usuario: $e");
    }
    return {};
  }

  // Método para actualizar el teléfono y correo
  Future<void> updateUserData(String newPhone, String newEmail) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Actualizando datos en Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'telefono': newPhone,
          'correo': newEmail,
        });

        // Actualizando el correo en FirebaseAuth si es necesario
        if (newEmail != user.email) {
          await user.updateEmail(newEmail);
        }

        // Mostramos mensaje y cerramos sesión
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.greenAccent, width: 2),
              ),
              title: const Text(
                'Datos Actualizados Correctamente',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Has actualizado tu correo. Por favor, inicia sesión nuevamente.',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HomePageController.signOut(
                        context); // Cierra sesión automáticamente
                  },
                  child: Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error al actualizar los datos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Información de Usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text('Error al cargar los datos del usuario'),
            );
          }

          final userData = snapshot.data!;
          _telefonoController.text = userData['telefono'] ?? '';
          _correoController.text = userData['correo'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Formulario unificado
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de Usuario
                        TextFormField(
                          initialValue: userData['username'],
                          decoration: const InputDecoration(
                            labelText: 'Nombre de Usuario',
                            border: OutlineInputBorder(),
                          ),
                          enabled: false, // No editable
                        ),
                        const SizedBox(height: 20),

                        // Pasaporte
                        TextFormField(
                          initialValue: userData['pasaporte'],
                          decoration: const InputDecoration(
                            labelText: 'Pasaporte',
                            border: OutlineInputBorder(),
                          ),
                          enabled: false, // No editable
                        ),
                        const SizedBox(height: 20),

                        // Correo Electrónico
                        TextFormField(
                          controller: _correoController,
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.edit, color: Colors.greenAccent),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                            color: Colors.greenAccent,
                                            width: 2),
                                      ),
                                      title: const Text(
                                        'Actualizar Correo',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: TextField(
                                        controller: _correoController,
                                        decoration: const InputDecoration(
                                          labelText: 'Nuevo Correo Electrónico',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            final newEmail =
                                                _correoController.text;
                                            updateUserData(
                                                _telefonoController.text,
                                                newEmail);
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text('Actualizar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                                color: Colors.greenAccent),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          enabled: true, // Editable
                        ),
                        const SizedBox(height: 20),

                        // Teléfono
                        TextFormField(
                          controller: _telefonoController,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.greenAccent),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(
                                            color: Colors.greenAccent,
                                            width: 2),
                                      ),
                                      title: const Text(
                                        'Actualizar Teléfono',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: TextField(
                                        controller: _telefonoController,
                                        decoration: const InputDecoration(
                                          labelText: 'Nuevo Teléfono',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.phone,
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            final newPhone =
                                                _telefonoController.text;
                                            updateUserData(newPhone,
                                                _correoController.text);
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text('Actualizar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                                color: Colors.greenAccent),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          enabled: true, // Editable
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
