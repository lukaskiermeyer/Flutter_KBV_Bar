import 'package:flutter/material.dart';
import '../../../models/bar.dart';
import '../../../models/product.dart';
import '../../../providers/app_provider.dart';
import '../../../services/firebase.dart';
import 'package:provider/provider.dart';

class ManageBarMenuScreen extends StatefulWidget {
  final Bar bar;
  const ManageBarMenuScreen({Key? key, required this.bar}) : super(key: key);

  @override
  _ManageBarMenuScreenState createState() => _ManageBarMenuScreenState();
}

class _ManageBarMenuScreenState extends State<ManageBarMenuScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late List<String> _selectedProductIds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProductIds = List<String>.from(widget.bar.menuProductIds);
  }

  // THE FIX IS HERE: The save function is now async and handles a loading state.
  Future<void> _saveMenu() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.updateBarMenu(widget.bar.id, _selectedProductIds);
      // Refresh data in the provider after saving
      await Provider.of<AppProvider>(context, listen: false).refreshData();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menü erfolgreich gespeichert!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final allProducts = Provider.of<AppProvider>(context).products;

    return Scaffold(
      appBar: AppBar(
        title: Text('Menü: ${widget.bar.name}'),
        actions: [
          // The save button now triggers the async save function
          _isLoading
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(color: Colors.white),
          )
              : IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMenu,
            tooltip: 'Menü Speichern',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: allProducts.length,
        itemBuilder: (context, index) {
          final product = allProducts[index];
          final isSelected = _selectedProductIds.contains(product.id);
          return CheckboxListTile(
            title: Text(product.name),
            subtitle: Text('${product.price.toStringAsFixed(2)} €'),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedProductIds.add(product.id);
                } else {
                  _selectedProductIds.remove(product.id);
                }
              });
            },
          );
        },
      ),
    );
  }
}

