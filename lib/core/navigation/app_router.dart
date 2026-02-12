import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../core/navigation/main_shell_page.dart';
import '../../features/bridges/bridges_page.dart';
import '../../features/culverts/culverts_page.dart';
import '../../features/bridges/bridges_by_location_page.dart';
import '../../features/bridges/bridges_by_route_page.dart';
import '../../features/bridges/bridge_detail_page.dart';
import '../../features/bridges/bridge_edit_page.dart';
import '../../features/bridges/bridge_new_page.dart';
import '../../features/culverts/culverts_by_location_page.dart';
import '../../features/culverts/culverts_by_route_page.dart';
import '../../features/culverts/culvert_detail_page.dart';
import '../../features/culverts/culvert_edit_page.dart';
import '../../features/culverts/culvert_new_page.dart';
import '../../features/reports/reports_page.dart';
import '../../features/reports/inventory_reports_page.dart';
import '../../features/reports/inspection_reports_page.dart';
import '../../features/reports/inventory_charts_page.dart';
import '../../features/reports/inspection_charts_page.dart';
import '../../features/maps/bridge_map_page.dart';
import '../../features/maps/bridge_map_by_segment_page.dart';
import '../../features/maps/culvert_map_page.dart';
import '../../features/maps/culvert_map_by_segment_page.dart';
import '../../features/tracking/active_users_map_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/settings/download_data_page.dart';
import '../../features/settings/view_all_tables_page.dart';
import '../../features/help/about_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      //builder: (context, state) => const DashboardPage(),
			builder: (context, state) => const MainShellPage(),
    ),

    GoRoute(
      path: '/bridges',
      builder: (context, state) => const BridgesPage(),
    ),

    GoRoute(
      path: '/culverts',
      builder: (context, state) => const CulvertsPage(),
    ),

    GoRoute(
      path: '/bridgesbylocation',
      builder: (context, state) => const BridgesByLocationPage(),
    ),

    GoRoute(
      path: '/bridgesbyroute',
      builder: (context, state) => const BridgesByRoutePage(),
    ),

    GoRoute(
      path: '/culvertsbylocation',
      builder: (context, state) => const CulvertsByLocationPage(),
    ),

    GoRoute(
      path: '/culvertsbyroute',
      builder: (context, state) => const CulvertsByRoutePage(),
    ),
		
		GoRoute(
			path: '/bridge/new',
			builder: (context, state) => const BridgeNewPage(),
		),
		
		GoRoute(
			path: '/culvert/new',
			builder: (context, state) => const CulvertNewPage(),
		),
		
		GoRoute(
			path: '/bridge/:id',
			builder: (context, state) {
				final bridgeId = state.pathParameters['id']!;
				return BridgeDetailPage(bridgeId: bridgeId);
			},
		),

		GoRoute(
			path: '/culvert/:id',
			builder: (context, state) {
				final culvertId = state.pathParameters['id']!;
				return CulvertDetailPage(culvertId: culvertId);
			},
		),
		
		GoRoute(
			path: '/bridge/edit/:id',
			builder: (context, state) {
				final bridgeId = state.pathParameters['id']!;
				return BridgeEditPage(bridgeId: bridgeId);
			},
		),
		
		GoRoute(
			path: '/culvert/edit/:id',
			builder: (context, state) {
				final culvertId = state.pathParameters['id']!;
				return CulvertEditPage(culvertId: culvertId);
			},
		),
		
		GoRoute(
			path: '/reports',
			builder: (context, state) => const ReportsPage(),
		),
		
		GoRoute(
			path: '/reports/inventoryreports',
			builder: (context, state) => const InventoryReportsPage(),
		),
		
		GoRoute(
			path: '/reports/inspectionreports',
			builder: (context, state) => const InspectionReportsPage(),
		),
		
		GoRoute(
			path: '/reports/inventorycharts',
			builder: (context, state) => const InventoryChartsPage(),
		),

		GoRoute(
			path: '/reports/inspectioncharts',
			builder: (context, state) => const InspectionChartsPage(),
		),
		
		GoRoute(
			path: '/bridge/map/:id',
			builder: (context, state) {
				final bridgeId = state.pathParameters['id']!;
				return BridgeMapPage(bridgeId: bridgeId);
			},
		),

		GoRoute(
			path: '/culvert/map/:id',
			builder: (context, state) {
				final culvertId = state.pathParameters['id']!;
				return CulvertMapPage(culvertId: culvertId);
			},
		),

		GoRoute(
			path: '/bridge/segmentmap/:segmentId',
			builder: (context, state) {
				final segmentId = state.pathParameters['segmentId']!;
				return BridgeMapBySegmentPage(segmentId: segmentId);
			},
		),

		GoRoute(
			path: '/culvert/segmentmap/:segmentId',
			builder: (context, state) {
				final segmentId = state.pathParameters['segmentId']!;
				return CulvertMapBySegmentPage(segmentId: segmentId);
			},
		),
		
		GoRoute(
			path: '/settings',
			builder: (context, state) => const SettingsPage(),
		),

		GoRoute(
			path: '/settings/tables',
			builder: (context, state) => const ViewAllTablesPage(),
		),
		
		GoRoute(
			path: '/settings/activeusers',
			builder: (context, state) => const ActiveUsersMapPage(),
		),
		
		GoRoute(
			path: '/settings/download',
			builder: (_, __) => const DownloadDataPage(),
		),
		
		GoRoute(
			path: '/about',
			builder: (context, state) => const AboutPage(),
		),
  ],
);
