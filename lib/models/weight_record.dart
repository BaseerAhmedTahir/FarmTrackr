class WeightRecord {
  final double weight;
  final DateTime date;
  final String? notes;
  final String goatId;

  const WeightRecord({
    required this.weight,
    required this.date,
    required this.goatId,
    this.notes,
  });

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      goatId: json['goat_id'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'date': date.toIso8601String(),
    'goat_id': goatId,
    'notes': notes,
  };
}
