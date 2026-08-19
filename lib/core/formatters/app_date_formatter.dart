abstract final class AppDateFormatter {
  static const _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static String dateTimeUtc(DateTime value) {
    final utc = value.toUtc();
    return '${_date(utc)} • ${timeUtc(utc)}';
  }

  static String date(DateTime value) => _date(value.toUtc());

  static String timeUtc(DateTime value) {
    final utc = value.toUtc();
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    return '$hour:$minute UTC';
  }

  static String _date(DateTime value) {
    return '${value.day} ${_months[value.month - 1]} ${value.year}';
  }
}
