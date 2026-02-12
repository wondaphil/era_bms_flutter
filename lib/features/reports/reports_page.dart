import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_drawer.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  Widget _quickCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(route),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [
          _quickCard(
            context,
            'Inventory Reports',
            Icons.inventory_2,
            '/reports/inventoryreports',
          ),
          _quickCard(
            context,
            'Inspection Reports',
            Icons.fact_check,
            '/reports/inspectionreports',
          ),
					_quickCard(
            context,
            'Inventory Charts',
            Icons.bar_chart,
            '/reports/inventorycharts',
          ),
          _quickCard(
            context,
            'Inspection Charts',
            Icons.analytics,
            '/reports/inspectioncharts',
          ),
        ],
      ),
    );
  }
}