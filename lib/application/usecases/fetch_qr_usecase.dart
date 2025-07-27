import '../../domain/repositories/recipe_repository.dart';

class FetchQrUseCase {
  final RecipeRepository _repo;
  FetchQrUseCase(this._repo);
  Future<String> execute(int recipeId) => _repo.fetchQrImage(recipeId);
}
