import 'package:flutter/material.dart';
import '../../application/usecases/fetch_medications_usecase.dart';
import '../../application/usecases/fetch_qr_usecase.dart';
import '../../application/usecases/supply_medications_usecase.dart';
import '../../domain/entities/medication.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  final FetchMedicationsUseCase _medsUc;
  final FetchQrUseCase _qrUc;
  final SupplyMedicationsUseCase _supplyUc;

  List<Medication> medications = [];
  String? qrImage;
  bool isLoading = false;
  String? error;

  RecipeDetailViewModel(this._medsUc, this._qrUc, this._supplyUc);

  Future<void> loadDetail(int recipeId, String role) async {
    isLoading = true; error = null; notifyListeners();
    try {
      qrImage = await _qrUc.execute(recipeId);
      if (role == 'paciente') {
        medications = await _medsUc.execute(recipeId);
      } else {
        medications = await _medsUc.executeByQr(qrImage!);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> supplySelected() async {
    final selected = medications
        .where((m) => m.supplied && !m.wasSuppliedInitially)
        .map((m) => m.id)
        .toList();
    if (selected.isEmpty) return;
    await _supplyUc.execute(selected, qrImage!);
    await loadDetail(0, 'farmacia'); // recargar 
  }
}
