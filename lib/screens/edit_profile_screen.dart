import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  String? _photoUrl;
  File? _imageFile;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    final data = await _userService.getUserData();
    if (data != null) {
      setState(() {
        nameController.text = data['nombre'] ?? '';
        primerApellidoController.text = data['apellidoPaterno'] ?? '';
        segundoApellidoController.text = data['apellidoMaterno'] ?? '';
        curpController.text = data['curp'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['telefono'] ?? '';
        direccionController.text = data['direccion'] ?? '';
        _photoUrl = data['photoUrl'] ?? '';
        userRole = data['role'] ?? '';
      });
    }
    setState(() => _loading = false);
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

    String? uploadedPhotoUrl;
    if (_imageFile != null) {
      uploadedPhotoUrl = await _userService.uploadUserImage(_imageFile!);
    }

    final success = await _userService.updateUserProfile(
      email: emailController.text.trim(),
      direction: direccionController.text.trim(),
      phone: phoneController.text.trim(),
      photoUrl: uploadedPhotoUrl,
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
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: AppDecorations.card,
                  padding: EdgeInsets.all(16.r),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomInputField(
                          label: 'Nombre',
                          controller: nameController,
                          icon: MdiIcons.account,
                          isDisabled: true,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu nombre' : null,
                        ),
                        if (userRole != 'farmacia') ...[
                          CustomInputField(
                            label: 'Primer Apellido',
                            controller: primerApellidoController,
                            icon: MdiIcons.account,
                            isDisabled: true,
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Ingresa tu Primer Apellido' : null,
                          ),
                          CustomInputField(
                            label: 'Segundo Apellido',
                            controller: segundoApellidoController,
                            icon: MdiIcons.account,
                            isDisabled: true,
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Ingresa tu Segundo Apellido' : null,
                          ),
                        ],
                        CustomInputField(
                          label: userRole == 'farmacia' ? 'RFC' : 'CURP',
                          controller: curpController,
                          icon: MdiIcons.account,
                          isDisabled: true,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu CURP' : null,
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
                        if (userRole == 'farmacia') ...[
                          CustomInputField(
                            label: 'Dirección',
                            controller: direccionController,
                            icon: MdiIcons.directions,
                            isDisabled: true,
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Ingresa tu CURP' : null,
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _loading
                ? const CircularProgressIndicator()
                : Row(
              children: [
                Expanded(
                  child: CustomButton(
                    icon: Icon(MdiIcons.logout, color: Colors.white),
                    text: 'Cerrar sesión',
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    onPressed: _logout,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    borderRadius: 15.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    icon: Icon(MdiIcons.update),
                    text: 'Actualizar',
                    onPressed: _updateProfile,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
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

