import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

part 'weight_log.freezed.dart';
part 'weight_log.g.dart';

@freezed
class WeightLog with _$WeightLog {
  const factory WeightLog({
    required String id,
    required String goatId,
    required double weightKg,
    required DateTime measuredAt,
    String? notes,
    required DateTime createdAt,
    required String userId,
  }) = _WeightLog;

  factory WeightLog.fromJson(Map<String, dynamic> json) => _$WeightLogFromJson(json);

  factory WeightLog.create({
    required String goatId,
    required double weightKg,
    String? notes,
    required String userId,
  }) {
    final now = DateTime.now();
    return WeightLog(
      id: const Uuid().v4(),
      goatId: goatId,
      weightKg: weightKg,
      measuredAt: now,
      notes: notes,
      createdAt: now,
      userId: userId,
    );
  }
}
