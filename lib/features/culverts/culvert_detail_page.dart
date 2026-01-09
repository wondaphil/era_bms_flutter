import 'package:flutter/material.dart';
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
	
	Future<void> _deleteCulvert() async {
		// TODO: call repository delete method
		// await _repo.deleteCulvert(widget.culvertId);

		if (!mounted) return;

		Navigator.pop(context); // go back after delete
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Culvert Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
						icon: const Icon(Icons.delete),
						tooltip: 'Delete Culvert',
						onPressed: () => _confirmDelete(context),
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
                      _field(context, 'Culvert No', culvert!['CulvertNo']),
                      _field(context, 'District', culvert!['DistrictName']),
                      _field(context, 'Section', culvert!['SectionName']),
                      _field(context, 'Segment', culvert!['SegmentName']),
                      _field(context, 'Main Route', culvert!['MainRouteName']),
                      _field(context, 'Sub Route', culvert!['SubRouteName']),
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
	
	void _confirmDelete(BuildContext context) {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Delete Culvert'),
				content: const Text(
					'Are you sure you want to delete this culvert?',
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: const Text('Cancel'),
					),
					TextButton(
						onPressed: () {
							Navigator.pop(context);
							_deleteCulvert();
						},
						child: const Text(
							'Delete',
							style: TextStyle(color: Colors.red),
						),
					),
				],
			),
		);
	}
}