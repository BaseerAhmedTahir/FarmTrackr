import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

part 'goat.freezed.dart';
part 'goat.g.dart';

@freezed
class Goat with _$Goat {
  const factory Goat({
    required String id,
    required String tagNumber,
    required String name,
    String? breed,
    required String gender,
    required DateTime birthDate,
    String? color,
    String? markings,
    String? photoUrl,
    String? qrCode,
    @Default(GoatStatus.active) GoatStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String userId,
  }) = _Goat;

  factory Goat.fromJson(Map<String, dynamic> json) => _$GoatFromJson(json);

  factory Goat.create({
    required String tagNumber,
    required String name,
    required String gender,
    required DateTime birthDate,
    String? breed,
    String? color,
    String? markings,
    String? photoUrl,
    required String userId,
  }) {
    final now = DateTime.now();
    return Goat(
      id: const Uuid().v4(),
      tagNumber: tagNumber,
      name: name,
      gender: gender,
      birthDate: birthDate,
      breed: breed,
      color: color,
      markings: markings,
      photoUrl: photoUrl,
      createdAt: now,
      updatedAt: now,
      userId: userId,
    );
  }
}
