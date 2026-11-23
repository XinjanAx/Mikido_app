import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_app/features/players/presentation/screens/player_enrollment_screen.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/route_constants.dart';
import '../core/sync/sync_engine_provider.dart';
import '../features/mesas/presentation/providers/mesa_provider.dart'
    show mesasProvider;
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/fixtures/presentation/screens/bracket_screen.dart';
import '../features/fixtures/presentation/screens/fixture_screen.dart';
import '../features/mesas/domain/entities/mesa_entity.dart';
import '../features/mesas/presentation/screens/mesa_form_screen.dart';
import '../features/mesas/presentation/screens/mesa_list_screen.dart';
import '../features/mesas/presentation/screens/mesa_live_screen.dart';
import '../features/mesas/presentation/screens/mesa_queue_screen.dart';
import '../features/players/presentation/screens/player_detail_screen.dart';
import '../features/players/presentation/screens/player_form_screen.dart';
import '../features/players/presentation/screens/player_list_screen.dart';
import '../features/reports/presentation/screens/report_screen.dart';
import '../features/standings/presentation/screens/standings_screen.dart';
import '../features/tournaments/domain/entities/tournament_entity.dart';
import '../features/tournaments/presentation/screens/tournament_detail_screen.dart';
import '../features/tournaments/presentation/screens/tournament_form_screen.dart';
import '../features/tournaments/presentation/screens/tournament_list_screen.dart';

// Splash animada que además TAPA LA CARGA INICIAL: el logo entra con un
// rebote y un fundido mientras, por detrás, se restaura la sesión, se abre
// la base local y corre la primera sincronización. Pasa a Mesas cuando
// todo eso terminó (y la animación ya se vio entera), no por un tiempo fijo.
class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Lo mínimo que se muestra, para que la animación de entrada se vea
  /// completa aunque todo cargue al instante.
  static const _minDuration = Duration(milliseconds: 2400);

  /// Lo máximo que se espera a la red. Sin internet o con red lenta se
  /// entra igual con los datos locales (la app es offline-first) y la
  /// sincronización sigue en segundo plano.
  static const _maxSyncWait = Duration(seconds: 8);

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  /// Se muestra "Cargando datos…" si la carga dura más que la animación.
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeIn),
    );
    _loadThenEnter();
  }

  Future<void> _loadThenEnter() async {
    final minTime = Future<void>.delayed(_minDuration);
    Future<void>.delayed(_minDuration, () {
      if (mounted) setState(() => _showLoading = true);
    });

    await Future.wait([
      minTime,
      _sessionRestored(),
      // Abre la base local y lee las mesas.
      ref.read(mesasProvider.future).then((_) {}, onError: (_) {}),
      // Se une a la sincronización inicial que ya disparó
      // syncTriggerProvider (no arranca una segunda).
      ref
          .read(syncEngineProvider)
          .trySync()
          .timeout(_maxSyncWait)
          .then((_) {}, onError: (_) {}),
    ]);

    if (mounted) context.go(RouteConstants.mesas);
  }

  /// Termina cuando se sabe si hay sesión (y con qué rol).
  Future<void> _sessionRestored() {
    bool resolved(AuthState s) =>
        s.status != AuthStatus.initial && s.status != AuthStatus.loading;
    if (resolved(ref.read(authProvider))) return Future.value();

    final completer = Completer<void>();
    final sub = ref.listenManual<AuthState>(authProvider, (_, next) {
      if (resolved(next) && !completer.isCompleted) completer.complete();
    });
    return completer.future
        .timeout(_maxSyncWait, onTimeout: () {})
        .whenComplete(sub.close);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Image.asset(
                  'assets/images/club_mikido_blanco.png',
                  width: 260,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Versión ${AppConstants.appVersion}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  letterSpacing: 0.8,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 28),
              // Solo aparece si la carga dura más que la animación; el
              // espacio está reservado para que el logo no salte.
              SizedBox(
                height: 40,
                child: AnimatedOpacity(
                  opacity: _showLoading ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Column(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cargando datos…',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Rutas que solo puede usar un usuario con rol admin (crear/editar mesas y
// categorías, inscripciones y reportes). El resto de la app —mesas, orden
// de la mesa, categorías, fixtures y posiciones— es pública.
final _adminOnlyPaths = <String>{
  RouteConstants.mesaCreate,
  RouteConstants.mesaEdit,
  RouteConstants.mesaLive,
  RouteConstants.tournamentCreate,
  RouteConstants.tournamentEdit,
  RouteConstants.playerEnroll,
  RouteConstants.reports,
  RouteConstants.playerCreate,
  RouteConstants.playerEdit,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RouteConstants.splash,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.initial) {
        return null; // restaurando sesión
      }

      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isOnAuth = state.matchedLocation == RouteConstants.login ||
          state.matchedLocation == RouteConstants.register;

      if (isLoggedIn && isOnAuth) return RouteConstants.mesas;

      final requiresAdmin = _adminOnlyPaths.contains(state.fullPath);
      if (requiresAdmin && !authState.isAdmin) {
        return isLoggedIn ? RouteConstants.mesas : RouteConstants.login;
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

      // ─── Mesas ───
      GoRoute(
        path: RouteConstants.mesas,
        builder: (_, __) => const MesaListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const MesaFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return TournamentListScreen(
                mesaId: id == RouteConstants.noMesaId ? null : id,
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, state) =>
                    MesaFormScreen(mesa: state.extra as MesaEntity?),
              ),
              GoRoute(
                path: 'orden',
                builder: (_, state) => MesaQueueScreen(
                  mesaId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'en-vivo',
                builder: (_, state) => MesaLiveScreen(
                  mesaId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),

      // ─── Categorías (en código/base: tournaments) ───
      // La lista ya no existe sola: las categorías se ven dentro de su mesa.
      GoRoute(
        path: RouteConstants.tournaments,
        redirect: (_, __) => RouteConstants.mesas,
      ),
      GoRoute(
        path: RouteConstants.tournamentCreate,
        builder: (_, state) => TournamentFormScreen(
          mesaId: state.uri.queryParameters['mesaId'],
        ),
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
            path: ':id',
            builder: (_, state) => PlayerDetailScreen(
              playerId: state.pathParameters['id']!,
            ),
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
      // Al arrancar, la sesión guardada se restaura en menos de un segundo
      // y esto cortaba la animación del splash. El splash ya navega solo a
      // Mesas al terminar, así que mientras se muestra no se interviene.
      final location = router.routerDelegate.currentConfiguration.uri.path;
      if (location == RouteConstants.splash) return;
      router.go(RouteConstants.mesas);
    }
  });

  return router;
});
