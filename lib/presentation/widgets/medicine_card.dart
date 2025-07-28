import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/medication.dart';
import 'custom_card.dart';

class MedicineCard extends StatefulWidget {
  final Medication medicine;
  const MedicineCard({super.key, required this.medicine});

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  bool isChecked = false;
  String role = '';

  @override
  void initState() {
    super.initState();
    isChecked = widget.medicine.supplied;
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => role = prefs.getString('role') ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            if (role == 'farmacia') ...[
              Checkbox(
                value: isChecked,
                onChanged: (v) {
                  setState(() {
                    isChecked = v ?? false;
                    widget.medicine.supplied = isChecked;
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                widget.medicine.text,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
