import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

part 'health_record.freezed.dart';
part 'health_record.g.dart';

@freezed
class HealthRecord with _$HealthRecord {
  const factory HealthRecord({
    required String id,
    required String goatId,
    required HealthRecordType recordType,
    required DateTime recordDate,
    String? diagnosis,
    String? treatment,
    String? medicine,
    String? dosage,
    DateTime? nextDueDate,
    String? vetName,
    String? vetContact,
    @Default(HealthStatus.healthy) HealthStatus status,
    String? notes,
    @Default([]) List<String> attachments,
    required DateTime createdAt,
    required String userId,
  }) = _HealthRecord;

  factory HealthRecord.fromJson(Map<String, dynamic> json) => _$HealthRecordFromJson(json);

  factory HealthRecord.create({
    required String goatId,
    required HealthRecordType recordType,
    required DateTime recordDate,
    String? diagnosis,
    String? treatment,
    String? medicine,
    String? dosage,
    DateTime? nextDueDate,
    String? vetName,
    String? vetContact,
    HealthStatus? status,
    String? notes,
    List<String>? attachments,
    required String userId,
  }) {
    final now = DateTime.now();
    return HealthRecord(
      id: const Uuid().v4(),
      goatId: goatId,
      recordType: recordType,
      recordDate: recordDate,
      diagnosis: diagnosis,
      treatment: treatment,
      medicine: medicine,
      dosage: dosage,
      nextDueDate: nextDueDate,
      vetName: vetName,
      vetContact: vetContact,
      status: status ?? HealthStatus.healthy,
      notes: notes,
      attachments: attachments ?? [],
      createdAt: now,
      userId: userId,
    );
  }
}
