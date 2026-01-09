import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/route_repository.dart';
import '../../core/database/culverts_repository.dart';
import '../../core/widgets/app_svg_icon.dart';

class CulvertsByRoutePage extends StatefulWidget {
  const CulvertsByRoutePage({Key? key}) : super(key: key);

  @override
  State<CulvertsByRoutePage> createState() =>
      _CulvertsByRoutePageState();
}

class _CulvertsByRoutePageState extends State<CulvertsByRoutePage> {
  final RouteRepository _locationRepo = RouteRepository();
  final CulvertsRepository _culvertsRepo = CulvertsRepository();

  List<Map<String, dynamic>> mainRoutes = [];
  List<Map<String, dynamic>> subRoutes = [];
  List<Map<String, dynamic>> culverts = [];

  String? selectedMainRouteId;
  String? selectedSubRouteId;

  bool loadingMainRoutes = false;
  bool loadingSubRoutes = false;
  bool loadingCulverts = false;

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
    setState(() {
      selectedMainRouteId = mainRouteId;
      selectedSubRouteId = null;
      subRoutes = [];
      culverts = [];
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
      culverts = [];
      loadingCulverts = true;
    });

    if (subRouteId != null) {
      final data =
          await _culvertsRepo.getCulvertsBySubRoute(subRouteId);
      setState(() => culverts = data);
    }

    setState(() => loadingCulverts = false);
  }

  // -----------------------
  // UI
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Culverts by Route'),
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
							child: loadingCulverts
									? const Center(child: CircularProgressIndicator())
									: culverts.isEmpty
											? const Center(child: Text('No culverts found'))
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
																'No. of Culverts: ${culverts.length}',
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
																itemCount: culverts.length,
																separatorBuilder: (_, __) =>
																		const Divider(height: 1),
																itemBuilder: (context, index) {
																	final b = culverts[index];
																	return ListTile(
																		leading: AppSvgIcon(asset: 'assets/icons/culvert.svg', size: 24),
																		title: Text(
																			'${b['CulvertNo']}',
																		),
																		onTap: () {
																			context.push('/culvert/${b['CulvertId']}');
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