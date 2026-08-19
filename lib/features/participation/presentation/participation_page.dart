import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/core/widgets/participation_stats_card.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';
import 'package:qo100_tr/features/participation/presentation/controllers/check_in_controller.dart';
import 'package:qo100_tr/features/participation/presentation/providers/participation_providers.dart';
import 'package:qo100_tr/features/participation/presentation/widgets/check_in_action_card.dart';
import 'package:qo100_tr/features/participation/presentation/widgets/operator_identity_card.dart';
import 'package:qo100_tr/features/participation/presentation/widgets/participant_list.dart';
import 'package:qo100_tr/features/participation/presentation/widgets/participation_session_card.dart';
import 'package:qo100_tr/features/participation/presentation/widgets/participation_state_card.dart';
import 'package:qo100_tr/features/participation/presentation/widgets/participation_type_selector.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

class ParticipationPage extends ConsumerWidget {
  const ParticipationPage({super.key});

  static const pageKey = Key('participation-page');
  static const weekDetailButtonKey = Key('participation-week-detail-button');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(participationSessionProvider);

    return Scaffold(
      key: pageKey,
      body: SafeArea(
        child: session.when(
          loading: () => const _PageList(
            children: [
              _PageHeader(),
              ParticipationStateCard(
                key: Key('participation-session-loading'),
                title: 'Oturum yükleniyor',
                message: 'Güncel katılım oturumu hazırlanıyor.',
                isLoading: true,
              ),
            ],
          ),
          error: (error, stackTrace) => _PageList(
            children: [
              const _PageHeader(),
              ParticipationStateCard(
                key: const Key('participation-session-error'),
                title: 'Oturum bilgisi alınamadı',
                message: 'Bağlantıyı kontrol edip yeniden deneyin.',
                icon: Icons.cloud_off_rounded,
                isError: true,
                actionLabel: 'Tekrar Dene',
                onAction: () => ref.invalidate(participationSessionProvider),
              ),
            ],
          ),
          data: (currentSession) {
            if (currentSession == null) {
              return const _PageList(
                children: [
                  _PageHeader(),
                  ParticipationStateCard(
                    key: Key('participation-no-session'),
                    title: 'Aktif oturum bulunmuyor',
                    message:
                        'Katılım kaydı, yeni oturum açıldığında kullanılabilir.',
                    icon: Icons.event_busy_rounded,
                  ),
                ],
              );
            }
            return _ParticipationDashboard(session: currentSession);
          },
        ),
      ),
    );
  }
}

class _ParticipationDashboard extends ConsumerWidget {
  const _ParticipationDashboard({required this.session});

  final CommunitySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(participationProfileProvider);
    final checkIns = ref.watch(participationCheckInsProvider(session.id));

    return _PageList(
      children: [
        const _PageHeader(),
        ParticipationSessionCard(session: session),
        const _SectionTitle('Katılım Türü ve Operatör'),
        profile.when(
          loading: () => const ParticipationStateCard(
            key: Key('participation-profile-loading'),
            title: 'Profil yükleniyor',
            message: 'Kayıtlı operatör bilgileriniz hazırlanıyor.',
            isLoading: true,
          ),
          error: (error, stackTrace) => ParticipationStateCard(
            key: const Key('participation-profile-error'),
            title: 'Profil bilgisi alınamadı',
            message: 'Profilinizi yeniden yükleyebilirsiniz.',
            icon: Icons.person_off_rounded,
            isError: true,
            actionLabel: 'Tekrar Dene',
            onAction: () => ref.invalidate(participationProfileProvider),
          ),
          data: (currentProfile) {
            if (currentProfile == null) {
              return const ParticipationStateCard(
                key: Key('participation-profile-unavailable'),
                title: 'Operatör profili gerekli',
                message: 'Katılım kaydı için önce profil bilgileri gereklidir.',
                icon: Icons.person_off_rounded,
              );
            }
            return _CheckInForm(session: session, profile: currentProfile);
          },
        ),
        const _SectionTitle('Canlı Katılım'),
        checkIns.when(
          loading: () => const ParticipationStateCard(
            key: Key('participation-list-loading'),
            title: 'Katılımcılar yükleniyor',
            message: 'Canlı katılım listesi hazırlanıyor.',
            isLoading: true,
          ),
          error: (error, stackTrace) => ParticipationStateCard(
            key: const Key('participation-list-error'),
            title: 'Katılımcılar alınamadı',
            message: 'Katılım listesini yeniden yükleyebilirsiniz.',
            icon: Icons.cloud_off_rounded,
            isError: true,
            actionLabel: 'Tekrar Dene',
            onAction: () =>
                ref.invalidate(participationCheckInsProvider(session.id)),
          ),
          data: (items) => _ParticipantsSection(checkIns: items),
        ),
        OutlinedButton.icon(
          key: ParticipationPage.weekDetailButtonKey,
          onPressed: () => context.go(AppRoutes.participationWeekDetail),
          icon: const Icon(Icons.calendar_month_rounded),
          label: const Text('Hafta Detayı'),
        ),
      ],
    );
  }
}

class _CheckInForm extends ConsumerWidget {
  const _CheckInForm({required this.session, required this.profile});

  final CommunitySession session;
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = checkInControllerProvider(
      CheckInContext(session: session, profile: profile),
    );
    final flow = ref.watch(provider);

    return flow.when(
      loading: () => const ParticipationStateCard(
        key: Key('participation-check-in-loading'),
        title: 'Katılım durumu kontrol ediliyor',
        message: 'Bu oturumdaki mevcut kaydınız aranıyor.',
        isLoading: true,
      ),
      error: (error, stackTrace) => ParticipationStateCard(
        key: const Key('participation-check-in-initialization-error'),
        title: 'Katılım durumu alınamadı',
        message: 'Katılım durumunu yeniden kontrol edebilirsiniz.',
        icon: Icons.error_outline_rounded,
        isError: true,
        actionLabel: 'Tekrar Dene',
        onAction: () => ref.invalidate(provider),
      ),
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ParticipationTypeSelector(
            selectedType: state.selectedType,
            enabled: state.canSelectType && session.isActive,
            onSelected: ref.read(provider.notifier).selectType,
          ),
          const SizedBox(height: AppSpacing.sm),
          OperatorIdentityCard(profile: profile),
          const SizedBox(height: AppSpacing.sm),
          CheckInActionCard(
            state: state,
            onSubmit: ref.read(provider.notifier).submit,
          ),
        ],
      ),
    );
  }
}

class _ParticipantsSection extends StatelessWidget {
  const _ParticipantsSection({required this.checkIns});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ParticipationStatsCard(
          directCount: directCount,
          swlCount: swlCount,
          directValueKey: const Key('participation-direct-count'),
          swlValueKey: const Key('participation-swl-count'),
          totalValueKey: const Key('participation-total-count'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (checkIns.isEmpty)
          const ParticipationStateCard(
            key: Key('participation-list-empty'),
            title: 'Henüz katılımcı yok',
            message: 'İlk katılım kaydı burada görünecek.',
            icon: Icons.groups_outlined,
          )
        else
          ParticipantList(checkIns: checkIns),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Katılım', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'TA-NET 777 haftalık buluşmasına katılımınızı kaydedin.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _PageList extends StatelessWidget {
  const _PageList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      itemCount: children.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => children[index],
    );
  }
}
