import 'package:freezed_annotation/freezed_annotation.dart';

part 'enums.freezed.dart';
part 'enums.g.dart';

enum GoatStatus {
  active,
  sold,
  dead
}

enum ExpenseType {
  feed,
  medicine,
  transport,
  other
}

enum HealthRecordType {
  vaccination,
  illness,
  injury,
  deworming,
  other
}

enum HealthStatus {
  healthy,
  under_treatment,
  recovered,
  deceased
}
