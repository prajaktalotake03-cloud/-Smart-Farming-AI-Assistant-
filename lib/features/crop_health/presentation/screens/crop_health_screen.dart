import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/crop_health_provider.dart';
import '../../domain/models/scan_result_model.dart';
import '../../../../core/theme/theme.dart';

class CropHealthScreen extends StatelessWidget {
  const CropHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<CropHealthProvider>(context);
    final result = provider.currentScanResult;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'AI Farming Scanner',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          if (provider.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.emeraldGreen),
              onPressed: provider.clearSelectedImage,
              tooltip: 'Reset Scanner',
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Segmented Scanner Type Selector
            if (provider.selectedImage == null) ...[
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: _buildScanTypeSelector(context, provider, isDark),
              ),
              const SizedBox(height: 24),
            ],

            // Scanner Card
            if (provider.selectedImage == null) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: _buildUploadCard(context, provider, theme, isDark),
              ),
            ] else ...[
              // Image Preview Panel
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: _buildImagePreviewCard(provider),
              ),
              const SizedBox(height: 20),
              
              // Run diagnosis button
              if (result == null && !provider.isLoading)
                FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppTheme.emeraldGreen, Color(0xFF0C8248)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.emeraldGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: provider.runScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            provider.selectedScanType == ScanType.seed
                                ? Icons.grain
                                : provider.selectedScanType == ScanType.plant
                                    ? Icons.local_florist
                                    : Icons.science,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _getButtonText(provider.selectedScanType),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            
            // Loading Animation
            if (provider.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.emeraldGreen,
                        strokeWidth: 3.5,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getLoadingText(provider.selectedScanType),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will take just a moment...',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              
            // Diagnosis Results Panel
            if (result != null && !provider.isLoading) ...[
              const SizedBox(height: 12),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: _buildResultsSection(context, result, theme, isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- SCAN TYPE SELECTOR ---
  Widget _buildScanTypeSelector(BuildContext context, CropHealthProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14241B) : const Color(0xFFEBF3EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildSelectorTab(
            context,
            provider,
            type: ScanType.disease,
            icon: Icons.bug_report_outlined,
            label: 'Disease',
          ),
          _buildSelectorTab(
            context,
            provider,
            type: ScanType.seed,
            icon: Icons.grain_outlined,
            label: 'Seeds',
          ),
          _buildSelectorTab(
            context,
            provider,
            type: ScanType.plant,
            icon: Icons.local_florist_outlined,
            label: 'Plants',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTab(
    BuildContext context,
    CropHealthProvider provider, {
    required ScanType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = provider.selectedScanType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setScanType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.emeraldGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.emeraldGreen.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppTheme.emeraldGreen,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected ? Colors.white : AppTheme.emeraldGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UPLOAD CARD ---
  Widget _buildUploadCard(BuildContext context, CropHealthProvider provider, ThemeData theme, bool isDark) {
    String emoji = '🔬';
    String title = 'Upload Leaf Photo';
    String desc = 'AI will inspect it for pests or infections';
    
    if (provider.selectedScanType == ScanType.seed) {
      emoji = '🌰';
      title = 'Scan Farm Seeds';
      desc = 'Identify crop seed type and view sowing guidelines';
    } else if (provider.selectedScanType == ScanType.plant) {
      emoji = '🌱';
      title = 'Identify Plant Species';
      desc = 'Identify species, growth stage, and care instructions';
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E15) : const Color(0xFFF2F7F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.emeraldGreen.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPickerButton(
                context,
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                source: ImageSource.camera,
              ),
              const SizedBox(width: 16),
              _buildPickerButton(
                context,
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                source: ImageSource.gallery,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return InkWell(
      onTap: () => Provider.of<CropHealthProvider>(context, listen: false).pickImage(source),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.emeraldGreen.withOpacity(0.08),
          border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.emeraldGreen),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.emeraldGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- IMAGE PREVIEW CARD ---
  Widget _buildImagePreviewCard(CropHealthProvider provider) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        image: DecorationImage(
          image: FileImage(provider.selectedImage!),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white, size: 20),
          onPressed: provider.clearSelectedImage,
        ),
      ),
    );
  }

  // --- RESULTS SECTION MANAGER ---
  Widget _buildResultsSection(BuildContext context, ScanResultModel result, ThemeData theme, bool isDark) {
    switch (result.type) {
      case ScanType.seed:
        return _buildSeedResults(result, theme, isDark);
      case ScanType.plant:
        return _buildPlantResults(result, theme, isDark);
      case ScanType.disease:
        return _buildDiseaseResults(result, theme, isDark);
    }
  }

  // --- SEED RESULTS ---
  Widget _buildSeedResults(ScanResultModel result, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Card(
          elevation: 0,
          color: AppTheme.emeraldGreen.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        result.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.emeraldGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildConfidenceBadge(result.confidence),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '🌰 AI Seed Identification & Sowing Guide',
                  style: GoogleFonts.outfit(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Seed details grid
        _buildInfoGridCard(theme, [
          _GridItem(icon: '📈', label: 'Germination Rate', value: result.germinationRate ?? 'N/A'),
          _GridItem(icon: '🏔️', label: 'Optimal Soil', value: result.optimalSoil ?? 'N/A'),
          _GridItem(icon: '📏', label: 'Sowing Depth', value: result.sowingDepth ?? 'N/A'),
          _GridItem(icon: '💧', label: 'Moisture Need', value: result.moistureNeed ?? 'N/A'),
          _GridItem(icon: '📅', label: 'Best Season', value: result.bestSeason ?? 'N/A'),
        ]),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- PLANT RESULTS ---
  Widget _buildPlantResults(ScanResultModel result, ThemeData theme, bool isDark) {
    final instructions = result.careInstructions ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Card(
          elevation: 0,
          color: AppTheme.emeraldGreen.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        result.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.emeraldGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildConfidenceBadge(result.confidence),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Family: ${result.family ?? "N/A"}',
                      style: GoogleFonts.outfit(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Growth & Health status
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth Stage',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.growthStage ?? 'N/A',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Status',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.healthStatus ?? 'N/A',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: result.healthStatus?.contains('Healthy') == true
                              ? AppTheme.emeraldGreen
                              : Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Care instructions title
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            '☀️ Plant Care Guidelines',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Care instructions grid
        if (instructions.isNotEmpty)
          _buildInfoGridCard(
            theme,
            instructions.entries.map((e) => _GridItem(icon: _getCareIcon(e.key), label: e.key, value: e.value)).toList(),
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- DISEASE RESULTS ---
  Widget _buildDiseaseResults(ScanResultModel result, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Card(
          elevation: 0,
          color: AppTheme.emeraldGreen.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        result.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.emeraldGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildSeverityBadge(result.severity ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricColumn(
                      'Confidence',
                      '${(result.confidence * 100).toStringAsFixed(1)}%',
                      theme,
                    ),
                    _buildMetricColumn(
                      'Date Checked',
                      'Just Now',
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Description
        _buildInfoCard(
          theme,
          icon: '📝',
          title: 'Description',
          content: result.description ?? 'No description provided.',
        ),
        const SizedBox(height: 12),
        
        // Cause
        _buildInfoCard(
          theme,
          icon: '🦠',
          title: 'Root Cause',
          content: result.cause ?? 'No root cause details.',
        ),
        const SizedBox(height: 12),
        
        // Treatments
        if (result.treatmentSteps != null)
          _buildListCard(
            theme,
            icon: '💊',
            title: 'Recommended Treatments',
            items: result.treatmentSteps!,
            bulletColor: AppTheme.soilAmber,
          ),
        const SizedBox(height: 12),
        
        // Prevention
        if (result.preventionSteps != null)
          _buildListCard(
            theme,
            icon: '🛡️',
            title: 'Long-term Prevention',
            items: result.preventionSteps!,
            bulletColor: AppTheme.emeraldGreen,
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- SUB-WIDGET HELPERS ---
  Widget _buildConfidenceBadge(double confidence) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.emeraldGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.4), width: 1),
      ),
      child: Text(
        '${(confidence * 100).toStringAsFixed(1)}% Match',
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.emeraldGreen,
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'high':
        color = Colors.redAccent;
        break;
      case 'medium':
      case 'moderate':
        color = Colors.orangeAccent;
        break;
      default:
        color = Colors.blueAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        severity.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required String icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(
    ThemeData theme, {
    required String icon,
    required String title,
    required List<String> items,
    required Color bulletColor,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, right: 12.0),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bulletColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                            color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGridCard(ThemeData theme, List<_GridItem> items) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: items.map((item) {
            final isLast = items.indexOf(item) == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white90
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- TEXT MATCHERS ---
  String _getButtonText(ScanType type) {
    switch (type) {
      case ScanType.seed:
        return 'Identify Sown Seed';
      case ScanType.plant:
        return 'Identify Plant Specimen';
      case ScanType.disease:
        return 'Start Leaf Tissue Scan';
    }
  }

  String _getLoadingText(ScanType type) {
    switch (type) {
      case ScanType.seed:
        return 'Analyzing seed seedcoat and pattern...';
      case ScanType.plant:
        return 'Analyzing plant structure and leaf veins...';
      case ScanType.disease:
        return 'Running microscopic leaf tissue analysis...';
    }
  }

  String _getCareIcon(String key) {
    final k = key.toLowerCase();
    if (k.contains('sun')) return '☀️';
    if (k.contains('water')) return '💧';
    if (k.contains('soil') || k.contains('ph')) return '🏔️';
    if (k.contains('prun') || k.contains('trim')) return '✂️';
    if (k.contains('temp')) return '🌡️';
    if (k.contains('fertiliz') || k.contains('npk')) return '💊';
    return '⚡';
  }
}

class _GridItem {
  final String icon;
  final String label;
  final String value;

  _GridItem({required this.icon, required this.label, required this.value});
}
