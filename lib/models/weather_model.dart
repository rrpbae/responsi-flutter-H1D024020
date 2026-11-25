class CurrentWeather {
  final double temperature; // current.temperature_2m
  final int relativeHumidity; // current.relative_humidity_2m
  final double apparentTemperature; // current.apparent_temperature
  final double precipitation; // current.precipitation
  final int weatherCode; // current.weather_code
  final double windSpeed; // current.wind_speed_10m

  CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemperature; // daily.temperature_2m_max
  final double minTemperature; // daily.temperature_2m_min
  final int precipitationProbabilityMax; // daily.precipitation_probability_max

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbabilityMax,
  });
}

class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentData = json['current'] as Map<String, dynamic>;
    final dailyData = json['daily'] as Map<String, dynamic>;

    final List<dynamic> times = dailyData['time'] ?? [];
    final List<dynamic> weatherCodes = dailyData['weather_code'] ?? [];
    final List<dynamic> maxTemps = dailyData['temperature_2m_max'] ?? [];
    final List<dynamic> minTemps = dailyData['temperature_2m_min'] ?? [];
    final List<dynamic> precipProbs =
        dailyData['precipitation_probability_max'] ?? [];

    List<DailyForecast> dailyList = [];
    for (int i = 0; i < times.length; i++) {
      dailyList.add(
        DailyForecast(
          date: DateTime.parse(times[i]),
          weatherCode: (weatherCodes[i] as num).toInt(),
          maxTemperature: (maxTemps[i] as num).toDouble(),
          minTemperature: (minTemps[i] as num).toDouble(),
          precipitationProbabilityMax: (precipProbs[i] as num).toInt(),
        ),
      );
    }

    return WeatherModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] ?? 'auto',
      current: CurrentWeather.fromJson(currentData),
      daily: dailyList,
    );
  }
}