String formatTime(int totalMinutes) {
  if (totalMinutes < 60) {
    return '$totalMinutes minutes';
  } else {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '$hours hours';
    } else {
      return '$hours hours $minutes minutes';
    }
  }
}