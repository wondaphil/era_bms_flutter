import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/database/database_info_repository.dart';
import '../tracking/active_users_map_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
	final _dbInfoRepo = DatabaseInfoRepository();
	
	Future<void> _saveDbToDownloads(File tempFile) async {
		final downloadsDir = Directory('/storage/emulated/0/Download');

		if (!await downloadsDir.exists()) {
			throw Exception('Downloads folder not accessible');
		}

		final targetPath = join(
			downloadsDir.path,
			basename(tempFile.path),
		);

		await tempFile.copy(targetPath);
	}
	
	Future<void> _shareDatabase(BuildContext context) async {
		try {
			final tempFile = await _dbInfoRepo.extractDatabaseToTempFile();

			await Share.shareXFiles(
				[XFile(tempFile.path)],
				text: 'ERA BMS Database Backup',
				subject: 'ERA BMS SQLite Database',
			);
			
			if (!context.mounted) return;

			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Database exported successfully'),
					behavior: SnackBarBehavior.floating,
				),
			);
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('Failed to share database: $e'),
					backgroundColor: Colors.red,
				),
			);
		}
	}
	
	Future<void> _shareDb(File tempFile) async {
		await Share.shareXFiles(
			[XFile(tempFile.path)],
			text: 'ERA BMS database backup',
		);
	}

  Widget _quickCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
			appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: [
          _quickCard(
            context,
            icon: Icons.cloud_download_outlined,
            title: 'Download Data',
            subtitle: 'Copy latest data from server',
            onTap: () {
              context.push('/settings/download');
            },
          ),

          _quickCard(
            context,
            icon: Icons.save_alt_outlined,
            title: 'Extract Database File',
            subtitle: 'Save current SQLite database locally',
            onTap: () => _shareDatabase(context),
          ),

          _quickCard(
            context,
            icon: Icons.file_upload_outlined,
            title: 'Copy Database File',
            subtitle: 'Replace app database with a local file',
            onTap: () async {
							final repo = DatabaseInfoRepository();

							final file = await repo.pickDatabaseFile();

							// ❌ Invalid or cancelled
							if (file == null) {
								ScaffoldMessenger.of(context).showSnackBar(
									const SnackBar(
										content: Text('Please select a valid SQLite (.db) file'),
										backgroundColor: Colors.red,
									),
								);
								return;
							}

							// ✅ Valid file
							await repo.replaceDatabaseWithPickedFile(file);

							ScaffoldMessenger.of(context).showSnackBar(
								const SnackBar(
									content: Text('Database replaced successfully'),
								),
							);
						},
          ),

          _quickCard(
            context,
            icon: Icons.table_chart_outlined,
            title: 'View All Tables',
            subtitle: 'Inspect tables and record counts',
            onTap: () {
              context.push('/settings/tables');
            },
          ),

          _quickCard(
						context,
						icon: Icons.location_on,
						title: 'Active Users',
						subtitle: 'View all active users',
            onTap: () {
							context.push('/settings/activeusers');
						},
					),
        ],
      ),
    );
  }
}