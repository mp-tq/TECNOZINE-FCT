import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/product_dialog.dart';
import '../../services/database_service.dart';

class BusquedaFiltradoScreen extends StatefulWidget {
  const BusquedaFiltradoScreen({super.key});

  @override
  State<BusquedaFiltradoScreen> createState() => _BusquedaFiltradoScreenState();
}

class _BusquedaFiltradoScreenState extends State<BusquedaFiltradoScreen> {
  final TextEditingController productoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final DatabaseService databaseService = DatabaseService();

  Stream<QuerySnapshot> getProductsFromFirestore() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 210, 228, 237),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Buscar por nombre o categoría",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() {}),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getProductsFromFirestore(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No hay productos disponibles"),
                  );
                }

                final products = snapshot.data!.docs;
                final searchText = searchController.text.toLowerCase();

                final filteredProducts =
                    products.where((product) {
                      var productData = product.data() as Map<String, dynamic>;
                      String name =
                          productData['producto'].toString().toLowerCase();
                      String category =
                          productData['categoria'].toString().toLowerCase();
                      return name.contains(searchText) ||
                          category.contains(searchText);
                    }).toList();

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var productData =
                        filteredProducts[index].data() as Map<String, dynamic>;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        leading: CircleAvatar(
                          child: Text((index + 1).toString()),
                        ),
                        title: Text(
                          productData['producto'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        subtitle: Text(productData['descripcion'].toString()),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      productoController.text =
                                          productData['producto'].toString();
                                      categoriaController.text =
                                          productData['categoria'].toString();
                                      descripcionController.text =
                                          productData['descripcion'].toString();
                                      stockController.text =
                                          productData['stock'].toString();
                                      precioController.text =
                                          productData['precio'].toString();

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ProductDialog(
                                            producto: "Actualizar producto",
                                            descripcion: "Actualizar",
                                            categoria: "Actualizar",
                                            stock: "Actualizar",
                                            precio: "Actualizar",
                                            productoController:
                                                productoController,
                                            descripcionController:
                                                descripcionController,
                                            categoriaController:
                                                categoriaController,
                                            stockController: stockController,
                                            precioController: precioController,
                                            onPressed: () {
                                              databaseService.updateProduct(
                                                filteredProducts[index].id,
                                                {
                                                  'producto':
                                                      productoController.text,
                                                  'descripcion':
                                                      descripcionController
                                                          .text,
                                                  'categoria':
                                                      categoriaController.text,
                                                  'stock': stockController.text,
                                                  'precio':
                                                      precioController.text,
                                                },
                                              );
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                    leading: const Icon(Icons.edit),
                                    title: const Text("Editar"),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      databaseService.deleteProduct(
                                        filteredProducts[index].id,
                                      );
                                    },
                                    leading: const Icon(Icons.delete),
                                    title: const Text("Eliminar"),
                                  ),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
