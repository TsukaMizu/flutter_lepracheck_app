class DateFormatId {
  static const _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String ddMmmYyyy(DateTime dt) {
    final m = _monthsShort[dt.month - 1];
    return '${dt.day.toString().padLeft(2, '0')} $m ${dt.year}';
    }

  static String hhmm(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}