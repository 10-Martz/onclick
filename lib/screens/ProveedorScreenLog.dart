import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';

class ProveedorScreenLog {
  Future<void> agregarProducto(
      Map<String, dynamic> productData, Usuario user) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        ...productData,
        'proveedorId': user.uid,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al agregar producto: $e');
      throw e; 
    }
  }

  Stream<Map<String, List<Map<String, dynamic>>>> obtenerProductosPorCategoria(
      Usuario user) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('proveedorId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      Map<String, List<Map<String, dynamic>>> productosPorCategoria = {};
      for (var doc in snapshot.docs) {
        var producto = doc.data();
        producto['id'] = doc.id; 
        var categoria = producto['categoria'];
        if (productosPorCategoria.containsKey(categoria)) {
          productosPorCategoria[categoria]!.add(producto);
        } else {
          productosPorCategoria[categoria] = [producto];
        }
      }
      return productosPorCategoria;
    });
  }

  Future<void> editarProducto(
      String productId, Map<String, dynamic> productData) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update(productData);
    } catch (e) {
      print('Error al editar producto: $e');
      throw e;
    }
  }

  Future<void> eliminarProducto(String productId, Usuario user) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
    } catch (e) {
      print('Error al eliminar producto: $e');
      throw e;
    }
  }
}