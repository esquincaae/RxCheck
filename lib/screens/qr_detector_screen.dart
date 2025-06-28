import 'package:flutter/material.dart';
import '../models/product.dart';
import '../cart/cart.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreensState createState() => _CartScreensState();
}

class _CartScreensState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final items = Cart.items;

    return Scaffold(
      appBar: AppBar(title: Text('Carrito de Compras')),
      body: items.isEmpty
          ? Center(child: Text('El carrito está vacío'))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items.keys.elementAt(index);
          final quantity = items[product]!;

          return ListTile(
            leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(product.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${product.price.toStringAsFixed(2)}'),
                Text('Cantidad: $quantity'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      Cart.remove(product);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      Cart.add(product);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${Cart.total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Cart.items.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('¡Compra realizada con éxito!')),
                );
              },
              child: Text('Comprar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
