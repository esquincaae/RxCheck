import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

// Obtener lista de productos
Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => Product.fromJson(item)).toList();
  } else {
    throw Exception('Error al obtener productos');
  }
}

// Obtener detalle de producto por id
Future<Product> fetchProductDetail(int id) async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/products/$id'));
  if (response.statusCode == 200) {
    return Product.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al obtener detalle del producto');
  }
}

// Simular carrito (POST)
Future<Map<String, dynamic>> postCart(List<Map<String, dynamic>> products) async {
  final response = await http.post(
    Uri.parse('https://fakestoreapi.com/carts'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "userId": 1,
      "date": DateTime.now().toIso8601String(),
      "products": products,
    }),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    return json.decode(response.body);
  } else {
    throw Exception('Error al simular carrito');
  }
}

// Obtener carrito simulado
Future<Map<String, dynamic>> fetchCart() async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/carts/1'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Error al obtener carrito');
  }
}
