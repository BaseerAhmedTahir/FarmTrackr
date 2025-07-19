class Expense {
  final String id;
  final String? goatId; // null means general expense
  final String userId;
  final String type; // feed, medicine, transport, etc.
  final double amount;
  final String? notes;
  final DateTime createdAt;

  const Expense({
    required this.id,
    this.goatId,
    required this.userId,
    required this.type,
    required this.amount,
    this.notes,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      goatId: json['goat_id'] as String?,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'goat_id': goatId,
    'user_id': userId,
    'type': type,
    'amount': amount,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  Expense copyWith({
    String? id,
    String? goatId,
    String? userId,
    String? type,
    double? amount,
    String? notes,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      goatId: goatId ?? this.goatId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
