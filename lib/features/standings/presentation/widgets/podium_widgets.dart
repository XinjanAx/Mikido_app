import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../players/presentation/providers/player_provider.dart'
    show playerGuildsProvider, nameWithGuild;
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/services/podium_calculator.dart';

Color podiumColor(int place) => switch (place) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      _ => AppColors.bronze,
    };

/// Logo de la copa del club según el tema (blanco en oscuro, negro en claro).
String get cupLogoAsset => AppColors.isDark
    ? 'assets/images/logo_copa_positivo.png'
    : 'assets/images/logo_copa_negativo.png';

/// Campeón de una categoría finalizada, compacto (tarjetas de la mesa).
class ChampionBadge extends StatelessWidget {
  final String name;

  /// true = cuadro para el espacio libre a la derecha (escritorio), con el
  /// logo de la copa de fondo al 50 %; false = fila dentro de la tarjeta
  /// (celular), con el logo en lugar de ícono.
  final bool vertical;

  /// Gremio completo del campeón (null si no tiene): debajo del nombre,
  /// más chico y en gris.
  final String? guild;

  const ChampionBadge({
    super.key,
    required this.name,
    this.vertical = false,
    this.guild,
  });

  bool get _hasGuild => guild != null && guild!.isNotEmpty;

  /// Gris que contrasta con el tema (claro en oscuro, oscuro en claro).
  Color get _guildColor =>
      AppColors.isDark ? const Color(0xFFBDBDBD) : const Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    final label = Text('Campeón',
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey400));
    final nameText = Text(
      name,
      style: AppTextStyles.titleMedium.copyWith(color: AppColors.gold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final guildText = _hasGuild
        ? Text(
            guild!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(color: _guildColor),
          )
        : null;

    if (vertical) {
      // Halo del color opuesto al logo para que el texto se despegue del
      // fondo (logo blanco en tema oscuro, negro en claro).
      final isDark = AppColors.isDark;
      final halo = isDark ? Colors.black : Colors.white;
      // En tema claro el halo se refuerza (más capas, más ceñido) porque el
      // logo negro compite más con el texto oscuro.
      final haloShadows = [
        Shadow(color: halo, blurRadius: 4),
        Shadow(color: halo, blurRadius: 8),
        Shadow(color: halo, blurRadius: 12),
        if (!isDark) ...[
          Shadow(color: halo, blurRadius: 2),
          Shadow(color: halo, blurRadius: 3),
          Shadow(color: halo, blurRadius: 6),
        ],
      ];
      return Container(
        height: 104,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.5 : 0.3,
                child: Image.asset(cupLogoAsset, fit: BoxFit.contain),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CAMPEÓN',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 13,
                      color: AppColors.isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      shadows: haloShadows,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    // Con gremio debajo, el nombre va en una línea para
                    // que todo quepa en el cuadro.
                    maxLines: _hasGuild ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleLarge.copyWith(
                      // En tema claro el dorado brillante se pierde sobre
                      // el fondo blanco: se usa un dorado oscuro.
                      color: isDark
                          ? const Color.fromARGB(255, 255, 232, 99)
                          : const Color.fromARGB(255, 161, 108, 0),
                      fontWeight: FontWeight.w800,
                      shadows: haloShadows,
                    ),
                  ),
                  if (_hasGuild)
                    Text(
                      guild!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _guildColor,
                        shadows: haloShadows,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Image.asset(cupLogoAsset, height: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [label, nameText, if (guildText != null) guildText],
            ),
          ),
        ],
      ),
    );
  }
}

/// Los tres puestos de una categoría finalizada (detalle de categoría).
class PodiumCard extends StatelessWidget {
  final List<PodiumEntry> podium;

  const PodiumCard({super.key, required this.podium});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(cupLogoAsset, height: 24),
                const SizedBox(width: 8),
                Text('Podio', style: AppTextStyles.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            for (final entry in podium) _PodiumRow(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _PodiumRow extends ConsumerWidget {
  final PodiumEntry entry;

  const _PodiumRow({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // "Nombre - Gremio completo" si tiene gremio.
    final displayName = nameWithGuild(
        ref.watch(playerGuildsProvider), entry.playerId, entry.name);
    final color = podiumColor(entry.place);
    final isFirst = entry.place == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: isFirst
                ? Image.asset(cupLogoAsset, height: 28)
                : Icon(Icons.military_tech, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 34,
            child: Text('${entry.place}°',
                style: AppTextStyles.titleMedium.copyWith(color: color)),
          ),
          Expanded(
            child: Text(
              displayName,
              style: (isFirst
                      ? AppTextStyles.titleLarge
                      : AppTextStyles.titleMedium)
                  .copyWith(color: isFirst ? color : null),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
