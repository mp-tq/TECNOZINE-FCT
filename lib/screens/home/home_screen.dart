import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prueba_mil/providers/user_provider.dart';
import 'package:flutter_prueba_mil/services/database_service.dart';
import 'package:provider/provider.dart';
import '../../widgets/product_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  void dispose() {
    productoController.dispose();
    descripcionController.dispose();
    categoriaController.dispose();
    stockController.dispose();
    precioController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 210, 228, 237),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFF03405D),
          title: Text(
            "Productos - ${userProvider.name ?? 'Guest'}",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                userProvider.clearUser();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de búsqueda
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

                  // Filtrar productos según el texto de búsqueda
                  final filteredProducts = products.where((product) {
                    var productData = product.data() as Map<String, dynamic>;
                    String name = productData['producto'].toString().toLowerCase();
                    String category = productData['categoria'].toString().toLowerCase();
                    return name.contains(searchText) || category.contains(searchText);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var productData = filteredProducts[index].data() as Map<String, dynamic>;

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
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                    productoController.text = productData['producto'].toString();
                                    categoriaController.text = productData['categoria'].toString();
                                    descripcionController.text = productData['descripcion'].toString();
                                    stockController.text = productData['stock'].toString();
                                    precioController.text = productData['precio'].toString();

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ProductDialog(
                                          producto: "Actualizar producto",
                                          descripcion: "Actualizar",
                                          categoria: "Actualizar",
                                          stock: "Actualizar",
                                          precio: "Actualizar",
                                          productoController: productoController,
                                          descripcionController: descripcionController,
                                          categoriaController: categoriaController,
                                          stockController: stockController,
                                          precioController: precioController,
                                          onPressed: () {
                                            databaseService.updateProduct(
                                              filteredProducts[index].id,
                                              {
                                                'producto': productoController.text,
                                                'descripcion': descripcionController.text,
                                                'categoria': categoriaController.text,
                                                'stock': stockController.text,
                                                'precio': precioController.text,
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
                                    databaseService.deleteProduct(filteredProducts[index].id);
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            productoController.clear();
            descripcionController.clear();
            categoriaController.clear();
            stockController.clear();
            precioController.clear();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ProductDialog(
                  producto: "Crear producto",
                  descripcion: "Añadir",
                  categoria: "Añadir",
                  stock: "Añadir",
                  precio: "Añadir",
                  productoController: productoController,
                  descripcionController: descripcionController,
                  categoriaController: categoriaController,
                  stockController: stockController,
                  precioController: precioController,
                  onPressed: () {
                    final id = DateTime.now().millisecondsSinceEpoch.toString();
                    databaseService.createProduct({
                      'producto': productoController.text,
                      'descripcion': descripcionController.text,
                      'categoria': categoriaController.text,
                      'stock': stockController.text,
                      'precio': precioController.text,
                      'id': id,
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}