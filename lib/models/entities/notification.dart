import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    String? goatId,
    required String title,
    required String message,
    required String type,
    DateTime? dueDate,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

  factory Notification.create({
    required String userId,
    String? goatId,
    required String title,
    required String message,
    required String type,
    DateTime? dueDate,
  }) {
    final now = DateTime.now();
    return Notification(
      id: const Uuid().v4(),
      userId: userId,
      goatId: goatId,
      title: title,
      message: message,
      type: type,
      dueDate: dueDate,
      createdAt: now,
    );
  }
}
