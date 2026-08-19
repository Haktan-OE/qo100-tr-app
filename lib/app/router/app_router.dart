import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/shell/app_shell.dart';
import 'package:qo100_tr/features/home/presentation/home_page.dart';
import 'package:qo100_tr/features/live/presentation/live_page.dart';
import 'package:qo100_tr/features/news/presentation/news_page.dart';
import 'package:qo100_tr/features/participation/presentation/participation_page.dart';
import 'package:qo100_tr/features/participation/presentation/week_detail_placeholder_page.dart';
import 'package:qo100_tr/features/profile/presentation/profile_page.dart';

abstract final class AppRoutes {
  static const home = '/app/home';
  static const live = '/app/live';
  static const participation = '/app/participation';
  static const participationWeekDetail = '/app/participation/week-detail';
  static const news = '/app/news';
  static const profile = '/app/profile';
}

GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.live,
              builder: (context, state) => const LivePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.participation,
              builder: (context, state) => const ParticipationPage(),
              routes: [
                GoRoute(
                  path: 'week-detail',
                  builder: (context, state) =>
                      const WeekDetailPlaceholderPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.news,
              builder: (context, state) => const NewsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
