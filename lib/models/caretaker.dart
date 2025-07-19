class Caretaker {
  final String id;
  final String name;
  final String phone;
  final String location;
  final String userId;
  final double profitShare; // Percentage or fixed amount
  final DateTime createdAt;
  final String status;
  final Map<String, dynamic>? metadata;

  const Caretaker({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.userId,
    required this.profitShare,
    required this.createdAt,
    this.status = 'active',
    this.metadata,
  });

  factory Caretaker.fromJson(Map<String, dynamic> json) {
    return Caretaker(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      userId: json['user_id'] as String,
      profitShare: (json['profit_share'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'active',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'location': location,
    'user_id': userId,
    'profit_share': profitShare,
    'created_at': createdAt.toIso8601String(),
    'status': status,
    'metadata': metadata,
  };

  Caretaker copyWith({
    String? id,
    String? name,
    String? phone,
    String? location,
    String? userId,
    double? profitShare,
    DateTime? createdAt,
    String? status,
    Map<String, dynamic>? metadata,
  }) {
    return Caretaker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      userId: userId ?? this.userId,
      profitShare: profitShare ?? this.profitShare,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
}
