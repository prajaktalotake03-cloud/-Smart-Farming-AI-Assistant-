import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/crop_health_provider.dart';
import '../../../../core/theme/theme.dart';

class CropHealthScreen extends StatelessWidget {
  const CropHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<CropHealthProvider>(context);
    final result = provider.currentDiagnosis;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Crop Health Diagnosis'),
        actions: [
          if (provider.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.emeraldGreen),
              onPressed: provider.clearSelectedImage,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Selection Card
            if (provider.selectedImage == null) ...[
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F1E15) : const Color(0xFFF0F5F2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.emeraldGreen.withOpacity(0.2),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔬', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        'Upload Leaf Photo',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'AI will inspect it for pests or infections',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
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
                ),
              ),
            ] else ...[
              // Image Preview Panel
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(provider.selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: provider.clearSelectedImage,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Run diagnosis button
              if (result == null && !provider.isLoading)
                FadeIn(
                  child: ElevatedButton(
                    onPressed: provider.runDiagnosis,
                    child: const Text('Start AI Diagnosis'),
                  ),
                ),
            ],
            
            // Loading Animation
            if (provider.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.emeraldGreen),
                      const SizedBox(height: 16),
                      Text(
                        'Leaf tissue analysis in progress...',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              
            // Diagnosis Results Panel
            if (result != null && !provider.isLoading) ...[
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result Header Card
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
                                    result.diseaseName,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: AppTheme.emeraldGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _buildSeverityBadge(result.severity),
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
                      content: result.description,
                    ),
                    const SizedBox(height: 12),
                    
                    // Cause
                    _buildInfoCard(
                      theme,
                      icon: '🦠',
                      title: 'Root Cause',
                      content: result.cause,
                    ),
                    const SizedBox(height: 12),
                    
                    // Treatments
                    _buildListCard(
                      theme,
                      icon: '💊',
                      title: 'Recommended Treatments',
                      items: result.treatmentSteps,
                      bulletColor: AppTheme.soilAmber,
                    ),
                    const SizedBox(height: 12),
                    
                    // Prevention
                    _buildListCard(
                      theme,
                      icon: '🛡️',
                      title: 'Long-term Prevention',
                      items: result.preventionSteps,
                      bulletColor: AppTheme.emeraldGreen,
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
          border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.emeraldGreen),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ],
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
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87),
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
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4, color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87),
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
}
