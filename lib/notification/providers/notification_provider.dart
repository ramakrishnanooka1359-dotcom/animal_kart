import 'package:animal_kart_demo2/notification/models/notification_model.dart';
import 'package:flutter_riverpod/legacy.dart';

final NotificationModelProvider =
    StateNotifierProvider<NotificationModelNotifier, List<NotificationModel>>(
        (ref) => NotificationModelNotifier());

class NotificationModelNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationModelNotifier() : super(_initialData);

  static final _initialData = [
  NotificationModel(
    id: '1',
    title: 'Buffalo Booked',
    description: 'Murrah buffalo has been successfully booked.',
    time: DateTime.now().subtract(const Duration(minutes: 10)),
    isNew: true,
  ),
  NotificationModel(
    id: '2',
    title: 'Buffalo Arrived',
    description: 'Murrah buffalo has been landed on the farm.',
    time: DateTime.now().subtract(const Duration(hours: 1)),
    isNew: true,
  ),
  NotificationModel(
    id: '3',
    title: 'Booking Completed',
    description: 'Murrah buffalo booking process completed successfully.',
    time: DateTime.now().subtract(const Duration(hours: 5)),
    isNew: false,
  ),
];


  void deleteNotificationModel(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}
