import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:screen_protector/screen_protector.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/styles.dart';
import 'splash_screen.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/two_factor_service.dart';

final secureStorage = FlutterSecureStorage();

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _userService = UserService();
  final _twoFactorService = TwoFactorService();
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
  bool is2FAEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
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
          _photoUrl = data['imagen'] ?? '';
          userRole = data['role'] ?? '';
          is2FAEnabled = (data['is_two_factor_enable'] == 1 ||
                          data['is_two_factor_enable'] == '1');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar datos del usuario')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUpdateImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() => _loading = true);
    final file = File(pickedFile.path);
    final updatedPhotoUrl = await _userService.updateUserImage(file);
    setState(() => _loading = false);
    if (updatedPhotoUrl != null) {
      setState(() => _photoUrl = updatedPhotoUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen actualizada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen')),
      );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Perfil actualizado correctamente' : 'Error al actualizar el perfil'
        )
      ),
    );
    if (success) _loadUserData();
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => SplashScreen()),
      (_) => false,
    );
  }

  Future<void> _deleteAccount() async {
    await _authService.deleteAccount();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => SplashScreen()),
      (_) => false,
    );
  }

  Future<String?> _pedirCodigo(BuildContext context, String title) async {
    final controller = TextEditingController();
    String? result;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Código'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              result = controller.text.trim();
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _activate2FA() async {
    setState(() => _loading = true);
    final qrBytes = await _twoFactorService.setup2FA();
    setState(() => _loading = false);

    if (qrBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error obteniendo QR de autenticación.')),
      );
      return;
    }

    // 1️⃣ Desactivar bloqueo de pantalla segura
    ScreenProtector.preventScreenshotOff();

    // 2️⃣ Mostrar diálogo con QR y botón de descarga
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escanea o descarga el QR'),
        content: Image.memory(qrBytes, width: 200, height: 200),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    // 3️⃣ Volver a activar bloqueo de pantalla segura
    ScreenProtector.preventScreenshotOn();

    // 4️⃣ Pedir y verificar el código como antes
    final code = await _pedirCodigo(context, 'Introduce el código de tu autenticador');
    if (code == null || code.isEmpty) return;

    setState(() => _loading = true);
    final enabled = await _twoFactorService.enable2FA(code);
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        enabled ? '2FA activado correctamente.' : 'Código incorrecto o error al activar 2FA.'
      )),
    );
    if (enabled) _loadUserData();
  }

  Future<void> _disable2FA() async {
    final code = await _pedirCodigo(context, 'Introduce el código para desactivar 2FA');
    if (code == null || code.isEmpty) return;
    setState(() => _loading = true);
    final disabled = await _twoFactorService.disable2FA(code);
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          disabled ? '2FA desactivado correctamente.' : 'Error al desactivar 2FA.'
        )
      ),
    );
    if (disabled) _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final usesNavbarButtons = bottomPadding > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Editar Perfil'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            SizedBox(
              width: 160.w, height: 160.w,
              child: ClipOval(
                child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : (_photoUrl?.isNotEmpty ?? false)
                    ? CachedNetworkImage(
                        imageUrl: _photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (_, __, ___) => SvgPicture.asset('assets/images/Default_Avatar.svg'),
                      )
                    : SvgPicture.asset('assets/images/Default_Avatar.svg'),
              ),
            ),
            SizedBox(height: 10.h),
            TextButton.icon(
              onPressed: _loading ? () {} : () => _pickAndUpdateImage(),
              icon: Icon(MdiIcons.camera),
              label: const Text('Cambiar foto'),
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
                              ),
                              if (userRole != 'farmacia') ...[
                                CustomInputField(
                                  label: 'Primer Apellido',
                                  controller: primerApellidoController,
                                  icon: MdiIcons.account,
                                  isDisabled: true,
                                ),
                                CustomInputField(
                                  label: 'Segundo Apellido',
                                  controller: segundoApellidoController,
                                  icon: MdiIcons.account,
                                  isDisabled: true,
                                ),
                              ],
                              CustomInputField(
                                label: userRole == 'farmacia' ? 'RFC' : 'CURP',
                                controller: curpController,
                                icon: MdiIcons.account,
                                isDisabled: true,
                              ),
                              CustomInputField(
                                label: 'Correo electrónico',
                                controller: emailController,
                                icon: MdiIcons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v!.isEmpty ? 'Ingresa tu correo' : null,
                              ),
                              CustomInputField(
                                label: 'Teléfono',
                                controller: phoneController,
                                icon: MdiIcons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (v) => v!.isEmpty ? 'Ingresa tu teléfono' : null,
                              ),
                              if (userRole == 'farmacia') ...[
                                CustomInputField(
                                  label: 'Dirección',
                                  controller: direccionController,
                                  icon: MdiIcons.directions,
                                  isDisabled: true,
                                ),
                                SizedBox(height: 20.h),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      icon: Icon(MdiIcons.accountRemove),
                                      text: 'Eliminar Cuenta',
                                      backgroundColor: Colors.red,
                                      onPressed: () => _deleteAccount(),
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      borderRadius: 15.r,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: is2FAEnabled
                                      ? CustomButton(
                                          icon: Icon(MdiIcons.shieldOff),
                                          text: 'Desactivar 2FA',
                                          backgroundColor: Colors.redAccent,
                                          onPressed: _loading ? () {} : () => _disable2FA(),
                                          padding: EdgeInsets.symmetric(vertical: 12.h),
                                        )
                                      : CustomButton(
                                          icon: SvgPicture.asset(
                                            'assets/icons/verify.svg', color: Colors.white,
                                          ),
                                          text: 'Activar 2FA',
                                          backgroundColor: Colors.green,
                                          onPressed: _loading ? () {} : () => _activate2FA(),
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
                    icon: Icon(MdiIcons.logout),
                    text: 'Cerrar sesión',
                    backgroundColor: Colors.orange,
                    onPressed: () => _logout(),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    icon: Icon(MdiIcons.update),
                    text: 'Actualizar',
                    onPressed: () => _updateProfile(),
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
