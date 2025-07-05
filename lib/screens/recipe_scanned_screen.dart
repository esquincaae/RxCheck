import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class RecipeScannedScreen extends StatefulWidget {
  final String pdfUrl;

  const RecipeScannedScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<RecipeScannedScreen> createState() => _RecipeScannedScreenState();
}

class _RecipeScannedScreenState extends State<RecipeScannedScreen> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF1F4F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            backgroundColor: backgroundColor,
            foregroundColor: Colors.black,
            elevation: 0,
            title: const Text(
              "Receta Médica",
            ),
          ),
          SliverFillRemaining(
            child: Container(
              color: backgroundColor,
              child: SfPdfViewer.network(
                widget.pdfUrl,
                controller: _pdfViewerController,
                pageLayoutMode: PdfPageLayoutMode.single,
                canShowScrollHead: false,
                canShowScrollStatus: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
