import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bar.dart';
import '../models/product.dart';
import '../models/sales.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Product Functions ---

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<void> saveProduct(Product product) async {
    try {
      await _db.collection('products').doc(product.id).set(product.toFirestore());
    } catch (e) {
      print('Error saving product: $e');
      rethrow;
    }
  }

  // --- Bar Functions ---

  Stream<List<Bar>> getBars() {
    return _db.collection('bars').snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => Bar.fromFirestore(doc)).toList());
  }

  // THE FIX IS HERE:
  // We are now updating the field named 'products' to match our bar.dart model.
  Future<void> updateBarMenu(String barId, List<String> productIds) async {
    try {
      await _db.collection('bars').doc(barId).update({'products': productIds});
    } catch (e) {
      print('Error updating bar menu: $e');
      rethrow;
    }
  }

  // --- Sales Functions ---

  Future<void> recordSales(List<Sale> sales) async {
    try {
      final WriteBatch batch = _db.batch();
      for (final sale in sales) {
        final docRef = _db.collection('sales').doc();
        batch.set(docRef, sale.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      print('Error recording sales: $e');
      rethrow;
    }
  }

  Stream<List<Sale>> getSalesStream() {
    return _db.collection('sales').snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }
}
