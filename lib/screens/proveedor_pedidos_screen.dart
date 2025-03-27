import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedidos.dart'; 

class ProveedorPedidosScreen extends StatelessWidget {
  final String proveedorId;

  const ProveedorPedidosScreen({Key? key, required this.proveedorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('proveedorId', isEqualTo: proveedorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar pedidos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay pedidos disponibles'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final pedido = Pedido.fromMap(snapshot.data!.docs[index].data() as Map<String, dynamic>);
              return ListTile(
                title: Text('Pedido #${snapshot.data!.docs[index].id}'),
                subtitle: Text('Cliente: ${pedido.clienteId} - Total: \$${pedido.total}'),
                onTap: () {
                },
              );
            },
          );
        },
      ),
    );
  }
}