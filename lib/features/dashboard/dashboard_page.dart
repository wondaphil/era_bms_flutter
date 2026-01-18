import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_view_model.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/widgets/app_svg_icon.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

  double _imageSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 120; // Desktop
    if (width >= 600) return 100; // Tablet
    return 64; // Phone
  }

  double _mainLogoSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 200;
    if (width >= 600) return 280;
    return 204;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(dashboardViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = Theme.of(context).colorScheme.primary;
    final imageSize = _imageSize(context);

    Widget framedImage(String asset) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
        ),
        child: Image.asset(
          asset,
          height: imageSize,
          fit: BoxFit.contain,
        ),
      );
    }

    return Scaffold(
      drawer: const AppDrawer(),
			appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: vm.onLogout,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Exit',
            onPressed: vm.onExit,
          ),
          PopupMenuButton<String>(
            onSelected: vm.onMenuSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'web', child: Text('Web ERA-BMS')),
              PopupMenuItem(value: 'help', child: Text('Help')),
              PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 15, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  vm.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: borderColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                framedImage('assets/images/dashboard/home_01a.jpg'),
                framedImage('assets/images/dashboard/home_02a.jpg'),
                framedImage('assets/images/dashboard/home_03a.jpg'),
                framedImage('assets/images/dashboard/home_04a.jpg'),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'የኢትዮጵያ መንገዶች አስተዳደር',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Nyala', fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 6),

            const Text(
              'Ethiopian Roads Administration',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 16),

            Image.asset(
              isDark
                  ? 'assets/images/logos/bms_icon_light.png'
                  : 'assets/images/logos/bms_icon.png',
              height: _mainLogoSize(context),
            ),

            const SizedBox(height: 16),

            const Text(
              'Bridge Management System',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 12),

            Image.asset(
              'assets/images/logos/era_bms.png',
              height: 60,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                framedImage('assets/images/dashboard/home_05a.jpg'),
                framedImage('assets/images/dashboard/home_06a.jpg'),
                framedImage('assets/images/dashboard/home_07a.jpg'),
                framedImage('assets/images/dashboard/home_08a.jpg'),
              ],
            ),

            const SizedBox(height: 30),
						
						Padding(
							padding: const EdgeInsets.symmetric(vertical: 8),
							child: GridView.count(
								crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
								shrinkWrap: true,
								physics: const NeverScrollableScrollPhysics(),
								mainAxisSpacing: 12,
								crossAxisSpacing: 12,
								children: [
									_quickCard(context, AppSvgIcon(asset: 'assets/icons/bridge.svg'), 'Bridges', '/bridges'),
									_quickCard(context, AppSvgIcon(asset: 'assets/icons/culvert.svg'), 'Culverts', '/culverts'),
									_quickCard(context, Icon(Icons.description), 'Reports', '/reports'),
									_quickCard(context, Icon(Icons.bar_chart), 'Charts', '/charts'),
								],
							),
						),
          ],
        ),
      ),
    );
  }
}

Widget _quickCard(
  BuildContext context,
  Widget icon,
  String title,
  String route,
) {
  return Card(
    elevation: 2,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.go(route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    ),
  );
}