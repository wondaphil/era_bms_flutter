import 'table_download_task.dart';
import '../api/bms_api.dart';

final List<TableDownloadTask> downloadTasks = [
  TableDownloadTask(
    tableName: 'District',
    displayName: 'District',
    fetcher: () => BmsApi().getDistrictList(),
  ),

  TableDownloadTask(
    tableName: 'Section',
    displayName: 'Section',
    fetcher: () => BmsApi().getAllSections(),
  ),

  TableDownloadTask(
    tableName: 'Segment',
    displayName: 'Segment',
    fetcher: () => BmsApi().getAllSegments(),
  ),

  TableDownloadTask(
    tableName: 'Bridge',
    displayName: 'Bridge',
    fetcher: () => BmsApi().getAllBridges(),
  ),

  TableDownloadTask(
    tableName: 'Culvert',
    displayName: 'Culvert',
    fetcher: () => BmsApi().getAllCulverts(),
  ),
];