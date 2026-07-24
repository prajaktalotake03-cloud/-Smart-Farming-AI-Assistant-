class WeatherModel {
  final String location;
  final double tempCelsius;
  final String condition;
  final String iconEmoji;
  final int humidity;
  final double windSpeedKph;
  final double rainfallMm;
  final int rainProbabilityPercent; // e.g. 75 for 75%
  final String agriculturalAdvisory;
  final List<String> cropSpecificRecommendations;
  final List<ForecastDay> forecast;

  WeatherModel({
    required this.location,
    required this.tempCelsius,
    required this.condition,
    required this.iconEmoji,
    required this.humidity,
    required this.windSpeedKph,
    required this.rainfallMm,
    required this.rainProbabilityPercent,
    required this.agriculturalAdvisory,
    required this.cropSpecificRecommendations,
    required this.forecast,
  });
}

class ForecastDay {
  final String dayName;
  final double tempCelsius;
  final String condition;
  final String iconEmoji;
  final int rainProbability;

  ForecastDay({
    required this.dayName,
    required this.tempCelsius,
    required this.condition,
    required this.iconEmoji,
    required this.rainProbability,
  });
}
