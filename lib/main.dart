import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/tracking/user_tracking_service.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AppLifecycleWrapper(),
    ),
  );
}

class AppLifecycleWrapper extends StatefulWidget {
  const AppLifecycleWrapper({super.key});

  @override
  State<AppLifecycleWrapper> createState() =>
      _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState
    extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {

  final UserTrackingService _trackingService =
      UserTrackingService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start tracking immediately
    _trackingService.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trackingService.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _trackingService.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _trackingService.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const EraBmsApp();
  }
}