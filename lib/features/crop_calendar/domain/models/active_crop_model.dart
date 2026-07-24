class CalendarStage {
  final String id;
  final String title;
  final String description;
  final int daysAfterSowing;
  bool isCompleted;
  final String category; // 'sowing', 'irrigation', 'fertilizer', 'care', 'harvest'

  CalendarStage({
    required this.id,
    required this.title,
    required this.description,
    required this.daysAfterSowing,
    this.isCompleted = false,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'daysAfterSowing': daysAfterSowing,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  factory CalendarStage.fromJson(Map<String, dynamic> json) {
    return CalendarStage(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      daysAfterSowing: json['daysAfterSowing'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      category: json['category'] as String,
    );
  }
}

class ActiveCropModel {
  final String id;
  final String cropName;
  final String emoji;
  final DateTime sowingDate;
  final String soilType;
  final List<CalendarStage> stages;

  ActiveCropModel({
    required this.id,
    required this.cropName,
    required this.emoji,
    required this.sowingDate,
    required this.soilType,
    required this.stages,
  });

  double get progress {
    if (stages.isEmpty) return 0.0;
    final completedCount = stages.where((s) => s.isCompleted).length;
    return completedCount / stages.length;
  }

  DateTime getEstimatedDate(CalendarStage stage) {
    return sowingDate.add(Duration(days: stage.daysAfterSowing));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'emoji': emoji,
      'sowingDate': sowingDate.toIso8601String(),
      'soilType': soilType,
      'stages': stages.map((s) => s.toJson()).toList(),
    };
  }

  factory ActiveCropModel.fromJson(Map<String, dynamic> json) {
    return ActiveCropModel(
      id: json['id'] as String,
      cropName: json['cropName'] as String,
      emoji: json['emoji'] as String,
      sowingDate: DateTime.parse(json['sowingDate'] as String),
      soilType: json['soilType'] as String,
      stages: (json['stages'] as List)
          .map((s) => CalendarStage.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
