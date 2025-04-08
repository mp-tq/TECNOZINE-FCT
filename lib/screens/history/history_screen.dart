import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Función para obtener el historial de movimientos desde Firestore
  Stream<List<Map<String, dynamic>>> getMovements() {
  return FirebaseFirestore.instance
      .collection('movements')
      .orderBy('fecha', descending: true) // Ordenar por fecha, descendente
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Movimientos')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getMovements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los movimientos.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay movimientos registrados.'));
          }

          final movements = snapshot.data!;

          return ListView.builder(
            itemCount: movements.length,
            itemBuilder: (context, index) {
              final movement = movements[index];
              return ListTile(
                title: Text(movement['producto']),
                subtitle: Text('Tipo: ${movement['tipo']} - Cantidad: ${movement['cantidad']}'),
                trailing: Text('Fecha: ${movement['fecha'].toDate().toString()}'),
                onTap: () {
                },
              );
            },
          );
        },
      ),
    );
  }
}

