import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/routes_repository.dart';
import '../../core/database/bridges_repository.dart';
import '../../core/widgets/app_svg_icon.dart';

class BridgesByRoutePage extends StatefulWidget {
  const BridgesByRoutePage({Key? key}) : super(key: key);

  @override
  State<BridgesByRoutePage> createState() =>
      _BridgesByRoutePageState();
}

class _BridgesByRoutePageState extends State<BridgesByRoutePage> {
  final RoutesRepository _locationRepo = RoutesRepository();
  final BridgesRepository _bridgesRepo = BridgesRepository();

  List<Map<String, dynamic>> mainRoutes = [];
  List<Map<String, dynamic>> subRoutes = [];
  List<Map<String, dynamic>> bridges = [];

  String? selectedMainRouteId;
  String? selectedSubRouteId;

  bool loadingMainRoutes = false;
  bool loadingSubRoutes = false;
  bool loadingBridges = false;

  @override
  void initState() {
    super.initState();
    _loadMainRoutes();
  }

  // -----------------------
  // Data loading
  // -----------------------

  Future<void> _loadMainRoutes() async {
    setState(() => loadingMainRoutes = true);
    final data = await _locationRepo.getMainRoutes();
    setState(() {
      mainRoutes = data;
      loadingMainRoutes = false;
    });
  }

  Future<void> _onMainRouteChanged(String? mainRouteId) async {
    if (mainRouteId == selectedMainRouteId) return;
		
		setState(() {
      selectedMainRouteId = mainRouteId;
      selectedSubRouteId = null;
      subRoutes = [];
      bridges = [];
      loadingSubRoutes = true;
    });

    if (mainRouteId != null) {
      final data =
          await _locationRepo.getSubRoutes(mainRouteId);
      setState(() => subRoutes = data);
    }

    setState(() => loadingSubRoutes = false);
  }

  Future<void> _onSubRouteChanged(String? subRouteId) async {
    setState(() {
      selectedSubRouteId = subRouteId;
      bridges = [];
      loadingBridges = true;
    });

    if (subRouteId != null) {
      final data =
          await _bridgesRepo.getBridgesBySubRoute(subRouteId);
      setState(() => bridges = data);
    }

    setState(() => loadingBridges = false);
  }

  // -----------------------
  // UI
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridges by Route'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dropdown(
              label: 'Main Route',
              loading: loadingMainRoutes,
              value: selectedMainRouteId,
              items: mainRoutes,
              idKey: 'MainRouteId',
              displayBuilder: (r) =>
                  '${r['MainRouteNo']} - ${r['MainRouteName']}',
              onChanged: _onMainRouteChanged,
            ),
            const SizedBox(height: 12),

            _dropdown(
              label: 'Sub Route',
              loading: loadingSubRoutes,
              value: selectedSubRouteId,
              items: subRoutes,
              idKey: 'SubRouteId',
              displayBuilder: (r) =>
                  '${r['SubRouteNo']} - ${r['SubRouteName']}',
              onChanged: _onSubRouteChanged,
            ),

            const SizedBox(height: 16),

            Expanded(
							child: loadingBridges
									? const Center(child: CircularProgressIndicator())
									: bridges.isEmpty
											? const Center(child: Text('No bridges found'))
											: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														// 🔢 COUNT HEADER
														Padding(
															padding: const EdgeInsets.symmetric(
																horizontal: 8,
																vertical: 6,
															),
															child: Text(
																'No. of Bridges: ${bridges.length}',
																style: Theme.of(context)
																		.textTheme
																		.titleSmall
																		?.copyWith(
																			fontWeight: FontWeight.w600,
																		),
															),
														),

														const Divider(height: 1),

														// 📋 LIST
														Expanded(
															child: ListView.separated(
																itemCount: bridges.length,
																separatorBuilder: (_, __) =>
																		const Divider(height: 1),
																itemBuilder: (context, index) {
																	final b = bridges[index];
																	return ListTile(
																		leading: AppSvgIcon(asset: 'assets/icons/bridge.svg', size: 24),
																		title: Text(
																			'${b['BridgeNo']} - ${b['BridgeName']}',
																		),
																		onTap: () {
																			context.push('/bridge/${b['BridgeId']}');
																		},
																	);
																},
															),
														),
													],
												),
						)
          ],
        ),
      ),
    );
  }

  // -----------------------
  // Reusable dropdown (SAFE)
  // -----------------------

  Widget _dropdown({
    required String label,
    required bool loading,
    required String? value,
    required List<Map<String, dynamic>> items,
    required String idKey,
    required String Function(Map<String, dynamic>) displayBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    final String? safeValue = items.any(
      (e) => e[idKey].toString() == value,
    )
        ? value
        : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e[idKey].toString(),
              child: Text(displayBuilder(e)),
            ),
          )
          .toList(),
      onChanged: loading ? null : onChanged,
    );
  }
}