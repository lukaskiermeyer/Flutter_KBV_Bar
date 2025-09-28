import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../../providers/app_provider.dart';
import '../../../services/firebase.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _showProductDialog({Product? product}) async {
    final isEditing = product != null;
    final idController = TextEditingController(text: product?.id ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    bool requiresDeposit = product?.requiresDeposit ?? false;
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Produkt bearbeiten' : 'Neues Produkt'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'Produkt-ID (z.B. helles, pils)'),
                  enabled: !isEditing, // ID cannot be changed once created
                  validator: (value) => value == null || value.isEmpty ? 'ID ist erforderlich' : null,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Anzeigename'),
                  validator: (value) => value == null || value.isEmpty ? 'Name ist erforderlich' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Preis'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Preis ist erforderlich';
                    if (double.tryParse(value) == null) return 'Ungültige Zahl';
                    return null;
                  },
                ),
                StatefulBuilder(builder: (context, setDialogState) {
                  return SwitchListTile(
                    title: const Text('Pfandpflichtig'),
                    value: requiresDeposit,
                    onChanged: (value) {
                      setDialogState(() {
                        requiresDeposit = value;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newProduct = Product(
                    id: idController.text,
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    requiresDeposit: requiresDeposit,
                  );
                  await _firestoreService.saveProduct(newProduct);
                  // Refresh the data in the provider to show the change
                  await Provider.of<AppProvider>(context, listen: false).refreshData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use a consumer here so the list rebuilds when data is refreshed
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Produkte verwalten'),
          ),
          body: ListView.builder(
            itemCount: appProvider.products.length,
            itemBuilder: (context, index) {
              final product = appProvider.products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('ID: ${product.id} | Pfand: ${product.requiresDeposit ? 'Ja' : 'Nein'}'),
                trailing: Text('${product.price.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16)),
                onTap: () => _showProductDialog(product: product),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showProductDialog(),
            tooltip: 'Neues Produkt hinzufügen',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

