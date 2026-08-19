import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/features/auth/domain/entities/auth_user.dart';
import 'package:qo100_tr/features/auth/domain/repositories/auth_repository.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/repositories/user_profile_repository.dart';

class AuthRouteGuard extends ChangeNotifier {
  AuthRouteGuard(AuthRepository auth, UserProfileRepository profiles) {
    _authSubscription = auth.watchAuthUser().listen((value) {
      _user = value;
      _authResolved = true;
      notifyListeners();
    });
    _profileSubscription = profiles.watchCurrentUserProfile().listen((value) {
      _profile = value;
      _profileResolved = true;
      notifyListeners();
    });
  }
  late final StreamSubscription<AuthUser?> _authSubscription;
  late final StreamSubscription<UserProfile?> _profileSubscription;
  AuthUser? _user;
  UserProfile? _profile;
  bool _authResolved = false;
  bool _profileResolved = false;
  String? _pendingAppLocation;

  String? redirect(GoRouterState state) {
    final location = state.uri.path;
    if (!_authResolved || !_profileResolved) {
      return location == '/splash' ? null : '/splash';
    }
    if (_user == null) {
      if (location.startsWith('/app/')) {
        _pendingAppLocation = state.uri.toString();
      }
      return location == '/auth/login' || location == '/auth/register'
          ? null
          : '/auth/login';
    }
    final complete = _profile?.id == _user!.id;
    if (!complete) {
      return location == '/onboarding/profile' ? null : '/onboarding/profile';
    }
    if (location == '/splash' ||
        location.startsWith('/auth/') ||
        location == '/onboarding/profile') {
      final target = _pendingAppLocation ?? '/app/home';
      _pendingAppLocation = null;
      return target;
    }
    return null;
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _profileSubscription.cancel();
    super.dispose();
  }
}
