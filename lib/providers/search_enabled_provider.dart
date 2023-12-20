import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchEnabledNotifierProvider =
    StateNotifierProvider<SearchEnabledProvider, bool>(
        (ref) => SearchEnabledProvider());

class SearchEnabledProvider extends StateNotifier<bool> {
  SearchEnabledProvider() : super(false);

  void updateState(bool newState) {
    state = newState;
  }
}