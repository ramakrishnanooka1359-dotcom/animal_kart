class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final bool isNew;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isNew,
  });
}
