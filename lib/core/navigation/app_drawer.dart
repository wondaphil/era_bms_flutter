import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_svg_icon.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SafeArea(
						bottom: false, 
						child: Container(
							height: 72,
							padding: const EdgeInsets.symmetric(horizontal: 16),
							alignment: Alignment.centerLeft,
							color: Theme.of(context).colorScheme.primaryContainer,
							child: Image.asset(
								Theme.of(context).brightness == Brightness.dark
										? 'assets/images/logos/era_logo_light.png'
										: 'assets/images/logos/era_logo.png',
								height: 48,
								fit: BoxFit.contain,
							),
						),
					),

          _item(context, const Icon(Icons.home), 'Home', '/'),
					
					const Divider(),
					_item(context, Icon(Icons.fact_check), 'Bridge Inventory/Inspection', '/bridge-inspection'),
          _item(context, Icon(Icons.fact_check_outlined), 'Culvert Inventory/Inspection', '/culvert-inspection'),

          const Divider(),
					_item(context, Icon(Icons.route), 'Location/Route', '/location'),
          
					_item(context, Icon(Icons.settings), 'Settings', '/settings'),
					const Divider(),
					
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  Widget _item(
		BuildContext context,
		Widget icon, // ✅ accepts SVG or Icon
		String title,
		String route,
	) {
		final currentRoute =
				GoRouter.of(context).routeInformationProvider.value.uri.path;

		final isSelected = route == '/'
				? (currentRoute == '/' || currentRoute.isEmpty)
				: (currentRoute == route ||
						currentRoute.startsWith('$route/'));

		return ListTile(
			leading: icon, // ✅ use widget directly
			title: Text(
				title,
				style: TextStyle(
					color: isSelected ? Colors.white : null,
					fontWeight: isSelected ? FontWeight.w600 : null,
				),
			),
			selected: isSelected,
			selectedTileColor: AppTheme.brandOrange,
			onTap: () {
				Navigator.pop(context);
				if (!isSelected) {
					context.push(route);
				}
			},
		);
	}
}