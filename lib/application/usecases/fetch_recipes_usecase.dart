import '../../domain/repositories/recipe_repository.dart';
import '../../domain/entities/recipe.dart';

class FetchRecipesUseCase {
  final RecipeRepository _repo;
  FetchRecipesUseCase(this._repo);
  Future<List<Recipe>> execute() => _repo.fetchRecipes();
}
