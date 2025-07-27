import '../../domain/repositories/recipe_repository.dart';

class SupplyMedicationsUseCase {
  final RecipeRepository _repo;
  SupplyMedicationsUseCase(this._repo);
  Future<void> execute(List<int> ids, String qr) => _repo.supplyMedications(ids, qr);
}
