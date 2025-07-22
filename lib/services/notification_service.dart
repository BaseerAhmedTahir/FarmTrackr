import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart' as goat_notification;

/// Service class to handle notification-related operations
class NotificationService {
  final SupabaseClient _client;

  NotificationService(this._client);

  /// Stream of notifications ordered by creation date
  /// Returns a stream of notifications with proper error handling
  Stream<List<goat_notification.Notification>> watchNotifications() {
    try {
      return _client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', _client.auth.currentUser?.id ?? '')
          .order('created_at', ascending: false)
          .map((event) {
            try {
              return event.map((e) => goat_notification.Notification.fromJson(e)).toList();
            } catch (e) {
              debugPrint('Error processing notification data: $e');
              return <goat_notification.Notification>[];
            }
          })
          .handleError((error) {
            debugPrint('Error in notification stream: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      debugPrint('Error setting up notification stream: $e');
      return Stream.value(<goat_notification.Notification>[]);
    }
  }

  /// Mark a notification as read
  /// [id] is the notification ID to mark as read
  /// Throws an exception if the operation fails
  Future<void> markNotificationAsRead(String id) async {
    if (id.isEmpty) {
      throw Exception('Invalid notification ID');
    }

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('notifications')
          .update({
            'read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Delete a notification
  /// [id] is the notification ID to delete
  /// Throws an exception if the operation fails
  Future<void> deleteNotification(String id) async {
    if (id.isEmpty) {
      throw Exception('Invalid notification ID');
    }

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('notifications')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Create a new notification
  /// [title] is the notification title
  /// [message] is the notification message
  /// [type] is the notification type (expense, sale, system, etc.)
  /// [metadata] is optional additional data
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    if (title.isEmpty || message.isEmpty || type.isEmpty) {
      throw Exception('Title, message and type are required');
    }

    try {
      await _client.from('notifications').insert({
        'title': title,
        'message': message,
        'type': type,
        'user_id': _client.auth.currentUser?.id,
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': metadata,
      }).select().single();
    } catch (e) {
      debugPrint('Error creating notification: $e');
      throw Exception('Failed to create notification: $e');
    }
  }
}
