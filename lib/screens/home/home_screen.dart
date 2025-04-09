import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prueba_mil/screens/export/export_options_screen.dart';
import 'package:flutter_prueba_mil/screens/history/history_screen.dart';
import 'package:flutter_prueba_mil/screens/login/login_screen.dart'; // Asegúrate de importar la pantalla de login
import 'package:flutter_prueba_mil/services/database_service.dart';
import 'package:flutter_prueba_mil/providers/user_provider.dart';
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

  // Obtener productos desde Firestore
  Stream<QuerySnapshot> getProductsFromFirestore() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userProvider.name ?? 'Cargando...'),
              accountEmail: Text(userProvider.email ?? 'Cargando...'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50.0),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de Movimientos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Exportar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportOptionsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // Opción de Logout
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar sesión'),
              onTap: () {
                // Limpiar el estado del usuario
                userProvider.clearUser();

                // Redirigir al login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()), // Aquí pones la pantalla de login
                  (Route<dynamic> route) => false, // Elimina las pantallas anteriores de la pila de navegación
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 210, 228, 237),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 64, 93),
        title: const Text(
          "Productos",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o categoría',
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
                  return const Center(child: Text("No hay productos disponibles"));
                }

                final products = snapshot.data!.docs;
                final searchText = searchController.text.toLowerCase();

                // Filtrar productos por nombre o categoría
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
                        leading: CircleAvatar(child: Text((index + 1).toString())),
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
                                        productoController: productoController,
                                        descripcionController: descripcionController,
                                        categoriaController: categoriaController,
                                        stockController: stockController,
                                        precioController: precioController,
                                        onPressed: () {
                                          databaseService.updateProduct(
                                            products[index].id,
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
                                  databaseService.deleteProduct(
                                    products[index].id,
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
    );
  }
}
