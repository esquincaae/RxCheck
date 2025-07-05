import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'recipe_scanned_screen.dart';

class QRDetectorScreen extends StatefulWidget {
  @override
  _QRDetectorScreenState createState() => _QRDetectorScreenState();
}

class _QRDetectorScreenState extends State<QRDetectorScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  String? qrCode;
  bool _isScanning = false; // Controla si la cámara está encendida

  void _errorQRCodeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Código QR Invalido', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
        content: Text('Este codigo QR no existe en nuestra base de datos.', style: TextStyle(color: Colors.black),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cameraController.start(); // Reanuda para otro escaneo
            },
            child: Text('Cerrar', style: TextStyle(color: Colors.blue),),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _toggleScanning() {
    if (_isScanning) {
      cameraController.stop();
    } else {
      cameraController.start();
    }
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F4F8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Escáner QR',
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Color(0xFFF1F4F8),
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
                        controller: cameraController,
                        onDetect: (capture) {
                          final barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty) {
                            final code = barcodes.first.rawValue ?? '---';
                            if (qrCode != code) {
                              setState(() {
                                qrCode = code;
                              });
                              cameraController.stop();
                              setState(() {
                                _isScanning = false;
                              });
                              Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeScannedScreen(pdfUrl: code,)));
                               //_errorQRCodeDialog(); //<-------------- aqui se usa el QR
                            }/*else{

                            }*/
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
            icon: Icon(_isScanning ? Icons.stop : Icons.camera_alt, color: Colors.white,),
            label: Text(_isScanning ? 'Detener' : 'Validar',
              style: TextStyle(fontSize: 16,
              color: _isScanning ? Colors.white : Colors.white,
              fontWeight: FontWeight.bold),

            ),
            onPressed: _toggleScanning,
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

