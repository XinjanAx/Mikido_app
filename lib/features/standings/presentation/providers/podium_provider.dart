import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart'
    show matchesStreamProvider;
import '../../../tournaments/presentation/providers/tournament_provider.dart'
    show tournamentByIdProvider;
import '../../domain/services/podium_calculator.dart';
import 'standing_provider.dart';

/// Podio de una categoría FINALIZADA (vacío mientras siga en curso).
final podiumProvider =
    Provider.family<List<PodiumEntry>, String>((ref, tournamentId) {
  final tournament = ref.watch(tournamentByIdProvider(tournamentId));
  if (tournament == null ||
      tournament.status != AppConstants.statusFinished) {
    return const [];
  }
  final isElimination =
      tournament.mode == AppConstants.tournamentModeElimination;
  return PodiumCalculator.compute(
    mode: tournament.mode,
    matches: isElimination
        ? ref.watch(matchesStreamProvider(tournamentId)).valueOrNull ?? []
        : const [],
    standings: isElimination
        ? const []
        : ref.watch(standingsStreamProvider(tournamentId)).valueOrNull ?? [],
  );
});
