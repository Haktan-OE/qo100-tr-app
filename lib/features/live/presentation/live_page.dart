import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/app_config_provider.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_radius.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/features/live/presentation/models/live_view_state.dart';
import 'package:qo100_tr/features/live/presentation/providers/live_providers.dart';

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  static const pageKey = Key('live-page');

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  LiveViewState _state = const LiveViewState.loading();
  int _reloadRequest = 0;

  void _setLiveState(LiveViewState state) {
    if (mounted) {
      setState(() => _state = state);
    }
  }

  void _retry() {
    setState(() {
      _state = const LiveViewState.loading();
      _reloadRequest += 1;
    });
  }

  Future<void> _openExternally(Uri url) async {
    var opened = false;
    try {
      opened = await ref.read(externalUrlLauncherProvider).open(url);
    } on Exception {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı tarayıcıda açılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveUrl = ref.watch(appConfigProvider).liveUrl;
    final effectiveState = liveUrl == null
        ? const LiveViewState.configurationMissing()
        : _state;

    return Scaffold(
      key: LivePage.pageKey,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            const _LiveIdentityHeader(),
            const SizedBox(height: AppSpacing.lg),
            _LiveStatusCard(state: effectiveState),
            const SizedBox(height: AppSpacing.md),
            if (liveUrl == null)
              const _ConfigurationMissingCard()
            else ...[
              _SourceCard(url: liveUrl),
              const SizedBox(height: AppSpacing.md),
              _LiveContainer(
                state: effectiveState,
                webView: ref
                    .watch(liveWebViewFactoryProvider)
                    .create(
                      url: liveUrl,
                      reloadRequest: _reloadRequest,
                      onLoading: () =>
                          _setLiveState(const LiveViewState.loading()),
                      onReady: () => _setLiveState(const LiveViewState.ready()),
                      onError: (message) =>
                          _setLiveState(LiveViewState.error(message)),
                    ),
                onRetry: _retry,
              ),
              const SizedBox(height: AppSpacing.md),
              _LiveActions(
                onReload: _retry,
                onOpenExternal: () => _openExternally(liveUrl),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LiveIdentityHeader extends StatelessWidget {
  const _LiveIdentityHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.control,
          ),
          child: const Icon(
            Icons.satellite_alt_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Canlı', style: textTheme.headlineMedium),
              Text(
                'QO-100 TR • TA-NET 777',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveStatusCard extends StatelessWidget {
  const _LiveStatusCard({required this.state});

  final LiveViewState state;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (state.status) {
      LiveViewStatus.configurationMissing => (
        Icons.settings_input_antenna_rounded,
        'Kaynak bekleniyor',
        AppColors.warning,
      ),
      LiveViewStatus.loading => (
        Icons.sync_rounded,
        'Yayın yükleniyor',
        AppColors.primary,
      ),
      LiveViewStatus.ready => (
        Icons.graphic_eq_rounded,
        'Dinlemeye hazır',
        AppColors.success,
      ),
      LiveViewStatus.error => (
        Icons.signal_wifi_bad_rounded,
        'Yayın bağlantısı kesildi',
        AppColors.error,
      ),
    };

    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Canlı yayın durumu', style: textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    label,
                    style: textTheme.titleMedium?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigurationMissingCard extends StatelessWidget {
  const _ConfigurationMissingCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(
            Icons.link_off_rounded,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Canlı yayın kaynağı yapılandırılmadı',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Yayın adresi tanımlandığında dinleme ekranı burada açılacak.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.url});

  final Uri url;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.radio_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dinleme kaynağı',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  url.host,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LiveContainer extends StatelessWidget {
  const _LiveContainer({
    required this.state,
    required this.webView,
    required this.onRetry,
  });

  final LiveViewState state;
  final Widget webView;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    height: (MediaQuery.sizeOf(context).height * 0.42).clamp(280.0, 440.0),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      border: Border.all(color: AppColors.outline),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        webView,
        if (state.status == LiveViewStatus.loading)
          const ColoredBox(
            color: AppColors.surface,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.md),
                  Text('Canlı yayın yükleniyor…'),
                ],
              ),
            ),
          ),
        if (state.status == LiveViewStatus.error)
          ColoredBox(
            color: AppColors.surface,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 44,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Yayın yüklenemedi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Bağlantınızı kontrol edip yeniden deneyin.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      key: const Key('live-error-retry'),
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _LiveActions extends StatelessWidget {
  const _LiveActions({required this.onReload, required this.onOpenExternal});

  final VoidCallback onReload;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      OutlinedButton.icon(
        key: const Key('live-reload'),
        onPressed: onReload,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Yenile'),
      ),
      FilledButton.tonalIcon(
        key: const Key('live-open-external'),
        onPressed: onOpenExternal,
        icon: const Icon(Icons.open_in_browser_rounded),
        label: const Text('Tarayıcıda Aç'),
      ),
    ],
  );
}
