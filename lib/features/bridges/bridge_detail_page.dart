import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
	
	@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Bridge',
						onPressed: () async {
							final updated = await context.push<bool>(
								'/bridge/edit/${widget.bridgeId}',
							);

							if (updated == true) {
								_loadBridge(); // reload data
							}
						},
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
}