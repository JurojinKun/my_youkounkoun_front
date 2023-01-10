import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final initConnectivityStatusAppNotifierProvider = StateNotifierProvider<
    InitConnectivityStatusAppProvider,
    ConnectivityResult?>((ref) => InitConnectivityStatusAppProvider());
final connectivityStatusAppNotifierProvider =
    StateNotifierProvider<ConnectivityStatusAppProvider, ConnectivityResult?>(
        (ref) => ConnectivityStatusAppProvider());

class InitConnectivityStatusAppProvider
    extends StateNotifier<ConnectivityResult?> {
  InitConnectivityStatusAppProvider() : super(null);

  void setInitConnectivityStatus(ConnectivityResult newState) {
    state = newState;
  }
}

class ConnectivityStatusAppProvider extends StateNotifier<ConnectivityResult?> {
  ConnectivityStatusAppProvider() : super(null);

  void updateConnectivityStatus(ConnectivityResult newState) {
    state = newState;
  }
}
