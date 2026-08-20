import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/config/app_config.dart';
import 'package:qo100_tr/app/providers/app_config_provider.dart';
import 'package:qo100_tr/features/auth/data/firebase/firebase_auth_repository.dart';
import 'package:qo100_tr/features/auth/data/fixtures/fixture_auth_repository.dart';
import 'package:qo100_tr/features/auth/domain/repositories/auth_repository.dart';
import 'package:qo100_tr/features/news/data/fixtures/fixture_news_repository.dart';
import 'package:qo100_tr/features/news/domain/repositories/news_repository.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_check_in_repository.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_session_repository.dart';
import 'package:qo100_tr/features/participation/domain/repositories/check_in_repository.dart';
import 'package:qo100_tr/features/participation/domain/repositories/session_repository.dart';
import 'package:qo100_tr/features/profile/data/fixtures/fixture_user_profile_repository.dart';
import 'package:qo100_tr/features/profile/data/firebase/firestore_user_profile_repository.dart';
import 'package:qo100_tr/features/profile/domain/repositories/user_profile_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => FixtureSessionRepository(),
);

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  final repository = FixtureCheckInRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => FixtureNewsRepository(),
);

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return switch (ref.watch(appConfigProvider).backend) {
    AppBackend.fixture => _createFixtureProfileRepository(ref),
    AppBackend.firebase => FirestoreUserProfileRepository(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    ),
  };
});
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return switch (ref.watch(appConfigProvider).backend) {
    AppBackend.fixture => _createFixtureAuthRepository(ref),
    AppBackend.firebase => FirebaseAuthRepository(FirebaseAuth.instance),
  };
});

UserProfileRepository _createFixtureProfileRepository(Ref ref) {
  final repository = FixtureUserProfileRepository();
  ref.onDispose(repository.dispose);
  return repository;
}

AuthRepository _createFixtureAuthRepository(Ref ref) {
  final repository = FixtureAuthRepository();
  ref.onDispose(repository.dispose);
  return repository;
}
