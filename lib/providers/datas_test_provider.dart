import 'package:flutter_riverpod/flutter_riverpod.dart';

final datasTestNotifierProvider =
    StateNotifierProvider<DatasTestProvider, int>((ref) => DatasTestProvider());

class DatasTestProvider extends StateNotifier<int> {
  DatasTestProvider() : super(15);

  loadMoreDatasTest() {
    int newState = state + 15;
    state = newState;
  }

  refreshDatasTest() {
    int newState = 15;
    state = newState;
  }
}
