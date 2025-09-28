import 'package:flutter/material.dart';
import '../models/bar.dart';
import '../models/product.dart';
import '../services/firebase.dart';

class AppProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Bar> _bars = [];
  List<Product> _products = [];
  Bar? _selectedBar;
  bool _isLoading = true;

  List<Bar> get bars => _bars;
  List<Product> get products => _products;
  Bar? get selectedBar => _selectedBar;
  bool get isLoading => _isLoading;

  AppProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // THE FIX IS HERE:
      // We are now waiting for the *first emission* from the stream,
      // which acts like a Future and is compatible with Future.wait.
      final results = await Future.wait([
        _firestoreService.getBars().first,
        _firestoreService.getProducts().first,
      ]);

      _bars = results[0] as List<Bar>;
      _products = results[1] as List<Product>;

    } catch (e) {
      print("Error loading initial data in provider: $e");
      // Handle error appropriately, maybe set an error state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectBar(Bar bar) {
    _selectedBar = bar;
    notifyListeners();
  }

  void deselectBar() {
    _selectedBar = null;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    await _loadInitialData();
  }
}

