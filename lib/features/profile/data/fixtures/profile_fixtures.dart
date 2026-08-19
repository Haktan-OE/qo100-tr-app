import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

abstract final class ProfileFixtures {
  static const currentUser = UserProfile(
    id: 'fixture-user-current',
    callsign: 'TA0AAA',
    name: 'Örnek Operatör',
    city: 'Ankara',
    locator: 'KM69',
    antenna: '80 cm ofset çanak',
    gear: 'Örnek SDR istasyonu',
    role: UserRole.member,
  );
}
