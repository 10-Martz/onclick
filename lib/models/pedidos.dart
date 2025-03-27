import 'package:cloud_firestore/cloud_firestore.dart';


class Pedido {
  String clienteId;
  String proveedorId;
  List<Map<String, dynamic>> productos;
  double total;
  String estado;
  DateTime fecha;

  Pedido({
    required this.clienteId,
    required this.proveedorId,
    required this.productos,
    required this.total,
    required this.estado,
    required this.fecha,
  });

  // Método para convertir un mapa de Cloud Firestore a un objeto Pedido
  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      clienteId: map['clienteId'],
      proveedorId: map['proveedorId'],
      productos: List<Map<String, dynamic>>.from(map['productos']),
      total: map['total'].toDouble(),
      estado: map['estado'],
      fecha: (map['fecha'] as Timestamp).toDate(),
    );
  }

  // Método para convertir un objeto Pedido a un mapa para Cloud Firestore
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'proveedorId': proveedorId,
      'productos': productos,
      'total': total,
      'estado': estado,
      'fecha': fecha,
    };
  }
}