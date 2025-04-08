import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Función para agregar un movimiento de producto
  Future<void> addMovement({
    required String producto,
    required String tipo,
    required int cantidad,
    String? comentario,
  }) async {
  // Registrar el movimiento en la colección 'movements'
    await _db.collection('movements').add({
      'producto': producto,             // Nombre del producto
      'tipo': tipo,                     // 'entrada' o 'salida'
      'cantidad': cantidad,             // Cantidad de productos
      'fecha': FieldValue.serverTimestamp(), // Fecha y hora del movimiento
      
    });

  // Actualizar la cantidad del producto en la colección 'products'
    await _updateProductQuantity(producto, tipo, cantidad);
  }

  // Función para actualizar la cantidad del producto
  Future<void> _updateProductQuantity(String producto, String tipo, int cantidad) async {
  // Obtener el producto de la colección 'products'
    DocumentSnapshot productDoc = await _db.collection('products').doc(producto).get();

    if (productDoc.exists) {
      int currentStock = productDoc['stock'];

  // Dependiendo del tipo, sumar o restar cantidad
      int newStock = tipo == 'entrada' ? currentStock + cantidad : currentStock - cantidad;
      

 // Actualizar el stock del producto
      await _db.collection('products').doc(producto).update({'stock': newStock});
    } else {
      debugPrint("Producto no encontrado.");
    }
  }
}
