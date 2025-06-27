import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<Product> products = [];

    for (var item in data) {
      products.add(Product.fromJson(item));
    }

    // Imprimir los títulos de los productos en consola
    for (var p in products) {
      print('Producto: ${p.title} - \$${p.price}');
    }

    return products;
  } else {
    throw Exception('Error al obtener productos');
  }
}
