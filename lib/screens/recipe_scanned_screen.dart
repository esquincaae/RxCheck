import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'medicine_list_screen.dart';
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            expandedHeight: 50,
            backgroundColor: const Color(0xFFF1F4F8),
            foregroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 17),
              title: SvgPicture.asset(
                'assets/images/Logo_LogRec',
                height: 24,
              ),
            ),
          ),

          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                elevation: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // alineación horizontal centrada
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12,right: 12, top: 10.0, bottom: 10),
                      child: Text(
                        'Receta PDF',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center, // asegura que el texto se centre si ocupa varias líneas
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                        child: MedicineListScreen(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}