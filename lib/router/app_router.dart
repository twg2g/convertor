import 'package:go_router/go_router.dart';

import '../screens/converter_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/main_shell.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) => const NoTransitionPage(child: SearchScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                pageBuilder: (context, state) => const NoTransitionPage(child: FavoritesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/convert/:categoryId',
        builder: (context, state) {
          final id = state.pathParameters['categoryId']!;
          return ConverterScreen(
            categoryId: id,
            initialFromId: state.uri.queryParameters['from'],
            initialToId: state.uri.queryParameters['to'],
            initialValueQuery: state.uri.queryParameters['v'],
          );
        },
      ),
    ],
  );
}
