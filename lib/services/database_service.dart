import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class DatabaseService {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref("Realtime Database");
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('DatabaseService');

  // Crear productos
  Future<void> createProduct(Map<String, dynamic> productData) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    try {
  // Realtime Database
      await databaseReference.child(id).set(productData);
  // Firestore
      await firestore.collection('products').doc(id).set(productData);
      _logger.log(Level.INFO, "Producto agregado correctamente a Firestore");
    } catch (e) {
      _logger.severe("Error al agregar producto a Firestore: $e");
    }
  }

  // Actualizar productos
  Future<void> updateProduct(String id, Map<String, dynamic> productData) async {
  // Realtime Database
    await databaseReference.child(id).update(productData);
  // Firestore
    await firestore.collection('products').doc(id).update(productData);
  }

  // Eliminar productos
  Future<void> deleteProduct(String id) async {
  // Realtime Database
    await databaseReference.child(id).remove();
  // Firestore
    await firestore.collection('products').doc(id).delete();
  }

  // Agregar movimiento (entrada o salida) a Firestore
  Future<void> addMovement({
    required String producto,
    required String tipo,  // 'entrada' o 'salida'
    required int cantidad,
    required String comentario,
  }) async {
    try {
  // Registrar movimiento en Firestore
      await firestore.collection('movements').add({
        'producto': producto,
        'tipo': tipo,  // 'entrada' o 'salida'
        'cantidad': cantidad,
        'comentario': comentario,
        'fecha': FieldValue.serverTimestamp(),  
      });
      _logger.log(Level.INFO, "Movimiento registrado correctamente en Firestore");

  // Registrar movimiento en Realtime Database (si es necesario)
      final movementData = {
        'producto': producto,
        'tipo': tipo,
        'cantidad': cantidad,
        'comentario': comentario,
        'fecha': DateTime.now().toIso8601String(),
      };
      await databaseReference.child("movements").push().set(movementData);
      _logger.log(Level.INFO, "Movimiento registrado correctamente en Realtime Database");
    } catch (e) {
      _logger.severe("Error al registrar movimiento: $e");
    }
  }
}
