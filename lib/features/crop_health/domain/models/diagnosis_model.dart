class DiagnosisModel {
  final String id;
  final String diseaseName;
  final double confidence; // e.g. 0.94 representing 94%
  final String severity; // Low, Medium, High
  final String description;
  final String cause;
  final List<String> treatmentSteps;
  final List<String> preventionSteps;
  final DateTime date;
  final String? localImagePath;

  DiagnosisModel({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.cause,
    required this.treatmentSteps,
    required this.preventionSteps,
    required this.date,
    this.localImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'description': description,
      'cause': cause,
      'treatmentSteps': treatmentSteps,
      'preventionSteps': preventionSteps,
      'date': date.toIso8601String(),
      'localImagePath': localImagePath,
    };
  }

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: json['id'] as String,
      diseaseName: json['diseaseName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      severity: json['severity'] as String,
      description: json['description'] as String,
      cause: json['cause'] as String,
      treatmentSteps: List<String>.from(json['treatmentSteps'] as Iterable),
      preventionSteps: List<String>.from(json['preventionSteps'] as Iterable),
      date: DateTime.parse(json['date'] as String),
      localImagePath: json['localImagePath'] as String?,
    );
  }
}
