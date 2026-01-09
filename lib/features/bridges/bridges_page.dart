import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_drawer.dart';

class BridgesPage extends StatelessWidget {
  const BridgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
			drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Bridges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Bridge',
            onPressed: () {
              // TODO: add new bridge
            },
          ),
          PopupMenuButton<String>(
						onSelected: (value) {
							if (value == 'location') {
								context.push('/bridgesbylocation');
							} else if (value == 'route') {
								context.push('/bridgesbyroute');
							}
						},
						itemBuilder: (context) => const [
							PopupMenuItem(
								value: 'location',
								child: Text('Bridges by Location'),
							),
							PopupMenuItem(
								value: 'route',
								child: Text('Bridges by Route'),
							),
						],
					),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search box
            TextField(
              decoration: InputDecoration(
                hintText: 'Search bridge...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),

            const SizedBox(height: 20),

            // Quick cards
            Row(
							children: [
								Expanded(
									child: SizedBox(
										height: 120,
										child: Card(
											child: InkWell(
												onTap: () {
													context.push('/bridgesbylocation');
												},
												child: Column(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														Icon(
															Icons.location_on,
															size: 32,
															color: Theme.of(context).colorScheme.primary,
														),
														const SizedBox(height: 8),
														const Text(
															'Bridges by Location',
															textAlign: TextAlign.center,
														),
													],
												),
											),
										),
									),
								),
								const SizedBox(width: 12),
								Expanded(
									child: SizedBox(
										height: 120,
										child: Card(
											child: InkWell(
												onTap: () {
													context.push('/bridgesbyroute');
												},
												child: Column(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														Icon(
															Icons.route,
															size: 32,
															color: Theme.of(context).colorScheme.primary,
														),
														const SizedBox(height: 8),
														const Text(
															'Bridges by Route',
															textAlign: TextAlign.center,
														),
													],
												),
											),
										),
									),
								),
							],
						),
          ],
        ),
      ),
    );
  }

  Widget _quickCard(
		BuildContext context, {
		required IconData icon,
		required String title,
	}) {
		return SizedBox(
			height: 120, // 👈 force equal height
			child: Card(
				elevation: 1,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(12),
				),
				child: InkWell(
					borderRadius: BorderRadius.circular(12),
					onTap: () {
						// TODO
					},
					child: Padding(
						padding: const EdgeInsets.all(12),
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(
									icon,
									size: 48,
									color: Theme.of(context).colorScheme.primary,
								),
								const SizedBox(height: 8),
								Text(
									title,
									textAlign: TextAlign.center,
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
									style: Theme.of(context).textTheme.bodyMedium,
								),
							],
						),
					),
				),
			),
		);
	}
}