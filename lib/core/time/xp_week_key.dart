/// Jour civil local au format `yyyyMMdd` (aligné sur les sessions `daily_yyyyMMdd`).
String calendarDayKeyYyyyMmDd(DateTime localNow) {
  final d = DateTime(localNow.year, localNow.month, localNow.day);
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y$m$day';
}

/// Clé de semaine calendaire : date du **lundi** (locale) au format `yyyyMMdd`.
/// Sert à réinitialiser `xpThisWeek` quand on change de semaine.
String xpWeekMondayKey(DateTime localNow) {
  final d = DateTime(localNow.year, localNow.month, localNow.day);
  final monday = d.subtract(Duration(days: d.weekday - DateTime.monday));
  final y = monday.year.toString().padLeft(4, '0');
  final m = monday.month.toString().padLeft(2, '0');
  final day = monday.day.toString().padLeft(2, '0');
  return '$y$m$day';
}
