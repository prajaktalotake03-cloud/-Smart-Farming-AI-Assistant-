import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import '../../../../core/theme/theme.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WeatherProvider>(context);
    final weather = provider.weather;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.emeraldGreen),
            onPressed: () => provider.fetchWeather(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.emeraldGreen))
          : weather == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('😢', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text('Could not load weather statistics.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => provider.fetchWeather(),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sky Gradient Card for Current Weather
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4A90E2), // Light Sky Blue
                                Color(0xFF50E3C2), // Minty Blue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A90E2).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        weather.location,
                                        style: GoogleFonts.outfit(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        weather.condition,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.85),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    weather.iconEmoji,
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${weather.tempCelsius}°C',
                                style: GoogleFonts.outfit(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Stats Row inside Sky Card
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSkyStatColumn('💧 Humidity', '${weather.humidity}%'),
                                    _buildSkyStatColumn('💨 Wind', '${weather.windSpeedKph} km/h'),
                                    _buildSkyStatColumn('🌧️ Rain Prob.', '${weather.rainProbabilityPercent}%'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Agricultural Advice Card
                      FadeInUp(
                        delay: const Duration(milliseconds: 150),
                        duration: const Duration(milliseconds: 500),
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('🌾', style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Farming Advisory',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  weather.agriculturalAdvisory,
                                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                                ),
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                Text(
                                  'Crop Specific Actions:',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.emeraldGreen,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...weather.cropSpecificRecommendations.map((rec) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0, right: 8.0),
                                        child: Icon(Icons.check_circle_outline, size: 14, color: AppTheme.emeraldGreen),
                                      ),
                                      Expanded(
                                        child: Text(
                                          rec,
                                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 7-Day Forecast Header
                      Text(
                        '7-Day Forecast',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // 7-Day List
                      FadeInUp(
                        delay: const Duration(milliseconds: 250),
                        duration: const Duration(milliseconds: 500),
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: weather.forecast.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final day = weather.forecast[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Day name
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          day.dayName,
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // Emoji & Condition
                                      Row(
                                        children: [
                                          Text(day.iconEmoji, style: const TextStyle(fontSize: 22)),
                                          const SizedBox(width: 12),
                                          Text(
                                            day.condition,
                                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      // Rain & Temp
                                      Row(
                                        children: [
                                          if (day.rainProbability > 25)
                                            Container(
                                              margin: const EdgeInsets.only(right: 12),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '💧${day.rainProbability}%',
                                                style: GoogleFonts.inter(
                                                  color: Colors.blueAccent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          Text(
                                            '${day.tempCelsius}°C',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.soilAmber,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSkyStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
