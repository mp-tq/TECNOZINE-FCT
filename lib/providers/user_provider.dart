import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _email;
  String? _name;

  String? get email => _email;
  String? get name => _name;

  void setUser(String email, String name) {
    _email = email;
    _name = name;
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

  void clearUser() {
    _email = null;
    _name = null;
    notifyListeners();
  }
}