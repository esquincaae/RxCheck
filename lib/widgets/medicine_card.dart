import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_card.dart';
import '../models/medication.dart';

class MedicineCard extends StatefulWidget {
  final Medication medicine;

  const MedicineCard({Key? key, required this.medicine}) : super(key: key);

  @override
  _MedicineCardState createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  bool isChecked = false;
  String role = '';

  @override
  void initState() {
    isChecked = widget.medicine.supplied;
    super.initState();
    role;
  }

  Future<void> _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('role') ?? '';
    setState(() {
      role = userRole;
    });
  }



  @override
  Widget build(BuildContext context) {
    _loadPrefs();
    final screenWidth = MediaQuery.of(context).size.width;
    final cardSize = screenWidth * 0.2;

    return CustomCard(
      height: cardSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (role == 'farmacia') ...[
                  Checkbox(
                    value: isChecked,
                    activeColor: Colors.blue,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isChecked = newValue ?? false;
                        widget.medicine.supplied = isChecked;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.medicine.text,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    'assets/icons/medicine.svg',
                    width: 25,
                    height: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
