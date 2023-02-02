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
    List<UserModel> recentSearches = [];

    recentSearches.add(recentSearchUser);

    state = [...recentSearches, ...state];
  }

  void updateRecentSearches(UserModel recentSearchUser) {
    List<UserModel> recentSearches = [];

    if (state.first.id != recentSearchUser.id) {
      state.removeWhere((element) => element.id == recentSearchUser.id);
      recentSearches.add(recentSearchUser);
    }

    state = [...recentSearches, ...state];
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
