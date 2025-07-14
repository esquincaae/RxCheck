import 'package:flutter/material.dart';
import '../data/recipe.dart'; // Importa tu fetchRecipes()
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<Recipe> recipes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    try {
      final fetchedRecipes = await fetchRecipes();
      setState(() {
        recipes = fetchedRecipes;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (recipes.isEmpty) {
      return Center(child: Text('No hay recetas disponibles'));
    }

    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {

        return RecipeCard(recipe: recipes[index]);
      },
    );
  }
}
