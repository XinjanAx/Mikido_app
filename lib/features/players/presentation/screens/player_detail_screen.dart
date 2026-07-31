import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tournaments/presentation/providers/tournament_provider.dart';
import '../providers/player_provider.dart';

class PlayerDetailScreen extends ConsumerWidget {
  final String playerId;

  const PlayerDetailScreen({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playersProvider);
    final isAdmin = ref.watch(isAdminProvider);

    final player = state.players.where((p) => p.id == playerId).firstOrNull;

    if (state.isLoading && player == null) {
      return const Scaffold(body: LoadingWidget());
    }

    if (player == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Participante no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                RouteConstants.playerEdit.replaceAll(':id', playerId),
                extra: player,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar grande
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              backgroundImage: player.photoUrl != null
                  ? NetworkImage(player.photoUrl!)
                  : null,
              child: player.photoUrl == null
                  ? Text(
                      player.name.isNotEmpty
                          ? player.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.displayLarge
                          .copyWith(color: AppColors.primary),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(player.name, style: AppTextStyles.headlineLarge),
          ),
          const SizedBox(height: 32),

          // Datos del participante
          _SectionCard(
            title: 'Información personal',
            children: [
              if (player.email != null)
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Correo',
                  value: player.email!,
                ),
              if (player.phone != null)
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: player.phone!,
                ),
              if (player.birthDate != null)
                _InfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Fecha de nacimiento',
                  value: player.birthDate!.toDisplayDate(),
                ),
              if (player.createdAt != null)
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Registrado el',
                  value: player.createdAt!.toDisplayDate(),
                ),
            ],
          ),

          if (isAdmin) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                // No se puede eliminar a alguien que sigue inscrito en un
                // torneo — primero hay que desinscribirlo (mismo chequeo
                // que en player_list_screen.dart; resolveActiveEnrollments
                // ya descarta/limpia solo las inscripciones huérfanas de
                // un torneo borrado).
                final playerEnrollments =
                    await resolveActiveEnrollments(ref, playerId);

                if (playerEnrollments.isNotEmpty) {
                  final tournamentNames = playerEnrollments
                      .map((e) => ref
                          .read(tournamentByIdProvider(e.tournamentId))!
                          .name)
                      .join(', ');
                  if (context.mounted) {
                    await showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('No se puede eliminar'),
                        content: Text(
                          '"${player.name}" está inscrito en: '
                          '$tournamentNames.\n\n'
                          'Debes quitar su inscripción de esos torneos '
                          'antes de poder eliminarlo.',
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    );
                  }
                  return;
                }

                if (!context.mounted) return;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Eliminar participante'),
                    content: Text(
                        '¿Eliminar a "${player.name}"? Esta acción no se puede deshacer.'),
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
                if (confirmed == true && context.mounted) {
                  await ref
                      .read(playersProvider.notifier)
                      .deletePlayer(playerId);
                  if (context.mounted) context.pop();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar participante'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.grey400),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey400)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
