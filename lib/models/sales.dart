import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String productId;
  final String barId;
  final double price;
  final DateTime timestamp;
  // We don't need an ID for sales documents, as they are write-only for us.
  // But if we ever wanted to display them, we would add 'final String id;' here.

  Sale({
    required this.productId,
    required this.barId,
    required this.price,
    required this.timestamp,
  });


  factory Sale.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Sale(
      productId: data['productId'] ?? '',
      barId: data['barId'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'barId': barId,
      'price': price,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
