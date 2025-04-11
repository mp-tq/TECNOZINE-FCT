import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;  // Para PDF
import 'package:open_file/open_file.dart';  // Para abrir archivos

class ExportOptionsScreen extends StatelessWidget {
  const ExportOptionsScreen({super.key});

  // Función para obtener los productos desde Firestore
  Future<List<Map<String, dynamic>>> getProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Función para exportar los productos a CSV
  Future<void> exportToCsv() async {
    List<Map<String, dynamic>> products = await getProducts();
    
  // Convertir los productos en una lista 
    List<List<dynamic>> rows = [];
    rows.add(["Producto", "Descripción", "Categoría", "Stock", "Precio"]); 

    for (var product in products) {
      rows.add([
        product['producto'],
        product['descripcion'],
        product['categoria'],
        product['stock'],
        product['precio'],
      ]);
    }

  // Convertir la lista de productos a CSV
    String csvData = const ListToCsvConverter().convert(rows);

  // Guardar el archivo CSV
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/productos.csv';
    final file = File(path);
    await file.writeAsString(csvData);

  // Abrir el archivo CSV automáticamente
    OpenFile.open(path);

  // Mostrar un mensaje 
    debugPrint('CSV guardado y abierto en: $path');
  }

  // Función para crear el PDF
  Future<void> createPdf() async {
    List<Map<String, dynamic>> products = await getProducts();

    final pdf = pw.Document();

  // Añadir una página al PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Inventario de Productos', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ["Producto", "Descripción", "Categoría", "Stock", "Precio"],
                data: products.map((product) {
                  return [
                    product['producto'],
                    product['descripcion'],
                    product['categoria'],
                    product['stock'],
                    product['precio'],
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

  // Guardar el PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/productos.pdf');
    await file.writeAsBytes(await pdf.save());

  // Abrir el archivo PDF automáticamente
    OpenFile.open(file.path);

  // Mostrar un mensaje 
    debugPrint('PDF generado y abierto en: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Archivo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                exportToCsv(); // Generar CSV directamente en la misma pantalla
              },
              child: const Text('Generar CSV'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                createPdf(); // Generar PDF directamente en la misma pantalla
              },
              child: const Text('Generar PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
