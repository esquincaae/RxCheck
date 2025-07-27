import '../entities/recipe.dart';
import '../entities/medication.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> fetchRecipes();
  Future<List<Medication>> fetchMedications(int recipeId);
  Future<List<Medication>> fetchMedicationsByQr(String qrCode);
  Future<String> fetchQrImage(int recipeId);
  Future<void> supplyMedications(List<int> medicationIds, String qrCode);
}
