import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../../models/sales.dart';
import '../../../providers/app_provider.dart';
import '../../../services/firebase.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final allProductsFromProvider = Provider.of<AppProvider>(context, listen: false).products;

    // Erstellt eine vollständige Produktliste, die auch virtuelle Pfand-Produkte enthält.
    final allProducts = [
      ...allProductsFromProvider,
      Product(id: '__deposit__', name: '+ Pfand', price: 2.0, requiresDeposit: false),
      Product(id: '__return_deposit__', name: '- Pfand (Rückgabe)', price: -2.0, requiresDeposit: false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live-Statistiken'),
      ),
      // StreamBuilder lauscht auf Live-Daten von Firestore
      body: StreamBuilder<List<Sale>>(
        stream: firestoreService.getSalesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Noch keine Verkäufe registriert.'));
          }

          final sales = snapshot.data!;

          // --- Datenverarbeitung ---
          double totalRevenue = 0;
          final Map<String, int> quantityPerProduct = {};
          final Map<String, double> revenuePerProduct = {};

          for (final sale in sales) {
            totalRevenue += sale.price;
            quantityPerProduct.update(sale.productId, (value) => value + 1, ifAbsent: () => 1);
            revenuePerProduct.update(sale.productId, (value) => value + sale.price, ifAbsent: () => sale.price);
          }

          final sortedProductsByRevenue = revenuePerProduct.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Zusammenfassungs-Karten ---
              _buildSummaryCard('Gesamtumsatz', '${totalRevenue.toStringAsFixed(2)} €', Icons.euro, Colors.green),
              const SizedBox(height: 16),
              _buildSummaryCard('Verkaufte Posten', '${sales.length}', Icons.shopping_cart, Colors.blue),
              const SizedBox(height: 24),

              // --- Detaillierte Liste ---
              Text('Umsatz pro Produkt', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              ...sortedProductsByRevenue.map((entry) {
                final productId = entry.key;
                final revenue = entry.value;
                final quantity = quantityPerProduct[productId] ?? 0;

                // Findet den Produktnamen aus unserer Produktliste
                final product = allProducts.firstWhere(
                        (p) => p.id == productId,
                    orElse: () => Product(id: productId, name: 'Unbekanntes Produkt', price: 0, requiresDeposit: false)
                );

                return ListTile(
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$quantity x verkauft'),
                  trailing: Text(
                    '${revenue.toStringAsFixed(2)} €',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

