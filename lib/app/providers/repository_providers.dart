import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/features/news/data/fixtures/fixture_news_repository.dart';
import 'package:qo100_tr/features/news/domain/repositories/news_repository.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_check_in_repository.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_session_repository.dart';
import 'package:qo100_tr/features/participation/domain/repositories/check_in_repository.dart';
import 'package:qo100_tr/features/participation/domain/repositories/session_repository.dart';
import 'package:qo100_tr/features/profile/data/fixtures/fixture_user_profile_repository.dart';
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

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => FixtureUserProfileRepository(),
);
