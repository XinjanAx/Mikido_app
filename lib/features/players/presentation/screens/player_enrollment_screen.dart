import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_app/core/constants/route_constants.dart';
import 'package:torneo_app/core/theme/app_colors.dart';
import 'package:torneo_app/features/players/presentation/providers/player_provider.dart';

class PlayerEnrollmentScreen extends ConsumerStatefulWidget {
  final String tournamentId;
  const PlayerEnrollmentScreen({required this.tournamentId});

  @override
  ConsumerState<PlayerEnrollmentScreen> createState() =>
      PlayerEnrollmentScreenState();
}

class PlayerEnrollmentScreenState
    extends ConsumerState<PlayerEnrollmentScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _unenroll(String playerId) async {
    final success = await ref.read(playersProvider.notifier).unenrollPlayer(
          playerId: playerId,
          tournamentId: widget.tournamentId,
        );
    if (success) {
      ref.invalidate(playersByTournamentProvider(widget.tournamentId));
    } else if (mounted) {
      final error = ref.read(playersProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al desinscribir: ${error ?? ''}')),
      );
    }
  }

  Future<void> _enroll(String playerId) async {
    final success = await ref.read(playersProvider.notifier).enrollPlayer(
          playerId: playerId,
          tournamentId: widget.tournamentId,
        );
    if (success) {
      ref.invalidate(playersByTournamentProvider(widget.tournamentId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlayers = ref.watch(playersProvider).players;
    final enrolledAsync =
        ref.watch(playersByTournamentProvider(widget.tournamentId));

    // Filtrar jugadores disponibles por búsqueda
    final availablePlayers = allPlayers.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          (p.email?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Participantes del torneo')),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar participante...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Lista
          Expanded(
            child: enrolledAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (enrolled) {
                final enrolledIds = enrolled.map((p) => p.id).toSet();
                final inscritos = enrolled.where((p) {
                  return _searchQuery.isEmpty ||
                      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (p.email
                              ?.toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ??
                          false);
                }).toList();
                final disponibles = availablePlayers
                    .where((p) => !enrolledIds.contains(p.id))
                    .toList();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    // ── Inscritos ──
                    Container(
                      color: AppColors.surfaceVariant,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Row(
                        children: [
                          const Text(
                            'INSCRITOS',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${inscritos.length} inscrito(s)',
                            style: TextStyle(
                              color: AppColors.grey400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (inscritos.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          'Sin participantes',
                          style:
                              TextStyle(color: AppColors.grey600, fontSize: 13),
                        ),
                      )
                    else
                      ...inscritos.map((p) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withOpacity(0.15),
                              child: Text(
                                p.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                            title: Text(p.name),
                            subtitle: p.email != null ? Text(p.email!) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red, size: 20),
                              tooltip: 'Desinscribir',
                              onPressed: () => _unenroll(p.id),
                            ),
                          )),
                    const Divider(height: 1),

                    // ── Disponibles (no inscritos) ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'DISPONIBLES',
                        style: TextStyle(
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    ...disponibles.map((p) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey.withOpacity(0.15),
                            child: Text(
                              p.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                          title: Text(p.name),
                          subtitle: p.email != null ? Text(p.email!) : null,
                          trailing: TextButton(
                            onPressed: () => _enroll(p.id),
                            child: const Text('Inscribir'),
                          ),
                        )),

                    if (disponibles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Todos los participantes están inscritos',
                          style:
                              TextStyle(color: AppColors.grey600, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.playerCreate),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nuevo participante'),
      ),
    );
  }
}
