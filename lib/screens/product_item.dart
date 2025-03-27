import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final productData = product.data() as Map<String, dynamic>;
            final providerName = productData['proveedor'] ?? 'Proveedor Desconocido'; 

            return Card(
              child: ListTile(
                leading: productData['imageUrl'] != null
                    ? Image.network(productData['imageUrl'], width: 25, height: 25)
                    : const Icon(Icons.image, size: 30),
                title: Text(productData['nombre']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productData['descripcion']),
                    Text('\$${productData['price']} - $providerName'), 
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}