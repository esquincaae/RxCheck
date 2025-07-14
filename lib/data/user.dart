import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

Future<List<User>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<User> users = [];

    for (var item in data) {
      users.add(User.fromJson(item));
    }

    for (var user in users) {
      print('Usuario: ${user.nombre} - Correo: ${user.email} - Rol: ${user.role}');
    }

    return users;
  } else {
    throw Exception('Error al obtener productos');
  }
}
