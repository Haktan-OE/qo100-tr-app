import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/core/widgets/participation_stats_card.dart';
import 'package:qo100_tr/features/home/presentation/providers/home_providers.dart';
import 'package:qo100_tr/features/home/presentation/widgets/announcement_card.dart';
import 'package:qo100_tr/features/home/presentation/widgets/home_action_card.dart';
import 'package:qo100_tr/features/home/presentation/widgets/home_state_card.dart';
import 'package:qo100_tr/features/home/presentation/widgets/news_preview_card.dart';
import 'package:qo100_tr/features/home/presentation/widgets/section_header.dart';
import 'package:qo100_tr/features/home/presentation/widgets/session_hero_card.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const pageKey = Key('home-page');
  static const allNewsButtonKey = Key('home-all-news-button');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final news = ref.watch(recentNewsProvider);

    return Scaffold(
      key: pageKey,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            const _HomeHeader(),
            const SizedBox(height: AppSpacing.xl),
            session.when(
              loading: () => const HomeStateCard(
                key: Key('home-session-loading'),
                title: 'Oturum bilgisi yükleniyor',
                message: 'Güncel TA-NET 777 oturumu hazırlanıyor.',
                isLoading: true,
              ),
              error: (error, stackTrace) => HomeStateCard(
                key: const Key('home-session-error'),
                title: 'Oturum bilgisi alınamadı',
                message: 'Bağlantıyı kontrol edip yeniden deneyin.',
                icon: Icons.cloud_off_rounded,
                actionLabel: 'Tekrar Dene',
                onAction: () => ref.invalidate(currentSessionProvider),
              ),
              data: (currentSession) => _SessionSection(
                session: currentSession,
                onListen: () => context.go(AppRoutes.live),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            HomeActionCard(onJoin: () => context.go(AppRoutes.participation)),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Son Duyurular'),
            const SizedBox(height: AppSpacing.sm),
            for (final announcement in _announcements) ...[
              AnnouncementCard(
                title: announcement.title,
                message: announcement.message,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.sm),
            SectionHeader(
              title: 'Haberler',
              actionLabel: 'Tüm Haberler',
              actionKey: allNewsButtonKey,
              onAction: () => context.go(AppRoutes.news),
            ),
            const SizedBox(height: AppSpacing.sm),
            news.when(
              loading: () => const HomeStateCard(
                key: Key('home-news-loading'),
                title: 'Haberler yükleniyor',
                message: 'Topluluk gündemi hazırlanıyor.',
                isLoading: true,
              ),
              error: (error, stackTrace) => HomeStateCard(
                key: const Key('home-news-error'),
                title: 'Haberler alınamadı',
                message: 'Haber akışını yeniden yükleyebilirsiniz.',
                icon: Icons.cloud_off_rounded,
                actionLabel: 'Tekrar Dene',
                onAction: () => ref.invalidate(recentNewsProvider),
              ),
              data: (items) => _NewsSection(items: items),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        DecoratedBox(
          decoration: ShapeDecoration(
            color: colors.primaryContainer,
            shape: const CircleBorder(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(Icons.satellite_alt_rounded, color: colors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QO-100 TR', style: textTheme.headlineMedium),
              Text(
                'TA-NET 777 Topluluğu',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.cell_tower_rounded, color: colors.primary),
      ],
    );
  }
}

class _SessionSection extends ConsumerWidget {
  const _SessionSection({required this.session, required this.onListen});

  final CommunitySession? session;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = session;
    if (currentSession == null) {
      return const HomeStateCard(
        key: Key('home-no-current-session'),
        title: 'Aktif oturum bulunmuyor',
        message: 'Yeni TA-NET 777 oturumu planlandığında burada görünecek.',
        icon: Icons.event_busy_rounded,
      );
    }

    final checkIns = ref.watch(sessionCheckInsProvider(currentSession.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SessionHeroCard(session: currentSession, onListen: onListen),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Bu Haftanın Katılımı'),
        const SizedBox(height: AppSpacing.sm),
        checkIns.when(
          loading: () => const HomeStateCard(
            key: Key('home-check-ins-loading'),
            title: 'Katılım bilgisi yükleniyor',
            message: 'Haftalık katılım özeti hazırlanıyor.',
            isLoading: true,
          ),
          error: (error, stackTrace) => HomeStateCard(
            key: const Key('home-check-ins-error'),
            title: 'Katılım bilgisi alınamadı',
            message: 'Katılım özetini yeniden yükleyebilirsiniz.',
            icon: Icons.cloud_off_rounded,
            actionLabel: 'Tekrar Dene',
            onAction: () =>
                ref.invalidate(sessionCheckInsProvider(currentSession.id)),
          ),
          data: (items) => _ParticipationSummary(checkIns: items),
        ),
      ],
    );
  }
}

class _ParticipationSummary extends StatelessWidget {
  const _ParticipationSummary({required this.checkIns});

  final List<CheckIn> checkIns;

  @override
  Widget build(BuildContext context) {
    final directCount = checkIns
        .where(
          (checkIn) => checkIn.participationType == ParticipationType.direct,
        )
        .length;
    final swlCount = checkIns
        .where((checkIn) => checkIn.participationType == ParticipationType.swl)
        .length;

    return ParticipationStatsCard(
      directCount: directCount,
      swlCount: swlCount,
      directValueKey: const Key('home-direct-count'),
      swlValueKey: const Key('home-swl-count'),
      totalValueKey: const Key('home-total-count'),
    );
  }
}

class _NewsSection extends StatelessWidget {
  const _NewsSection({required this.items});

  final List<NewsItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const HomeStateCard(
        key: Key('home-news-empty'),
        title: 'Henüz haber yok',
        message: 'Yeni topluluk haberleri burada yayınlanacak.',
        icon: Icons.article_outlined,
      );
    }

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          NewsPreviewCard(item: items[index]),
          if (index != items.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

typedef _HomeAnnouncement = ({String title, String message});

const List<_HomeAnnouncement> _announcements = [
  (
    title: 'Haftalık buluşma hatırlatması',
    message:
        'Oturum bilgileri örnek veriden gelir; güncel programı takip edin.',
  ),
  (
    title: 'Topluluk bilgisi',
    message:
        'TA-NET 777 duyuruları yakında ortak veri kaynağından yayınlanacak.',
  ),
];
