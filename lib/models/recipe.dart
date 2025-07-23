import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Recipe {
  late final int id;
  final String issue_at;
  late final String? qr;


  Recipe({
    required this.id,
    required this.issue_at,
    required this.qr,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    String formattedDate = 'Sin Fecha';

    if(json['issue_at'] != null){
      try{
        DateTime parsedDate = DateTime.parse(json['issue_at']);
        formattedDate = DateFormat('d \'de\' MMMM \'de\' yyyy, hh:mm a', 'es').format(parsedDate);
      }catch(e){
        formattedDate = 'Fecha Invalida';
      }
    }

    return Recipe(
      id: json['id'],
      issue_at: formattedDate, // "issue_at": "2025-07-13T22:33:37.000Z"
      qr: json['qr_image'],
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, issue_at: $issue_at)';
  }
}
