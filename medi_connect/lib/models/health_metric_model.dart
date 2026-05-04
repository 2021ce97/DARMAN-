class HealthMetric {
  final String id;
  final String userId;
  final MetricType type;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String? notes;

  HealthMetric({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.notes,
  });

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: MetricType.fromString(json['type'] ?? 'blood_pressure'),
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.value,
    'value': value,
    'unit': unit,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };
}

enum MetricType {
  bloodPressure('blood_pressure', 'Blood Pressure', 'mmHg', '🩸'),
  heartRate('heart_rate', 'Heart Rate', 'bpm', '❤️'),
  bloodSugar('blood_sugar', 'Blood Sugar', 'mg/dL', '🩺'),
  weight('weight', 'Weight', 'kg', '⚖️'),
  temperature('temperature', 'Temperature', '°C', '🌡️'),
  oxygenSaturation('oxygen_saturation', 'Oxygen Saturation', '%', '💨'),
  steps('steps', 'Steps', 'steps', '👣'),
  sleep('sleep', 'Sleep', 'hours', '😴');

  final String value;
  final String label;
  final String unit;
  final String emoji;

  const MetricType(this.value, this.label, this.unit, this.emoji);

  static MetricType fromString(String value) {
    return MetricType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MetricType.bloodPressure,
    );
  }
}
