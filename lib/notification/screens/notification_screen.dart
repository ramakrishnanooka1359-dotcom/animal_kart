import 'package:animal_kart_demo2/notification/models/notification_model.dart';
import 'package:animal_kart_demo2/notification/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:intl/intl.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(NotificationModelProvider);

    final newNotifications =
        notifications.where((n) => n.isNew).toList();
    final recentNotifications =
        notifications.where((n) => !n.isNew).toList();

    return Scaffold(
      appBar: AppBar(
      title: const Text('Notifications'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
  ),

      body: notifications.isEmpty ? const Center(
        child: Text(
          'There are no notifications to show',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ): ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (newNotifications.isNotEmpty) ...[
            const Text("NEW", style: _sectionStyle),
            const SizedBox(height: 10),
            ...newNotifications.map((e) => _notificationTile(context, ref, e)),
          ],

          if (recentNotifications.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("Recent", style: _sectionStyle),
            const SizedBox(height: 10),
            ...recentNotifications
                .map((e) => _notificationTile(context, ref, e)),
          ],
        ],
      ),
    );
  }

  static const TextStyle _sectionStyle =
      TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey);

  Widget _notificationTile(
      BuildContext context, WidgetRef ref, NotificationModel notification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          ref
              .read(NotificationModelProvider.notifier)
              .deleteNotificationModel(notification.id);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6C9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.access_time, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(notification.description,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                DateFormat('h:mm a').format(notification.time),
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
