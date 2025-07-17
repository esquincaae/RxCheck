import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Medication medication = Medication(id: 0, text: '', supplied: false);
  List<Medication> medicines = [];
  bool isLoading = true;
  String? errorMessage;


  @override
  void initState() {
    super.initState();
    loadRoleAndFetchMedicines();
  }

  Future<void> loadRoleAndFetchMedicines() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? role = prefs.getString('role');

      if (role == 'paciente') {
        await loadMedicinesWithId();
      } else if (role == 'farmacia') {
        await loadMedicinesWithQr();
      } else {
        setState(() {
          errorMessage = 'Rol no identificado';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al obtener rol';
        isLoading = false;
      });
    }
  }


  Future<void> loadMedicinesWithId() async {
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

  Future<void> loadMedicinesWithQr() async {
    try {
      final fetchedMedicines = await fetchMedicinesQrCode(widget.recipe.qr);
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
        return MedicineCard(medicine: medicines[index]);
      },
    );
  }
}
