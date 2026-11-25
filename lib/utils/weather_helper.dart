import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeatherHelper {
  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Sebagian Besar Cerah';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 71:
      case 73:
      case 75:
        return 'Bersalju';
      case 80:
      case 81:
      case 82:
        return 'Hujan Deras Lokal';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir Disertai Es';
      default:
        return 'Kondisi Cuaca Normal';
    }
  }

  static IconData getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return CupertinoIcons.sun_max_fill;
      case 1:
      case 2:
        return CupertinoIcons.cloud_sun_fill;
      case 3:
        return CupertinoIcons.cloud_fill;
      case 45:
      case 48:
        return CupertinoIcons.cloud_fog_fill;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
        return CupertinoIcons.cloud_rain_fill;
      case 65:
      case 80:
      case 81:
      case 82:
        return CupertinoIcons.cloud_heavyrain_fill;
      case 71:
      case 73:
      case 75:
        return CupertinoIcons.snow;
      case 95:
      case 96:
      case 99:
        return CupertinoIcons.cloud_bolt_rain_fill;
      default:
        return CupertinoIcons.cloud_sun_fill;
    }
  }

  static Color getWeatherColor(int code) {
    switch (code) {
      case 0:
      case 1:
        return Colors.orangeAccent;
      case 2:
      case 3:
        return Colors.blueGrey;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Colors.blueAccent;
      case 95:
      case 96:
      case 99:
        return Colors.deepPurpleAccent;
      default:
        return Colors.blue;
    }
  }
}