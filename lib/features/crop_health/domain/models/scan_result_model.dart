enum ScanType { seed, plant, disease }

class ScanResultModel {
  final String id;
  final ScanType type;
  final String title;
  final double confidence;
  final DateTime date;
  final String? localImagePath;

  // Disease diagnosis details
  final String? severity;
  final String? description;
  final String? cause;
  final List<String>? treatmentSteps;
  final List<String>? preventionSteps;

  // Plant identification details
  final String? family;
  final String? growthStage;
  final String? healthStatus;
  final Map<String, String>? careInstructions;

  // Seed identification details
  final String? germinationRate;
  final String? optimalSoil;
  final String? sowingDepth;
  final String? moistureNeed;
  final String? bestSeason;

  ScanResultModel({
    required this.id,
    required this.type,
    required this.title,
    required this.confidence,
    required this.date,
    this.localImagePath,
    this.severity,
    this.description,
    this.cause,
    this.treatmentSteps,
    this.preventionSteps,
    this.family,
    this.growthStage,
    this.healthStatus,
    this.careInstructions,
    this.germinationRate,
    this.optimalSoil,
    this.sowingDepth,
    this.moistureNeed,
    this.bestSeason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'confidence': confidence,
      'date': date.toIso8601String(),
      'localImagePath': localImagePath,
      'severity': severity,
      'description': description,
      'cause': cause,
      'treatmentSteps': treatmentSteps,
      'preventionSteps': preventionSteps,
      'family': family,
      'growthStage': growthStage,
      'healthStatus': healthStatus,
      'careInstructions': careInstructions,
      'germinationRate': germinationRate,
      'optimalSoil': optimalSoil,
      'sowingDepth': sowingDepth,
      'moistureNeed': moistureNeed,
      'bestSeason': bestSeason,
    };
  }

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'] as String,
      type: ScanType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      localImagePath: json['localImagePath'] as String?,
      severity: json['severity'] as String?,
      description: json['description'] as String?,
      cause: json['cause'] as String?,
      treatmentSteps: json['treatmentSteps'] != null
          ? List<String>.from(json['treatmentSteps'] as Iterable)
          : null,
      preventionSteps: json['preventionSteps'] != null
          ? List<String>.from(json['preventionSteps'] as Iterable)
          : null,
      family: json['family'] as String?,
      growthStage: json['growthStage'] as String?,
      healthStatus: json['healthStatus'] as String?,
      careInstructions: json['careInstructions'] != null
          ? Map<String, String>.from(json['careInstructions'] as Map)
          : null,
      germinationRate: json['germinationRate'] as String?,
      optimalSoil: json['optimalSoil'] as String?,
      sowingDepth: json['sowingDepth'] as String?,
      moistureNeed: json['moistureNeed'] as String?,
      bestSeason: json['bestSeason'] as String?,
    );
  }
}
