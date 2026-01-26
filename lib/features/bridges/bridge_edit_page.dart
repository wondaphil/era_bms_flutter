import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/bridges_repository.dart';
import '../../core/database/location_repository.dart';
import '../../core/database/routes_repository.dart';

class BridgeEditPage extends StatefulWidget {
  final String bridgeId;

  const BridgeEditPage({
    super.key,
    required this.bridgeId,
  });

  @override
  State<BridgeEditPage> createState() => _BridgeEditPageState();
}

class _BridgeEditPageState extends State<BridgeEditPage> {
  final _formKey = GlobalKey<FormState>();
	bool _isDirty = false;
	
  final BridgesRepository _bridgesRepo = BridgesRepository();
  final LocationRepository _locationRepo = LocationRepository();
  final RoutesRepository _routesRepo = RoutesRepository();

  // Text controllers
  final TextEditingController _bridgeNoCtrl = TextEditingController();
  final TextEditingController _revisedBridgeNoCtrl = TextEditingController();
  final TextEditingController _bridgeNameCtrl = TextEditingController();

  // Dropdown data
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> sections = [];
  List<Map<String, dynamic>> segments = [];

  List<Map<String, dynamic>> mainRoutes = [];
  List<Map<String, dynamic>> subRoutes = [];

  // Selected IDs
  String? districtId;
  String? sectionId;
  String? segmentId;
  String? mainRouteId;
  String? subRouteId;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // -----------------------
  // Load existing bridge + dropdowns
  // -----------------------

  Future<void> _loadInitialData() async {
		final bridge =
				await _bridgesRepo.getBridgeDetail(widget.bridgeId);

		if (bridge == null) return;

		// Load base dropdowns FIRST
		districts = await _locationRepo.getDistricts();
		mainRoutes = await _routesRepo.getMainRoutes();

		// Assign text fields
		_bridgeNoCtrl.text = bridge['BridgeNo'];
		_revisedBridgeNoCtrl.text = bridge['RevisedBridgeNo'];
		_bridgeNameCtrl.text = bridge['BridgeName'];

		// Assign selected IDs (AFTER items exist)
		districtId = bridge['DistrictId'];
		sectionId = bridge['SectionId'];
		segmentId = bridge['SegmentId'];

		mainRouteId = bridge['MainRouteId'];
		subRouteId = bridge['SubRouteId'];

		// Load cascading dropdowns
		if (districtId != null) {
			sections = await _locationRepo.getSections(districtId!);
		}

		if (sectionId != null) {
			segments = await _locationRepo.getSegments(sectionId!);
		}

		if (mainRouteId != null) {
			subRoutes = await _routesRepo.getSubRoutes(mainRouteId!);
		}

		setState(() => loading = false);
	}

  // -----------------------
  // Save
  // -----------------------

  Future<void> _save() async {
		if (!_formKey.currentState!.validate()) return;

		setState(() => saving = true);

		final exists = await _bridgesRepo.bridgeNoExists(
			_bridgeNoCtrl.text.trim(),
			widget.bridgeId,
		);

		if (exists) {
			setState(() => saving = false);

			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Bridge no. already exists'),
					backgroundColor: Colors.red,
				),
			);
			return;
		}

		await _bridgesRepo.updateBridge(
			bridgeId: widget.bridgeId,
			bridgeNo: _bridgeNoCtrl.text.trim(),
			revisedBridgeNo: _revisedBridgeNoCtrl.text.trim(),
			bridgeName: _bridgeNameCtrl.text.trim(),
			segmentId: segmentId!,
			subRouteId: subRouteId!,
		);

		if (!mounted) return;

		ScaffoldMessenger.of(context).showSnackBar(
			const SnackBar(
				content: Text('Bridge updated successfully'),
				behavior: SnackBarBehavior.floating,
			),
		);

		// Return RESULT to trigger refresh
		context.pop(true);
	}

  // -----------------------
  // UI
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bridge'),
        actions: [
          IconButton(
            icon: saving
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: saving ? null : _save,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _readOnlyField(
                      'Ser. No',
                      widget.bridgeId,
                      color: Colors.red,
                    ),

                    _textField(
                      controller: _bridgeNoCtrl,
                      label: 'Bridge Id',
                      required: true,
											textColor: Colors.red,
                    ),

                    _textField(
                      controller: _revisedBridgeNoCtrl,
                      label: 'Revised Id',
                      required: false,
											textColor: Colors.red,
                    ),

                    _textField(
                      controller: _bridgeNameCtrl,
                      label: 'Bridge Name',
                      required: true,
                    ),

                    _dropdown(
                      label: 'District',
                      value: districtId,
                      items: districts,
                      idKey: 'DistrictId',
                      labelBuilder: (d) =>
                          '${d['DistrictNo']} - ${d['DistrictName']}',
                      onChanged: (v) async {
                        if (v == districtId) return; 
												
												districtId = v;
                        sectionId = null;
                        segmentId = null;
                        sections =
                            await _locationRepo.getSections(v!);
                        segments = [];
                        setState(() {});
                      },
                    ),

                    _dropdown(
                      label: 'Section',
                      value: sectionId,
                      items: sections,
                      idKey: 'SectionId',
                      labelBuilder: (s) =>
                          '${s['SectionNo']} - ${s['SectionName']}',
                      onChanged: (v) async {
                        if (v == sectionId) return;
												
												sectionId = v;
                        segmentId = null;
                        segments =
                            await _locationRepo.getSegments(v!);
                        setState(() {});
                      },
                    ),

                    _dropdown(
                      label: 'Segment',
                      value: segmentId,
                      items: segments,
                      idKey: 'SegmentId',
                      labelBuilder: (s) =>
                          '${s['SegmentNo']} - ${s['SegmentName']}',
                      onChanged: (v) =>
                          setState(() => segmentId = v),
                    ),

                    _dropdown(
                      label: 'Main Route',
                      value: mainRouteId,
                      items: mainRoutes,
                      idKey: 'MainRouteId',
                      labelBuilder: (r) =>
                          '${r['MainRouteNo']} - ${r['MainRouteName']}',
                      onChanged: (v) async {
                        if (v == mainRouteId) return;
												
												mainRouteId = v;
                        subRouteId = null;
                        subRoutes =
                            await _routesRepo.getSubRoutes(v!);
                        setState(() {});
                      },
                    ),

                    _dropdown(
                      label: 'Sub Route',
                      value: subRouteId,
                      items: subRoutes,
                      idKey: 'SubRouteId',
                      labelBuilder: (r) =>
                          '${r['SubRouteNo']} - ${r['SubRouteName']}',
                      onChanged: (v) =>
                          setState(() => subRouteId = v),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // -----------------------
  // Widgets
  // -----------------------

  Widget _readOnlyField(
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _textField({
		required TextEditingController controller,
		required String label,
		bool required = false,
		Color? textColor,
	}) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 16),
			child: TextFormField(
				controller: controller,
				style: TextStyle(color: textColor),
				decoration: InputDecoration(
					labelText: label,
					border: const OutlineInputBorder(),
				),
				validator: required
						? (v) =>
								v == null || v.trim().isEmpty ? 'Required' : null
						: null,
			),
		);
	}

  Widget _dropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required String idKey,
    required String Function(Map<String, dynamic>) labelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
                value: e[idKey].toString(),
                child: Text(labelBuilder(e)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (v) =>
            v == null ? 'Required' : null,
      ),
    );
  }
}