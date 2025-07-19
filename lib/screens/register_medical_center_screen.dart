import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_input_field.dart';
import '../services/auth_service.dart';

class RegisterMedicalCenterScreen extends StatefulWidget {
  @override
  State<RegisterMedicalCenterScreen> createState() => _RegisterMedicalCenterScreenState();
}

class _RegisterMedicalCenterScreenState extends State<RegisterMedicalCenterScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  final TextEditingController rfcController = TextEditingController();
  final TextEditingController nombreFarmaciaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool isLoading = false;
  String error = "";

  @override
  void dispose() {
    rfcController.dispose();
    nombreFarmaciaController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> registerPharmacy() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        error = '';
      });

      try {
        bool result = await AuthService().signUp(
          rfcController.text.trim(), // al no tener curp, se mete el RFC
          ' ',
          nombreFarmaciaController.text.trim(),
          'farmacia', // rol
          emailController.text.trim(),
          passController.text.trim(),
          telefonoController.text.trim(),
          direccionController.text.trim(),
          ' ',
          ' ',
        );

        if (result) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      } catch (e) {
        setState(() {
          error = e.toString();
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.only(top: 140),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/images/Logo_Register_Pharmacy.svg',
                height: 150,
                placeholderBuilder: (context) => const CircularProgressIndicator(),
              ),
              const SizedBox(height: 10),
              const Text(
                'Registro Farmacia',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [

                          // Página 1: Datos farmacia
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                CustomInputField(
                                  controller: rfcController,
                                  label: "RFC",
                                  toUpperCase: true,
                                  icon: Icons.perm_identity_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor el RFC de la farmacia';
                                    }
                                    return null;
                                  },
                                ),
                                CustomInputField(
                                  controller: nombreFarmaciaController,
                                  label: "Nombre de la Farmacia",
                                  icon: Icons.local_pharmacy_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa el nombre de la farmacia';
                                    }
                                    return null;
                                  },
                                ),
                                CustomInputField(
                                  controller: direccionController,
                                  label: "Dirección",
                                  icon: Icons.location_on_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa la dirección';
                                    }
                                    return null;
                                  },
                                ),
                                CustomInputField(
                                  controller: telefonoController,
                                  label: "Teléfono",
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty || value.length != 10) {
                                      return 'Por favor ingresa el teléfono';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.ease,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  ),
                                  child: const Text("Siguiente"),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),

                          // Página 2: Cuenta farmacia
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      _pageController.previousPage(
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.ease,
                                      );
                                    },
                                  ),
                                ),
                                CustomInputField(
                                  controller: emailController,
                                  label: "Correo electrónico",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu correo';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Ingresa un correo válido';
                                    }
                                    return null;
                                  },
                                ),
                                CustomInputField(
                                  controller: passController,
                                  label: "Contraseña",
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu contraseña';
                                    }
                                    if (value.length < 8) {
                                      return 'Debe tener al menos 8 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                CustomInputField(
                                  controller: confirmPassController,
                                  label: "Confirmar Contraseña",
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor confirma tu contraseña';
                                    }
                                    if (value != passController.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                isLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                  onPressed: registerPharmacy,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  ),
                                  child: const Text("Registrar Farmacia"),
                                ),
                                if (error.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text(error, style: const TextStyle(color: Colors.red)),
                                  ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}