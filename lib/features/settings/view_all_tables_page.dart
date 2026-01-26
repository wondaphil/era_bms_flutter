import 'package:flutter/material.dart';
import '../../core/database/database_info_repository.dart';
import 'package:intl/intl.dart';

class ViewAllTablesPage extends StatefulWidget {
  const ViewAllTablesPage({super.key});

  @override
  State<ViewAllTablesPage> createState() => _ViewAllTablesPageState();
}

class _ViewAllTablesPageState extends State<ViewAllTablesPage> {
  final _repo = DatabaseInfoRepository();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getDatabaseTablesInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Tables')),
      body: FutureBuilder<Map<String, dynamic>>(
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

          final data = snapshot.data!;
          final tables = data['tables'] as List<Map<String, dynamic>>;
          final tableCount = data['tableCount'];
          final sizeKb = NumberFormat('#,###').format(data['sizeKb']);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Total of $tableCount tables ($sizeKb KB)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),

              const Divider(),

              // ---------- TABLE ----------
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    itemCount: tables.length + 1,
                    itemBuilder: (context, index) {
                      // ----- HEADER ROW -----
                      if (index == 0) {
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  'Table Name',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  'Records',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final row = tables[index - 1];

                      return Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 6, 16, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                row['table'].toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                row['count'].toString(),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}