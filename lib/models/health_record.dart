import 'package:flutter/foundation.dart';

@immutable
class HealthRecord {
  final String id;
  final String goatId;
  final String recordType;
  final DateTime recordDate;
  final String? diagnosis;
  final String? treatment;
  final String? medicine;
  final String? dosage;
  final DateTime? nextDueDate;
  final String? vetName;
  final String? vetContact;
  final List<String>? attachments;
  final String? notes;
  final String userId;
  final DateTime createdAt;

  const HealthRecord({
    required this.id,
    required this.goatId,
    required this.recordType,
    required this.recordDate,
    this.diagnosis,
    this.treatment,
    this.medicine,
    this.dosage,
    this.nextDueDate,
    this.vetName,
    this.vetContact,
    this.attachments,
    this.notes,
    required this.userId,
    required this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String,
      goatId: json['goat_id'] as String,
      recordType: json['record_type'] as String,
      recordDate: DateTime.parse(json['record_date'] as String),
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      medicine: json['medicine'] as String?,
      dosage: json['dosage'] as String?,
      nextDueDate: json['next_due_date'] == null
          ? null
          : DateTime.parse(json['next_due_date'] as String),
      vetName: json['vet_name'] as String?,
      vetContact: json['vet_contact'] as String?,
      attachments: (json['attachments'] as List?)?.cast<String>(),
      notes: json['notes'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goat_id': goatId,
      'record_type': recordType,
      'record_date': recordDate.toIso8601String(),
      'diagnosis': diagnosis,
      'treatment': treatment,
      'medicine': medicine,
      'dosage': dosage,
      'next_due_date': nextDueDate?.toIso8601String(),
      'vet_name': vetName,
      'vet_contact': vetContact,
      'attachments': attachments,
      'notes': notes,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  HealthRecord copyWith({
    String? id,
    String? goatId,
    String? recordType,
    DateTime? recordDate,
    String? diagnosis,
    String? treatment,
    String? medicine,
    String? dosage,
    DateTime? nextDueDate,
    String? vetName,
    String? vetContact,
    List<String>? attachments,
    String? notes,
    String? userId,
    DateTime? createdAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      goatId: goatId ?? this.goatId,
      recordType: recordType ?? this.recordType,
      recordDate: recordDate ?? this.recordDate,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      medicine: medicine ?? this.medicine,
      dosage: dosage ?? this.dosage,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      vetName: vetName ?? this.vetName,
      vetContact: vetContact ?? this.vetContact,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
