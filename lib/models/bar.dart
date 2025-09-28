import 'package:cloud_firestore/cloud_firestore.dart';

class Bar {
  final String id;
  final String name;
  final List<String> menuProductIds;

  Bar({required this.id, required this.name, required this.menuProductIds});

  factory Bar.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;


    final menuData = data['products'];

    final List<String> productIds = (menuData is List)
        ? menuData.map((item) => item.toString()).toList()
        : [];

    return Bar(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Bar',
      menuProductIds: productIds, // The variable name inside our app stays clean
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'products': menuProductIds,
    };
  }
}