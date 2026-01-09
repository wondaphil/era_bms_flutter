import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardViewModelProvider =
    Provider<DashboardViewModel>((ref) {
  return DashboardViewModel();
});

class DashboardViewModel {
  String get userName => 'User Name';

  void onLogout() {
    // TODO: logout logic
  }

  void onExit() {
    // TODO: exit app
  }

  void onMenuSelected(String value) {
    switch (value) {
      case 'web':
        // open web ERA-BMS
        break;
      case 'help':
        break;
      case 'about':
        break;
    }
  }
}