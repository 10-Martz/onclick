import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProveedorEdit extends StatefulWidget {
  final String productoId;
  final Map<String, dynamic> productoData;

  ProveedorEdit({required this.productoId, required this.productoData});

  @override
  _ProveedorEditState createState() => _ProveedorEditState();
}

class _ProveedorEditState extends State<ProveedorEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _descripcionController;
  late TextEditingController _imageUrlController;
  late String _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.productoData['nombre']);
    _precioController = TextEditingController(text: widget.productoData['price'].toString());
    _descripcionController = TextEditingController(text: widget.productoData['descripcion']);
    _imageUrlController = TextEditingController(text: widget.productoData['imageUrl']);
    _categoriaSeleccionada = widget.productoData['categoria'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio del producto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL de la Imagen'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la URL de la imagen del producto';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                onChanged: (String? newValue) {
                  setState(() {
                    _categoriaSeleccionada = newValue!;
                  });
                },
                items: <String>[
                  "Bebidas",
                  'Alimentos Enlatados',
                  "Productos de Limpieza",
                  "Dulces y Snacks",
                  "Productos Lácteos",
                  'Granos y Semillas',
                  "Productos de Higiene",
                  "Condimentos y Especias",
                  "Otros"
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                decoration: InputDecoration(labelText: 'Categoría'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(widget.productoId)
                            .update({
                          'nombre': _nombreController.text,
                          'price': double.parse(_precioController.text),
                          'descripcion': _descripcionController.text,
                          'imageUrl': _imageUrlController.text,
                          'categoria': _categoriaSeleccionada,
                        });
                        Navigator.pop(context); 
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar el producto: $e')),
                        );
                      }
                    }
                  },
                  child: Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}