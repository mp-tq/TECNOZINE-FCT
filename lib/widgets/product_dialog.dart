import 'package:flutter/material.dart';
import '../../services/database_service.dart';  

class ProductDialog extends StatelessWidget {
  final String producto;
  final String descripcion;
  final String categoria;
  final String stock;
  final String precio;
  final TextEditingController productoController;
  final TextEditingController descripcionController;
  final TextEditingController categoriaController;
  final TextEditingController stockController;
  final TextEditingController precioController;
  final VoidCallback onPressed;

  const ProductDialog({
    super.key,
    required this.producto,
    required this.descripcion,
    required this.categoria,
    required this.stock,
    required this.precio,
    required this.productoController,
    required this.descripcionController,
    required this.categoriaController,
    required this.stockController,
    required this.precioController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.blue[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 214, 228, 239),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Text(
                  producto,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                CircleAvatar(
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
            TextField(controller: productoController, decoration: const InputDecoration(labelText: "Nombre del producto")),
            TextField(controller: descripcionController, decoration: const InputDecoration(labelText: "Descripción")),
            TextField(controller: categoriaController, decoration: const InputDecoration(labelText: "Categoría")),
            TextField(controller: stockController, decoration: const InputDecoration(labelText: "Stock")),
            TextField(controller: precioController, decoration: const InputDecoration(labelText: "Precio")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
    
                final productoData = {
                  'producto': productoController.text,
                  'descripcion': descripcionController.text,
                  'categoria': categoriaController.text,
                  'stock': stockController.text,
                  'precio': precioController.text,
                };

                if (productoController.text.isNotEmpty) {
  
                  String productoId = 'productoId'; 
                  DatabaseService().updateProduct(productoId, productoData);
  
                      // Registro del movimiento (entrada o salida)
                      int cantidadMovida = int.parse(stockController.text);
                      if (cantidadMovida > 0) {
                        DatabaseService().addMovement(
                          producto: productoController.text,
                          tipo: 'entrada',
                          cantidad: cantidadMovida,
                          comentario: 'Nuevo stock añadido',
                                        );
                                      }
                                    }
                            onPressed();
                          },
                          child: Text(descripcion),  
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              }
            }
