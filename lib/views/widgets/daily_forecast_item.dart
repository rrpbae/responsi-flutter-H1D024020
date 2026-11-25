import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_model.dart';
import '../../utils/weather_helper.dart';

class DailyForecastItem extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;

  const DailyForecastItem({
    Key? key,
    required this.forecast,
    this.isToday = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayName = isToday
        ? 'Hari Ini'
        : DateFormat('EEEE', 'id_ID').format(forecast.date);
    final dateStr = DateFormat('d MMM', 'id_ID').format(forecast.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primaryContainer.withOpacity(0.35)
            : theme.colorScheme.surfaceVariant.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? theme.colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Hari dan Tanggal
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                Text(
                  dateStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Icon dan Teks Kondisi Cuaca
          Icon(
            WeatherHelper.getWeatherIcon(forecast.weatherCode),
            color: WeatherHelper.getWeatherColor(forecast.weatherCode),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                if (forecast.precipitationProbabilityMax > 0) ...[
                  Icon(
                    CupertinoIcons.drop_fill,
                    size: 14,
                    color: Colors.blueAccent.shade200,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${forecast.precipitationProbabilityMax}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.blueAccent.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Suhu Maks / Min
          Row(
            children: [
              Text(
                '${forecast.maxTemperature.round()}°',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${forecast.minTemperature.round()}°',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}