import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cliente_screen_perfil.dart';

class ClienteScreen extends StatefulWidget {
  final Usuario user;

  const ClienteScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ClienteScreenState createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  bool _isSearchVisible = false;
  List<DocumentSnapshot> _carrito = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Negocios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuario',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildNegocios();
      case 1:
        return _buildCarrito();
      case 2:
        return ClienteScreenPerfil(user: widget.user);
      default:
        return _buildNegocios();
    }
  }

  Widget _buildNegocios() {
    return Column(
      children: [
        if (_isSearchVisible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar productos',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
          ),
        Expanded(
          child: Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar productos'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay productos disponibles'));
                }
                Map<String, List<DocumentSnapshot>> productosPorCategoria = {};
                snapshot.data!.docs.forEach((producto) {
                  if (_searchTerm.isEmpty ||
                      (producto['nombre'] ?? '').toLowerCase().contains(_searchTerm.toLowerCase())) {
                    String categoria = producto['categoria'] ?? 'Sin categoría';
                    if (!productosPorCategoria.containsKey(categoria)) {
                      productosPorCategoria[categoria] = [];
                    }
                    productosPorCategoria[categoria]!.add(producto);
                  }
                });
                return ListView.builder(
                  itemCount: productosPorCategoria.length,
                  itemBuilder: (context, index) {
                    String categoria = productosPorCategoria.keys.elementAt(index);
                    List<DocumentSnapshot> productos = productosPorCategoria[categoria]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            categoria,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final producto = productos[index];
                            return ListTile(
                              title: Text(
                                  '${producto['nombre'] ?? 'Nombre no disponible'} - \$${producto['precio'] ?? 'Precio no disponible'}'),
                              onTap: () {
                                _mostrarDetallesProducto(context, producto);
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  _agregarAlCarrito(context, producto); // Pasa el contexto
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarrito() {
    if (_carrito.isEmpty) {
      return const Center(child: Text('El carrito está vacío'));
    } else {
      double total = 0;
      for (var producto in _carrito) {
        total += producto['precio'] ?? 0;
      }
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _carrito.length,
              itemBuilder: (context, index) {
                final producto = _carrito[index];
                return ListTile(
                  title: Text('${producto['nombre'] ?? 'Nombre no disponible'} - \$${producto['precio'] ?? 'Precio no disponible'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _eliminarDelCarrito(producto);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para proceder al pago
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                ),
                child: const Text('Proceder a pagar', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total: \$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }
  }

  void _mostrarDetallesProducto(BuildContext context, DocumentSnapshot producto) {
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

  void _agregarAlCarrito(BuildContext context, DocumentSnapshot producto) { 
    setState(() {
      _carrito.add(producto);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto agregado al carrito')),
    );
  }

  void _eliminarDelCarrito(DocumentSnapshot producto) {
    setState(() {
      _carrito.remove(producto);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado del carrito')),
    );
  }
}