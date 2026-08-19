class ProfileInputValidation {
  const ProfileInputValidation({required this.values, required this.errors});
  final Map<String, String> values;
  final Map<String, String> errors;
  bool get isValid => errors.isEmpty;
}

abstract final class ProfileInputValidator {
  static ProfileInputValidation validate({
    required String callsign,
    required String name,
    required String city,
    required String locator,
  }) {
    final values = <String, String>{
      'callsign': callsign.trim(),
      'name': name.trim(),
      'city': city.trim(),
      'locator': locator.trim(),
    };
    final errors = <String, String>{};
    for (final entry in values.entries) {
      if (entry.value.isEmpty) errors[entry.key] = 'Bu alan zorunludur.';
    }
    return ProfileInputValidation(values: values, errors: errors);
  }
}
