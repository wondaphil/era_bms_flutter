typedef Fetcher = Future<List<Map<String, dynamic>>> Function();

class TableDownloadTask {
  final String tableName;     // SQLite table name
  final String displayName;   // User friendly name
  final Fetcher fetcher;      // API call

  const TableDownloadTask({
    required this.tableName,
    required this.displayName,
    required this.fetcher,
  });
}