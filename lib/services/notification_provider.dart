import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

final supabaseClient = Supabase.instance.client;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(supabaseClient);
});

/// Provider for all notifications
final notificationsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.notificationStream();
});

/// Provider specifically for unread notification count
final unreadNotificationsProvider = StreamProvider.autoDispose<int>((ref) async* {
  await for (final notifications in ref.watch(notificationsProvider.stream)) {
    yield notifications.where((n) => n['read_at'] == null).length;
  }
});
