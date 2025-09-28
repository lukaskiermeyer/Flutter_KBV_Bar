import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/product.dart';
import '../../models/sales.dart';
import '../../providers/app_provider.dart';
import '../../services/firebase.dart';
import '../widgets/product_card.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({Key? key}) : super(key: key);

  @override
  _CashRegisterScreenState createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  // State variables
  final Map<Product, int> _currentOrder = {};
  final List<List<Product>> _actionHistory = [];
  final FirestoreService _firestoreService = FirestoreService();

  // Virtual products for deposit handling
  final Product _depositProduct = Product(id: '__deposit__', name: '+ Pfand', price: 2.0, requiresDeposit: false);
  final Product _returnDepositProduct = Product(id: '__return_deposit__', name: '- Pfand (Rückgabe)', price: -2.0, requiresDeposit: false);

  // --- Core Logic Methods ---

  void _addAction(List<Product> productsInAction) {
    setState(() {
      _actionHistory.add(productsInAction);
      for (final product in productsInAction) {
        _currentOrder.update(product, (value) => value + 1, ifAbsent: () => 1);
      }
    });
  }

  void _undoLastAction() {
    setState(() {
      if (_actionHistory.isNotEmpty) {
        final lastAction = _actionHistory.removeLast();
        for (final product in lastAction) {
          if (_currentOrder.containsKey(product)) {
            _currentOrder.update(product, (value) => value - 1);
            if (_currentOrder[product]! <= 0) {
              _currentOrder.remove(product);
            }
          }
        }
      }
    });
  }

  Future<void> _finalizeSale() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (_currentOrder.isEmpty || appProvider.selectedBar == null) return;

    final List<Sale> sales = [];
    _currentOrder.forEach((product, quantity) {
      for (int i = 0; i < quantity.abs(); i++) {
        sales.add(Sale(
          productId: product.id,
          barId: appProvider.selectedBar!.id,
          price: product.price,
          timestamp: DateTime.now(),
        ));
      }
    });

    try {
      await _firestoreService.recordSales(sales);
      setState(() {
        _currentOrder.clear();
        _actionHistory.clear();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verkauf erfolgreich gespeichert!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showChangeDialog(double total) {
    final List<double> commonGivenAmounts = [5.0, 10.0, 20.0, 50.0];

    double nextAmount = 0;
    if (total > 0) {
      nextAmount = commonGivenAmounts.firstWhere((amount) => amount >= total, orElse: () {
        return (total / 50).ceil() * 50.0;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rückgeld-Rechner'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gesamtbetrag: ${total.toStringAsFixed(2)} €',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Divider(height: 20),
              if (total > 0) ...[
                _buildChangeOption(total, nextAmount),
                if (nextAmount < 50) _buildChangeOption(total, nextAmount + 10),
                if (nextAmount < 20) _buildChangeOption(total, 20),
              ] else ...[
                const Text('Pfandrückgabe oder kostenlos.')
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _finalizeSale();
              },
              child: const Text('Verkauf abschließen'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChangeOption(double total, double given) {
    if (given < total) return const SizedBox.shrink();
    final change = given - total;
    return ListTile(
      title: Text('Gegeben: ${given.toStringAsFixed(2)} €'),
      trailing: Text(
        'Rückgeld: ${change.toStringAsFixed(2)} €',
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.kbvGreen),
      ),
    );
  }

  void _showFullscreenOrder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        double total = _currentOrder.entries
            .fold(0.0, (sum, item) => sum + (item.key.price * item.value));

        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 1.0,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Bestellübersicht', style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: _currentOrder.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = _currentOrder.entries.elementAt(index);
                        return ListTile(
                          title: Text(entry.key.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text('${entry.value} x ${entry.key.price.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16)),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Gesamt: ${total.toStringAsFixed(2)} €',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final selectedBar = appProvider.selectedBar;

    if (selectedBar == null) {
      return const Scaffold(body: Center(child: Text('Keine Bar ausgewählt.')));
    }

    final List<Product> menu = appProvider.products
        .where((product) => selectedBar.menuProductIds.contains(product.id))
        .where((product) => product.id.toLowerCase() != 'deposit')
        .toList();

    double total = _currentOrder.entries
        .fold(0.0, (sum, item) => sum + (item.key.price * item.value));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/SBLogo.png', height: 35),
            const SizedBox(width: 8),
            Text(selectedBar.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AppProvider>(context, listen: false).deselectBar(),
            tooltip: 'Bar wechseln',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  final product = menu[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      if (product.requiresDeposit) {
                        _addAction([product, _depositProduct]);
                      } else {
                        _addAction([product]);
                      }
                    },
                  );
                },
              ),
            ),

            _buildActionButtons(),
            _buildCurrentOrderSheet(total),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.remove_circle),
              label: const Text('Pfand-Rückgabe'),
              onPressed: () => _addAction([_returnDepositProduct]),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.undo),
              label: const Text('Letzte Eingabe'),
              onPressed: _actionHistory.isNotEmpty ? _undoLastAction : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOrderSheet(double total) {
    return Material(
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bestellung (${_currentOrder.length} Posten)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: AppTheme.kbvGreen),
                  onPressed: _currentOrder.isNotEmpty ? _showFullscreenOrder : null,
                ),
              ],
            ),
            if (_currentOrder.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _currentOrder.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Chip(
                        label: Text('${entry.value}x ${entry.key.name}'),
                        backgroundColor: AppTheme.kbvGreen.withOpacity(0.1),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gesamt:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${total.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.kbvGreen),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _currentOrder.isNotEmpty ? () => _showChangeDialog(total) : null,
              icon: const Icon(Icons.check_circle),
              label: const Text('Verkauf abschließen'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green.shade600
              ),
            ),
          ],
        ),
      ),
    );
  }
}

