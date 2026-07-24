import 'package:flutter/material.dart';
import '../../domain/models/active_crop_model.dart';

class CropCalendarProvider extends ChangeNotifier {
  final List<ActiveCropModel> _activeCrops = [];

  CropCalendarProvider() {
    // Add default active crops so the screen is interactive immediately
    _initDefaultCrops();
  }

  List<ActiveCropModel> get activeCrops => List.unmodifiable(_activeCrops);

  void _initDefaultCrops() {
    final now = DateTime.now();
    
    // 1. Tomato Crop sowed 15 days ago
    final tomatoSowingDate = now.subtract(const Duration(days: 15));
    _activeCrops.add(
      ActiveCropModel(
        id: 'default_tomato',
        cropName: 'Tomato',
        emoji: '🍅',
        sowingDate: tomatoSowingDate,
        soilType: 'Loamy',
        stages: [
          CalendarStage(
            id: 'tom_1',
            title: 'Nursery Sowing',
            description: 'Sow tomato seeds in germination trays with coco-peat.',
            daysAfterSowing: 1,
            isCompleted: true,
            category: 'sowing',
          ),
          CalendarStage(
            id: 'tom_2',
            title: 'Seedling Sprouting',
            description: 'Provide indirect sunlight, keep compost slightly moist.',
            daysAfterSowing: 6,
            isCompleted: true,
            category: 'care',
          ),
          CalendarStage(
            id: 'tom_3',
            title: 'Transplanting',
            description: 'Move sturdy seedlings (4-5 leaves) into rows spaced 60cm apart in main field.',
            daysAfterSowing: 14,
            isCompleted: true,
            category: 'care',
          ),
          CalendarStage(
            id: 'tom_4',
            title: 'Weeding & Staking',
            description: 'Provide supportive wooden sticks (staking) and clear grass weeds.',
            daysAfterSowing: 28,
            isCompleted: false,
            category: 'care',
          ),
          CalendarStage(
            id: 'tom_5',
            title: 'Nitrogen Top-Dressing',
            description: 'Apply organic compost or urea to accelerate vegetative growth.',
            daysAfterSowing: 40,
            isCompleted: false,
            category: 'fertilizer',
          ),
          CalendarStage(
            id: 'tom_6',
            title: 'Flowering Stage Irrigation',
            description: 'Ensure consistent water supply at base to prevent flower drop.',
            daysAfterSowing: 55,
            isCompleted: false,
            category: 'irrigation',
          ),
          CalendarStage(
            id: 'tom_7',
            title: 'Potash Fertilizer & Care',
            description: 'Apply potassium to enhance fruit size. Check for early blight under leaves.',
            daysAfterSowing: 70,
            isCompleted: false,
            category: 'fertilizer',
          ),
          CalendarStage(
            id: 'tom_8',
            title: 'Harvesting',
            description: 'Pick red, firm tomatoes during early morning or late evening.',
            daysAfterSowing: 90,
            isCompleted: false,
            category: 'harvest',
          ),
        ],
      ),
    );

    // 2. Wheat Crop sowed 45 days ago
    final wheatSowingDate = now.subtract(const Duration(days: 42));
    _activeCrops.add(
      ActiveCropModel(
        id: 'default_wheat',
        cropName: 'Wheat',
        emoji: '🌾',
        sowingDate: wheatSowingDate,
        soilType: 'Clayey',
        stages: [
          CalendarStage(
            id: 'wht_1',
            title: 'Field Preparation & Sowing',
            description: 'Sow seeds at 4-5 cm depth using seed drills.',
            daysAfterSowing: 1,
            isCompleted: true,
            category: 'sowing',
          ),
          CalendarStage(
            id: 'wht_2',
            title: 'Crown Root Irrigation',
            description: 'Water field 20 days after sowing. Highly critical for root set.',
            daysAfterSowing: 20,
            isCompleted: true,
            category: 'irrigation',
          ),
          CalendarStage(
            id: 'wht_3',
            title: 'Tillering NPK Application',
            description: 'Broadcast Nitrogen fertilizer to promote strong tillers.',
            daysAfterSowing: 40,
            isCompleted: true,
            category: 'fertilizer',
          ),
          CalendarStage(
            id: 'wht_4',
            title: 'Jointing Stage Irrigation',
            description: 'Second watering cycle to support node elongation and stem thickness.',
            daysAfterSowing: 60,
            isCompleted: false,
            category: 'irrigation',
          ),
          CalendarStage(
            id: 'wht_5',
            title: 'Rust & Mildew Inspection',
            description: 'Scan leaves for yellow powder spots (rust). Spray fungicide if detected.',
            daysAfterSowing: 80,
            isCompleted: false,
            category: 'care',
          ),
          CalendarStage(
            id: 'wht_6',
            title: 'Flowering & Milking Irrigation',
            description: 'Water at grain-filling phase. Avoid heavy wind watering to prevent lodging.',
            daysAfterSowing: 100,
            isCompleted: false,
            category: 'irrigation',
          ),
          CalendarStage(
            id: 'wht_7',
            title: 'Harvesting',
            description: 'Harvest grains when ears turn dry golden and moisture drops to 12%.',
            daysAfterSowing: 120,
            isCompleted: false,
            category: 'harvest',
          ),
        ],
      ),
    );
  }

  void addCrop(String cropName, DateTime sowingDate, String soilType) {
    final String id = 'crop_${DateTime.now().millisecondsSinceEpoch}';
    final String emoji = _getEmojiForCrop(cropName);
    
    // Generate stages tailored to crop
    final List<CalendarStage> stages = _generateStagesForCrop(cropName);

    // Auto check stages that are in the past
    final daysSinceSowing = DateTime.now().difference(sowingDate).inDays;
    for (var stage in stages) {
      if (stage.daysAfterSowing <= daysSinceSowing) {
        stage.isCompleted = true;
      }
    }

    _activeCrops.add(
      ActiveCropModel(
        id: id,
        cropName: cropName,
        emoji: emoji,
        sowingDate: sowingDate,
        soilType: soilType,
        stages: stages,
      ),
    );
    notifyListeners();
  }

  void toggleStageCompletion(String cropId, String stageId) {
    final cropIndex = _activeCrops.indexWhere((c) => c.id == cropId);
    if (cropIndex != -1) {
      final stageIndex = _activeCrops[cropIndex].stages.indexWhere((s) => s.id == stageId);
      if (stageIndex != -1) {
        final currentVal = _activeCrops[cropIndex].stages[stageIndex].isCompleted;
        _activeCrops[cropIndex].stages[stageIndex].isCompleted = !currentVal;
        notifyListeners();
      }
    }
  }

  void deleteCrop(String cropId) {
    _activeCrops.removeWhere((c) => c.id == cropId);
    notifyListeners();
  }

  String _getEmojiForCrop(String name) {
    switch (name.toLowerCase()) {
      case 'tomato': return '🍅';
      case 'wheat': return '🌾';
      case 'rice': return '🍚';
      case 'maize': return '🌽';
      case 'cotton': return '☁️';
      case 'potato': return '🥔';
      case 'onion': return '🧅';
      case 'soybean': return '🌱';
      default: return '🌿';
    }
  }

  List<CalendarStage> _generateStagesForCrop(String name) {
    final String c = name.toLowerCase();
    
    if (c == 'tomato') {
      return [
        CalendarStage(id: 't1', title: 'Nursery Sowing', description: 'Sow tomato seeds in trays.', daysAfterSowing: 1, category: 'sowing'),
        CalendarStage(id: 't2', title: 'Seedling Sprouting', description: 'Keep coco-peat damp.', daysAfterSowing: 6, category: 'care'),
        CalendarStage(id: 't3', title: 'Transplanting', description: 'Move seedling to field.', daysAfterSowing: 14, category: 'care'),
        CalendarStage(id: 't4', title: 'Weeding & Staking', description: 'Support tomato vines.', daysAfterSowing: 28, category: 'care'),
        CalendarStage(id: 't5', title: 'NPK Organic Fertilizing', description: 'Apply vegetative compost.', daysAfterSowing: 40, category: 'fertilizer'),
        CalendarStage(id: 't6', title: 'Watering & Flowering Care', description: 'Water regularly at bottom.', daysAfterSowing: 55, category: 'irrigation'),
        CalendarStage(id: 't7', title: 'Pest Control', description: 'Inspect leaves for early blight.', daysAfterSowing: 70, category: 'care'),
        CalendarStage(id: 't8', title: 'Harvesting', description: 'Pluck red firm tomatoes.', daysAfterSowing: 90, category: 'harvest'),
      ];
    } else if (c == 'wheat') {
      return [
        CalendarStage(id: 'w1', title: 'Field Preparation & Sowing', description: 'Drill seeds at 4cm depth.', daysAfterSowing: 1, category: 'sowing'),
        CalendarStage(id: 'w2', title: 'Crown Root Irrigation', description: 'Irrigate field 20 days after.', daysAfterSowing: 20, category: 'irrigation'),
        CalendarStage(id: 'w3', title: 'Tillering Nitrogen Dosage', description: 'Broadcast urea fertilizer.', daysAfterSowing: 40, category: 'fertilizer'),
        CalendarStage(id: 'w4', title: 'Jointing Irrigation', description: 'Water to strengthen nodes.', daysAfterSowing: 60, category: 'irrigation'),
        CalendarStage(id: 'w5', title: 'Rust check', description: 'Look for orange powdery spots.', daysAfterSowing: 80, category: 'care'),
        CalendarStage(id: 'w6', title: 'Flowering & Grain Filling', description: 'Water but avoid windy days.', daysAfterSowing: 100, category: 'irrigation'),
        CalendarStage(id: 'w7', title: 'Harvesting', description: 'Mow dry golden grains.', daysAfterSowing: 120, category: 'harvest'),
      ];
    } else if (c == 'rice' || c == 'paddy') {
      return [
        CalendarStage(id: 'r1', title: 'Paddy Nursery Sowing', description: 'Prepare nursery bed with organic compost.', daysAfterSowing: 1, category: 'sowing'),
        CalendarStage(id: 'r2', title: 'Transplanting', description: 'Shift seedlings (25 days old) to puddled muddy field.', daysAfterSowing: 25, category: 'care'),
        CalendarStage(id: 'r3', title: 'Active Tillering Water', description: 'Keep water logged to about 3-5 cm.', daysAfterSowing: 45, category: 'irrigation'),
        CalendarStage(id: 'r4', title: 'Nitrogen Application', description: 'Apply first split dose of nitrogen.', daysAfterSowing: 60, category: 'fertilizer'),
        CalendarStage(id: 'r5', title: 'Flowering Irrigation', description: 'Ensure constant soil saturation.', daysAfterSowing: 80, category: 'irrigation'),
        CalendarStage(id: 'r6', title: 'Field Drainage', description: 'Drain out water 10 days before harvest.', daysAfterSowing: 100, category: 'irrigation'),
        CalendarStage(id: 'r7', title: 'Harvesting', description: 'Cut panicles when they turn straw color.', daysAfterSowing: 115, category: 'harvest'),
      ];
    } else {
      // Default Fallback lifecycle
      return [
        CalendarStage(id: 'd1', title: 'Sowing & Initial Irrigation', description: 'Sow seeds and perform light irrigation.', daysAfterSowing: 1, category: 'sowing'),
        CalendarStage(id: 'd2', title: 'Germination & Weeding', description: 'Remove competing weeds, check sprouting.', daysAfterSowing: 10, category: 'care'),
        CalendarStage(id: 'd3', title: 'First Fertilizer Top Dress', description: 'Apply nitrogen compost to boost leaves.', daysAfterSowing: 30, category: 'fertilizer'),
        CalendarStage(id: 'd4', title: 'Vegetative Water Cycle', description: 'Deep water plants to establish root support.', daysAfterSowing: 45, category: 'irrigation'),
        CalendarStage(id: 'd5', title: 'Flowering Nutrition', description: 'Apply potash and phosphorus booster.', daysAfterSowing: 65, category: 'fertilizer'),
        CalendarStage(id: 'd6', title: 'Pest Guard', description: 'Apply neem oil spray to keep flies/bugs away.', daysAfterSowing: 80, category: 'care'),
        CalendarStage(id: 'd7', title: 'Final Harvesting', description: 'Harvest crop when completely mature.', daysAfterSowing: 100, category: 'harvest'),
      ];
    }
  }
}
