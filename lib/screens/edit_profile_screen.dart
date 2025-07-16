import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/styles.dart';
import 'select_mode_login_screen.dart';
import '../services/user_service.dart';

final secureStorage = FlutterSecureStorage();

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final picker = ImagePicker();

  final curpController = TextEditingController();
  final primerApellidoController = TextEditingController();
  final segundoApellidoController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final direccionController = TextEditingController();

  bool _loading = false;
  String? _photoUrl = '';
  File? _imageFile;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _photoUrl;
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    print('Cargando datos del usuario...');

    try{
      final data = await _userService.getUserData();
      if (!mounted) return;
      if (data != null) {
        setState(() {
          nameController.text = data['nombre'] ?? '';
          primerApellidoController.text = data['apellidoPaterno'] ?? '';
          segundoApellidoController.text = data['apellidoMaterno'] ?? '';
          curpController.text = data['curp'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['telefono'] ?? '';
          direccionController.text = data['direccion'] ?? '';
          _photoUrl = data['imagen'] ?? '';
          userRole = data['role'] ?? '';
        });
        print('Datos del usuario cargados correctamente');
      }else{print('Error al cargar datos del usuario');}
    }catch(e){
      print('Error al cargar datos del usuario: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar datos del usuario')),);
    }finally{
      if (mounted) {
        setState(() => _loading = false);
        print('_loading set to false in finally block of _loadUserData');
      }
    }
  }

  Future<void> _pickAndUpdateImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _loading = true; // Mostrar loader al subir la imagen
      });

      final file = File(pickedFile.path);

      final updatedPhotoUrl = await _userService.updateUserImage(file);

      if (updatedPhotoUrl != null) {
        setState(() {
          _photoUrl = updatedPhotoUrl;
          _imageFile = null; // Limpiar el archivo local tras subirlo
          _loading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen actualizada correctamente')),
        );
      } else {
        setState(() {
          _loading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir la imagen')),
        );
      }
    }
  }


  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final success = await _userService.updateUserProfile(
      email: emailController.text.trim(),
      direction: direccionController.text.trim(),
      phone: phoneController.text.trim(),
    );

    setState(() => _loading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      _loadUserData();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el perfil')),
      );
    }
  }



  Future<void> _logout() async {
    await _userService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => SelectModeLoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final usesNavbarButtons = bottomPadding > 0; // Generalmente indica navbar visible

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            
            SizedBox(
              width: 160.w,
              height: 160.w,
              child: ClipOval(
                child: _imageFile != null // Prioridad 1: Si el usuario seleccionó una nueva imagen local
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : (_photoUrl != null && _photoUrl!.isNotEmpty) // Prioridad 2: Si hay una URL de foto de perfil
                    ? CachedNetworkImage(
                  imageUrl: _photoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0, // Indicador más pequeño
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('Error loading image for URL: $url, Error: $error'); // Depuración
                    return SvgPicture.asset( // Muestra el avatar por defecto si hay un error de carga
                      'assets/images/Default_Avatar.svg',
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : SvgPicture.asset( // Prioridad 3: Si no hay imagen local ni URL de foto de perfil
                  'assets/images/Default_Avatar.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            SizedBox(height: 10.h),
            TextButton.icon(
              onPressed: _loading ? null : _pickAndUpdateImage,
              icon: Icon(MdiIcons.camera, color: AppColors.primary),
              label: Text('Cambiar foto', style: AppTextStyles.linkText),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Container(
                decoration: AppDecorations.card,
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomInputField(
                                label: 'Nombre',
                                controller: nameController,
                                icon: MdiIcons.account,
                                isDisabled: true,
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Ingresa tu nombre'
                                    : null,
                              ),
                              if (userRole != 'farmacia') ...[
                                CustomInputField(
                                  label: 'Primer Apellido',
                                  controller: primerApellidoController,
                                  icon: MdiIcons.account,
                                  isDisabled: true,
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Ingresa tu Primer Apellido'
                                      : null,
                                ),
                                CustomInputField(
                                  label: 'Segundo Apellido',
                                  controller: segundoApellidoController,
                                  icon: MdiIcons.account,
                                  isDisabled: true,
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Ingresa tu Segundo Apellido'
                                      : null,
                                ),
                              ],
                              CustomInputField(
                                label: userRole == 'farmacia' ? 'RFC' : 'CURP',
                                controller: curpController,
                                icon: MdiIcons.account,
                                isDisabled: true,
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Ingresa tu CURP'
                                    : null,
                              ),
                              CustomInputField(
                                label: 'Correo electrónico',
                                controller: emailController,
                                icon: MdiIcons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Ingresa tu correo'
                                    : null,
                              ),
                              CustomInputField(
                                label: 'Teléfono',
                                controller: phoneController,
                                icon: MdiIcons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Ingresa tu teléfono'
                                    : null,
                              ),
                              if (userRole == 'farmacia') ...[
                                CustomInputField(
                                  label: 'Dirección',
                                  controller: direccionController,
                                  icon: MdiIcons.directions,
                                  isDisabled: true,
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Ingresa tu dirección'
                                      : null,
                                ),
                                SizedBox(height: 20.h),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      icon: Icon(MdiIcons.accountRemove, color: Colors.white),
                                      text: 'Eliminar Cuenta',
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      onPressed: _logout,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      borderRadius: 15.r,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: CustomButton(
                                      icon: SvgPicture.asset(
                                        'assets/icons/verify.svg', color: Colors.white,
                                      ),
                                      text: 'Activar 2FA',
                                      backgroundColor: Colors.green,
                                      onPressed: _updateProfile,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: usesNavbarButtons ? 40.h : 20.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    icon: Icon(MdiIcons.logout, color: Colors.white),
                    text: 'Cerrar sesión',
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    onPressed: _logout,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    borderRadius: 15.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    icon: Icon(MdiIcons.update),
                    text: 'Actualizar',
                    onPressed: _updateProfile,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
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

