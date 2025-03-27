import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'ProveedorScreenLog.dart';

class ProveedorHomeScreen extends StatelessWidget {
  final Usuario user;

  ProveedorHomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final logica = ProveedorScreenLog();
    return Scaffold(
      appBar: AppBar(title: Text('Productos')),
      body: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
        stream: logica.obtenerProductosPorCategoria(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, List<Map<String, dynamic>>>? productosPorCategoria =
                snapshot.data;
            if (productosPorCategoria == null ||
                productosPorCategoria.isEmpty) {
              return Center(child: Text('No hay productos disponibles.'));
            }

            List<String> categorias = productosPorCategoria.keys.toList();
            categorias.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

            return ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                String categoria = categorias[index];
                List<Map<String, dynamic>> productos =
                    productosPorCategoria[categoria]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        categoria,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  productos[index]['imageUrl'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset('assets/placeholder_image.png'); 
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(productos[index]['nombre']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('\$${productos[index]['price']}'), 
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}