import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/weather_helper.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/daily_forecast_item.dart';
import 'widgets/weather_info_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weatherVM = context.watch<WeatherViewModel>();
    final searchVM = context.watch<SearchViewModel>();

    final location = weatherVM.currentLocation;
    final isFav = location != null ? searchVM.isLocationFavorite(location) : false;

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.location_solid, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    location?.name ?? 'Pilih Lokasi',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.chevron_down, size: 14),
              ],
            ),
          ),
        ),
        actions: [
          if (location != null)
            IconButton(
              icon: Icon(
                isFav ? CupertinoIcons.star_fill : CupertinoIcons.star,
                color: isFav ? Colors.amber : null,
              ),
              tooltip: isFav ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
              onPressed: () {
                searchVM.toggleFavorite(location);
              },
            ),
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            tooltip: 'Cari Kota',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context, weatherVM),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel weatherVM) {
    final theme = Theme.of(context);

    // 1. Loading State
    if (weatherVM.state == WeatherState.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 16),
            Text('Memuat informasi cuaca...'),
          ],
        ),
      );
    }

    // 2. Error State
    if (weatherVM.state == WeatherState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.cloud_bolt_rain,
                  size: 56, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Gagal Mengambil Data Cuaca',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                weatherVM.errorMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => weatherVM.refreshWeather(),
                icon: const Icon(CupertinoIcons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final weather = weatherVM.weather;
    if (weather == null) {
      return const Center(child: Text('Data cuaca tidak tersedia'));
    }

    final current = weather.current;
    final weatherDesc =
    WeatherHelper.getWeatherDescription(current.weatherCode);
    final weatherIcon = WeatherHelper.getWeatherIcon(current.weatherCode);
    final weatherColor = WeatherHelper.getWeatherColor(current.weatherCode);

    // 3. Success State: Tampilan Lengkap
    return RefreshIndicator(
      onRefresh: () => weatherVM.refreshWeather(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Cuaca Utama
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 28.0, horizontal: 20.0),
                child: Column(
                  children: [
                    Icon(weatherIcon, size: 72, color: weatherColor),
                    const SizedBox(height: 12),
                    Text(
                      '${current.temperature.round()}°C',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weatherDesc,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weatherVM.currentLocation?.fullDisplayName ?? '',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Grid Metrik Cuaca Lengkap (Sesuai parameter tabel modul)
            Text(
              'Informasi Cuaca Terkini',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                WeatherInfoCard(
                  icon: CupertinoIcons.thermometer,
                  title: 'Suhu Terasa',
                  value: '${current.apparentTemperature.round()}°C',
                  iconColor: Colors.deepOrangeAccent,
                ),
                WeatherInfoCard(
                  icon: CupertinoIcons.drop,
                  title: 'Kelembapan',
                  value: '${current.relativeHumidity}%',
                  iconColor: Colors.blueAccent,
                ),
                WeatherInfoCard(
                  icon: CupertinoIcons.cloud_rain,
                  title: 'Curah Hujan',
                  value: '${current.precipitation} mm',
                  iconColor: Colors.cyan,
                ),
                WeatherInfoCard(
                  icon: CupertinoIcons.wind,
                  title: 'Kecepatan Angin',
                  value: '${current.windSpeed} km/j',
                  iconColor: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Prakiraan Harian (Daily Forecast)
            Text(
              'Perkiraan Cuaca Harian',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weather.daily.length,
              itemBuilder: (context, index) {
                return DailyForecastItem(
                  forecast: weather.daily[index],
                  isToday: index == 0,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}