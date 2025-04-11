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
    // Tema actual
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blue[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : const Color.fromARGB(255, 214, 228, 239),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : Colors.black,  // Color de texto según el tema
                  ),
                ),
                CircleAvatar(
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode ? Colors.white : Colors.black,  // Color del ícono según el tema
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: productoController,
              decoration: InputDecoration(
                labelText: "Nombre del producto",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black), // Color del label
              ),
            ),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(
                labelText: "Descripción",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
              ),
            ),
            TextField(
              controller: categoriaController,
              decoration: InputDecoration(
                labelText: "Categoría",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
              ),
            ),
            TextField(
              controller: stockController,
              decoration: InputDecoration(
                labelText: "Stock",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
              ),
            ),
            TextField(
              controller: precioController,
              decoration: InputDecoration(
                labelText: "Precio",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
              ),
            ),
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
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  isDarkMode ? Colors.blue[800] : Colors.blue,  // Color de fondo del botón según el tema
                ),
              ),
              child: Text(
                descripcion,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,  // Color del texto en el botón
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
