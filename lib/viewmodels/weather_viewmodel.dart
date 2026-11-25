import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

enum WeatherState { initial, loading, success, error }

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final StorageService _storageService = StorageService();

  WeatherState _state = WeatherState.initial;
  WeatherState get state => _state;

  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  LocationModel? _currentLocation;
  LocationModel? get currentLocation => _currentLocation;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Lokasi default saat pertama kali install dan belum ada riwayat (Purwokerto)
  final LocationModel _defaultLocation = LocationModel(
    id: 1630789,
    name: 'Purwokerto',
    latitude: -7.4214,
    longitude: 109.2344,
    country: 'Indonesia',
    admin1: 'Jawa Tengah',
  );

  WeatherViewModel() {
    initWeather();
  }

  // Mengambil lokasi terakhir dari storage atau pakai default jika baru pertama buka
  Future<void> initWeather() async {
    final lastLocation = await _storageService.getLastLocation();
    if (lastLocation != null) {
      await fetchWeather(lastLocation);
    } else {
      await fetchWeather(_defaultLocation);
    }
  }

  // Mengambil data cuaca berdasarkan lokasi yang dipilih
  Future<void> fetchWeather(LocationModel location) async {
    _currentLocation = location;
    _state = WeatherState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _weatherService.getWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _weather = result;
      _state = WeatherState.success;
      // Simpan lokasi terpilih ke SharedPreferences agar persist saat dibuka ulang
      await _storageService.saveLastLocation(location);
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  // Fungsi pull-to-refresh
  Future<void> refreshWeather() async {
    if (_currentLocation != null) {
      await fetchWeather(_currentLocation!);
    } else {
      await fetchWeather(_defaultLocation);
    }
  }
}