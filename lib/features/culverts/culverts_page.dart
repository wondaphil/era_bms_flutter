import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/database/culverts_repository.dart';

class CulvertsPage extends StatefulWidget {
  const CulvertsPage({super.key});

  @override
  State<CulvertsPage> createState() => _CulvertsPageState();
}

class _CulvertsPageState extends State<CulvertsPage> {
  final CulvertsRepository _repo = CulvertsRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> searchResults = [];
  bool searching = false;

  // -----------------------
  // Search logic
  // -----------------------

  Future<void> _onSearchChanged(String value) async {
    if (value.trim().length < 3) {
      setState(() {
        searchResults.clear();
        searching = false;
      });
      return;
    }

    setState(() => searching = true);

    final results = await _repo.searchCulverts(value.trim());

    if (!mounted) return;

    setState(() {
      searchResults = results;
      searching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => searchResults = []);
  }

  // -----------------------
  // UI
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Culverts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Culvert',
            onPressed: () {
              // TODO: add new culvert
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'location') {
                context.push('/culvertsbylocation');
              } else if (value == 'route') {
                context.push('/culvertsbyroute');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'location',
                child: Text('Culverts by Location'),
              ),
              PopupMenuItem(
                value: 'route',
                child: Text('Culverts by Route'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						// Search box
						TextField(
							controller: _searchController,
							onChanged: _onSearchChanged,
							decoration: InputDecoration(
								hintText: 'Search culvert...',
								prefixIcon: const Icon(Icons.search),
								suffixIcon: searching
										? const Padding(
												padding: EdgeInsets.all(12),
												child: SizedBox(
													width: 16,
													height: 16,
													child: CircularProgressIndicator(strokeWidth: 2),
												),
											)
										: (_searchController.text.isNotEmpty
												? IconButton(
														icon: const Icon(Icons.clear),
														onPressed: _clearSearch,
													)
												: null),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(12),
								),
								isDense: true,
							),
						),

						// Search results
						if (searchResults.isNotEmpty) ...[
							const SizedBox(height: 4),
							Container(
								constraints: const BoxConstraints(maxHeight: 300),
								decoration: BoxDecoration(
									color: Theme.of(context).cardColor,
									border: Border.all(color: Colors.grey.shade300),
									borderRadius: BorderRadius.circular(8),
								),
								child: ListView.separated(
									shrinkWrap: true,
									physics: const NeverScrollableScrollPhysics(),
									itemCount: searchResults.length,
									separatorBuilder: (_, __) =>
											const Divider(height: 1),
									itemBuilder: (context, index) {
										final b = searchResults[index];
										return ListTile(
											dense: true,
											title: Text(
												'${b['CulvertNo']}',
											),
											onTap: () {
												_clearSearch();
												context.push('/culvert/${b['CulvertId']}');
											},
										);
									},
								),
							),
						],

						const SizedBox(height: 20),

						// Quick cards
						Row(
							children: [
								Expanded(
									child: _quickCard(
										context,
										icon: Icons.location_on,
										title: 'Culverts by Location',
										onTap: () =>
												context.push('/culvertsbylocation'),
									),
								),
								const SizedBox(width: 12),
								Expanded(
									child: _quickCard(
										context,
										icon: Icons.route,
										title: 'Culverts by Route',
										onTap: () =>
												context.push('/culvertsbyroute'),
									),
								),
							],
						),
					],
				),
			),
    );
  }

  // -----------------------
  // Quick card
  // -----------------------

  Widget _quickCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 120,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color:
                      Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}