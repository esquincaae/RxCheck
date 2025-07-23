import 'package:RxCheck/screens/qr_detector_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_button.dart';
import '../models/medication.dart';
import '../widgets/medicine_card.dart';
import '../models/recipe.dart';
import '../data/medication.dart';
import '../services/qr_service.dart';

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
  String? errorMessage = null;
  String? role = '';


  @override
  void initState() {
    super.initState();
    errorMessage;
    loadRoleAndFetchMedicines();
  }

  Future<void> loadRoleAndFetchMedicines() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userRole = prefs.getString('role');

      if (userRole == 'paciente') {
        setState(() {
          role = userRole;
        });
        await loadMedicinesWithId();
      } else if (userRole == 'farmacia') {
        setState(() {
          role = userRole;
        });
        await loadMedicinesWithQr();
      } else {
        setState(() {
          role = '';
          errorMessage = 'Rol no identificado';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        role = '';
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

      //final allSupplied = fetchedMedicines.isNotEmpty && fetchedMedicines.every((med) => med.supplied);

      if (fetchedMedicines.isEmpty) {
        print('MEDICINES isEmpty - $fetchedMedicines');
        setState(() {
          isLoading = false;
          medicines = [];
          errorMessage = 'Receta ya surtida';
        });
      } else {
        setState(() {
          print('MEDICINES notIsEmpty- $fetchedMedicines');
          medicines = fetchedMedicines.where((med) => !med.supplied).toList();
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => QRDetectorScreen()),
            (route) => false,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al verificar la receta: Esta receta ya no esta disponible.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
          setState(() {
            errorMessage = '$e';
            print(errorMessage);
            isLoading = false;
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      if(errorMessage == 'Receta ya surtida'){
        return Center(
          child: Text(errorMessage!,
            style: TextStyle(color: errorMessage == 
                'Receta ya surtida' ? Colors.blue : Colors.red
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.only(bottom: 80),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          return MedicineCard(medicine: medicines[index]);
        },
      ),
      bottomNavigationBar:  role != 'paciente' && medicines.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: 'Surtir Medicamentos',
          icon: Icon(Icons.check_circle),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50),
          onPressed: () {
            List<int> medIds = medicines
                .where((med) => med.supplied && !med.wasSuppliedInitially)
                .map((med) => med.id).toList();
            if (medIds.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No hay medicamentos marcados como surtidos')),
              );
              return;
            }
            print('MEDICATIONS - medicineListScreen - $medIds');
            QrService().updateStatusMedications(medIds);
            loadRoleAndFetchMedicines();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Medicamentos marcados como surtidos')),
            );
          },
        ),
      ) : null,
    );
  }



}
