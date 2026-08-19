import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';

final currentSessionProvider = StreamProvider<CommunitySession?>((ref) {
  return ref.watch(sessionRepositoryProvider).watchCurrentSession();
});

final sessionCheckInsProvider = StreamProvider.family<List<CheckIn>, String>((
  ref,
  sessionId,
) {
  return ref.watch(checkInRepositoryProvider).watchCheckIns(sessionId);
});

final recentNewsProvider = StreamProvider<List<NewsItem>>((ref) {
  return ref.watch(newsRepositoryProvider).watchRecentNews(limit: 3);
});
