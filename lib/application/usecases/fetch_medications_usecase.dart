import '../../domain/repositories/recipe_repository.dart';
import '../../domain/entities/medication.dart';

class FetchMedicationsUseCase {
  final RecipeRepository _repo;
  FetchMedicationsUseCase(this._repo);
  Future<List<Medication>> execute(int recipeId) => _repo.fetchMedications(recipeId);
  Future<List<Medication>> executeByQr(String qrCode) => _repo.fetchMedicationsByQr(qrCode);
}
