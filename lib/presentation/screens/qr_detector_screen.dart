import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/recipe.dart';
import '../viewmodels/recipe_detail_viewmodel.dart';
import 'recipe_detail_screen.dart';

class QRDetectorScreen extends StatefulWidget {
  const QRDetectorScreen({super.key});

  @override
  State<QRDetectorScreen> createState() => _QRDetectorScreenState();
}

class _QRDetectorScreenState extends State<QRDetectorScreen> {
  late final MobileScannerController _ctrl;
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController(facing: CameraFacing.back);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture cap) {
    if (!_scanning) return;
    final code = cap.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _scanning = false);
    _ctrl.stop();

    final dummyRecipe = Recipe(id: 0, issueAt: '', qrImage: code); // solo QR
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: dummyRecipe)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          if (!_scanning)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(_scanning ? Icons.stop : Icons.qr_code_scanner),
        onPressed: () {
          if (_scanning) {
            _ctrl.stop();
          } else {
            _ctrl.start();
          }
          setState(() => _scanning = !_scanning);
        },
      ),
    );
  }
}
