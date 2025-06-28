import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final TextEditingController nameController = TextEditingController(text: "Juan Pérez");
  final TextEditingController emailController = TextEditingController(text: "juan.perez@email.com");
  final TextEditingController phoneController = TextEditingController(text: "+52 123 456 7890");

  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget buildInput({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blue) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Color(0xFFE0E3E7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F4F8),
        title: const Text("Editar Perfil", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 0),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      )
                          : SvgPicture.asset(
                        'assets/images/Default_Avatar.svg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(MaterialCommunityIcons.camera, color: Colors.blue),
                    label: const Text("Cambiar foto", style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(height: 40),
                  buildInput(
                    label: "Nombre",
                    controller: nameController,
                    prefixIcon: MaterialCommunityIcons.account,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu nombre';
                      if (value.length < 3) return 'Debe tener al menos 3 caracteres';
                      return null;
                    },
                  ),
                  buildInput(
                    label: "Correo electrónico",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: MaterialCommunityIcons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu correo';
                      if (!value.contains('@')) return 'Ingresa un correo válido';
                      return null;
                    },
                  ),
                  buildInput(
                    label: "Teléfono",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: MaterialCommunityIcons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu teléfono';
                      if (value.length < 10) return 'Número demasiado corto';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Lógica eliminar cuenta
                          },
                          icon: const Icon(MaterialCommunityIcons.delete),
                          label: const Text("Eliminar cuenta"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                              await _storage.deleteAll();
                              if (!mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => LoginScreen()),
                                    (route) => false,
                              );
                            } catch (e) {
                              debugPrint("Error al cerrar sesión: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Ocurrió un error al cerrar sesión.")),
                              );
                            }
                          },
                          icon: const Icon(MaterialCommunityIcons.logout),
                          label: const Text("Cerrar sesión"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Guardar cambios
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(MaterialCommunityIcons.content_save),
                      label: const Text("Guardar cambios"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
