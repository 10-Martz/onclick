import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedidos.dart'; 

class ProveedorCart extends StatelessWidget {
  final String proveedorId; 

  const ProveedorCart({Key? key, required this.proveedorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedidos de Clientes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('proveedorId', isEqualTo: proveedorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay pedidos disponibles.'));
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = Pedido.fromMap(pedidos[index].data() as Map<String, dynamic>);

              return ExpansionTile(
                title: Text('Pedido #${index + 1} - Cliente: ${pedido.clienteId}'),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pedido.productos.length,
                    itemBuilder: (context, productIndex) {
                      final producto = pedido.productos[productIndex];
                      return ListTile(
                        title: Text(producto['nombre']),
                        subtitle: Text('\$${producto['precio']}'),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total de Productos: ${pedido.productos.length}'),
                        Text('Total a Pagar: \$${pedido.total.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}