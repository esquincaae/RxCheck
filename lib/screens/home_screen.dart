import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'edit_profile_screen.dart';
import 'recipe_list_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  Future<Map<String, dynamic>> _userPrefs() async {
    final SharedPreferences localPrefs = await SharedPreferences.getInstance();
    final userName = localPrefs.getString('nombre') ?? 'Usuario';
    final firstName = userName.split(' ').first;

    return {
      'nombre': firstName,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userPrefs(),
        builder: (context, snapshot) {
          String displayName = 'Usuario';
          print('HOME - Snapshot: $snapshot');
          if (snapshot.connectionState == ConnectionState.waiting) {
            displayName = 'Cargando...';
          } else if (snapshot.hasError) {
            displayName = 'Error al cargar';
          } else if (snapshot.hasData) {
            displayName = "Bienvenido " + snapshot.data!['nombre'];
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: false,
                snap: false,
                expandedHeight: 50,
                backgroundColor: const Color(0xFFF1F4F8),
                foregroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 17),
                  title: Text(
                    '$displayName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.86,
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.blue.shade100),
                      ),
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12, top: 10.0, bottom: 10),
                            child: Text(
                              'Historial de Recetas',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                              child: RecipeListScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


            ],
          );
        },
      ),
    );
  }
}
