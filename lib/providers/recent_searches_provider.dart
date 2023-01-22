import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/models/user_model.dart';

final recentSearchesNotifierProvider =
    StateNotifierProvider<RecentSearchesProvider, List<UserModel>>(
        (ref) => RecentSearchesProvider());

class RecentSearchesProvider extends StateNotifier<List<UserModel>> {
  RecentSearchesProvider() : super([]);

  void initRecentSearches(List<UserModel> recentSearches) {
    state = [...recentSearches];
  }

  void addRecentSearches(UserModel recentSearchUser) {
    List<UserModel> newState = [];
    List<UserModel> recentSearches = [];

    if (!state.contains(recentSearchUser)) {
      recentSearches.add(recentSearchUser);
    }

    newState = [...recentSearches, ...state];
    state = [...newState];
  }

  void deleteRecentSearches(UserModel recentSearch) {
    List<UserModel> newState = [...state];
    newState.removeWhere((element) => element.id == recentSearch.id);
    state = [...newState];
  }

  void clearRecentSearches() {
    state.clear();
  }
}
