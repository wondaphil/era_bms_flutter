import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/bridges_repository.dart';
import '../../core/database/location_repository.dart';
import '../../core/database/routes_repository.dart';

class BridgeNewPage extends StatefulWidget {
  const BridgeNewPage({super.key});

  @override
  State<BridgeNewPage> createState() => _BridgeNewPageState();
}

class _BridgeNewPageState extends State<BridgeNewPage> {
  final _formKey = GlobalKey<FormState>();

  final BridgesRepository _bridgesRepo = BridgesRepository();
  final LocationRepository _locationRepo = LocationRepository();
  final RoutesRepository _routesRepo = RoutesRepository();

  final TextEditingController _bridgeNoCtrl = TextEditingController();
  final TextEditingController _revisedBridgeNoCtrl = TextEditingController();
  final TextEditingController _bridgeNameCtrl = TextEditingController();

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> sections = [];
  List<Map<String, dynamic>> segments = [];

  List<Map<String, dynamic>> mainRoutes = [];
  List<Map<String, dynamic>> subRoutes = [];

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
    _loadBaseData();
  }

  Future<void> _loadBaseData() async {
    districts = await _locationRepo.getDistricts();
    mainRoutes = await _routesRepo.getMainRoutes();
    setState(() => loading = false);
  }
	
	String _suggestNextBridgeNo(
		String prefix,        // e.g. "A1-1"
		String? lastFullCode, // e.g. "A1-1-009"
	) {
		// If no previous bridge exists
		if (lastFullCode == null) {
			return '$prefix-001'; // default starting width = 3
		}

		final parts = lastFullCode.split('-');
		if (parts.length < 2) {
			return '$prefix-001';
		}

		final lastSuffixStr = parts.last;          // "009"
		final width = lastSuffixStr.length;        // 3
		final lastNumber = int.tryParse(lastSuffixStr) ?? 0;

		final nextNumber = lastNumber + 1;

		final nextSuffix =
				nextNumber.toString().padLeft(width, '0');

		return '$prefix-$nextSuffix';
	}

  // -----------------------
  // Save (INSERT)
  // -----------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final bridgeNo = _bridgeNoCtrl.text.trim();

    // Bridge No uniqueness check
    final exists =
        await _bridgesRepo.bridgeNoExists(bridgeNo, '');

    if (exists) {
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bridge No already exists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newBridgeId = const Uuid().v4();

    await _bridgesRepo.insertBridge(
      bridgeId: newBridgeId,
      bridgeNo: bridgeNo,
      revisedBridgeNo: _revisedBridgeNoCtrl.text.trim(),
      bridgeName: _bridgeNameCtrl.text.trim(),
      segmentId: segmentId!,
      subRouteId: subRouteId!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bridge created successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go('/bridge/$newBridgeId');
  }

  // -----------------------
  // UI
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bridge'),
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
                      onChanged: (v) {
                        if (v == segmentId) return;
                        setState(() => segmentId = v);
                      },
                    ),

                    _dropdown(
                      label: 'Main Route',
                      value: mainRouteId,
                      items: mainRoutes,
                      idKey: 'MainRouteId',
                      labelBuilder: (r) => '${r['MainRouteNo']} - ${r['MainRouteName']}',
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
                      labelBuilder: (r) => '${r['SubRouteNo']} - ${r['SubRouteName']}',
                      onChanged: (v) async {
                        if (v == subRouteId) return;

												subRouteId = v;
												
												// Get SubRouteNo
												final subRoute = subRoutes.firstWhere(
													(r) => r['SubRouteId'] == v,
												);
												final subRouteNo = subRoute['SubRouteNo'];

												// Get last BridgeNo
												final lastBridgeNo =
														await _bridgesRepo.getNextBridgeNoForSubRoute(v!);

												final suggested =
														_suggestNextBridgeNo(subRouteNo, lastBridgeNo);

												setState(() {
													_bridgeNoCtrl.text = suggested;
												});
                      },
                    ),
										
										_textField(
                      controller: _bridgeNoCtrl,
                      label: 'Bridge Id',
                      required: true,
                      textColor: Colors.red,
											hintText: 'Suggested here',
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
                  ],
                ),
              ),
            ),
    );
  }

  // -----------------------
  // Reusable widgets
  // -----------------------

  Widget _textField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    Color? textColor,
		String? hintText, 
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
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