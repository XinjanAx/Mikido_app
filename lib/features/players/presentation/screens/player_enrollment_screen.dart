import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:torneo_app/core/constants/route_constants.dart';
import 'package:torneo_app/features/categories/presentation/providers/category_provider.dart';
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
  String? _selectedCategoryId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _unenroll(String playerId) async {
    try {
      await Supabase.instance.client
          .from('enrollments')
          .delete()
          .eq('player_id', playerId)
          .eq('tournament_id', widget.tournamentId);
      ref.invalidate(playersByTournamentProvider(widget.tournamentId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al desinscribir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlayers = ref.watch(playersProvider).players;
    final enrolledAsync =
        ref.watch(playersByTournamentProvider(widget.tournamentId));
    final categoriesState = ref.watch(categoriesProvider(widget.tournamentId));

    if (_selectedCategoryId == null && categoriesState.categories.isNotEmpty) {
      _selectedCategoryId = categoriesState.categories.first.id;
    }

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
          // Selector de categoría para inscribir
          if (categoriesState.categories.isEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_outlined, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Primero crea categorías para este torneo'),
                  ),
                  TextButton(
                    onPressed: () => context.push(
                      '/tournaments/${widget.tournamentId}/categories/create',
                    ),
                    child: const Text('Crear'),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Inscribir en categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                  isDense: true,
                ),
                items: categoriesState.categories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
            ),

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
                final categories = categoriesState.categories;

                return ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    // ── Inscritos por categoría ──
                    ...categories.map((cat) {
                      final inscritosEnCat = enrolled.where((p) {
                        final matchesSearch = _searchQuery.isEmpty ||
                            p.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            (p.email
                                    ?.toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) ??
                                false);
                        return p.categoryId == cat.id && matchesSearch;
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: const Color(0xFF2C2C2C),
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                            child: Row(
                              children: [
                                const Icon(Icons.category_outlined,
                                    size: 13, color: Color(0xFFC9A84C)),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFC9A84C),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${inscritosEnCat.length} inscrito(s)',
                                  style: const TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (inscritosEnCat.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Text(
                                'Sin participantes',
                                style: TextStyle(
                                    color: Color(0xFF757575), fontSize: 13),
                              ),
                            )
                          else
                            ...inscritosEnCat.map((p) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.green.withOpacity(0.15),
                                    child: Text(
                                      p.name[0].toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                  ),
                                  title: Text(p.name),
                                  subtitle:
                                      p.email != null ? Text(p.email!) : null,
                                  trailing: IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                        size: 20),
                                    tooltip: 'Desinscribir',
                                    onPressed: () => _unenroll(p.id),
                                  ),
                                )),
                          const Divider(height: 1),
                        ],
                      );
                    }),

                    // ── Disponibles (no inscritos) ──
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'DISPONIBLES',
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    ...availablePlayers
                        .where((p) => !enrolledIds.contains(p.id))
                        .map((p) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Colors.blueGrey.withOpacity(0.15),
                                child: Text(
                                  p.name[0].toUpperCase(),
                                  style:
                                      const TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                              title: Text(p.name),
                              subtitle: p.email != null ? Text(p.email!) : null,
                              trailing: _selectedCategoryId != null
                                  ? TextButton(
                                      onPressed: () async {
                                        final success = await ref
                                            .read(playersProvider.notifier)
                                            .enrollPlayer(
                                              playerId: p.id,
                                              tournamentId: widget.tournamentId,
                                              categoryId: _selectedCategoryId!,
                                            );
                                        if (success) {
                                          ref.invalidate(
                                            playersByTournamentProvider(
                                                widget.tournamentId),
                                          );
                                        }
                                      },
                                      child: const Text('Inscribir'),
                                    )
                                  : const Text(
                                      'Sin categoría',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                            )),

                    if (availablePlayers
                        .where((p) => !enrolledIds.contains(p.id))
                        .isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Todos los participantes están inscritos',
                          style:
                              TextStyle(color: Color(0xFF757575), fontSize: 13),
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
