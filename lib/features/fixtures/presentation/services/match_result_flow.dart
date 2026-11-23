import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tournaments/presentation/providers/tournament_provider.dart';
import '../../domain/entities/match_entity.dart';
import '../providers/fixture_provider.dart';
import '../widgets/round_advance_confirm_dialog.dart';

/// Guarda el resultado de un encuentro con todas las reglas de la app, en
/// un solo lugar para que Encuentros (corrección) y Mesa en vivo (registro
/// normal) se comporten igual:
///
/// - En eliminación directa no se permite empate (cada encuentro necesita
///   un ganador para avanzar; antes un empate se resolvía en silencio a
///   favor del local).
/// - Si con este resultado se completa una ronda de eliminación, se le pide
///   al admin que confirme quiénes pasan antes de generar la siguiente.
///
/// Devuelve true si el resultado se guardó.
Future<bool> submitMatchResult({
  required BuildContext context,
  required WidgetRef ref,
  required MatchEntity match,
  required int homeScore,
  required int awayScore,
}) async {
  final tournamentId = match.tournamentId;
  final tournament = ref.read(tournamentByIdProvider(tournamentId));
  final isElimination =
      tournament?.mode == AppConstants.tournamentModeElimination;

  if (isElimination && homeScore == awayScore) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('En eliminación directa no se permiten empates: el '
            'resultado debe tener un ganador.'),
        backgroundColor: AppColors.error,
      ),
    );
    return false;
  }

  final ok =
      await ref.read(fixtureProvider(tournamentId).notifier).updateResult(
            matchId: match.id,
            homeScore: homeScore,
            awayScore: awayScore,
          );
  if (!ok) return false;

  if (isElimination && match.round != null && context.mounted) {
    final bracket = ref.read(eliminationBracketServiceProvider);
    final pending = await bracket.checkRoundComplete(
      tournamentId: tournamentId,
      completedRound: match.round!,
    );
    if (pending != null && context.mounted) {
      final confirmed = await showRoundAdvanceConfirmDialog(context, pending);
      if (confirmed) {
        await bracket.generateNextRound(pending);
        ref.read(fixtureProvider(tournamentId).notifier).loadMatches();
      }
    }
  }
  return true;
}
