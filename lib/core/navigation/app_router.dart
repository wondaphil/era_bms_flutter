import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/bridges/bridges_page.dart';
import '../../features/culverts/culverts_page.dart';
import '../../features/bridges/bridges_by_location_page.dart';
import '../../features/bridges/bridges_by_route_page.dart';
import '../../features/bridges/bridge_detail_page.dart';
import '../../features/culverts/culverts_by_location_page.dart';
import '../../features/culverts/culverts_by_route_page.dart';
import '../../features/culverts/culvert_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardPage(),
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
  ],
);
