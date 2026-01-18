import 'package:flutter/material.dart';
import '../../core/database/report_chart_repository.dart';
import 'simple_bar_chart.dart';

enum InspectionChartType {
  bridgesByInspectionYear,
  culvertsByInspectionYear,
	bridgesByServiceCondition,
  bridgesByDistrict,
  culvertsByDistrict,
}

class InspectionChartsPage extends StatefulWidget {
  const InspectionChartsPage({super.key});

  @override
  State<InspectionChartsPage> createState() => _InspectionChartsPageState();
}

class _InspectionChartsPageState extends State<InspectionChartsPage> {
  InspectionChartType _selected = InspectionChartType.bridgesByInspectionYear;

  final _repo = ReportChartRepository();
  int? _inspectionYear;
  List<int> _years = [];
	Future<List<Map<String, dynamic>>>? _future;

  Future<void> _loadYears() async {
    _years = await _repo.getInspectionYears();
    if (_years.isNotEmpty) {
      _inspectionYear = _years.first;
      _future = _loadChart();
    }
    setState(() {});
  }

  String _label(InspectionChartType t) {
    switch (t) {
      case InspectionChartType.bridgesByInspectionYear:
        return 'Inspected Bridges\nby Year';
      case InspectionChartType.culvertsByInspectionYear:
        return 'Inspected Culverts\nby Year';
			case InspectionChartType.bridgesByServiceCondition:
        return 'Bridges\nby Service Condition';
      case InspectionChartType.bridgesByDistrict:
        return 'Inspected Bridges\nby District';
      case InspectionChartType.culvertsByDistrict:
        return 'Inspected Culverts\nby District';
    }
  }

  Future<List<Map<String, dynamic>>> _loadChart() {
		// ---- charts that do NOT need inspection year ----
		if (_selected == InspectionChartType.bridgesByInspectionYear) {
			return _repo.getInspectedBridgesByInspectionYear();
		}

		if (_selected == InspectionChartType.culvertsByInspectionYear) {
			return _repo.getInspectedCulvertsByInspectionYear();
		}

		// ---- charts that REQUIRE inspection year ----
		if (_inspectionYear == null) {
			return Future.value([]); 
		}

		switch (_selected) {
			case InspectionChartType.bridgesByServiceCondition:
				return _repo.getBridgesByServiceCondition(_inspectionYear!);

			case InspectionChartType.bridgesByDistrict:
				return _repo.getInspectedBridgesByDistrict(_inspectionYear!);

			case InspectionChartType.culvertsByDistrict:
				return _repo.getInspectedCulvertsByDistrict(_inspectionYear!);

			default:
				return Future.value([]);
		}
	}

  @override
  void initState() {
    super.initState();
		_loadYears();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Charts')),
      body: Column(
        children: [
          // ---------- Inspection Year ----------
					Padding(
						padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
						child: Align(
							alignment: Alignment.centerLeft,
							child: SizedBox(
								width: 140, // perfect for YYYY
								child: DropdownButtonFormField<int>(
									value: _inspectionYear,
									decoration: const InputDecoration(
										labelText: 'Inspection Year',
										floatingLabelBehavior: FloatingLabelBehavior.auto,
										border: OutlineInputBorder(),
										isDense: true,
									),
									items: _years
											.map(
												(y) => DropdownMenuItem(
													value: y,
													child: Text(y.toString()),
												),
											)
											.toList(),
									onChanged: (v) {
										if (v == null) return;
										setState(() {
											_inspectionYear = v;
											_future = _loadChart();
										});
									},
								),
							),
						),
					),
					
					// ---------- Chips ----------
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: InspectionChartType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final t = InspectionChartType.values[i];
                return ChoiceChip(
                  label: SizedBox(
                    width: 160,
                    child: Text(
                      _label(t),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  selected: _selected == t,
                  onSelected: (_) {
                    setState(() {
                      _selected = t;
                      _future = _loadChart();
                    });
                  },
                );
              },
            ),
          ),

          const Divider(),

          // ---------- Chart ----------
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final rows = snapshot.data ?? [];
                if (rows.isEmpty) {
                  return const Center(child: Text('No data'));
                }

                // ---- Inspected Bridges by Year ----
                if (_selected ==
                    InspectionChartType.bridgesByInspectionYear) {
                  final labels = rows
                      .map((r) => r['InspectionYear'].toString())
                      .toList();

                  final values = rows
                      .map((r) => (r['BridgeCount'] as int?) ?? 0)
                      .toList();

                  return SimpleBarChart(
                    labels: labels,
                    values: values,
                    yAxisLabel: 'No. of Bridges',
                  );
                }

                // ---- Inspected Culverts by Year ----
                if (_selected ==
                    InspectionChartType.culvertsByInspectionYear) {
                  final labels = rows
                      .map((r) => r['InspectionYear'].toString())
                      .toList();

                  final values = rows
                      .map((r) => (r['CulvertCount'] as int?) ?? 0)
                      .toList();

                  return SimpleBarChart(
                    labels: labels,
                    values: values,
                    yAxisLabel: 'No. of Culverts',
                  );
                }
								
								// ---- Inspected Bridges by Service Condition ----
                if (_selected == InspectionChartType.bridgesByServiceCondition) {
									final labels =
											rows.map((r) => r['Condition'].toString()).toList();

									final values =
											rows.map((r) => (r['BridgeCount'] as int?) ?? 0).toList();

									return SimpleBarChart(
										labels: labels,
										values: values,
										yAxisLabel: 'No. of Bridges',
									);
								}
								
								// ---- Inspected Bridges by District ----
                if (_selected == InspectionChartType.bridgesByDistrict) {
									final labels =
											rows.map((r) => r['DistrictName'].toString()).toList();

									final values =
											rows.map((r) => (r['BridgeCount'] as int?) ?? 0).toList();

									return SimpleBarChart(
										labels: labels,
										values: values,
										yAxisLabel: 'No. of Bridges',
									);
								}
								
								// ---- Inspected Culverts by District ----
                if (_selected == InspectionChartType.culvertsByDistrict) {
									final labels =
											rows.map((r) => r['DistrictName'].toString()).toList();

									final values =
											rows.map((r) => (r['CulvertCount'] as int?) ?? 0).toList();

									return SimpleBarChart(
										labels: labels,
										values: values,
										yAxisLabel: 'No. of Culverts',
									);
								}

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}