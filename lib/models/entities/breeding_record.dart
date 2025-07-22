import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'breeding_record.freezed.dart';
part 'breeding_record.g.dart';

@freezed
class BreedingRecord with _$BreedingRecord {
  const factory BreedingRecord({
    required String id,
    required String damId,
    String? sireId,
    DateTime? matingDate,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    int? numberOfKids,
    Map<String, dynamic>? kidsDetail,
    String? notes,
    required DateTime createdAt,
    required String userId,
  }) = _BreedingRecord;

  factory BreedingRecord.fromJson(Map<String, dynamic> json) => _$BreedingRecordFromJson(json);

  factory BreedingRecord.create({
    required String damId,
    String? sireId,
    DateTime? matingDate,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    int? numberOfKids,
    Map<String, dynamic>? kidsDetail,
    String? notes,
    required String userId,
  }) {
    final now = DateTime.now();
    return BreedingRecord(
      id: const Uuid().v4(),
      damId: damId,
      sireId: sireId,
      matingDate: matingDate,
      expectedBirthDate: expectedBirthDate,
      actualBirthDate: actualBirthDate,
      numberOfKids: numberOfKids,
      kidsDetail: kidsDetail,
      notes: notes,
      createdAt: now,
      userId: userId,
    );
  }
}
