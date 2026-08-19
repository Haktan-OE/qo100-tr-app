enum UserRole { member, moderator, admin }

class UserProfile {
  const UserProfile({
    required this.id,
    required this.callsign,
    required this.name,
    required this.city,
    required this.locator,
    required this.role,
    this.antenna,
    this.gear,
  });

  final String id;
  final String callsign;
  final String name;
  final String city;
  final String locator;
  final String? antenna;
  final String? gear;
  final UserRole role;
}
