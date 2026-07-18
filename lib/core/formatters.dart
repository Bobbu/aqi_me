// Small display formatters shared across cards.

/// A 12-hour clock like `2:00 PM` from a local wall-clock [DateTime].
String formatClock(DateTime t) {
  final int hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final String minute = t.minute.toString().padLeft(2, '0');
  final String meridiem = t.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $meridiem';
}

/// Temperature in whole degrees Fahrenheit from Celsius, e.g. `71°F`.
String formatTempF(double celsius) => '${(celsius * 9 / 5 + 32).round()}°F';
