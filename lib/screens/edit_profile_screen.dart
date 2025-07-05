import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/styles.dart';
import 'select_mode_login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final _secureStorage = const FlutterSecureStorage();
  final picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool _loading = false;
  String? _photoUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          _photoUrl = data['photoUrl'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      String? imageUrl;
      if (_imageFile != null) {
        final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(user.uid).update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        if (imageUrl != null) 'photoUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );

      _loadUserData();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el perfil')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Editar Perfil'),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            // Imagen y botón arriba, fijo
            SizedBox(
              width: 160.w,
              height: 160.w,
              child: ClipOval(
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : (_photoUrl != null && _photoUrl!.isNotEmpty)
                    ? Image.network(_photoUrl!, fit: BoxFit.cover)
                    : SvgPicture.asset(
                  'assets/images/Default_Avatar.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            TextButton.icon(
              onPressed: _loading ? null : _pickImage,
              icon: Icon(MdiIcons.camera, color: AppColors.primary),
              label: Text('Cambiar foto', style: AppTextStyles.linkText),
            ),
            SizedBox(height: 20.h),

            // El formulario ocupa el espacio restante scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: AppDecorations.card,
                  padding: EdgeInsets.all(16.r),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        CustomInputField(
                          label: 'Nombre',
                          controller: nameController,
                          icon: MdiIcons.account,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu nombre' : null,
                          isDisabled: true,
                        ),

                        CustomInputField(
                          label: 'Correo electrónico',
                          controller: emailController,
                          icon: MdiIcons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu correo' : null,
                        ),
                        
                        CustomInputField(
                          label: 'Teléfono',
                          controller: phoneController,
                          icon: MdiIcons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu teléfono' : null,
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),


            _loading
                ? const CircularProgressIndicator()
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    /*Expanded(
                      child: CustomButton(
                        icon: Icon(MdiIcons.delete),
                        text: 'Eliminar cuenta',
                        backgroundColor: AppColors.error,
                        onPressed: _deleteAccount,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),*/
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CustomButton(
                        icon: Icon(MdiIcons.logout, color: Colors.white),
                        text: 'Cerrar sesión',
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        borderRadius: 15.r,
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            await _secureStorage.deleteAll();
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => SelectModeLoginScreen()),
                                  (route) => false,
                            );
                          } catch (e) {
                            debugPrint("Error al cerrar sesión: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ocurrió un error al cerrar sesión.")),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10.w,),
                    Expanded(child:  CustomButton(
                        icon: Icon(MdiIcons.update),
                        text: 'Actualizar',
                        onPressed: _updateProfile,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    )


                  ],
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 200.w, // ancho fijo para que no sea tan ancho, ajusta como quieras

                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
