import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  // 1. Mencari daftar kota via Geocoding API
  Future<List<LocationModel>> searchCity(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
        '$_geocodingBaseUrl?name=${Uri.encodeComponent(query.trim())}&count=10&language=id&format=json');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map((item) => LocationModel.fromJson(item)).toList();
        }
        return [];
      } else {
        throw HttpException('Gagal mencari kota (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Silakan periksa jaringan Anda.');
    } catch (e) {
      rethrow;
    }
  }

  // 2. Mengambil data cuaca terkini & forecast dari Forecast API
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    // Sesuai parameter modul responsi
    final currentParams = [
      'temperature_2m',
      'relative_humidity_2m',
      'apparent_temperature',
      'precipitation',
      'weather_code',
      'wind_speed_10m',
    ].join(',');

    final dailyParams = [
      'weather_code',
      'temperature_2m_max',
      'temperature_2m_min',
      'precipitation_probability_max',
    ].join(',');

    final url = Uri.parse(
      '$_weatherBaseUrl?latitude=$latitude&longitude=$longitude&current=$currentParams&daily=$dailyParams&timezone=auto',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw HttpException('Gagal memuat cuaca (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Silakan periksa jaringan Anda.');
    } catch (e) {
      rethrow;
    }
  }
}