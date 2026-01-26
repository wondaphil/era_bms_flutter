import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/culverts_repository.dart';

class CulvertDetailPage extends StatefulWidget {
  final String culvertId;

  const CulvertDetailPage({
    Key? key,
    required this.culvertId,
  }) : super(key: key);

  @override
  State<CulvertDetailPage> createState() => _CulvertDetailPageState();
}

class _CulvertDetailPageState extends State<CulvertDetailPage> {
  final CulvertsRepository _repo = CulvertsRepository();

  Map<String, dynamic>? culvert;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCulvert();
  }

  Future<void> _loadCulvert() async {
    final data = await _repo.getCulvertDetail(widget.culvertId);
    setState(() {
      culvert = data;
      loading = false;
    });
  }
	
	@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Culvert Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Culvert',
						onPressed: () async {
							final updated = await context.push<bool>(
								'/culvert/edit/${widget.culvertId}',
							);

							if (updated == true) {
								_loadCulvert(); // reload data
							}
						},
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : culvert == null
              ? const Center(child: Text('Culvert not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(context, 'Serial No.', culvert!['CulvertId']),
                      _field(context, 'Culvert Id', culvert!['CulvertNo']),
                      _field(context, 'Revised Id', culvert!['RevisedCulvertNo']),
                      _field(context, 'District', culvert!['DistrictName']),
                      _field(context, 'Section', culvert!['SectionName']),
                      _field(context, 'Segment', culvert!['SegmentName']),
                      _field(context, 'Main Route', culvert!['MainRouteName']),
                      _field(context, 'Sub Route', culvert!['SubRouteName']),
											const SizedBox(height: 24),

											// ---------- ROW 1 ----------
											Row(
												children: [
													Expanded(
														child: _quickCard(
															context: context,
															icon: Icons.description,
															title: 'Culvert Profile',
															onTap: null, // later
														),
													),
													const SizedBox(width: 12),
													Expanded(
														child: _quickCard(
															context: context,
															icon: Icons.assignment,
															title: 'Major Inspection',
															onTap: null, // later
														),
													),
												],
											),

											const SizedBox(height: 12),

											// ---------- ROW 2 ----------
											Row(
												children: [
													Expanded(
														child: _quickCard(
															context: context,
															icon: Icons.visibility,
															title: 'Visual Inspection',
															onTap: null, // later
														),
													),
													const SizedBox(width: 12),
													Expanded(
														child: _quickCard(
															context: context,
															icon: Icons.build,
															title: 'Improvement',
															onTap: null, // later
														),
													),
												],
											),

											const SizedBox(height: 12),

											// ---------- ROW 3 ----------
											Row(
												children: [
													Expanded(
														child: _quickCard(
															context: context,
															icon: Icons.map,
															title: 'Culvert Map',
															onTap: () {
																context.push('/culvert/map/${widget.culvertId}');
															},
														),
													),
													const SizedBox(width: 12),
													Expanded(
														child: _quickCard(
															context: context,
															icon: Icons.route,
															title: 'Map by Segment',
															onTap: () {
																context.push('/culvert/segmentmap/${culvert!['SegmentId']}');
															},
														),
													),
												],
											),
                    ],
                  ),
                ),
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    Object? value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? '-',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
	
	Widget _quickCard({
		required BuildContext context,
		required IconData icon,
		required String title,
		VoidCallback? onTap,
	}) {
		return SizedBox(
			height: 110,
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
									size: 32,
									color: onTap == null
											? Colors.grey
											: Theme.of(context).colorScheme.primary,
								),
								const SizedBox(height: 8),
								Text(
									title,
									textAlign: TextAlign.center,
									maxLines: 2,
									style: Theme.of(context).textTheme.bodyMedium?.copyWith(
												color: onTap == null ? Colors.grey : null,
											),
								),
							],
						),
					),
				),
			),
		);
	}
}