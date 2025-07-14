import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../widgets/medicine_card.dart';
import '../models/recipe.dart';
import '../data/medication.dart';

class MedicineListScreen extends StatefulWidget {
  final Recipe recipe;
  const MedicineListScreen({super.key, required this.recipe});

  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  Medication medication = Medication(text: '');
  List<Medication> medicines = [];
  bool isLoading = true;
  String? errorMessage;


  @override
  void initState() {
    super.initState();
    fetchMedicines(widget.recipe.id);
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    try {
      final fetchedMedicines = await fetchMedicines(widget.recipe.id);
      setState(() {
        medicines = fetchedMedicines;
        isLoading = false;
        errorMessage = null;
      });
    }catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) { return Center(child: CircularProgressIndicator()); }
    if (errorMessage != null) { return Center(child: Text(errorMessage!)); }
    if (medicines.isEmpty) { return Center(child: Text('No hay medicamentos disponibles')); }

    return ListView.builder(
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        print('Medicine ${index + 1}: ${medicines[index].text}');
        return MedicineCard(medicine: medicines[index]);
      },
    );
  }
}
