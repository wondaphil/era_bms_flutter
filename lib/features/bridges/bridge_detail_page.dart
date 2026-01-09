import 'package:flutter/material.dart';
import '../../core/database/bridges_repository.dart';

class BridgeDetailPage extends StatefulWidget {
  final String bridgeId;

  const BridgeDetailPage({
    Key? key,
    required this.bridgeId,
  }) : super(key: key);

  @override
  State<BridgeDetailPage> createState() => _BridgeDetailPageState();
}

class _BridgeDetailPageState extends State<BridgeDetailPage> {
  final BridgesRepository _repo = BridgesRepository();

  Map<String, dynamic>? bridge;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadBridge();
  }

  Future<void> _loadBridge() async {
    final data = await _repo.getBridgeDetail(widget.bridgeId);
    setState(() {
      bridge = data;
      loading = false;
    });
  }
	
	Future<void> _deleteBridge() async {
		// TODO: call repository delete method
		// await _repo.deleteBridge(widget.bridgeId);

		if (!mounted) return;

		Navigator.pop(context); // go back after delete
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
						icon: const Icon(Icons.delete),
						tooltip: 'Delete Bridge',
						onPressed: () => _confirmDelete(context),
					),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bridge == null
              ? const Center(child: Text('Bridge not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(context, 'Serial No.', bridge!['BridgeId']),
                      _field(context, 'Bridge No', bridge!['BridgeNo']),
                      _field(context, 'Bridge Name', bridge!['BridgeName']),
                      _field(context, 'District', bridge!['DistrictName']),
                      _field(context, 'Section', bridge!['SectionName']),
                      _field(context, 'Segment', bridge!['SegmentName']),
                      _field(context, 'Main Route', bridge!['MainRouteName']),
                      _field(context, 'Sub Route', bridge!['SubRouteName']),
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
				title: const Text('Delete Bridge'),
				content: const Text(
					'Are you sure you want to delete this bridge?',
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: const Text('Cancel'),
					),
					TextButton(
						onPressed: () {
							Navigator.pop(context);
							_deleteBridge();
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