import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/services/supabase_service.dart';

final notificationsProvider = StreamProvider.autoDispose((ref) => 
  Svc.notificationStream());

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final notification = data[index];
              final isRead = notification['read'] as bool;
              
              return ListTile(
                leading: Icon(
                  notification['type'] == 'sale' 
                    ? Icons.shopping_cart 
                    : Icons.money_off,
                  color: isRead ? Colors.grey : Colors.blue,
                ),
                title: Text(
                  notification['message'],
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => Svc.deleteNotification(notification['id']),
                ),
                onTap: () {
                  if (!isRead) {
                    Svc.markNotificationAsRead(notification['id']);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
