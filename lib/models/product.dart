import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nombre;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;

  Product({
    required this.id,
    required this.nombre,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      nombre: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
    );
  }
}