import 'package:flutter/material.dart';
import 'package:flutter_prueba_mil/screens/home/home_screen.dart' as home;
import 'package:flutter_prueba_mil/screens/busqueda/busqueda_filtrado.dart' as busqueda;
import 'package:provider/provider.dart';
import 'package:flutter_prueba_mil/providers/theme_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const home.HomeScreen(),
    const busqueda.BusquedaFiltradoScreen(),
  ];

  final List<String> _titles = ["Productos", "Filtrar Productos"];

  @override
  Widget build(BuildContext context) {
    // Obtener el estado del tema desde el provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: const Color.fromARGB(255, 3, 64, 93),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 3, 64, 93),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Modo Oscuro/Claro'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}