import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';
import '../models/pedidos.dart';

class ClienteController {
  final Usuario user;
  late final Function(void Function()) setStateCallback;
  late BuildContext context;

  ClienteController({required this.user});

  int selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  String searchTerm = '';
  bool isSearchVisible = false;
  List<DocumentSnapshot> carrito = [];

  void setContext(BuildContext context) {
    this.context = context;
  }

  void setSetStateCallback(Function(void Function()) callback) {
    setStateCallback = callback;
  }

  void onItemTapped(int index) {
    setStateCallback(() {
      selectedIndex = index;
    });
  }

  void toggleSearchVisibility() {
    setStateCallback(() {
      isSearchVisible = !isSearchVisible;
    });
  }

  void updateSearchTerm(String value) {
    setStateCallback(() {
      searchTerm = value;
    });
  }

  void agregarAlCarrito(DocumentSnapshot producto) async {
    try {
      await FirebaseFirestore.instance.collection('carritos').add({
        'userId': user.uid,
        'productoId': producto.id,
        'nombre': producto['nombre'],
        'precio': producto['precio'],
        'imageUrl': producto['imageUrl'],
      });
      setStateCallback(() {
        carrito.add(producto);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado al carrito')),
      );
    } catch (e) {
      print('Error al agregar al carrito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar al carrito: $e')),
      );
    }
  }

  void eliminarDelCarrito(DocumentSnapshot producto) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('carritos')
          .where('userId', isEqualTo: user.uid)
          .where('productoId', isEqualTo: producto.id)
          .get();

      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });

      setStateCallback(() {
        carrito.remove(producto);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado del carrito')),
      );
    } catch (e) {
      print('Error al eliminar del carrito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar del carrito: $e')),
      );
    }
  }

  Future<void> guardarPedido(BuildContext context) async {
    if (carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    if (user.uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede crear el pedido porque el ID del usuario es desconocido')),
      );
      return;
    }

    if (carrito.first['proveedorId'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede crear el pedido porque el proveedorId es desconocido')),
      );
      return;
    }

    String proveedorId = carrito.first['proveedorId'];

    List<Map<String, dynamic>> productosPedido = carrito.map((producto) {
      return {
        'productoId': producto.id,
        'nombre': producto['nombre'],
        'precio': producto['precio'],
        'cantidad': 1,
        'imageUrl': producto['imageUrl'],
      };
    }).toList();

    double total = carrito.fold(0, (sum, producto) => sum + (producto['precio'] ?? 0));

    try {
      Pedido pedido = Pedido(
        clienteId: user.uid!,
        proveedorId: proveedorId,
        productos: productosPedido,
        total: total,
        estado: 'pendiente',
        fecha: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('pedidos').add(pedido.toMap());
      setStateCallback(() {
        carrito.clear();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido realizado con éxito')),
        );
      }
    } catch (e) {
      print('Error al guardar el pedido: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al realizar el pedido: $e')),
        );
      }
    }
  }

  void mostrarDetallesProducto(DocumentSnapshot producto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(producto['nombre'] ?? 'Nombre no disponible'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Categoría: ${producto['categoria'] ?? 'Sin categoría'}'),
              Text('Descripción: ${producto['descripcion'] ?? 'Sin descripción'}'),
              Text('Precio: \$${producto['precio'] ?? 'Precio no disponible'}'),
              if (producto['imageUrl'] != null)
                Image.network(producto['imageUrl']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    searchController.dispose();
  }

  Future<void> cargarCarritoDesdeFirestore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('carritos')
          .where('userId', isEqualTo: user.uid)
          .get();

      setStateCallback(() {
        carrito = querySnapshot.docs;
      });
    } catch (e) {
      print('Error al cargar el carrito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el carrito: $e')),
      );
    }
  }
}