import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_app/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('debe crear un producto válido desde el JSON de FakeStoreAPI', () {
      final json = {
        "id": 1,
        "title": "Fjallraven - Foldsack No. 1 Backpack",
        "price": 109.95,
        "description": "Your perfect pack for everyday use...",
        "category": "men's clothing",
        "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
        "rating": {
          "rate": 3.9,
          "count": 120
        }
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, contains('Backpack'));
      expect(product.price, greaterThan(0));
      expect(product.image, startsWith('https://'));
    });

    test('retorna valores por defecto si el JSON está vacío', () {
      final Map<String, dynamic> json = {};

      final product = Product.fromJson(json);

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.price, 0.0);
      expect(product.image, '');
    });
  });
}
