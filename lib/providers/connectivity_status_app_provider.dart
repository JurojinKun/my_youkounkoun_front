import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStatusAppNotifierProvider =
    StateNotifierProvider<ConnectivityStatusAppProvider, ConnectivityResult?>(
        (ref) => ConnectivityStatusAppProvider());

class ConnectivityStatusAppProvider extends StateNotifier<ConnectivityResult?> {
  ConnectivityStatusAppProvider() : super(null);

  void updateConnectivityStatus(ConnectivityResult newState) {
    state = newState;
  }
}
