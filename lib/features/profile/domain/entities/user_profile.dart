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

  UserProfile copyWith({
    String? callsign,
    String? name,
    String? city,
    String? locator,
    String? antenna,
    String? gear,
  }) => UserProfile(
    id: id,
    callsign: callsign ?? this.callsign,
    name: name ?? this.name,
    city: city ?? this.city,
    locator: locator ?? this.locator,
    antenna: antenna ?? this.antenna,
    gear: gear ?? this.gear,
    role: role,
  );
}
