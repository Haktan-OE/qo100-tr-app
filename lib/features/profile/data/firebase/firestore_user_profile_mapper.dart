import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/exceptions/profile_exceptions.dart';

abstract final class FirestoreUserProfileMapper {
  static UserProfile fromMap({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return UserProfile(
      id: documentId,
      callsign: _string(data['callsign']),
      name: _string(data['name']),
      city: _string(data['city']),
      locator: _string(data['locator']),
      antenna: _optionalString(data['antenna']),
      gear: _optionalString(data['gear']),
      role: _parseRole(data['role']),
    );
  }

  static Map<String, dynamic> toMap(UserProfile profile) => {
    'callsign': profile.callsign,
    'name': profile.name,
    'city': profile.city,
    'locator': profile.locator,
    'antenna': profile.antenna,
    'gear': profile.gear,
    'role': profile.role.name,
  };

  static void assertUidMatchesProfile(String uid, UserProfile profile) {
    if (profile.id != uid) throw ProfileIdentityMismatchException();
  }

  static String _string(Object? value) => value is String ? value : '';

  static String? _optionalString(Object? value) {
    return value is String && value.isNotEmpty ? value : null;
  }

  static UserRole _parseRole(Object? value) {
    return UserRole.values.where((role) => role.name == value).firstOrNull ??
        UserRole.member;
  }
}
