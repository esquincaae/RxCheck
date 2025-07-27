import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'recipe_list_screen.dart';

class HomeScreen extends StatelessWidget {
  Future<String> _firstName() async {
    final prefs = await SharedPreferences.getInstance();
    final full = prefs.getString('nombre') ?? 'Usuario';
    return full.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: FutureBuilder<String>(
        future: _firstName(),
        builder: (_, snap) {
          final name = snap.data ?? 'Usuario';
          return CustomScrollView(slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Color(0xFFF1F4F8),
              title: Text('Bienvenido $name'),
              actions: [
                IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen())), icon: Icon(Icons.person)),
              ],
            ),
            SliverToBoxAdapter(child: RecipeListScreen()),
          ]);
        },
      ),
    );
  }
}
