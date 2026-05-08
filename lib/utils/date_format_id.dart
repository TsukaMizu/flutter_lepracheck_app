class DateFormatId {
  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const _monthsLong = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String dateTimeWib(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year} • $h:$m WIB';
  }

  static String monthYearLabelUpper(DateTime dt) {
    return '${_monthsLong[dt.month - 1].toUpperCase()} ${dt.year}';
  }

  static String dateOnly(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} ${_monthsShort[dt.month - 1]} ${dt.year}';
  }

  static String monthYear(DateTime dt) {
    return '${_monthsLong[dt.month - 1]} ${dt.year}';
  }
}
