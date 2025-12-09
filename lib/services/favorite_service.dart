import 'package:flutter/foundation.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final List<Map<String, dynamic>> _favorites = [];
  final ValueNotifier<List<Map<String, dynamic>>> _notifier =
      ValueNotifier([]);

  ValueNotifier<List<Map<String, dynamic>>> get favoritesNotifier => _notifier;

  void toggleFavorite(String id, String name, String thumbnail) {
    final index = _favorites.indexWhere((f) => f['id'] == id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add({'id': id, 'name': name, 'thumbnail': thumbnail});
    }
    _notifier.value = [..._favorites];
  }

  void removeFavorite(String id) {
    _favorites.removeWhere((f) => f['id'] == id);
    _notifier.value = [..._favorites];
  }

  bool isFavorite(String id) {
    return _favorites.any((f) => f['id'] == id);
  }
}