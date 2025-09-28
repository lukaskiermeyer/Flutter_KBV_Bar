import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bar.dart';
import '../../providers/app_provider.dart';
import 'admin/admin_login_screen.dart';
import 'statistics_screen.dart';
import 'cash_register_screen.dart';

class BarSelectionScreen extends StatelessWidget {
  const BarSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    // Navigate to cash register if a bar is already selected
    if (appProvider.selectedBar != null) {
      return const CashRegisterScreen();
    }


    return Scaffold(
      appBar: AppBar(
        // Your new logo is included
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/KBVLogo.png', height: 35),
            const SizedBox(width: 10),
            const Text('Wähle deine Bar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminLoginScreen()));
            },
            tooltip: 'Admin Bereich',
          ),
        ],
      ),
      body: appProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appProvider.bars.isEmpty
          ? const Center(child: Text('Keine Bars in der Datenbank gefunden.'))
      // We re-introduce the Column to make space for the button
          : Column(
        children: [
          // The GridView is wrapped in Expanded to fill the available space
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 2,
              ),
              itemCount: appProvider.bars.length,
              itemBuilder: (context, index) {
                final bar = appProvider.bars[index];
                // Your updated BarCard is used here
                return BarCard(
                  bar: bar,
                  onTap: () => appProvider.selectBar(bar),
                );
              },
            ),
          ),
          // THE STATISTICS BUTTON IS INSERTED HERE
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('Live-Statistiken anzeigen'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Your new BarCard implementation with dynamic images
class BarCard extends StatelessWidget {
  final Bar bar;
  final VoidCallback onTap;

  const BarCard({Key? key, required this.bar, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                bar.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          // Your dynamic image loading logic is preserved
          child: Image.asset('assets/images/${bar.name}.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}


