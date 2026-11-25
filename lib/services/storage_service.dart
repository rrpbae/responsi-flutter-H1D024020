import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class StorageService {
  static const String _favoritesKey = 'weather_favorites';
  static const String _lastLocationKey = 'last_selected_location';

  // --- KOTA FAVORIT ---

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null || favoritesJson.isEmpty) return [];

    try {
      final List<dynamic> decoded = json.decode(favoritesJson);
      return decoded.map((item) => LocationModel.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveFavorite(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    // Cek duplikasi ID atau koordinat
    final alreadyExists = favorites.any((item) =>
    item.id == location.id ||
        (item.latitude == location.latitude && item.longitude == location.longitude));

    if (!alreadyExists) {
      favorites.add(location);
      final encoded = json.encode(favorites.map((e) => e.toJson()).toList());
      return await prefs.setString(_favoritesKey, encoded);
    }
    return false;
  }

  Future<bool> removeFavorite(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere((item) =>
    item.id == location.id ||
        (item.latitude == location.latitude && item.longitude == location.longitude));

    final encoded = json.encode(favorites.map((e) => e.toJson()).toList());
    return await prefs.setString(_favoritesKey, encoded);
  }

  Future<bool> isFavorite(LocationModel location) async {
    final favorites = await getFavorites();
    return favorites.any((item) =>
    item.id == location.id ||
        (item.latitude == location.latitude && item.longitude == location.longitude));
  }

  // --- LOKASI TERAKHIR DIBUKA (Agar saat reopen langsung termuat) ---

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(location.toJson());
    await prefs.setString(_lastLocationKey, encoded);
  }

  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_lastLocationKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final Map<String, dynamic> decoded = json.decode(jsonStr);
      return LocationModel.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }
}