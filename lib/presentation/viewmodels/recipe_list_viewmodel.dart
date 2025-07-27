import 'package:flutter/material.dart';
import '../../application/usecases/fetch_recipes_usecase.dart';
import '../../domain/entities/recipe.dart';

class RecipeListViewModel extends ChangeNotifier {
  final FetchRecipesUseCase _useCase;
  List<Recipe> recipes = [];
  bool isLoading = false;
  String? error;

  RecipeListViewModel(this._useCase);

  Future<void> loadRecipes() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      recipes = await _useCase.execute();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
