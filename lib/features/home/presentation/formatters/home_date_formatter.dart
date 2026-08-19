abstract final class HomeDateFormatter {
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

  static String sessionDateTime(DateTime value) {
    final utc = value.toUtc();
    final minute = utc.minute.toString().padLeft(2, '0');
    return '${utc.day} ${_months[utc.month - 1]} ${utc.year} • '
        '${utc.hour.toString().padLeft(2, '0')}:$minute UTC';
  }

  static String newsDate(DateTime value) {
    final utc = value.toUtc();
    return '${utc.day} ${_months[utc.month - 1]} ${utc.year}';
  }
}
