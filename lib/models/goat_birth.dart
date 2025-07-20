import 'package:flutter/foundation.dart';

@immutable
class GoatBirth {
  final String id;
  final String childGoatId;
  final String parentGoatId;
  final DateTime birthDate;

  const GoatBirth({
    required this.id,
    required this.childGoatId,
    required this.parentGoatId,
    required this.birthDate,
  });

  factory GoatBirth.fromJson(Map<String, dynamic> json) {
    return GoatBirth(
      id: json['id'] as String,
      childGoatId: json['child_goat_id'] as String,
      parentGoatId: json['parent_goat_id'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'child_goat_id': childGoatId,
    'parent_goat_id': parentGoatId,
    'birth_date': birthDate.toIso8601String(),
  };

  GoatBirth copyWith({
    String? id,
    String? childGoatId,
    String? parentGoatId,
    DateTime? birthDate,
  }) {
    return GoatBirth(
      id: id ?? this.id,
      childGoatId: childGoatId ?? this.childGoatId,
      parentGoatId: parentGoatId ?? this.parentGoatId,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
