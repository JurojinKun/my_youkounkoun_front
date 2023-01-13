import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/snack_bar_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';

final currentRouteAppNotifierProvider =
    StateNotifierProvider<CurrentRouteAppProvider, String>(
        (ref) => CurrentRouteAppProvider());

class CurrentRouteAppProvider extends StateNotifier<String> {
  CurrentRouteAppProvider() : super("");

  void setCurrentRouteApp(
      String newState, BuildContext context, WidgetRef ref) {
    state = newState;

    if (ref.read(connectivityStatusAppNotifierProvider) ==
        ConnectivityResult.none) {
      scaffoldMessengerKey.currentState!.clearSnackBars();
      scaffoldMessengerKey.currentState!.showSnackBar(showSnackBarCustom(context, state));
    }
  }
}
