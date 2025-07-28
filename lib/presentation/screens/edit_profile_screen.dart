import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/edit_profile_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl  = TextEditingController();
  final _picker    = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Disparar la carga:
    Future.microtask(() => context.read<EditProfileViewModel>().loadUser());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditProfileViewModel>();

    if (vm.isLoading && vm.user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF1F4F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // -- rellenar controles la primera vez que ya exista vm.user
    if (vm.user != null && _emailCtrl.text.isEmpty) {
      _emailCtrl.text = vm.user!.email;
      _phoneCtrl.text = vm.user!.telefono;
      _addrCtrl.text  = vm.user!.direccion;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      backgroundColor: const Color(0xFFF1F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // FOTO
            GestureDetector(
              onTap: vm.isLoading ? null : () async {
                final picked = await _picker.pickImage(source: ImageSource.gallery);
                if (picked != null) await vm.updateImage(File(picked.path));
              },
              child: vm.user?.imagen.isNotEmpty == true
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(vm.user!.imagen),
                  )
                : CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    child: SvgPicture.asset(
                      'assets/images/Default_Avatar.svg',
                      width: 120,
                      height: 120,
                    ),
                  ),
            ),
            const SizedBox(height: 24),

            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (v) => v != null && v.contains('@') ? null : 'Correo inválido',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v != null && v.length >= 8 ? null : 'Teléfono inválido',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addrCtrl,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  const SizedBox(height: 24),
                  vm.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (!_form.currentState!.validate()) return;

                            final ok = await vm.updateProfile(
                              email  : _emailCtrl.text.trim(),
                              phone  : _phoneCtrl.text.trim(),
                              address: _addrCtrl.text.trim(),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok ? 'Perfil actualizado correctamente'
                                    : 'El servidor rechazó la petición. Revisa los datos.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Guardar cambios'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
