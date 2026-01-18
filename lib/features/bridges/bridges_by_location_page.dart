import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/location_repository.dart';
import '../../core/database/bridges_repository.dart';
import '../../core/widgets/app_svg_icon.dart';

class BridgesByLocationPage extends StatefulWidget {
  const BridgesByLocationPage({Key? key}) : super(key: key);

  @override
  State<BridgesByLocationPage> createState() =>
      _BridgesByLocationPageState();
}

class _BridgesByLocationPageState extends State<BridgesByLocationPage> {
  final LocationRepository _locationRepo = LocationRepository();
  final BridgesRepository _bridgesRepo = BridgesRepository();

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> sections = [];
  List<Map<String, dynamic>> segments = [];
  List<Map<String, dynamic>> bridges = [];

  String? selectedDistrictId;
  String? selectedSectionId;
  String? selectedSegmentId;

  bool loadingDistricts = false;
  bool loadingSections = false;
  bool loadingSegments = false;
  bool loadingBridges = false;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  // -----------------------
  // Data loading
  // -----------------------

  Future<void> _loadDistricts() async {
    setState(() => loadingDistricts = true);
    final data = await _locationRepo.getDistricts();
    setState(() {
      districts = data;
      loadingDistricts = false;
    });
  }

  Future<void> _onDistrictChanged(String? districtId) async {
    if (districtId == selectedDistrictId) return;
		
		setState(() {
      selectedDistrictId = districtId;
      selectedSectionId = null;
      selectedSegmentId = null;
      sections = [];
      segments = [];
      bridges = [];
      loadingSections = true;
    });

    if (districtId != null) {
      final data = await _locationRepo.getSections(districtId);
      setState(() => sections = data);
    }

    setState(() => loadingSections = false);
  }

  Future<void> _onSectionChanged(String? sectionId) async {
    if (sectionId == selectedSectionId) return;
		
		setState(() {
      selectedSectionId = sectionId;
      selectedSegmentId = null;
      segments = [];
      bridges = [];
      loadingSegments = true;
    });

    if (sectionId != null) {
      final data = await _locationRepo.getSegments(sectionId);
      setState(() => segments = data);
    }

    setState(() => loadingSegments = false);
  }

  Future<void> _onSegmentChanged(String? segmentId) async {
    setState(() {
      selectedSegmentId = segmentId;
      bridges = [];
      loadingBridges = true;
    });

    if (segmentId != null) {
      final data = await _bridgesRepo.getBridgesBySegment(segmentId);
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
        title: const Text('Bridges by Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dropdown(
              label: 'District',
              loading: loadingDistricts,
              value: selectedDistrictId,
              items: districts,
              idKey: 'DistrictId',
              displayBuilder: (d) =>
                  '${d['DistrictNo']} - ${d['DistrictName']}',
              onChanged: _onDistrictChanged,
            ),
            const SizedBox(height: 12),

            _dropdown(
              label: 'Section',
              loading: loadingSections,
              value: selectedSectionId,
              items: sections,
              idKey: 'SectionId',
              displayBuilder: (s) =>
                  '${s['SectionNo']} - ${s['SectionName']}',
              onChanged: _onSectionChanged,
            ),
            const SizedBox(height: 12),

            _dropdown(
              label: 'Segment',
              loading: loadingSegments,
              value: selectedSegmentId,
              items: segments,
              idKey: 'SegmentId',
              displayBuilder: (s) =>
                  '${s['SegmentNo']} - ${s['SegmentName']}',
              onChanged: _onSegmentChanged,
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
  // Reusable dropdown (CORRECT)
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
    // 🔑 GUARANTEE: dropdown never receives an invalid value
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
                  child: CircularProgressIndicator(strokeWidth: 2),
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