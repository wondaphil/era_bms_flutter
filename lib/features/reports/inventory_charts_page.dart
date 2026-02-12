import 'package:flutter/material.dart';
import '../../core/database/report_chart_repository.dart';
import 'simple_bar_chart.dart';

enum InventoryChartType {
  bridgesByDistrict,
  culvertsByDistrict,
  bridgesByConstructionYear,
  bridgesByLength,
  bridgesByType,
  culvertsByType,
}

class InventoryChartsPage extends StatefulWidget {
  const InventoryChartsPage({super.key});

  @override
  State<InventoryChartsPage> createState() => _InventoryChartsPageState();
}

class _InventoryChartsPageState extends State<InventoryChartsPage> {
  InventoryChartType _selected = InventoryChartType.bridgesByDistrict;
	final _repo = ReportChartRepository();
	Future<List<Map<String, dynamic>>>? _future;

  String _label(InventoryChartType t) {
    switch (t) {
      case InventoryChartType.bridgesByDistrict:
        return 'Bridges\nby District';
      case InventoryChartType.culvertsByDistrict:
        return 'Culverts\nby District';
      case InventoryChartType.bridgesByConstructionYear:
        return 'Bridges\nby Constr. Yr';
      case InventoryChartType.bridgesByLength:
        return 'Bridges\nby Length';
      case InventoryChartType.bridgesByType:
        return 'Bridges\nby Type';
      case InventoryChartType.culvertsByType:
        return 'Culverts\nby Type';
    }
  }
	
	Future<List<Map<String, dynamic>>> _loadChart() {
		switch (_selected) {
			case InventoryChartType.bridgesByDistrict:
				return _repo.getBridgesByDistrict();

			case InventoryChartType.culvertsByDistrict:
				return _repo.getCulvertsByDistrict();

			case InventoryChartType.bridgesByConstructionYear:
				return _repo.getBridgesByConstructionYear();

			case InventoryChartType.bridgesByLength:
				return _repo.getBridgesByLength();

			case InventoryChartType.bridgesByType:
				return _repo.getBridgesByBridgeType();

			case InventoryChartType.culvertsByType:
				return _repo.getCulvertsByCulvertType();
			
			default:
				return Future.value([]);
		}
	}
	
	@override
	void initState() {
		super.initState();
		_future = _loadChart();
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Charts'),
      ),
      body: Column(
        children: [
          // ---------- Chips ----------
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: InventoryChartType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final t = InventoryChartType.values[i];
                return ChoiceChip(
                  label: SizedBox(
                    width: 140,
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

          // ---------- Chart  ----------
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

								// ---- Bridges by District ----
								if (_selected == InventoryChartType.bridgesByDistrict) {
									final labels = rows
											.map((r) => r['DistrictName'].toString())
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
								
								// ---- Culverts by District ----
								if (_selected == InventoryChartType.culvertsByDistrict) {
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
								
								// ---- Bridges by Construction Year ----
								if (_selected == InventoryChartType.bridgesByConstructionYear) {
									final labels =
											rows.map((r) => r['ConstructionYear'].toString()).toList();

									final values =
											rows.map((r) => (r['BridgeCount'] as int?) ?? 0).toList();

									return SimpleBarChart(
										labels: labels,
										values: values,
										yAxisLabel: 'No. of Bridges',
									);
								}

								// ---- Bridges by Length ----
								if (_selected == InventoryChartType.bridgesByLength) {
									final labels =
											rows.map((r) => r['BridgeLength'].toString()).toList();

									final values =
											rows.map((r) => (r['BridgeCount'] as int?) ?? 0).toList();

									return SimpleBarChart(
										labels: labels,
										values: values,
										yAxisLabel: 'No. of Bridges',
									);
								}
								
								// ---- Bridges by Bridge Type ----
								if (_selected == InventoryChartType.bridgesByType) {
									final labels =
											rows.map((r) => r['TypeName'].toString()).toList();

									final values =
											rows.map((r) => (r['BridgeCount'] as int?) ?? 0).toList();

									return SimpleBarChart(
										labels: labels,
										values: values,
										yAxisLabel: 'No. of Bridges',
									);
								}
								
								// ---- Culverts by Culvert Type ----
								if (_selected == InventoryChartType.culvertsByType) {
									final labels =
											rows.map((r) => r['TypeName'].toString()).toList();

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