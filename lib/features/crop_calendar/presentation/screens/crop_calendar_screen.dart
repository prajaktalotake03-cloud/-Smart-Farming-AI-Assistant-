import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/crop_calendar_provider.dart';
import '../../domain/models/active_crop_model.dart';
import '../../../../core/theme/theme.dart';

class CropCalendarScreen extends StatelessWidget {
  const CropCalendarScreen({super.key});

  void _showAddCropDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCropDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<CropCalendarProvider>(context);
    final crops = provider.activeCrops;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Sowing Calendar',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.emeraldGreen, size: 28),
            onPressed: () => _showAddCropDialog(context),
            tooltip: 'Add Active Crop',
          )
        ],
      ),
      body: crops.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📅', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'No active crops logged yet',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a crop to view its sowing schedule and lifecycle.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showAddCropDialog(context),
                    child: const Text('Add My First Crop'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  child: ActiveCropCard(crop: crop),
                );
              },
            ),
      floatingActionButton: crops.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              onPressed: () => _showAddCropDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// --- ACTIVE CROP CARD ---
class ActiveCropCard extends StatelessWidget {
  final ActiveCropModel crop;

  const ActiveCropCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressPct = (crop.progress * 100).toStringAsFixed(0);
    final nextTask = crop.stages.firstWhere((s) => !s.isCompleted, orElse: () => crop.stages.last);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CropTimelineDetailScreen(crop: crop),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crop Title Header
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(crop.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.cropName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sown: ${DateFormat('dd MMM yyyy').format(crop.sowingDate)}  •  Soil: ${crop.soilType}',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              // Progress Bar Section
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: crop.progress,
                        backgroundColor: isDark ? const Color(0xFF14241B) : const Color(0xFFE2EBE5),
                        color: AppTheme.emeraldGreen,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '$progressPct%',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.emeraldGreen,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Next Task Info Box
              if (crop.progress < 1.0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getCategoryEmoji(nextTask.category),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next: ${nextTask.title}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Target: ${DateFormat('dd MMM').format(crop.getEstimatedDate(nextTask))} (${nextTask.daysAfterSowing} Days after sowing)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20, color: AppTheme.emeraldGreen),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('🌾', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text(
                        'Crop Lifecycle Complete!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Are you sure you want to stop tracking this ${crop.cropName} crop? This will delete all calendar tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CropCalendarProvider>(context, listen: false).deleteCrop(crop.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String cat) {
    switch (cat) {
      case 'sowing': return '🌰';
      case 'irrigation': return '💧';
      case 'fertilizer': return '🧪';
      case 'care': return '🛡️';
      case 'harvest': return '🚜';
      default: return '🌿';
    }
  }
}

// --- ADD CROP DIALOG ---
class AddCropDialog extends StatefulWidget {
  const AddCropDialog({super.key});

  @override
  State<AddCropDialog> createState() => _AddCropDialogState();
}

class _AddCropDialogState extends State<AddCropDialog> {
  String _selectedCrop = 'Tomato';
  String _selectedSoil = 'Loamy';
  DateTime _selectedDate = DateTime.now();

  final List<String> _crops = ['Rice', 'Wheat', 'Tomato', 'Cotton', 'Maize', 'Potato', 'Onion', 'Soybean'];
  final List<String> _soilTypes = ['Clayey', 'Loamy', 'Sandy', 'Black', 'Alluvial', 'Red'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Add Active Crop',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Crop Select
            DropdownButtonFormField<String>(
              value: _selectedCrop,
              decoration: const InputDecoration(
                labelText: 'Crop Type',
                prefixIcon: Icon(Icons.grass, color: AppTheme.emeraldGreen),
              ),
              dropdownColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
              items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCrop = val);
              },
            ),
            const SizedBox(height: 16),
            
            // Soil Select
            DropdownButtonFormField<String>(
              value: _selectedSoil,
              decoration: const InputDecoration(
                labelText: 'Soil Type',
                prefixIcon: Icon(Icons.layers, color: AppTheme.emeraldGreen),
              ),
              dropdownColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
              items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSoil = val);
              },
            ),
            const SizedBox(height: 16),
            
            // Date Picker
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14241B) : const Color(0xFFF1F5F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: AppTheme.emeraldGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sowing Date', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_selectedDate),
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Provider.of<CropCalendarProvider>(context, listen: false).addCrop(
              _selectedCrop,
              _selectedDate,
              _selectedSoil,
            );
            Navigator.pop(context);
          },
          child: const Text('Add Crop'),
        ),
      ],
    );
  }
}

// --- TIMELINE DETAIL SCREEN ---
class CropTimelineDetailScreen extends StatelessWidget {
  final ActiveCropModel crop;

  const CropTimelineDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Calculate Estimated Harvest Date
    final harvestStage = crop.stages.firstWhere((s) => s.category == 'harvest', orElse: () => crop.stages.last);
    final harvestDate = crop.getEstimatedDate(harvestStage);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          '${crop.cropName} Lifecycle',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1E15) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Text(crop.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${crop.cropName} (Soil: ${crop.soilType})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emeraldGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sown on: ${DateFormat('dd MMM yyyy').format(crop.sowingDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                        ),
                        Text(
                          'Estimated Harvest: ${DateFormat('dd MMM yyyy').format(harvestDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.soilAmber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Timeline Tasks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '📋 Lifecycle Tasks & Activities',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // List of stages in vertical timeline
                  Consumer<CropCalendarProvider>(
                    builder: (context, provider, child) {
                      // Fetch updated version of this crop
                      final currentCrop = provider.activeCrops.firstWhere((c) => c.id == crop.id, orElse: () => crop);
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentCrop.stages.length,
                        itemBuilder: (context, index) {
                          final stage = currentCrop.stages[index];
                          final isLast = index == currentCrop.stages.length - 1;
                          final stageDate = currentCrop.getEstimatedDate(stage);
                          
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Date Indicator
                                SizedBox(
                                  width: 60,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM').format(stageDate),
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: stage.isCompleted ? Colors.grey : theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Day ${stage.daysAfterSowing}',
                                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                
                                // Center line and indicator
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        provider.toggleStageCompletion(currentCrop.id, stage.id);
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: stage.isCompleted
                                              ? AppTheme.emeraldGreen
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.emeraldGreen,
                                            width: 2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: stage.isCompleted
                                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: stage.isCompleted
                                              ? AppTheme.emeraldGreen
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                
                                // Right Content Card
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 24.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.toggleStageCompletion(currentCrop.id, stage.id);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: stage.isCompleted
                                              ? (isDark ? const Color(0xFF0F1E15) : const Color(0xFFF2F8F4))
                                              : (isDark ? const Color(0xFF1B1B1E) : Colors.white),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: stage.isCompleted
                                                ? AppTheme.emeraldGreen.withOpacity(0.2)
                                                : (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  _getCategoryIcon(stage.category),
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    stage.title,
                                                    style: theme.textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      decoration: stage.isCompleted
                                                          ? TextDecoration.lineThrough
                                                          : null,
                                                      color: stage.isCompleted ? Colors.grey : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              stage.description,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                height: 1.4,
                                                color: stage.isCompleted
                                                    ? Colors.grey
                                                    : (isDark ? Colors.white70 : Colors.black87),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String cat) {
    switch (cat) {
      case 'sowing': return '🌰';
      case 'irrigation': return '💧';
      case 'fertilizer': return '🧪';
      case 'care': return '🛡️';
      case 'harvest': return '🚜';
      default: return '🌿';
    }
  }
}
