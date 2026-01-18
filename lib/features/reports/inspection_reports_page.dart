import 'package:flutter/material.dart';
import '../../core/database/report_chart_repository.dart';

enum InspectionReportType {
  bridgesByInspectionYear,
  culvertsByInspectionYear,
  bridgesByServiceCondition,
  bridgesByDistrict,
  culvertsByDistrict,
}

class InspectionReportsPage extends StatefulWidget {
  const InspectionReportsPage({super.key});

  @override
  State<InspectionReportsPage> createState() => _InspectionReportsPageState();
}

class _InspectionReportsPageState extends State<InspectionReportsPage> {
  final _repo = ReportChartRepository();

  InspectionReportType _selected = InspectionReportType.bridgesByInspectionYear;

  int? _inspectionYear;
  List<int> _years = [];
  Future<List<Map<String, dynamic>>>? _future;

  Future<void> _loadYears() async {
    _years = await _repo.getInspectionYears();
    if (_years.isNotEmpty) {
      _inspectionYear = _years.first;
      _future = _loadReport();
    }
    setState(() {});
  }

  String _label(InspectionReportType t) {
    switch (t) {
      case InspectionReportType.bridgesByInspectionYear:
        return 'Inspected Bridges\nby Inspection Year';
      case InspectionReportType.culvertsByInspectionYear:
        return 'Inspected Culverts\nby Inspection Year';
      case InspectionReportType.bridgesByServiceCondition:
        return 'Bridges\nby Service Condition';
      case InspectionReportType.bridgesByDistrict:
        return 'Inspected Bridges\nby District';
      case InspectionReportType.culvertsByDistrict:
        return 'Inspected Culverts\nby District';
    }
  }

  Future<List<Map<String, dynamic>>> _loadReport() {
    switch (_selected) {
      case InspectionReportType.bridgesByInspectionYear:
        return _repo.getInspectedBridgesByInspectionYear();

      case InspectionReportType.culvertsByInspectionYear:
        return _repo.getInspectedCulvertsByInspectionYear();

      case InspectionReportType.bridgesByServiceCondition:
        return _repo.getBridgesByServiceCondition(_inspectionYear!);

      case InspectionReportType.bridgesByDistrict:
        return _repo.getInspectedBridgesByDistrict(_inspectionYear!);

      case InspectionReportType.culvertsByDistrict:
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
      appBar: AppBar(title: const Text('Inspection Reports')),
      body: Column(
        children: [
          // ---------- Inspection Year ----------
          Padding(
						padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
						child: Align(
							alignment: Alignment.centerLeft,
							child: SizedBox(
								width: 140, // 👈 perfect for YYYY
								child: DropdownButtonFormField<int>(
									value: _inspectionYear,
									decoration: const InputDecoration(
										labelText: 'Inspection Year',
										floatingLabelBehavior: FloatingLabelBehavior.auto,
										border: OutlineInputBorder(),
										isDense: true, // 👈 tighter vertical height
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
											_future = _loadReport();
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: InspectionReportType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final t = InspectionReportType.values[i];
                return ChoiceChip(
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      _label(t),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  selected: _selected == t,
                  onSelected: (_) {
                    setState(() {
                      _selected = t;
                      _future = _loadReport();
                    });
                  },
                );
              },
            ),
          ),

          const Divider(),

          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE BUILDER (HARD-CODED HEADERS LIKE INVENTORY REPORTS)
  // ============================================================
  Widget _buildTable() {
    if (_future == null) {
      return const Center(child: Text('Select report'));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return const Center(child: Text('No data found'));
        }

        // --------------------------------------------------------
        // Inspected Bridges by Inspection Year
        // --------------------------------------------------------
        if (_selected == InspectionReportType.bridgesByInspectionYear) {
          int total = 0;
          for (final r in rows) {
            total += (r['BridgeCount'] as int? ?? 0);
          }

          return _tableWrapper(
            DataTable(
              columns: const [
                DataColumn(label: Text('Inspection Year')),
                DataColumn(label: Text('No. of Bridges')),
              ],
              rows: [
                ...rows.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text(r['InspectionYear'].toString())),
                      DataCell(Text(r['BridgeCount'].toString())),
                    ],
                  );
                }),
                _totalRow(['TOTAL', total.toString()]),
              ],
            ),
          );
        }

        // --------------------------------------------------------
        // Inspected Culverts by Inspection Year
        // --------------------------------------------------------
        if (_selected == InspectionReportType.culvertsByInspectionYear) {
          int total = 0;
          for (final r in rows) {
            total += (r['CulvertCount'] as int? ?? 0);
          }

          return _tableWrapper(
            DataTable(
              columns: const [
                DataColumn(label: Text('Inspection Year')),
                DataColumn(label: Text('No. of Culverts')),
              ],
              rows: [
                ...rows.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text(r['InspectionYear'].toString())),
                      DataCell(Text(r['CulvertCount'].toString())),
                    ],
                  );
                }),
                _totalRow(['TOTAL', total.toString()]),
              ],
            ),
          );
        }

        // --------------------------------------------------------
        // Bridges by Service Condition
        // --------------------------------------------------------
        if (_selected == InspectionReportType.bridgesByServiceCondition) {
          int total = 0;
          for (final r in rows) {
            total += (r['BridgeCount'] as int? ?? 0);
          }

          return _tableWrapper(
            DataTable(
              columns: const [
                DataColumn(label: Text('Service Condition')),
                DataColumn(label: Text('No. of Bridges')),
              ],
              rows: [
                ...rows.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text(r['Condition'].toString())),
                      DataCell(Text(r['BridgeCount'].toString())),
                    ],
                  );
                }),
                _totalRow(['TOTAL', total.toString()]),
              ],
            ),
          );
        }

        // --------------------------------------------------------
        // Inspected Bridges by District
        // --------------------------------------------------------
        if (_selected == InspectionReportType.bridgesByDistrict) {
          int total = 0;
          for (final r in rows) {
            total += (r['BridgeCount'] as int? ?? 0);
          }

          return _tableWrapper(
            DataTable(
              columns: const [
                DataColumn(label: Text('District')),
                DataColumn(label: Text('No. of Bridges')),
              ],
              rows: [
                ...rows.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text(r['DistrictName'].toString())),
                      DataCell(Text(r['BridgeCount'].toString())),
                    ],
                  );
                }),
                _totalRow(['TOTAL', total.toString()]),
              ],
            ),
          );
        }

        // --------------------------------------------------------
        // Inspected Culverts by District
        // --------------------------------------------------------
        if (_selected == InspectionReportType.culvertsByDistrict) {
          int total = 0;
          for (final r in rows) {
            total += (r['CulvertCount'] as int? ?? 0);
          }

          return _tableWrapper(
            DataTable(
              columns: const [
                DataColumn(label: Text('District')),
                DataColumn(label: Text('No. of Culverts')),
              ],
              rows: [
                ...rows.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text(r['DistrictName'].toString())),
                      DataCell(Text(r['CulvertCount'].toString())),
                    ],
                  );
                }),
                _totalRow(['TOTAL', total.toString()]),
              ],
            ),
          );
        }

        return const Center(child: Text('Unsupported report'));
      },
    );
  }

  // ---------- Helpers ----------

  Widget _tableWrapper(DataTable table) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        ),
      ),
    );
  }

  DataRow _totalRow(List<String> values) {
    return DataRow(
      cells: values
          .map(
            (v) => DataCell(
              Text(
                v,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }
}