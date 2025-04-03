import 'package:flutter/material.dart';
import 'package:flutter_prueba_mil/models/producto.dart';

class PantallaBusquedaFiltro extends StatefulWidget {
  const PantallaBusquedaFiltro({super.key});

  @override
  EstadoProductos createState() => EstadoProductos();
}

class EstadoProductos extends State<PantallaBusquedaFiltro> {
  final List<Producto> productos = [
    Producto(
      nombre: 'iPhone 14',
      descripcion: 'Teléfono móvil de última generación',
      categoria: 'Teléfonos',
      stock: 10,
      precio: 999.99,
    ),
    Producto(
      nombre: 'Samsung Galaxy S23',
      descripcion: 'Smartphone con cámara avanzada',
      categoria: 'Teléfonos',
      stock: 15,
      precio: 899.99,
    ),
    Producto(
      nombre: 'MacBook Pro',
      descripcion: 'Ordenador portátil de alto rendimiento',
      categoria: 'Ordenadores',
      stock: 8,
      precio: 1999.99,
    ),
    Producto(
      nombre: 'Dell XPS 13',
      descripcion: 'Laptop potente y liviano',
      categoria: 'Ordenadores',
      stock: 12,
      precio: 1299.99,
    ),
    Producto(
      nombre: 'Google Pixel 7',
      descripcion: 'Smartphone con Android puro',
      categoria: 'Teléfonos',
      stock: 20,
      precio: 799.99,
    ),
  ];

  String consultaBusqueda = "";
  String categoriaSeleccionada = "Todas";
  double precioMaximo = 2000.0;

  List<Producto> get productosFiltrados =>
      productos.where((producto) {
        final coincideNombre = producto.nombre.toLowerCase().contains(
          consultaBusqueda.toLowerCase(),
        );
        final coincideCategoria =
            categoriaSeleccionada == "Todas" ||
            producto.categoria == categoriaSeleccionada;
        final coincidePrecio = producto.precio <= precioMaximo;
        return coincideNombre && coincideCategoria && coincidePrecio;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda y Filtro')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => consultaBusqueda = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: categoriaSeleccionada,
              isExpanded: true,
              onChanged:
                  (value) => setState(() => categoriaSeleccionada = value!),
              items:
                  ["Todas", "Teléfonos", "Ordenadores"]
                      .map(
                        (categoria) => DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria),
                        ),
                      )
                      .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filtrar por precio máximo"),
                Slider(
                  value: precioMaximo,
                  min: 0,
                  max: 2000,
                  divisions: 20,
                  label: "€${precioMaximo.toStringAsFixed(2)}",
                  onChanged: (value) => setState(() => precioMaximo = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productosFiltrados.length,
              itemBuilder: (context, index) {
                final producto = productosFiltrados[index];
                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text(
                    "${producto.descripcion}\nStock: ${producto.stock} - Precio: €${producto.precio}",
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
