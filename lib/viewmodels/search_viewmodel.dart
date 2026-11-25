import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

enum SearchState { initial, loading, success, empty, error }

class SearchViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final StorageService _storageService = StorageService();

  SearchState _state = SearchState.initial;
  SearchState get state => _state;

  List<LocationModel> _searchResults = [];
  List<LocationModel> get searchResults => _searchResults;

  List<LocationModel> _favorites = [];
  List<LocationModel> get favorites => _favorites;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  SearchViewModel() {
    loadFavorites();
  }

  // Memuat daftar favorit dari SharedPreferences
  Future<void> loadFavorites() async {
    _favorites = await _storageService.getFavorites();
    notifyListeners();
  }

  // Melakukan pencarian kota ke Geocoding API
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _state = SearchState.initial;
      notifyListeners();
      return;
    }

    _state = SearchState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _weatherService.searchCity(query);
      if (results.isEmpty) {
        _state = SearchState.empty;
        _searchResults = [];
      } else {
        _searchResults = results;
        _state = SearchState.success;
      }
    } catch (e) {
      _state = SearchState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _searchResults = [];
    }

    notifyListeners();
  }

  // Menambah atau menghapus favorit (toggle)
  Future<void> toggleFavorite(LocationModel location) async {
    final isFav = isLocationFavorite(location);
    if (isFav) {
      await _storageService.removeFavorite(location);
    } else {
      await _storageService.saveFavorite(location);
    }
    await loadFavorites();
  }

  // Mengecek apakah kota ini sudah ada di daftar favorit
  bool isLocationFavorite(LocationModel location) {
    return _favorites.any((item) =>
    item.id == location.id ||
        (item.latitude == location.latitude && item.longitude == location.longitude));
  }

  void clearSearch() {
    _searchResults = [];
    _state = SearchState.initial;
    notifyListeners();
  }
}