import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_app/features/players/presentation/screens/player_enrollment_screen.dart';

import '../core/constants/route_constants.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/fixtures/presentation/screens/bracket_screen.dart';
import '../features/fixtures/presentation/screens/fixture_screen.dart';
import '../features/players/presentation/screens/player_form_screen.dart';
import '../features/players/presentation/screens/player_list_screen.dart';
import '../features/reports/presentation/screens/report_screen.dart';
import '../features/standings/presentation/screens/standings_screen.dart';
import '../features/tournaments/domain/entities/tournament_entity.dart';
import '../features/tournaments/presentation/screens/tournament_detail_screen.dart';
import '../features/tournaments/presentation/screens/tournament_form_screen.dart';
import '../features/tournaments/presentation/screens/tournament_list_screen.dart';

// Splash screen minimalista
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Rutas que solo puede usar un usuario con rol admin (crear/editar torneos,
// inscripciones y reportes). El resto de la app —incluida la lista de
// torneos, el detalle, fixtures y posiciones— es pública.
final _adminOnlyPaths = <String>{
  RouteConstants.tournamentCreate,
  RouteConstants.tournamentEdit,
  RouteConstants.playerEnroll,
  RouteConstants.reports,
  RouteConstants.playerCreate,
  RouteConstants.playerEdit,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RouteConstants.tournaments,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.initial) return null; // restaurando sesión

      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isOnAuth = state.matchedLocation == RouteConstants.login ||
          state.matchedLocation == RouteConstants.register;

      if (isLoggedIn && isOnAuth) return RouteConstants.tournaments;

      final requiresAdmin = _adminOnlyPaths.contains(state.fullPath);
      if (requiresAdmin && !authState.isAdmin) {
        return isLoggedIn ? RouteConstants.tournaments : RouteConstants.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // ─── Torneos ───
      GoRoute(
        path: RouteConstants.tournaments,
        builder: (_, __) => const TournamentListScreen(),
      ),
      GoRoute(
        path: RouteConstants.tournamentCreate,
        builder: (_, __) => const TournamentFormScreen(),
      ),
      GoRoute(
        path: '/tournaments/:id',
        builder: (_, state) => TournamentDetailScreen(
          tournamentId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => TournamentFormScreen(
              tournament: state.extra as TournamentEntity?,
            ),
          ),
          GoRoute(
            path: 'enroll',
            builder: (_, state) => PlayerEnrollmentScreen(
              tournamentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'fixtures',
            builder: (_, state) => FixtureScreen(
              tournamentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'standings',
            builder: (_, state) => StandingsScreen(
              tournamentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'bracket',
            builder: (_, state) => BracketScreen(
              tournamentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, state) => ReportScreen(
              tournamentId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // ─── Participantes globales ───
      GoRoute(
        path: RouteConstants.players,
        builder: (_, __) => const PlayerListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const PlayerFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (_, state) => PlayerFormScreen(
              player: state.extra as dynamic,
            ),
          ),
        ],
      ),
    ],
  );
  ref.listen(authProvider, (previous, next) {
    if (next.status == AuthStatus.authenticated && !next.isRegistering) {
      router.go(RouteConstants.tournaments);
    }
    // Ya no se fuerza a /login cuando el estado pasa a 'unauthenticated'
    // (login o logout): la navegación pública se queda donde está y solo
    // el `redirect` de arriba manda a login si hace falta rol admin.
  });

  return router;
});
