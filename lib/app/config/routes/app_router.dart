import 'package:mydairy/app/core/constants/route_constants.dart';
import 'package:mydairy/app/core/widgets/scaffold_bottom_nav.dart';
import 'package:mydairy/screens/analytics/view/analytics_screen.dart';
import 'package:mydairy/screens/entry_detail/view/entry_detail_screen.dart';
import 'package:mydairy/screens/home/view/home_screen.dart';
import 'package:mydairy/screens/splash/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mydairy/screens/setting/view/setting_screen.dart';
import 'package:mydairy/screens/write_entry/view/write_entry_screen.dart';

class AppRouter {
  AppRouter();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  GoRouter get router => _goRouter;

  late final _goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    onException: (context, state, router) => router.go(RouteConstants.home),
    routes: [
      ..._mainRoute,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldBottomNav(navigationShell: navigationShell);
        },
        branches: [_homeBranch, _analyticsBranch, _settingBranch],
      ),
    ],
  );

  late final _mainRoute = <RouteBase>[
    GoRoute(
      path: RouteConstants.splash,
      name: RouteConstants.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteConstants.writeEntry,
      name: RouteConstants.writeEntry,
      builder: (context, state) => const WriteEntryScreen(),
    ),
    GoRoute(
      path: '${RouteConstants.entryDetail}/:id',
      name: RouteConstants.entryDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EntryDetailScreen(entryId: id);
      },
    ),
  ];

  late final _homeBranch = StatefulShellBranch(
    initialLocation: RouteConstants.home,
    routes: [
      GoRoute(
        path: RouteConstants.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );

  late final _analyticsBranch = StatefulShellBranch(
    initialLocation: RouteConstants.analytics,
    routes: [
      GoRoute(
        path: RouteConstants.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );

  late final _settingBranch = StatefulShellBranch(
    initialLocation: RouteConstants.setting,
    routes: [
      GoRoute(
        path: RouteConstants.setting,
        builder: (context, state) => const SettingScreen(),
      ),
    ],
  );
}
