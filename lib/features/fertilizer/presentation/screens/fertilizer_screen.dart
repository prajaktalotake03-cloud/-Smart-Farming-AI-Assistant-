import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/fertilizer_provider.dart';
import '../../../../core/theme/theme.dart';

class FertilizerScreen extends StatefulWidget {
  const FertilizerScreen({super.key});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCrop = 'Tomato';
  String _selectedSoilType = 'Loamy';
  
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();

  final List<String> _crops = ['Rice', 'Wheat', 'Cotton', 'Maize', 'Tomato', 'Potato'];
  final List<String> _soilTypes = ['Clayey', 'Loamy', 'Sandy', 'Black', 'Alluvial', 'Red'];

  @override
  void dispose() {
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    setState(() {
      _selectedCrop = 'Tomato';
      _selectedSoilType = 'Loamy';
      _nController.text = '24';
      _pController.text = '48';
      _kController.text = '52';
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    Provider.of<FertilizerProvider>(context, listen: false).suggestFertilizers(
      crop: _selectedCrop,
      soilType: _selectedSoilType,
      nitrogen: double.parse(_nController.text),
      phosphorus: double.parse(_pController.text),
      potassium: double.parse(_kController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<FertilizerProvider>(context);
    final result = provider.result;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Fertilizer Advisor'),
        actions: [
          if (result != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.emeraldGreen),
              onPressed: () {
                provider.reset();
                setState(() {
                  _nController.clear();
                  _pController.clear();
                  _kController.clear();
                  _selectedCrop = 'Tomato';
                  _selectedSoilType = 'Loamy';
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
              // Intro Card
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Card(
                  elevation: 0,
                  color: AppTheme.emeraldGreen.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Text('🧪', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fertilizer Optimization',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.emeraldGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Input N-P-K nutrient levels to receive custom fertilizer recommendations and safe dosage plans.',
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
                    // Crop Select Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCrop,
                      decoration: const InputDecoration(
                        labelText: 'Target Crop',
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

                    // Soil Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedSoilType,
                      decoration: const InputDecoration(
                        labelText: 'Soil Type',
                        prefixIcon: Icon(Icons.layers, color: AppTheme.emeraldGreen),
                        floatingLabelStyle: TextStyle(color: AppTheme.emeraldGreen),
                      ),
                      dropdownColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
                      items: _soilTypes.map((soil) => DropdownMenuItem(
                        value: soil,
                        child: Text(soil),
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

                    // Nitrogen, Phosphorus, Potassium
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _nController,
                            label: 'Nitrogen (N)',
                            suffix: 'mg/kg',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _pController,
                            label: 'Phosphorus (P)',
                            suffix: 'mg/kg',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _kController,
                      label: 'Potassium (K)',
                      suffix: 'mg/kg',
                    ),
                    const SizedBox(height: 28),

                    // Buttons row
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
                              'Sample Soil',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Suggest Fertilizers'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Loading State
            if (provider.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.emeraldGreen),
                      const SizedBox(height: 16),
                      Text(
                        'AI is matching soil deficiencies...',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

            // Outputs Display
            if (result != null && !provider.isLoading) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Suggestion Context Overview Card
                    Card(
                      elevation: 0,
                      color: AppTheme.emeraldGreen.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text('🧪', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              'AI NUTRIENT SUMMARY',
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
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dosage Card
                    _buildOutputHeaderCard(
                      theme,
                      isDark,
                      icon: '⚖️',
                      title: 'Suggested Fertilizer & Dosage',
                      name: result.fertilizerName,
                      value: result.dosage,
                      color: AppTheme.soilAmber,
                    ),
                    const SizedBox(height: 16),

                    // Step Instructions Card
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('📋', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  'Application Instructions',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(result.instructions.length, (idx) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppTheme.emeraldGreen.withOpacity(0.12),
                                    child: Text(
                                      '${idx + 1}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      result.instructions[idx],
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
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

  Widget _buildOutputHeaderCard(
    ThemeData theme,
    bool isDark, {
    required String icon,
    required String title,
    required String name,
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
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dosage: $value',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
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
