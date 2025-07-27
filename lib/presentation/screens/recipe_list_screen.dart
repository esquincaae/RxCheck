import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/recipe_list_viewmodel.dart';
import '../widgets/recipe_card.dart';

class RecipeListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipeListViewModel>();
    if (vm.isLoading) return Center(child: CircularProgressIndicator());
    if (vm.error != null) return Center(child: Text(vm.error!));
    if (vm.recipes.isEmpty) return Center(child: Text('No hay recetas disponibles'));
    return RefreshIndicator(
      onRefresh: () => vm.loadRecipes(),
      child: ListView.builder(
        itemCount: vm.recipes.length,
        itemBuilder: (_, i) => RecipeCard(recipe: vm.recipes[i]),
      ),
    );
  }
}
