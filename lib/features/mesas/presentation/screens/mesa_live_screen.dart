import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/category_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../../../fixtures/presentation/services/match_result_flow.dart';
import '../../../players/presentation/providers/player_provider.dart'
    show playerAcronymsProvider, playerGuildsProvider, nameWithAcronym;
import '../../../fixtures/presentation/widgets/match_card_widget.dart'
    show MesaTurnBadge;
import '../../../tournaments/presentation/providers/tournament_provider.dart';
import '../../../tournaments/presentation/widgets/category_color_widgets.dart';
import '../providers/mesa_provider.dart';

/// Mesa en vivo: la forma normal de registrar resultados (solo admin).
///
/// Muestra el encuentro ACTUAL de la mesa —el primero pendiente de la
/// cola— con su número de turno en grande (pensado para transmitir la
/// pantalla al público), un marcador táctil para cargarlo y, al guardar,
/// pasa solo al siguiente. Debajo/al costado, los próximos encuentros para
/// que los competidores se vayan preparando.
///
/// Las correcciones de encuentros ya jugados se hacen en Encuentros de la
/// categoría. Las reglas de guardado (sin empates en eliminación, avance de
/// ronda con confirmación) son las mismas: submitMatchResult.
/// Por debajo de este ancho (celular) el "VS" va arriba de las esquinas.
const double _narrowCardWidth = 520;

class MesaLiveScreen extends ConsumerStatefulWidget {
  final String mesaId;

  const MesaLiveScreen({super.key, required this.mesaId});

  @override
  ConsumerState<MesaLiveScreen> createState() => _MesaLiveScreenState();
}

class _MesaLiveScreenState extends ConsumerState<MesaLiveScreen> {
  static const _upcomingCount = 4;

  String? _currentId;
  int _home = 0;
  int _away = 0;
  bool _isSaving = false;
  final _saveFocus = FocusNode(canRequestFocus: false, skipTraversal: true);

  @override
  void dispose() {
    _saveFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final mesa = ref.watch(mesaByIdProvider(widget.mesaId));
    final queueAsync = ref.watch(mesaQueueProvider(widget.mesaId));

    final queue = queueAsync.valueOrNull ?? const <MatchEntity>[];
    final pending = queue.where((m) => !m.isFinished).toList();
    final current = pending.isEmpty ? null : pending.first;
    final upcoming = pending.skip(1).take(_upcomingCount).toList();

    // Encuentro nuevo en pantalla: el marcador arranca en 0 - 0.
    if (current?.id != _currentId) {
      _currentId = current?.id;
      _home = 0;
      _away = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${mesa?.name ?? 'Mesa'} · En vivo'),
            // Regla de operación: la cola se calcula en el dispositivo y se
            // sincroniza después; con dos dispositivos cargando la misma
            // mesa ambos verían el mismo "actual".
            Row(
              children: [
                const Icon(Icons.phonelink_lock,
                    size: 13, color: AppColors.warning),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Usar un solo dispositivo por mesa',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (queue.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  // Total final (incluye rondas de eliminación por generar).
                  '${queue.length - pending.length} de '
                  '${ref.watch(mesaProjectedTotalProvider(widget.mesaId))}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey400),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.format_list_numbered),
            tooltip: 'Orden completo',
            onPressed: () => context.push(
                RouteConstants.mesaQueue.replaceAll(':id', widget.mesaId)),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: !isAdmin
          ? const Center(
              child: Text('Solo un administrador puede usar Mesa en vivo'))
          : queueAsync.isLoading && queue.isEmpty
              ? const LoadingWidget(message: 'Cargando mesa...')
              : current == null
                  ? _EmptyState(hasMatches: queue.isNotEmpty)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;
                        final currentPanel = _buildCurrent(current);
                        final upcomingPanel = _UpcomingList(matches: upcoming);
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: currentPanel,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: SingleChildScrollView(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 16, 16),
                                  child: upcomingPanel,
                                ),
                              ),
                            ],
                          );
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              currentPanel,
                              const SizedBox(height: 16),
                              upcomingPanel,
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildCurrent(MatchEntity match) {
    final category = ref.watch(tournamentByIdProvider(match.tournamentId));
    final color = CategoryColors.parse(category?.color) ?? AppColors.accent;
    final guilds = ref.watch(playerGuildsProvider);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera: número de turno en grande + categoría y ronda.
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.35),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'ENCUENTRO ACTUAL',
                  style: AppTextStyles.labelSmall.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey400,
                  ),
                ),
                FittedBox(
                  child: Text(
                    '#${match.mesaOrder}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 48,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Categoría en grande (se lee de lejos al transmitir); la
                // ronda debajo, más chica.
                if (category != null)
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                if (match.round != null)
                  Text(
                    match.round!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 16,
                      color: AppColors.grey400,
                    ),
                  ),
              ],
            ),
          ),
          // Competidores y marcador. En pantallas angostas (celular) el "VS"
          // va arriba, debajo de la ronda y más chico, para que cada
          // esquina use todo el ancho; en anchas va entre las dos esquinas.
          LayoutBuilder(builder: (context, constraints) {
            final narrow = constraints.maxWidth < _narrowCardWidth;
            final blue = Expanded(
              child: _ScoreColumn(
                corner: _Corner.blue,
                name: match.homePlayerName,
                guild: guilds[match.homePlayerId],
                score: _home,
                enabled: !_isSaving,
                onChanged: (v) => setState(() => _home = v),
              ),
            );
            final red = Expanded(
              child: _ScoreColumn(
                corner: _Corner.red,
                name: match.awayPlayerName,
                guild: guilds[match.awayPlayerId],
                score: _away,
                enabled: !_isSaving,
                onChanged: (v) => setState(() => _away = v),
              ),
            );
            TextStyle vsStyle(double size) =>
                AppTextStyles.titleMedium.copyWith(
                  fontSize: size,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: AppColors.grey400,
                );

            if (narrow) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: Column(
                  children: [
                    Text('VS', style: vsStyle(20)),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [blue, const SizedBox(width: 8), red],
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  blue,
                  Padding(
                    // 122 + 22 de la línea del gremio.
                    padding:
                        const EdgeInsets.only(top: 166, left: 10, right: 10),
                    child: Text('VS', style: vsStyle(30)),
                  ),
                  red,
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                // Sin foco de teclado: en Windows el botón se quedaba con
                // el foco tras usarlo, y un Enter/Espacio posterior (al
                // volver a esta pantalla) lo reactivaba y abría la
                // confirmación sin que nadie tocara el botón.
                focusNode: _saveFocus,
                onPressed: _isSaving ? null : () => _confirmAndSave(match),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text('GUARDAR RESULTADO',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndSave(MatchEntity match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Confirmar resultado #${match.mesaOrder}'),
        content: Text.rich(
          TextSpan(
            style: AppTextStyles.titleMedium,
            children: [
              TextSpan(
                text: '${match.homePlayerName}  $_home',
                style: TextStyle(
                    color: _Corner.blue.color, fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '  –  '),
              TextSpan(
                text: '$_away  ${match.awayPlayerName}',
                style: TextStyle(
                    color: _Corner.red.color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Corregir'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Mientras el diálogo estaba abierto la cola pudo cambiar (encuentros
    // borrados o regenerados, otra sincronización): solo se guarda si este
    // sigue siendo el encuentro actual de la mesa.
    final latest =
        ref.read(mesaQueueProvider(widget.mesaId)).valueOrNull ?? const [];
    final stillCurrent =
        latest.where((m) => !m.isFinished).firstOrNull?.id == match.id;
    if (!stillCurrent) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('El encuentro actual cambió (se borraron o '
              'regeneraron encuentros). No se guardó nada: revisa el '
              'encuentro en pantalla.'),
          backgroundColor: AppColors.warning,
        ));
      return;
    }

    setState(() => _isSaving = true);
    final ok = await submitMatchResult(
      context: context,
      ref: ref,
      match: match,
      homeScore: _home,
      awayScore: _away,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Resultado #${match.mesaOrder} guardado'),
          duration: const Duration(seconds: 2),
        ));
    }
  }
}

/// Nombre del competidor + marcador grande con botones − / +. Tocar el
/// número permite escribirlo.
/// Esquina de cada competidor en Mesa en vivo. Fija, no aleatoria: el
/// primero del encuentro (local) va en la esquina azul, a la izquierda, y el
/// segundo (visitante) en la roja, a la derecha.
enum _Corner {
  blue('ESQUINA AZUL', Color(0xFF1E88E5)),
  red('ESQUINA ROJA', Color(0xFFE53935));

  const _Corner(this.label, this.color);
  final String label;
  final Color color;
}

class _ScoreColumn extends StatelessWidget {
  final _Corner corner;
  final String name;

  /// Gremio completo del competidor (null si no tiene).
  final String? guild;
  final int score;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _ScoreColumn({
    required this.corner,
    required this.name,
    this.guild,
    required this.score,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = corner.color;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: _buildContent(context, color),
    );
  }

  Widget _buildContent(BuildContext context, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            corner.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 72,
          child: Center(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleLarge.copyWith(fontSize: 26),
            ),
          ),
        ),
        // Gremio completo, más chico. La línea se reserva siempre (aunque
        // no tenga gremio) para que las dos esquinas queden alineadas.
        SizedBox(
          height: 22,
          child: Text(
            guild ?? '',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              color: AppColors.grey400,
            ),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          canRequestFocus: false,
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? () => _typeScore(context) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FittedBox(
              child: Text(
                '$score',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 104,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundButton(
              icon: Icons.remove,
              color: color,
              onTap: enabled && score > 0 ? () => onChanged(score - 1) : null,
            ),
            const SizedBox(width: 16),
            _RoundButton(
              icon: Icons.add,
              color: color,
              filled: true,
              onTap: enabled && score < AppConstants.maxMatchScore
                  ? () => onChanged(score + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _typeScore(BuildContext context) async {
    final controller = TextEditingController(text: '$score');
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(name),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Marcador'),
          onSubmitted: (v) =>
              Navigator.pop(dialogContext, int.tryParse(v) ?? score),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
                dialogContext, int.tryParse(controller.text) ?? score),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (value != null) {
      onChanged(value.clamp(0, AppConstants.maxMatchScore));
    }
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  /// Color de la esquina del competidor.
  final Color color;

  const _RoundButton({
    required this.icon,
    required this.color,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabledColor = this.color;
    final color = onTap == null ? AppColors.grey400 : enabledColor;
    return Material(
      color: filled && onTap != null ? enabledColor : Colors.transparent,
      shape: CircleBorder(side: BorderSide(color: color, width: 2)),
      child: InkWell(
        canRequestFocus: false, // ver _saveFocus
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon,
              size: 30,
              color: filled && onTap != null ? AppColors.white : color),
        ),
      ),
    );
  }
}

class _UpcomingList extends ConsumerWidget {
  final List<MatchEntity> matches;

  const _UpcomingList({required this.matches});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // En la lista de siguientes va el acrónimo del gremio (más corto).
    final acronyms = ref.watch(playerAcronymsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'A CONTINUACIÓN',
            style: AppTextStyles.labelSmall.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              color: AppColors.grey400,
            ),
          ),
        ),
        if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('No hay más encuentros generados por ahora.',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.grey400)),
          ),
        for (final m in matches)
          Builder(builder: (context) {
            final category = ref.watch(tournamentByIdProvider(m.tournamentId));
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CategoryColorStrip(hex: category?.color, width: 6),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            MesaTurnBadge(turn: m.mesaOrder!),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${nameWithAcronym(acronyms, m.homePlayerId, m.homePlayerName)}'
                                    '  vs  '
                                    '${nameWithAcronym(acronyms, m.awayPlayerId, m.awayPlayerName)}',
                                    style: AppTextStyles.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    [
                                      if (category != null) category.name,
                                      if (m.round != null) m.round!,
                                    ].join(' · '),
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: AppColors.grey400),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasMatches;

  const _EmptyState({required this.hasMatches});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasMatches ? Icons.emoji_events_outlined : Icons.hourglass_empty,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              hasMatches
                  ? 'No quedan encuentros pendientes'
                  : 'Aún no hay encuentros en esta mesa',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasMatches
                  ? 'Si una categoría de eliminación espera la siguiente '
                      'ronda, confírmala desde Encuentros de esa categoría. '
                      'Cuando se genere, aparecerá aquí.'
                  : 'Genera los encuentros de las categorías de esta mesa '
                      'para empezar.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
