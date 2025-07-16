import 'package:flutter/material.dart';
import '../data/recipe.dart';
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
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
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

  Future<void> _handleRefresh() async {
    await loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (recipes.isEmpty) {
      return Center(child: Text('No hay recetas disponibles'));
    }

    return RefreshIndicator(
      color: Colors.blue,
      backgroundColor: Colors.white,
      onRefresh: _handleRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return RecipeCard(recipe: recipes[index]);
        },
      ),
    );
  }
}
