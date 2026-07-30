import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/player_card_widget.dart';

class PlayerListScreen extends ConsumerStatefulWidget {
  const PlayerListScreen({super.key});

  @override
  ConsumerState<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends ConsumerState<PlayerListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playersProvider);
    final isAdmin = ref.watch(isAdminProvider);

    // Filtrar por búsqueda
    final filtered = state.players.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          (p.email?.toLowerCase().contains(q) ?? false) ||
          (p.phone?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participantes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.read(syncEngineProvider).trySync(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, correo o teléfono...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),

          // Contador
          if (state.players.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    _searchQuery.isEmpty
                        ? '${state.players.length} participante(s)'
                        : '${filtered.length} de ${state.players.length}',
                    style: TextStyle(
                      color: AppColors.grey400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Lista
          Expanded(
            child: _buildBody(context, ref, state, filtered, isAdmin),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteConstants.playerCreate),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Nuevo participante'),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, PlayersState state,
      List filtered, bool isAdmin) {
    if (state.isLoading && state.players.isEmpty) {
      return const LoadingWidget(message: 'Cargando participantes...');
    }

    if (state.players.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'Sin participantes',
        subtitle: isAdmin ? 'Registra el primer deportista' : null,
        actionLabel: isAdmin ? 'Registrar' : null,
        onAction:
            isAdmin ? () => context.push(RouteConstants.playerCreate) : null,
      );
    }

    if (filtered.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'Sin resultados',
        subtitle: 'No hay participantes que coincidan con "$_searchQuery"',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(playersProvider.notifier).loadPlayers(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final p = filtered[i];
          return PlayerCard(
            player: p,
            isAdmin: isAdmin,
            onTap: () => context.push(
              RouteConstants.playerDetail.replaceAll(':id', p.id),
            ),
            onDelete: isAdmin
                ? () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar participante'),
                        content: Text('¿Eliminar a "${p.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref
                          .read(playersProvider.notifier)
                          .deletePlayer(p.id);
                    }
                  }
                : null,
          );
        },
      ),
    );
  }
}
