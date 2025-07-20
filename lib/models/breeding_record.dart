import 'package:flutter/foundation.dart';

@immutable
class BreedingRecord {
  final String id;
  final String damId;
  final String sireId;
  final DateTime? matingDate;
  final DateTime? expectedBirthDate;
  final DateTime? actualBirthDate;
  final int? numberOfKids;
  final Map<String, dynamic>? kidsDetail;
  final String? notes;
  final String userId;
  final DateTime createdAt;

  const BreedingRecord({
    required this.id,
    required this.damId,
    required this.sireId,
    this.matingDate,
    this.expectedBirthDate,
    this.actualBirthDate,
    this.numberOfKids,
    this.kidsDetail,
    this.notes,
    required this.userId,
    required this.createdAt,
  });

  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'] as String,
      damId: json['dam_id'] as String,
      sireId: json['sire_id'] as String,
      matingDate: json['mating_date'] == null
          ? null
          : DateTime.parse(json['mating_date'] as String),
      expectedBirthDate: json['expected_birth_date'] == null
          ? null
          : DateTime.parse(json['expected_birth_date'] as String),
      actualBirthDate: json['actual_birth_date'] == null
          ? null
          : DateTime.parse(json['actual_birth_date'] as String),
      numberOfKids: json['number_of_kids'] as int?,
      kidsDetail: json['kids_detail'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dam_id': damId,
      'sire_id': sireId,
      'mating_date': matingDate?.toIso8601String(),
      'expected_birth_date': expectedBirthDate?.toIso8601String(),
      'actual_birth_date': actualBirthDate?.toIso8601String(),
      'number_of_kids': numberOfKids,
      'kids_detail': kidsDetail,
      'notes': notes,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BreedingRecord copyWith({
    String? id,
    String? damId,
    String? sireId,
    DateTime? matingDate,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    int? numberOfKids,
    Map<String, dynamic>? kidsDetail,
    String? notes,
    String? userId,
    DateTime? createdAt,
  }) {
    return BreedingRecord(
      id: id ?? this.id,
      damId: damId ?? this.damId,
      sireId: sireId ?? this.sireId,
      matingDate: matingDate ?? this.matingDate,
      expectedBirthDate: expectedBirthDate ?? this.expectedBirthDate,
      actualBirthDate: actualBirthDate ?? this.actualBirthDate,
      numberOfKids: numberOfKids ?? this.numberOfKids,
      kidsDetail: kidsDetail ?? this.kidsDetail,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
