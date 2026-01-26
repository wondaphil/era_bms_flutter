import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/culverts_repository.dart';
import '../../core/database/location_repository.dart';
import '../../core/database/routes_repository.dart';

class CulvertNewPage extends StatefulWidget {
  const CulvertNewPage({super.key});

  @override
  State<CulvertNewPage> createState() => _CulvertNewPageState();
}

class _CulvertNewPageState extends State<CulvertNewPage> {
  final _formKey = GlobalKey<FormState>();

  final CulvertsRepository _culvertsRepo = CulvertsRepository();
  final LocationRepository _locationRepo = LocationRepository();
  final RoutesRepository _routesRepo = RoutesRepository();

  final TextEditingController _culvertNoCtrl = TextEditingController();
  final TextEditingController _revisedCulvertNoCtrl = TextEditingController();
  
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
	
	String _suggestNextCulvertNo(
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

    final culvertNo = _culvertNoCtrl.text.trim();

    // Culvert No uniqueness check
    final exists =
        await _culvertsRepo.culvertNoExists(culvertNo, '');

    if (exists) {
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Culvert No already exists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newCulvertId = const Uuid().v4();

    await _culvertsRepo.insertCulvert(
      culvertId: newCulvertId,
      culvertNo: culvertNo,
      revisedCulvertNo: _revisedCulvertNoCtrl.text.trim(),
      segmentId: segmentId!,
      subRouteId: subRouteId!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Culvert created successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go('/culvert/$newCulvertId');
  }

  // -----------------------
  // UI
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Culvert'),
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

												// Get last CulvertNo
												final lastCulvertNo =
														await _culvertsRepo.getNextCulvertNoForSubRoute(v!);

												final suggested =
														_suggestNextCulvertNo(subRouteNo, lastCulvertNo);

												setState(() {
													_culvertNoCtrl.text = suggested;
												});

                      },
                    ),
										
										_textField(
                      controller: _culvertNoCtrl,
                      label: 'Culvert Id',
                      required: true,
                      textColor: Colors.red,
											hintText: 'Suggested here',
                    ),
										
										_textField(
                      controller: _revisedCulvertNoCtrl,
                      label: 'Revised Id',
                      required: false,
                      textColor: Colors.red
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