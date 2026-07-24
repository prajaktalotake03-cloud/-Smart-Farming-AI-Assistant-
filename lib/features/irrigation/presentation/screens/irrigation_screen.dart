import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/irrigation_provider.dart';
import '../../../../core/theme/theme.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  double _soilMoisture = 35.0; // default 35% moisture
  String _selectedCrop = 'Tomato';
  String _selectedWeather = 'Sunny';

  final List<String> _crops = ['Rice', 'Wheat', 'Cotton', 'Maize', 'Tomato', 'Potato'];
  final List<String> _weatherConditions = ['Sunny', 'Cloudy', 'Rainy', 'Windy'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<IrrigationProvider>(context);
    final result = provider.result;

    // Get color dynamically based on soil moisture percentage
    Color moistureColor = _soilMoisture < 30 
        ? Colors.redAccent 
        : (_soilMoisture < 65 ? AppTheme.soilAmber : AppTheme.emeraldGreen);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Smart Irrigation'),
        actions: [
          if (result != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.emeraldGreen),
              onPressed: () {
                provider.reset();
                setState(() {
                  _soilMoisture = 35.0;
                  _selectedCrop = 'Tomato';
                  _selectedWeather = 'Sunny';
                });
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (result == null && !provider.isLoading) ...[
              // Intro Banner
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Card(
                  elevation: 0,
                  color: AppTheme.emeraldGreen.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Text('💧', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calculate Irrigation',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.emeraldGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Input active soil parameters to schedule water distribution and prevent water waste.',
                                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Soil Moisture Slider Label & Value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Soil Moisture Level',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: moistureColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_soilMoisture.toInt()}%',
                            style: GoogleFonts.outfit(
                              color: moistureColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Slider
                    Slider(
                      value: _soilMoisture,
                      min: 10,
                      max: 100,
                      divisions: 9,
                      activeColor: moistureColor,
                      inactiveColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      onChanged: (val) {
                        setState(() {
                          _soilMoisture = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Crop Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCrop,
                      decoration: const InputDecoration(
                        labelText: 'Crop Type',
                        prefixIcon: Icon(Icons.grass, color: AppTheme.emeraldGreen),
                        floatingLabelStyle: TextStyle(color: AppTheme.emeraldGreen),
                      ),
                      dropdownColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
                      items: _crops.map((crop) => DropdownMenuItem(
                        value: crop,
                        child: Text(crop),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCrop = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Weather Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedWeather,
                      decoration: const InputDecoration(
                        labelText: 'Current Weather',
                        prefixIcon: Icon(Icons.cloudy_snowing, color: AppTheme.emeraldGreen),
                        floatingLabelStyle: TextStyle(color: AppTheme.emeraldGreen),
                      ),
                      dropdownColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
                      items: _weatherConditions.map((cond) => DropdownMenuItem(
                        value: cond,
                        child: Text(cond),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedWeather = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    ElevatedButton(
                      onPressed: () {
                        provider.calculateIrrigation(
                          soilMoisturePercent: _soilMoisture,
                          cropType: _selectedCrop,
                          weatherCondition: _selectedWeather,
                        );
                      },
                      child: const Center(
                        child: Text('Calculate Irrigation Schedule'),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Loading state
            if (provider.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.emeraldGreen),
                      const SizedBox(height: 16),
                      Text(
                        'AI is calculating watering volumes...',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

            // Outputs Display Card Layout
            if (result != null && !provider.isLoading) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result Overview Card
                    Card(
                      elevation: 0,
                      color: AppTheme.emeraldGreen.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text('💧', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              'IRRIGATION ADVISORY',
                              style: theme.textTheme.bodySmall?.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              result.advisory,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3 Outputs (Schedule, Quantity, Timing)
                    _buildOutputCard(
                      theme,
                      isDark,
                      icon: '📅',
                      title: 'Watering Schedule',
                      value: result.schedule,
                      color: AppTheme.emeraldGreen,
                    ),
                    const SizedBox(height: 12),

                    _buildOutputCard(
                      theme,
                      isDark,
                      icon: '🚿',
                      title: 'Water Quantity',
                      value: result.waterQuantity,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 12),

                    _buildOutputCard(
                      theme,
                      isDark,
                      icon: '⏰',
                      title: 'Best Irrigation Timing',
                      value: result.bestTiming,
                      color: AppTheme.soilAmber,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOutputCard(
    ThemeData theme,
    bool isDark, {
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
