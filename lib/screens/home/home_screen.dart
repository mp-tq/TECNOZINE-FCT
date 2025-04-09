import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prueba_mil/screens/export/export_options_screen.dart';
import 'package:flutter_prueba_mil/screens/history/history_screen.dart';
import 'package:flutter_prueba_mil/screens/login/login_screen.dart'; 
import 'package:flutter_prueba_mil/services/database_service.dart';
import 'package:flutter_prueba_mil/providers/user_provider.dart';
import 'package:provider/provider.dart'; 
import 'package:flutter_prueba_mil/providers/theme_provider.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context); // Acceder al ThemeProvider

    // Detectar si el tema es oscuro
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Cambiar solo en el UserAccountsDrawerHeader
            UserAccountsDrawerHeader(
              accountName: Text(
                userProvider.name ?? 'Cargando...',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Solo afecta el color del nombre
                ),
              ),
              accountEmail: Text(
                userProvider.email ?? 'Cargando...',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Solo afecta el color del email
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50.0),
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.blue, // Fondo del header solo en el Drawer
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
            // Switch para cambiar entre el modo claro y oscuro
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(themeProvider.isDarkMode ? 'Modo Claro' : 'Modo Oscuro'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);  // Cambiar el tema
                  Navigator.pop(context);  // Cerrar el Drawer
                },
              ),
            ),
            // Opción de Logout al final
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar sesión'),
              onTap: () {
                // Limpiar el estado del usuario
                userProvider.clearUser();
                // Redirigir al login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()), 
                  (Route<dynamic> route) => false, 
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)  // Color de fondo oscuro
          : const Color.fromARGB(255, 210, 228, 237),  // Color de fondo claro
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode
            ? const Color(0xFF1E1E1E)  // Color de AppBar oscuro
            : const Color.fromARGB(255, 3, 64, 93),  // Color de AppBar claro
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
                  padding: const EdgeInsets.only(bottom: 90.0),
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
