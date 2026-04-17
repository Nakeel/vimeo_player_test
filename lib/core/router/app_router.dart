import 'package:go_router/go_router.dart';
import 'package:udux_concerts_test/features/player/domain/entities/player_config_entity.dart';
import 'package:udux_concerts_test/features/player/presentation/screens/home_screen.dart';
import 'package:udux_concerts_test/features/player/presentation/screens/player_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const player = '/player';
}

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.player,
      builder: (context, state) {
        final config = state.extra as PlayerConfigEntity;
        return PlayerScreen(config: config);
      },
    ),
  ],
);
