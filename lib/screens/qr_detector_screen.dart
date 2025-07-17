import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import 'edit_profile_screen.dart';
import 'recipe_detail_screen.dart';

class QRDetectorScreen extends StatefulWidget {
  @override
  _QRDetectorScreenState createState() => _QRDetectorScreenState();
}

class _QRDetectorScreenState extends State<QRDetectorScreen> {
  late MobileScannerController cameraController;
  String? qrCode;
  Recipe? recipe;
  int _scannerKey = 0;
  bool _isScanning = false;

  Future<Map<String, dynamic>> _userPrefs() async {
    final SharedPreferences localPrefs = await SharedPreferences.getInstance();
    final userName = localPrefs.getString('nombre') ?? 'Usuario';
    final firstName = userName.split(' ').first;

    return {
      'nombre': firstName,
    };
  }

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
    _userPrefs();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _restartScanner() {
    setState(() {
      cameraController.dispose();
      cameraController = MobileScannerController();
      _isScanning = true;
      qrCode = null;
    });
  }

  void _toggleScanning() {
    if (_isScanning) {
      cameraController.stop();
      setState(() => _isScanning = false);
    } else {
      _restartScanner();
    }
  }

  void _errorQRCodeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Código QR Inválido',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Este código QR no existe en nuestra base de datos.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartScanner();
            },
            child: Text('Cerrar', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
  void _navigateToRecipeDetailOrError(String? qrCode) {
    _errorQRCodeDialog();

    if (qrCode == null || qrCode!.isEmpty) {
      _errorQRCodeDialog();
    }else{
      recipe = Recipe(
        id: 0,
        issue_at: '',
        qr: qrCode ?? '',
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: recipe!),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userPrefs(),
      builder: (context, snapshot) {
        String displayName = 'Usuario';
        if (snapshot.connectionState == ConnectionState.waiting) {
          displayName = 'Cargando...';
        } else if (snapshot.hasError) {
          displayName = 'Error al cargar';
        } else if (snapshot.hasData) {
          displayName = "Bienvenido ${snapshot.data!['nombre']}";
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF1F4F8),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF1F4F8),
            title: Text(
              '$displayName',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfileScreen()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Comprobar QR de la Receta',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 350,
                        height: 350,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _isScanning
                              ? MobileScanner(
                            key: ValueKey(_scannerKey),
                            controller: cameraController,
                            onDetect: (capture) {
                              final barcodes = capture.barcodes;
                              if (barcodes.isNotEmpty) {
                                final code = barcodes.first.rawValue ?? '---';
                                if (qrCode != code) {
                                  setState(() => qrCode = code);
                                  cameraController.stop();
                                  setState(() => _isScanning = false);
                                  _navigateToRecipeDetailOrError(qrCode);

                                }
                              }
                            },
                          )
                              : Container(
                            color: Color(0xFFB5B5B5),
                            child: Center(
                              child: Icon(
                                Icons.qr_code,
                                color: Color(0xFF3C3C3C),
                                size: 100,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScanning ? Colors.red : Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: Icon(
                  _isScanning ? Icons.stop : Icons.camera_alt,
                  color: Colors.white,
                ),
                label: Text(
                  _isScanning ? 'Detener' : 'Validar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _toggleScanning,
              ),
              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
