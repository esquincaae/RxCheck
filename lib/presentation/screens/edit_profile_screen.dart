import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../viewmodels/edit_profile_viewmodel.dart';

class EditProfileScreen extends StatelessWidget {
  final _email   = TextEditingController();
  final _phone   = TextEditingController();
  final _address = TextEditingController();
  final _picker  = ImagePicker();

  EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditProfileViewModel>();

    // Cargar usuario la primera vez
    if (vm.userData == null && !vm.isLoading) vm.loadUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: vm.isLoading && vm.userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  if (vm.userData != null) ...[
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: vm.userData!.imagen.isNotEmpty
                          ? NetworkImage(vm.userData!.imagen)
                          : null,
                      child: vm.userData!.imagen.isEmpty
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final x = await _picker.pickImage(source: ImageSource.gallery);
                        if (x != null) await vm.updateImage(File(x.path));
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cambiar foto'),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _email..text = vm.userData!.email,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phone..text = vm.userData!.telefono,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _address..text = vm.userData!.direccion,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                    ),
                    const SizedBox(height: 24),
                    vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () => vm.updateProfile(
                              _email.text.trim(),
                              _phone.text.trim(),
                              _address.text.trim(),
                            ),
                            child: const Text('Guardar cambios'),
                          ),
                    if (vm.message != null) ...[
                      const SizedBox(height: 12),
                      Text(vm.message!,
                          style: TextStyle(
                            color: vm.message!.contains('Error') ? Colors.red : Colors.green,
                          )),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}
