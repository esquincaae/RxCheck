import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/recipe_detail_viewmodel.dart';
import '../../domain/entities/recipe.dart';
import '../widgets/medicine_card.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipeDetailViewModel>();
    final role = (Provider.of(context, listen: false) as dynamic).prefs.getString('role');
    if (!vm.isLoading && vm.medications.isEmpty && vm.error==null) vm.loadDetail(recipe.id, role!);
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      appBar: AppBar(title: Text('Detalles')),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(child: Text(vm.error!))
              : Column(children: [
                  if (role != 'farmacia') Image.network(vm.qrImage ?? ''),
                  Expanded(
                    child: ListView(
                      children: vm.medications.map((m) => MedicineCard(medicine: m)).toList(),
                    ),
                  ),
                  if (role == 'farmacia')
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: ElevatedButton(
                          onPressed: vm.supplySelected, child: Text('Surtir Medicamentos')),
                    ),
                ]),
    );
  }
}
