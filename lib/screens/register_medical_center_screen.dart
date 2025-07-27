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
  RegExp regRFC = RegExp(r'^[a-zA-Z0-9]{12,13}$');
  RegExp regCurp = RegExp(r'^[a-zA-Z0-9]{18}$');
  RegExp regMail = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  RegExp regName = RegExp(r'^[a-zA-Z]+$');
  RegExp regNum = RegExp(r'^[0-9]{10}$');
  RegExp regPass = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
  RegExp regDir = RegExp(r'^[a-zA-Z0-9 ]+$');

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
                                      return 'Por favor ingrese el RFC de la farmacia';
                                    }
                                    if (value.length != 12 && value.length != 13) {
                                      return 'Debe constar de 12 o 13 caracteres';
                                    }
                                    if (!regRFC.hasMatch(value)) {
                                      return 'Solo se permiten letras y números';
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
                                    if (value.length < 3) {
                                      return 'Debe constar de al menos 3 caracteres';
                                    }
                                    if (!regName.hasMatch(value)) {
                                      return 'Solo se permiten letras';
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
                                    if (value.length < 3) {
                                      return 'Debe constar de al menos 3 caracteres';
                                    }
                                    if (!regDir.hasMatch(value)) {
                                      return 'Solo se permiten letras y números';
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
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa un numero valido';
                                    }
                                    if (value.length != 10) {
                                      return 'Teléfono debe constar de 10 caracteres';
                                    }
                                    if (!regNum.hasMatch(value)) {
                                      return 'Solo se permiten números';
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
                                    if (!regMail.hasMatch(value)) {
                                      return 'no ingrese caracteres invalidos';
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
                                    if (regPass.hasMatch(value)) {
                                      return 'ingrese una contraseña valida';
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