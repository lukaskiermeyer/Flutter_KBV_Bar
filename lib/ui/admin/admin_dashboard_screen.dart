import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import 'manage_products_screen.dart';
import 'manage_bar_menu_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DashboardCard(
            title: 'Produkte verwalten',
            icon: Icons.fastfood,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageProductsScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text("Bar-Menüs bearbeiten", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          // Create a list of cards for each bar
          ...appProvider.bars.map((bar) {
            return _DashboardCard(
              title: bar.name,
              icon: Icons.local_bar,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageBarMenuScreen(bar: bar)),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontSize: 20)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
