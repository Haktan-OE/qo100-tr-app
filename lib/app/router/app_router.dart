import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/router/auth_route_guard.dart';
import 'package:qo100_tr/app/shell/app_shell.dart';
import 'package:qo100_tr/features/home/presentation/home_page.dart';
import 'package:qo100_tr/features/auth/presentation/auth_form_page.dart';
import 'package:qo100_tr/features/auth/presentation/controllers/auth_form_controller.dart';
import 'package:qo100_tr/features/auth/presentation/onboarding_page.dart';
import 'package:qo100_tr/features/auth/presentation/splash_page.dart';
import 'package:qo100_tr/features/live/presentation/live_page.dart';
import 'package:qo100_tr/features/news/presentation/news_detail_page.dart';
import 'package:qo100_tr/features/news/presentation/news_page.dart';
import 'package:qo100_tr/features/participation/presentation/participation_page.dart';
import 'package:qo100_tr/features/participation/presentation/week_detail_placeholder_page.dart';
import 'package:qo100_tr/features/profile/presentation/profile_page.dart';
import 'package:qo100_tr/features/profile/presentation/profile_edit_page.dart';

abstract final class AppRoutes {
  static const home = '/app/home';
  static const splash = '/splash';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const onboarding = '/onboarding/profile';
  static const live = '/app/live';
  static const participation = '/app/participation';
  static const participationWeekDetail = '/app/participation/week-detail';
  static const news = '/app/news';
  static String newsDetail(String id) => '$news/${Uri.encodeComponent(id)}';
  static const profile = '/app/profile';
  static const profileEdit = '/app/profile/edit';
}

GoRouter createAppRouter({AuthRouteGuard? guard}) => GoRouter(
  initialLocation: guard == null ? AppRoutes.home : AppRoutes.splash,
  refreshListenable: guard,
  redirect: guard == null ? null : (context, state) => guard.redirect(state),
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, _) => const AuthFormPage(mode: AuthFormMode.login),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, _) => const AuthFormPage(mode: AuthFormMode.register),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, _) => const OnboardingPage(),
    ),
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
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      NewsDetailPage(newsId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const ProfileEditPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
