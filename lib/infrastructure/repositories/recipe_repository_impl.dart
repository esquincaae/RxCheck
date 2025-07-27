import 'dart:convert';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasource/http_recipe_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final HttpRecipeDataSource _ds;
  final FlutterSecureStorage _storage;

  RecipeRepositoryImpl(this._ds, this._storage);

  Future<String> _token() async => await _storage.read(key: 'authToken') ?? '';

  @override
  Future<List<Recipe>> fetchRecipes() async {
    final resp = await _ds.getRecipes(await _token());
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body)['data'] as List;
      return list
          .map((e) => Recipe(
                id: e['id'],
                issueAt: e['issue_at'] ?? '',
                qrImage: e['qr_image'] ?? '',
              ))
          .toList()
          .reversed
          .toList();
    }
    throw Exception('Error al obtener recetas');
  }

  @override
  Future<List<Medication>> fetchMedications(int recipeId) async {
    final resp = await _ds.getMedications(recipeId, await _token());
    if (resp.statusCode == 200) {
      final meds = jsonDecode(resp.body)['data']['medications'] as List;
      return meds
          .map((m) => Medication(
                id: m['id'],
                text: m['text'],
                supplied: m['supplied'],
              ))
          .toList();
    }
    throw Exception('Error al obtener medicamentos');
  }

  @override
  Future<List<Medication>> fetchMedicationsByQr(String qr) async {
    final resp = await _ds.getMedicationsByQr(qr, await _token());
    if (resp.statusCode == 200) {
      final meds = jsonDecode(resp.body)['data']['medications'] as List;
      return meds
          .map((m) => Medication(
                id: m['id'],
                text: m['text'],
                supplied: m['supplied'],
              ))
          .toList();
    } else if (resp.statusCode == 404) {
      throw Exception('Esta Receta ya ha sido surtida por una Farmacia');
    }
    throw Exception('Error al obtener medicamentos');
  }

  @override
  Future<String> fetchQrImage(int recipeId) async {
    final resp = await _ds.getQrImage(recipeId, await _token());
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)['data']['qr_image'] ?? '';
    }
    throw Exception('Error al obtener QR');
  }

  @override
  Future<void> supplyMedications(List<int> medicationIds, String qrCode) async {
    final resp = await _ds.supplyMedications(qrCode, medicationIds, await _token());
    if (resp.statusCode != 200) {
      throw Exception('Error al surtir medicamentos');
    }
  }
}
