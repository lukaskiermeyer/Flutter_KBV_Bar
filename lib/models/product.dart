import 'package:cloud_firestore/cloud_firestore.dart';


class Product {
  final String id;
  final String name;
  final double price;
  final bool requiresDeposit;
  final String? description; // NEW: Optional field for info text

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.requiresDeposit,
    this.description, // Added to constructor
  });

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      requiresDeposit: data['deposit'] ?? false, // Using 'deposit' as you configured
      description: data['description'] as String?, // Reading the new field
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'deposit': requiresDeposit,
      'description': description, // Writing the new field
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
