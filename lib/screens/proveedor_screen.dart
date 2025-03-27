import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'agregar_producto.dart';
import 'ProveedorScreenLog.dart';
import 'proveedor_edit.dart'; 

class ProveedorScreen extends StatefulWidget {
  final Usuario user;

  ProveedorScreen({required this.user});

  @override
  _ProveedorScreenState createState() => _ProveedorScreenState();
}

class _ProveedorScreenState extends State<ProveedorScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cerrar sesión.')),
      );
      print('Error al cerrar sesión: $e');
    }
  }

  void _editarProducto(Map<String, dynamic> producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProveedorEdit(
          productoId: producto['id'],
          productoData: producto,
        ),
      ),
    ).then((_) {
      setState(() {}); // Actualiza la vista después de editar
    });
  }

  void _eliminarProducto(Map<String, dynamic> producto) async {
    final logica = ProveedorScreenLog();
    await logica.eliminarProducto(producto['id'], widget.user);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pantalla del Proveedor')),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Agregar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    final logica = ProveedorScreenLog();

    switch (_selectedIndex) {
      case 0:
        return StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
          stream: logica.obtenerProductosPorCategoria(widget.user),
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
              categorias
                  .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

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
                          final producto = productos[index];
                          return Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    producto['imageUrl'] ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                          'assets/placeholder_image.png');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(producto['nombre']),
                                      Text('Categoría: ${producto['categoria']}'),
                                    ],
                                  )
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('\$${producto['price']}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(producto['descripcion']),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _editarProducto(producto),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _eliminarProducto(producto),
                                    ),
                                  ],
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
        );
      case 1:
        return AgregarProductoScreen(user: widget.user);
      case 2:
        return _buildPerfilProveedor();
      default:
        return Container();
    }
  }

  Widget _buildPerfilProveedor() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Nombre: ${widget.user.fullname}',
              style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Email: ${widget.user.email}', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _logout(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}