import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/soil_yield_provider.dart';
import '../../../../core/theme/theme.dart';

class SoilYieldScreen extends StatefulWidget {
  const SoilYieldScreen({super.key});

  @override
  State<SoilYieldScreen> createState() => _SoilYieldScreenState();
}

class _SoilYieldScreenState extends State<SoilYieldScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedSoilType = 'Loamy';
  String _selectedSeason = 'Kharif';
  
  final _tempController = TextEditingController();
  final _humidityController = TextEditingController();
  final _rainfallController = TextEditingController();

  final List<String> _soilTypes = ['Clayey', 'Loamy', 'Sandy', 'Black', 'Alluvial', 'Red'];
  final List<String> _seasons = ['Kharif', 'Rabi', 'Zaid'];

  @override
  void dispose() {
    _tempController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    setState(() {
      _selectedSoilType = 'Loamy';
      _selectedSeason = 'Rabi';
      _tempController.text = '24.5';
      _humidityController.text = '68';
      _rainfallController.text = '145';
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    Provider.of<SoilYieldProvider>(context, listen: false).predictSuitableCrops(
      soilType: _selectedSoilType,
      season: _selectedSeason,
      temp: double.parse(_tempController.text),
      humidity: double.parse(_humidityController.text),
      rainfall: double.parse(_rainfallController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<SoilYieldProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Crop Advisor'),
        actions: [
          if (provider.recommendations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.emeraldGreen),
              onPressed: () {
                provider.reset();
                setState(() {
                  _tempController.clear();
                  _humidityController.clear();
                  _rainfallController.clear();
                  _selectedSoilType = 'Loamy';
                  _selectedSeason = 'Kharif';
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
            if (provider.recommendations.isEmpty && !provider.isLoading) ...[
              // Form Introduction Banner
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Card(
                  elevation: 0,
                  color: AppTheme.emeraldGreen.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Crop Recommendation',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.emeraldGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Configure parameters below to discover the highest yielding crops for your land.',
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

              // Inputs Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Soil Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedSoilType,
                      decoration: const InputDecoration(
                        labelText: 'Soil Type',
                        prefixIcon: Icon(Icons.layers, color: AppTheme.emeraldGreen),
                        floatingLabelStyle: TextStyle(color: AppTheme.emeraldGreen),
                      ),
                      dropdownColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
                      items: _soilTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSoilType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Season Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedSeason,
                      decoration: const InputDecoration(
                        labelText: 'Season',
                        prefixIcon: Icon(Icons.wb_sunny, color: AppTheme.emeraldGreen),
                        floatingLabelStyle: TextStyle(color: AppTheme.emeraldGreen),
                      ),
                      dropdownColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
                      items: _seasons.map((season) => DropdownMenuItem(
                        value: season,
                        child: Text(season),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSeason = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Temperature & Humidity row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _tempController,
                            label: 'Temperature',
                            suffix: '°C',
                            icon: Icons.thermostat,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _humidityController,
                            label: 'Humidity',
                            suffix: '%',
                            icon: Icons.water_drop,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rainfall
                    _buildTextField(
                      controller: _rainfallController,
                      label: 'Average Rainfall',
                      suffix: 'mm',
                      icon: Icons.umbrella,
                    ),
                    const SizedBox(height: 28),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loadSampleData,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: const BorderSide(color: AppTheme.emeraldGreen),
                            ),
                            child: Text(
                              'Sample Metrics',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Predict Crop Fit'),
                          ),
                        ),
                      ],
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
                        'AI is selecting ideal crop types...',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

            // Prediction Results Display
            if (provider.recommendations.isNotEmpty && !provider.isLoading) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'AI Suggested Crops',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Matched crops based on ${provider.soilType} Soil during ${provider.season} season.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Crop Cards list
                    ...provider.recommendations.map((crop) => _buildCropCard(context, crop, theme, isDark)),
                    
                    const SizedBox(height: 12),

                    // Fertilizer & Soil advisory
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  'Soil Improvement Advisory',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...provider.fertilizerTips.map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6.0, right: 12.0),
                                    child: Icon(Icons.check_circle_outline, size: 16, color: AppTheme.emeraldGreen),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: AppTheme.emeraldGreen, size: 20),
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        floatingLabelStyle: const TextStyle(color: AppTheme.emeraldGreen),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildCropCard(BuildContext context, RecommendedCropItem crop, ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Crop Avatar/Emoji Graphic
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                
                // Crop Name & Suitability
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(crop.confidence * 100).toStringAsFixed(1)}% Match',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.emeraldGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Predicted',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Yield & Profitability metrics row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 Expected Yield',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        crop.expectedYield,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.soilAmber,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💰 Est. Profitability',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        crop.profitability,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description paragraph
            Text(
              crop.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
