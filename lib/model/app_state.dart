import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final String defaultPage = '100';
  String teletextImageUrl =
    'https://api-teletext.ceskatelevize.cz/services-old/teletext/picture.php?channel=CT2&page=%s';
  String page = '';

  Future <List<String>> get favorites async {
    final SharedPreferences prefs = await _prefs;

    List<String>? favorites = prefs.getStringList('favorites');

    favorites ??= [];
    favorites.sort();

    return favorites;
  }

  Future<String> pageTitle({required String page}) async {
    final SharedPreferences prefs = await _prefs;
    String title = prefs.getString('favorites_$page') ?? '';

    return title;
  }


  initiate() {
    if (page.isEmpty) {
      page = defaultPage;
    }
  }

  updatePage({ required String entered }) async {
    page = entered;
    notifyListeners();
  }

  clear() {
    page = '';
    notifyListeners();
  }

  removeAll() async {
    final SharedPreferences prefs = await _prefs;

    await prefs.clear();
    notifyListeners();
  }

  addFavorite({ required String selectedPage, required String title }) async {
    final SharedPreferences prefs = await _prefs;

    if (title.isEmpty) {
      title = selectedPage;
    }

    favorites.then((List<String> favorites) {
      favorites.add(selectedPage);
      favorites = favorites.toSet().toList(); // removing duplicates

      prefs.setStringList('favorites', favorites);
      prefs.setString('favorites_$selectedPage', title);

      notifyListeners();
    });
  }

  removeFavorite({ required String selectedPage }) async {
    final SharedPreferences prefs = await _prefs;

    favorites.then((favorites) {
      favorites.remove(selectedPage);

      prefs.setStringList('favorites', favorites);
      notifyListeners();
    });
  }

  Future<bool> isFavorite({required String page}) {
    return favorites.then((favorites) => favorites.contains(page));
  }
}
