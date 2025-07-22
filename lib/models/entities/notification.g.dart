// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationImpl _$$NotificationImplFromJson(Map<String, dynamic> json) =>
    _$NotificationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      goatId: json['goatId'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$NotificationImplToJson(_$NotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'goatId': instance.goatId,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'dueDate': instance.dueDate?.toIso8601String(),
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
