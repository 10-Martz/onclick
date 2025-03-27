import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';
import 'cliente_controller.dart';

class ClienteView extends StatefulWidget {
  final Usuario user;

  ClienteView({required this.user});

  @override
  _ClienteViewState createState() => _ClienteViewState();
}

class _ClienteViewState extends State<ClienteView> {
  late ClienteController controller;

  @override
  void initState() {
    super.initState();
    controller = ClienteController(user: widget.user);
    controller.setContext(context);
    controller.setSetStateCallback(setState);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: controller.toggleSearchVisibility,
          ),
        ],
        bottom: controller.isSearchVisible
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.updateSearchTerm,
                    decoration: const InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: controller.selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: controller.onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    switch (controller.selectedIndex) {
      case 0:
        return _buildProductList();
      case 1:
        return _buildCart();
      case 2:
        return _buildProfile();
      default:
        return Container();
    }
  }

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('productos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final productos = snapshot.data!.docs;
        final productosFiltrados = productos.where((producto) {
          final nombre = producto['nombre'].toString().toLowerCase();
          final termino = controller.searchTerm.toLowerCase();
          return nombre.contains(termino);
        }).toList();

        return ListView.builder(
          itemCount: productosFiltrados.length,
          itemBuilder: (context, index) {
            final producto = productosFiltrados[index];
            return ListTile(
              title: Text(producto['nombre']),
              subtitle: Text('\$${producto['precio']}'),
              onTap: () => controller.mostrarDetallesProducto(producto),
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () => controller.agregarAlCarrito(producto),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCart() {
    return ListView.builder(
      itemCount: controller.carrito.length,
      itemBuilder: (context, index) {
        final producto = controller.carrito[index];
        return ListTile(
          title: Text(producto['nombre']),
          subtitle: Text('\$${producto['precio']}'),
          trailing: IconButton(
            icon: const Icon(Icons.remove_shopping_cart),
            onPressed: () => controller.eliminarDelCarrito(producto),
          ),
        );
      },
    );
  }

  Widget _buildProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Nombre: ${widget.user.fullname}'),
          Text('Email: ${widget.user.email}'),
          ElevatedButton(
            onPressed: () => controller.guardarPedido(context),
            child: const Text('Realizar pedido'),
          ),
        ],
      ),
    );
  }
}