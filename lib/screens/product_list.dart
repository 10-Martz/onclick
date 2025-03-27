import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Productos de Proveedores')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay productos disponibles.'));
          }

          final products = snapshot.data!.docs;
          Map<String, List<DocumentSnapshot>> productsByProvider = {};

          for (var product in products) {
            final providerName = product['proveedor'] ?? 'Proveedor Desconocido';
            if (!productsByProvider.containsKey(providerName)) {
              productsByProvider[providerName] = [];
            }
            productsByProvider[providerName]!.add(product);
          }

          return ListView.builder(
            itemCount: productsByProvider.keys.length,
            itemBuilder: (context, index) {
              final providerName = productsByProvider.keys.elementAt(index);
              final providerProducts = productsByProvider[providerName]!;

              return ExpansionTile(
                title: Text(providerName),
                children: providerProducts.map((product) {
                  final productData = product.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(productData['nombre']),
                    subtitle: Text('\$${productData['price']}'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}