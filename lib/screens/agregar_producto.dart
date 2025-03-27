import 'package:flutter/material.dart';
import '../screens/ProveedorScreenLog.dart';
import '../models/usuario.dart';
import 'proveedor_screen.dart'; 

class AgregarProductoScreen extends StatefulWidget {
  final Usuario user;

  AgregarProductoScreen({required this.user});

  @override
  AgregarProductoScreenState createState() => AgregarProductoScreenState(); 
}

class AgregarProductoScreenState extends State<AgregarProductoScreen> { 
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _categoriaSeleccionada;

  final List<String> _categorias = [
    'Bebidas',
    'Alimentos Enlatados',
    'Productos de Limpieza',
    'Dulces y Snacks',
    'Productos Lácteos',
    'Granos y Semillas',
    'Productos de Higiene',
    'Condimentos y Especias',
    'Otros',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el precio del producto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un precio válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la descripción del producto';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                items: _categorias.map((String categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _categoriaSeleccionada = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione una categoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de la imagen'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la URL de la imagen';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _categoriaSeleccionada != null) {
                    final logica = ProveedorScreenLog();
                    await logica.agregarProducto({
                      'nombre': _nombreController.text,
                      'precio': double.parse(_precioController.text),
                      'descripcion': _descripcionController.text,
                      'categoria': _categoriaSeleccionada,
                      'imageUrl': _imageUrlController.text,
                    }, widget.user);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProveedorScreen(user: widget.user),
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}