import '../models/product.dart';

class Cart {
  static final Map<Product, int> _items = {};

  static Map<Product, int> get items => _items;

  static void add(Product product) {
    if (_items.containsKey(product)) {
      _items[product] = _items[product]! + 1;
    } else {
      _items[product] = 1;
    }
  }

  static void remove(Product product) {
    if (_items.containsKey(product)) {
      _items[product] = _items[product]! - 1;
      if (_items[product]! <= 0) {
        _items.remove(product);
      }
    }
  }

  static double get total {
    return _items.entries
        .map((entry) => entry.key.price * entry.value)
        .fold(0.0, (a, b) => a + b);
  }

  static void clear() => _items.clear();
}
