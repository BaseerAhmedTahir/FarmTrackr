import 'package:flutter/foundation.dart';

@immutable
class Notification {
  final String id;
  final String goatId;
  final String type;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status;
  final String userId;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.goatId,
    required this.type,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    required this.userId,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      goatId: json['goat_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goat_id': goatId,
      'type': type,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? goatId,
    String? type,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? userId,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      goatId: goatId ?? this.goatId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
