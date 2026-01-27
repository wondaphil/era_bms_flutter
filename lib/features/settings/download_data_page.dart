import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/sync/data_download_service.dart';
import '../../core/api/api_config.dart';
import '../../core/api/bms_api.dart';

class DownloadDataPage extends StatefulWidget {
  const DownloadDataPage({super.key});

  @override
  State<DownloadDataPage> createState() => _DownloadDataPageState();
}

class _DownloadDataPageState extends State<DownloadDataPage> {
  bool _hasInternet = false;
  bool _checkingConnectivity = true;
  bool _downloading = false;

  String _statusText = '';
	int _currentStep = 0;
	int _totalSteps = 0;
	
	bool _testingConnection = false;
	String? _testResult;
	Color? _testResultColor;
	
	DateTime? _startTime;
	Timer? _timer;
	String _elapsedText = '';
	double _progress = 0.0;

  final List<String> _schemes = ['http://', 'https://'];
  String _selectedScheme = 'http://';
  final TextEditingController _serverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
		_loadSavedApiUrl();
  }
	
	Future<void> _loadSavedApiUrl() async {
		final url = await ApiConfig.getBaseUrl();

		if (url.isEmpty) return;

		if (url.startsWith('https://')) {
			_selectedScheme = 'https://';
			_serverCtrl.text = url.replaceFirst('https://', '');
		} else if (url.startsWith('http://')) {
			_selectedScheme = 'http://';
			_serverCtrl.text = url.replaceFirst('http://', '');
		}
	}

  // -----------------------------------------------------------
  // INTERNET CHECK
  // -----------------------------------------------------------

  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> result =
				await Connectivity().checkConnectivity();

    setState(() {
      _hasInternet = result.contains(ConnectivityResult.mobile) ||
                   result.contains(ConnectivityResult.wifi);
      _checkingConnectivity = false;
    });
  }
	
	// -----------------------------------------------------------
  // TEST CONNECTION
  // -----------------------------------------------------------

  Future<void> _testConnection() async {
		setState(() {
			_testingConnection = true;
			_testResult = null;
		});

		try {
			// lightweight POST call
			await BmsApi().getDistrictList();

			setState(() {
				_testResult = 'Successful';
				_testResultColor = Colors.green;
			});
		} catch (e) {
			setState(() {
				_testResult = 'Failed';
				_testResultColor = Colors.red;
			});
		} finally {
			setState(() => _testingConnection = false);
		}
	}

  // -----------------------------------------------------------
  // START DOWNLOAD
  // -----------------------------------------------------------

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _statusText = 'Starting download...';
			_currentStep = 0;
			_totalSteps = 0;
    });

    try {
      final service = DataDownloadService(
        onProgress: (progress) {
					setState(() {
						_statusText = progress.message;
						_currentStep = progress.current;
						_totalSteps = progress.total;

						_progress = progress.total == 0
								? 0.0
								: progress.current / progress.total;
					});
				},
      );
			
			_startTime = DateTime.now();

			_timer = Timer.periodic(const Duration(seconds: 1), (_) {
				if (_startTime == null) return;

				final elapsed = DateTime.now().difference(_startTime!);
				setState(() {
					_elapsedText =
							'Elapsed: ${elapsed.inMinutes.toString().padLeft(2, '0')}:'
							'${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
				});
			});

      await service.start();

      if (!mounted) return;

      setState(() => _downloading = false);

			_timer?.cancel();
			_timer = null;
			
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Data downloaded successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _downloading = false);
			_timer?.cancel();
			_timer = null;
			
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // -----------------------------------------------------------
  // UI
  // -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
			onWillPop: () async => !_downloading, // block back while downloading
			child: Scaffold(
				appBar: AppBar(title: const Text('Download Data')),
				body: Padding(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// ---------- INTERNET STATUS ----------
							Row(
								children: [
									const Text(
										'Internet Status: ',
										style: TextStyle(fontWeight: FontWeight.w600),
									),
									if (_checkingConnectivity)
										const Text('Checking...')
									else
										Text(
											_hasInternet ? 'Available' : 'Not Available',
											style: TextStyle(
												color: _hasInternet ? Colors.green : Colors.red,
												fontWeight: FontWeight.w600,
											),
										),
								],
							),

							const SizedBox(height: 24),

							// ---------- SERVER ADDRESS ----------
							const Text(
								'Server Address',
								style: TextStyle(fontWeight: FontWeight.w600),
							),
							const SizedBox(height: 8),

							Row(
								children: [
									DropdownButton<String>(
										value: _selectedScheme,
										items: _schemes
												.map(
													(s) => DropdownMenuItem(
														value: s,
														child: Text(s),
													),
												)
												.toList(),
										onChanged: (v) {
											if (v != null) {
												setState(() => _selectedScheme = v);
											}
										},
									),
									const SizedBox(width: 8),
									Expanded(
										child: TextField(
											controller: _serverCtrl,
											decoration: const InputDecoration(
												hintText: 'Server address here',
												border: OutlineInputBorder(),
												isDense: true,
											),
										),
									),
								],
							),

							const SizedBox(height: 8),

							Column(
								children: [
									SizedBox(
										width: double.infinity,
										child: ElevatedButton.icon(
											icon: const Icon(Icons.save),
											label: const Text('Set Address'),
											onPressed: () async {
												final fullUrl =
														'$_selectedScheme${_serverCtrl.text.trim()}';
												await ApiConfig.setBaseUrl(fullUrl);

												if (!mounted) return;

												ScaffoldMessenger.of(context).showSnackBar(
													SnackBar(
														content: Text('Server set to: $fullUrl'),
													),
												);
											},
										),
									),
									
									const SizedBox(height: 8),

									// ---------- TEST CONNECTION ----------
									Row(
										children: [
											// Button at natural width
											ElevatedButton.icon(
												icon: _testingConnection
														? const SizedBox(
																width: 16,
																height: 16,
																child: CircularProgressIndicator(strokeWidth: 2),
															)
														: const Icon(Icons.wifi_tethering),
												label: const Text('Test Connection'),
												onPressed: _testingConnection ? null : _testConnection,
											),
											
											// Spacing and result text
											if (_testResult != null) ...[
												const SizedBox(width: 12),
												Flexible(
													child: Row(
														mainAxisSize: MainAxisSize.min,
														children: [
															Icon(
																_testResultColor == Colors.green
																		? Icons.check_circle
																		: Icons.error,
																color: _testResultColor,
																size: 18,
															),
															const SizedBox(width: 6),
															Flexible(
																child: Text(
																	_testResult!,
																	style: TextStyle(
																		color: _testResultColor,
																		fontWeight: FontWeight.w600,
																	),
																	overflow: TextOverflow.ellipsis,
																),
															),
														],
													),
												),
											],
										],
									),
								],
							),

							const Spacer(),

							if (_downloading) ...[
								// ---------- PROGRESS BAR ----------
								LinearProgressIndicator(value: _progress),
								const SizedBox(height: 8),

								// ---------- STATUS TEXT ----------
								Text(
									_statusText,
									style: const TextStyle(fontWeight: FontWeight.w600),
								),

								// ---------- ELAPSED TIME ----------
								const SizedBox(height: 4),
								Text(
									_elapsedText,
									style: const TextStyle(
										fontSize: 12,
										color: Colors.black54,
									),
								),
							],

							const SizedBox(height: 12),

							// ---------- WARNING ----------
							Text(
								'⚠️ Downloading data may take several minutes. '
								'Do not interrupt once started.',
								style: TextStyle(
									color: Colors.red.shade400,
									fontSize: 16,
								),
							),

							const SizedBox(height: 12),

							// ---------- START BUTTON ----------
							SafeArea(
								minimum: const EdgeInsets.only(bottom: 12),
								child: SizedBox(
									width: double.infinity,
									child: ElevatedButton.icon(
										icon: _downloading
												? const SizedBox(
														width: 18,
														height: 18,
														child: CircularProgressIndicator(strokeWidth: 2),
													)
												: const Icon(Icons.download),
										label: const Text('Start Download'),
										onPressed:
												(!_hasInternet || _downloading) ? null : _startDownload,
									),
								),
							),
						],
					),
				),
			),
    );
  }
}