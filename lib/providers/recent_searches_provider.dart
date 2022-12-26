import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/models/user_model.dart';

final recentSearchesNotifierProvider =
    StateNotifierProvider<RecentSearchesProvider, List<User>>(
        (ref) => RecentSearchesProvider());

class RecentSearchesProvider extends StateNotifier<List<User>> {
  RecentSearchesProvider() : super([]);

  void initRecentSearches(List<User> recentSearches) {
    state = [...recentSearches];
  }

  void addRecentSearches(User recentSearchUser) {
    List<User> newState = [];
    List<User> recentSearches = [];

    if (!state.contains(recentSearchUser)) {
      recentSearches.add(recentSearchUser);
    }

    newState = [...recentSearches, ...state];
    state = [...newState];
  }

  void deleteRecentSearches(User recentSearch) {
    List<User> newState = [...state];
    newState.removeWhere((element) => element.id == recentSearch.id);
    state = [...newState];
  }

  void clearRecentSearches() {
    state.clear();
  }
}
