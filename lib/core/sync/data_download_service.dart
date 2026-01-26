import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../api/bms_api.dart';
import '../api/bms_api_bridge_inventory.dart';
import '../api/bms_api_major_inspection.dart';
import '../api/bms_api_visual_inspection.dart';
import '../api/bms_api_culvert_inventory.dart';
import '../api/bms_api_culvert_inspection.dart';
import 'download_registry.dart';

class DownloadProgress {
  final String message;
	final int current;
  final int total;
  
  DownloadProgress({
    required this.message,
    required this.current,
    required this.total,
  });
}

typedef ProgressCallback = void Function(DownloadProgress progress);

class DataDownloadService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProgressCallback? onProgress;

  DataDownloadService({this.onProgress});

  Future<void> start() async {
    final db = await _dbHelper.database;
    final totalSteps = downloadTasks.length;
    int step = 0;

    await db.transaction((txn) async {
      for (final task in downloadTasks) {
        step++;

        onProgress?.call(
          DownloadProgress(
            message: 'Downloading ${task.displayName}...',
						current: step,
						total: totalSteps,
          ),
        );

        final rows = await task.fetcher();
        await _replaceTable(txn, task.tableName, rows);
      }
    });
  }

  Future<void> _replaceTable(
    DatabaseExecutor db,
    String tableName,
    List<Map<String, dynamic>> rows,
  ) async {
    await db.delete(tableName);
    for (final row in rows) {
      await db.insert(tableName, row);
    }
  }
}