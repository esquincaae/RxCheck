import 'package:RxCheck/services/qr_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'medicine_list_screen.dart';
import '../models/recipe.dart';
import '../data/medication.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  String? qrImageUrl;
  bool isLoadingQr = true;
  String? role = '';
  final qrService = QrService();



  @override
  void initState() {
    super.initState();
    loadRole();
    loadQrImage();
    qrImageUrl;
    role;
  }

  Future<void> loadRole() async{
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('role') ?? '';

    print('RECIPEDETAIL - $userRole');
    setState(() {
      role = userRole;
    });
  }

  Future<void> loadQrImage() async {

    String url = await fetchQrImage(widget.recipe.id);
    final SharedPreferences localPrefs = await SharedPreferences.getInstance();
    final userRole = localPrefs.getString('role');

    setState(() {
      qrImageUrl = url;
      role = userRole!;

    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double cardHeightFactor = (role == 'farmacia') ? 0.86 : 0.45;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Detalles de la Receta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        widthFactor: 0.95,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * cardHeightFactor, // 45% de la pantalla
                            minHeight: 300,
                          ),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.blue.shade100),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  const Text(
                                    'Lista de Medicamentos',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: MedicineListScreen(recipe: widget.recipe)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if(role != 'farmacia') ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Muestra este QR en la Farmacia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: qrImageUrl == null
                              ? SizedBox(
                            height: screenHeight * 0.25,
                            child: const Center(child: CircularProgressIndicator()),
                          )
                              : Image.network(
                            qrImageUrl!,
                            height: screenHeight * 0.25,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
