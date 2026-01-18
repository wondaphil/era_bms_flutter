import 'package:flutter/material.dart';
import '../../core/database/report_chart_repository.dart';

enum InventoryReportType {
  bridgesAndCulvertsByDistrict,
  bridgesByConstructionYear,
  bridgesByLength,
  bridgesByBridgeType,
  culvertsByCulvertType,
}

class InventoryReportsPage extends StatefulWidget {
  const InventoryReportsPage({super.key});

  @override
  State<InventoryReportsPage> createState() =>
      _InventoryReportsPageState();
}

class _InventoryReportsPageState extends State<InventoryReportsPage> {
  final _repo = ReportChartRepository();

  InventoryReportType _selected = InventoryReportType.bridgesAndCulvertsByDistrict;

  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadReport();
  }

  String _label(InventoryReportType t) {
    switch (t) {
      case InventoryReportType.bridgesAndCulvertsByDistrict:
        return 'Bridges & Culverts\nby District';
      case InventoryReportType.bridgesByConstructionYear:
        return 'Bridges by\nConstruction Year';
      case InventoryReportType.bridgesByLength:
        return 'Bridges by\nLength';
      case InventoryReportType.bridgesByBridgeType:
        return 'Bridges by\nBridge Type';
      case InventoryReportType.culvertsByCulvertType:
        return 'Culverts by\nCulvert Type';
    }
  }

  Future<List<Map<String, dynamic>>> _loadReport() {
		switch (_selected) {
			case InventoryReportType.bridgesAndCulvertsByDistrict:
				return _repo.getBridgesAndCulvertsByDistrict();

			case InventoryReportType.bridgesByConstructionYear:
				return _repo.getBridgesByConstructionYear();

			case InventoryReportType.bridgesByLength:
				return _repo.getBridgesByLength();

			case InventoryReportType.bridgesByBridgeType:
				return _repo.getBridgesByBridgeType();

			case InventoryReportType.culvertsByCulvertType:
				return _repo.getCulvertsByCulvertType();
				
			default:
				return Future.value([]);
		}
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Reports'),
      ),
      body: Column(
        children: [
          // =========================
          // Sticky Chips
          // =========================
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: InventoryReportType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final t = InventoryReportType.values[i];
                return ChoiceChip(
                  label: SizedBox(
                    width: 130,
                    child: Text(
                      _label(t),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  selected: _selected == t,
                  onSelected: (_) {
                    if (_selected != t) {
                      setState(() {
                        _selected = t;
                        _future = _loadReport();
                      });
                    }
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // =========================
          // Report Table
          // =========================
          Expanded(
            child: _buildTable(),
          ),
        ],
      ),
    );
  }

  // -----------------------
  // Table builder
  // -----------------------
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
					return const Center(child: Text('No data found'));
				}

				// =====================================================
				// REPORT 1: Bridges & Culverts by District
				// =====================================================
				if (_selected == InventoryReportType.bridgesAndCulvertsByDistrict) {
					int totalBridges = 0;
					int totalCulverts = 0;

					for (final r in rows) {
						totalBridges += (r['BridgeCount'] as int? ?? 0);
						totalCulverts += (r['CulvertCount'] as int? ?? 0);
					}

					return Scrollbar(
						thumbVisibility: true,
						child: SingleChildScrollView(
							padding: const EdgeInsets.all(12),
							child: SingleChildScrollView(
								scrollDirection: Axis.horizontal,
								child: DataTable(
									columns: const [
										DataColumn(label: Text('District')),
										DataColumn(label: Text('No. of Bridges')),
										DataColumn(label: Text('No. of Culverts')),
									],
									rows: [
										...rows.map((r) {
											return DataRow(
												cells: [
													DataCell(Text(r['DistrictName'].toString())),
													DataCell(Text(r['BridgeCount'].toString())),
													DataCell(Text(r['CulvertCount'].toString())),
												],
											);
										}),

										// ---------- TOTAL ROW ----------
										DataRow(
											cells: [
												const DataCell(
													Text(
														'TOTAL',
														style: TextStyle(fontWeight: FontWeight.bold),
													),
												),
												DataCell(
													Text(
														totalBridges.toString(),
														style: const TextStyle(fontWeight: FontWeight.bold),
													),
												),
												DataCell(
													Text(
														totalCulverts.toString(),
														style: const TextStyle(fontWeight: FontWeight.bold),
													),
												),
											],
										),
									],
								),
							),
						),
					);
				}

				// =====================================================
				// REPORT 2: Bridges by Construction Year
				// =====================================================
				if (_selected == InventoryReportType.bridgesByConstructionYear) {
												
					int total = 0;
					for (final r in rows) {
						total += (r['BridgeCount'] as int? ?? 0);
					}

					return Scrollbar(
						thumbVisibility: true,
						child: SingleChildScrollView(
							padding: const EdgeInsets.all(12),
							child: SingleChildScrollView(
								scrollDirection: Axis.horizontal,
								child: DataTable(
									columns: const [
										DataColumn(label: Text('Construction Year')),
										DataColumn(label: Text('No. of Bridges')),
									],
									rows: [
										...rows.map((r) {
											return DataRow(
												cells: [
													DataCell(Text(r['ConstructionYear'].toString())),
													DataCell(Text(r['BridgeCount'].toString())),
												],
											);
										}),

										// -------- TOTAL ROW --------
										DataRow(
											cells: [
												const DataCell(
													Text('TOTAL',
															style: TextStyle(fontWeight: FontWeight.bold)),
												),
												DataCell(
													Text(
														total.toString(),
														style: const TextStyle(fontWeight: FontWeight.bold),
													),
												),
											],
										),
									],
								),
							),
						),
					);
				}

				// =====================================================
				// REPORT 3: Bridges by Length
				// =====================================================
				if (_selected == InventoryReportType.bridgesByLength) {
					int total = 0;
					for (final r in rows) {
						total += (r['BridgeCount'] as int? ?? 0);
					}

					return Scrollbar(
						thumbVisibility: true,
						child: SingleChildScrollView(
							padding: const EdgeInsets.all(12),
							child: SingleChildScrollView(
								scrollDirection: Axis.horizontal,
								child: DataTable(
									columns: const [
										DataColumn(label: Text('Bridge Length')),
										DataColumn(label: Text('No. of Bridges')),
									],
									rows: [
										...rows.map((r) {
											return DataRow(
												cells: [
													DataCell(Text(r['BridgeLength'].toString())),
													DataCell(Text(r['BridgeCount'].toString())),
												],
											);
										}),

										// -------- TOTAL ROW --------
										DataRow(
											cells: [
												const DataCell(
													Text('TOTAL',
															style: TextStyle(fontWeight: FontWeight.bold)),
												),
												DataCell(
													Text(
														total.toString(),
														style: const TextStyle(fontWeight: FontWeight.bold),
													),
												),
											],
										),
									],
								),
							),
						),
					);
				}

				// =====================================================
				// REPORT 4: Bridges by Bridge Type
				// =====================================================
				if (_selected == InventoryReportType.bridgesByBridgeType) {
					int total = 0;
					for (final r in rows) {
						total += (r['Count'] as int? ?? 0);
					}

					return Scrollbar(
						thumbVisibility: true,
						child: SingleChildScrollView(
							padding: const EdgeInsets.all(12),
							child: SingleChildScrollView(
								scrollDirection: Axis.horizontal,
								child: DataTable(
									columns: const [
										DataColumn(label: Text('Bridge Type')),
										DataColumn(label: Text('No. of Bridges')),
									],
									rows: [
										...rows.map((r) {
											return DataRow(
												cells: [
													DataCell(Text(r['TypeName'].toString())),
													DataCell(Text(r['BridgeCount'].toString())),
												],
											);
										}),

										// TOTAL row
										DataRow(
											cells: [
												const DataCell(
													Text('TOTAL',
															style: TextStyle(fontWeight: FontWeight.bold)),
												),
												DataCell(
													Text(
														total.toString(),
														style: const TextStyle(fontWeight: FontWeight.bold),
													),
												),
											],
										),
									],
								),
							),
						),
					);
				}

				// =====================================================
				// REPORT 5: Culverts by Culvert Type
				// =====================================================
				if (_selected == InventoryReportType.culvertsByCulvertType) {
					int total = 0;
					for (final r in rows) {
						total += (r['Count'] as int? ?? 0);
					}

					return Scrollbar(
						thumbVisibility: true,
						child: SingleChildScrollView(
							padding: const EdgeInsets.all(12),
							child: SingleChildScrollView(
								scrollDirection: Axis.horizontal,
								child: DataTable(
									columns: const [
										DataColumn(label: Text('Culvert Type')),
										DataColumn(label: Text('No. of Culverts')),
									],
									rows: [
										...rows.map((r) {
											return DataRow(
												cells: [
													DataCell(Text(r['TypeName'].toString())),
													DataCell(Text(r['CulvertCount'].toString())),
												],
											);
										}),

										// ---------- TOTAL ROW ----------
										DataRow(
											cells: [
												const DataCell(
													Text(
														'TOTAL',
														style: TextStyle(fontWeight: FontWeight.bold),
													),
												),
												DataCell(
													Text(
														total.toString(),
														style: const TextStyle(fontWeight: FontWeight.bold),
													),
												),
											],
										),
									],
								),
							),
						),
					);
				}

				return const Center(child: Text('Unsupported report'));
			},
		);
	}
}