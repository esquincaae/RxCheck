import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../cart/cart.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(product.image, height: 150),
              SizedBox(height: 8),
              Text(product.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green)),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Cart.add(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.title} agregado al carrito')),
                  );
                },
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Agregar al carrito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
