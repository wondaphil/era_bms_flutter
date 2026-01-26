import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'database_helper.dart';

class DatabaseInfoRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getDatabaseTablesInfo() async {
    final db = await _dbHelper.database;

    final tables = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type='table'
        AND name NOT LIKE 'sqlite_%'
      ORDER BY name
      '''
    );

    final List<Map<String, dynamic>> tableInfos = [];

    for (final t in tables) {
      final name = t['name'] as String;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $name'),
      )!;
      tableInfos.add({'table': name, 'count': count});
    }

    final dbPath = await getDatabasesPath();
    final file = File(join(dbPath, DatabaseHelper.dbFileName));

    return {
      'tables': tableInfos,
      'tableCount': tableInfos.length,
      'sizeKb': (await file.length() / 1024).ceil(),
    };
  }
	
	Future<String> extractDatabaseFile() async {
    // 1️⃣ Source DB path (app internal)
    final dbPath = await getDatabasesPath();
    final sourcePath = join(dbPath, 'era_bms.db');

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Database file not found');
    }

    // 2️⃣ Destination folder (Documents/ERA-BMS)
    final Directory docsDir = await getApplicationDocumentsDirectory();
    final Directory targetDir =
        Directory(join(docsDir.path, 'ERA-BMS'));

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    // 3️⃣ Destination file name with timestamp
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-');

    final targetPath =
        join(targetDir.path, 'era_bms_$timestamp.db');

    // 4️⃣ Copy file
    await sourceFile.copy(targetPath);

    return targetPath; // return saved location
  }
	
	Future<File> extractDatabaseToTempFile() async {
    final dbPath = await getDatabasesPath();
    final sourcePath = join(dbPath, 'era_bms.db');

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

    final targetPath =
        join(tempDir.path, 'era_bms_$timestamp.db');

    return File(sourcePath).copy(targetPath);
  }
	
	Future<void> replaceDatabaseWithPickedFile(File sourceFile) async {
    final dbPath = await getDatabasesPath();
		final targetPath = join(dbPath, 'era_bms.db');

		// Close current DB
    await _dbHelper.closeDatabase();

		await sourceFile.copy(targetPath);
  }
	
	Future<File?> pickDatabaseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, 
    );

    // User cancelled
    if (result == null || result.files.single.path == null) {
      return null;
    }

    final path = result.files.single.path!;

    // Validate extension
    if (!path.endsWith('.db') && !path.endsWith('.db3')) {
      return null;
    }

    return File(path);
  }
}