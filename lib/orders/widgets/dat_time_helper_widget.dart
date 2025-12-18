String formatToIndianDateTime(DateTime? date) {
  if (date == null) return "--";

  // If backend sends UTC
  final DateTime istTime =
      date.toUtc().add(const Duration(hours: 5, minutes: 30));

  const months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  String day = istTime.day.toString().padLeft(2, '0');
  String month = months[istTime.month - 1];
  String year = istTime.year.toString();

  int hour = istTime.hour;
  String amPm = hour >= 12 ? "PM" : "AM";
  hour = hour % 12;
  if (hour == 0) hour = 12;

  String minute = istTime.minute.toString().padLeft(2, '0');

  return "$day $month $year, $hour:$minute $amPm";
}
