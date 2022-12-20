import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/models/user_model.dart';

//datas mockés recent searches users
List<User> recentSearchesDatasMockes = [
  User(
      id: 45,
      token: "",
      email: "test1y@gmail.com",
      pseudo: "Kev",
      gender: "Male",
      birthday: "1992-06-06 00:00",
      nationality: "CA",
      profilePictureUrl: "https://animeholicph.files.wordpress.com/2008/10/lalouch-mask.png",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  User(
      id: 186,
      token: "",
      email: "test2@gmail.com",
      pseudo: "Rimbaud",
      gender: "Female",
      birthday: "2002-06-06 00:00",
      nationality: "FR",
      profilePictureUrl: "https://w0.peakpx.com/wallpaper/291/730/HD-wallpaper-death-note-kira.jpg",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  User(
      id: 4,
      token: "",
      email: "test3@gmail.com",
      pseudo: "Destin",
      gender: "Male",
      birthday: "1995-02-06 00:00",
      nationality: "FR",
      profilePictureUrl: "",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
];

//datas mockés possible results possible on search user
List<User> potentialsResultsSearchDatasMockes = [
  User(
      id: 45,
      token: "",
      email: "test1y@gmail.com",
      pseudo: "Kev",
      gender: "Male",
      birthday: "1992-06-06 00:00",
      nationality: "CA",
      profilePictureUrl: "https://animeholicph.files.wordpress.com/2008/10/lalouch-mask.png",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  User(
      id: 1,
      token: "tokenTest1234",
      email: "ccommunay@gmail.com",
      pseudo: "0ruj",
      gender: "Male",
      birthday: "1997-06-06 00:00",
      nationality: "FR",
      profilePictureUrl: "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  User(
      id: 186,
      token: "",
      email: "test2@gmail.com",
      pseudo: "Rimbaud",
      gender: "Female",
      birthday: "2002-06-06 00:00",
      nationality: "FR",
      profilePictureUrl: "https://w0.peakpx.com/wallpaper/291/730/HD-wallpaper-death-note-kira.jpg",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  User(
      id: 4,
      token: "",
      email: "test3@gmail.com",
      pseudo: "Destin",
      gender: "Male",
      birthday: "1995-02-06 00:00",
      nationality: "FR",
      profilePictureUrl: "",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
];

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
