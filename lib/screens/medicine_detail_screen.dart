import 'package:flutter/material.dart';
import '../models/medicine.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;
  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: Text(
          medicine.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF1F4F8),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Medicine>(
        future: fetchMedicineDetail(medicine.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final product = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 20),
                      Text(
                        medicine.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        medicine.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<Medicine> fetchMedicineDetail(int id) async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/$id'));
    if (response.statusCode == 200) {
      return Medicine.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener los detalles del medicamento');
    }
  }
}
