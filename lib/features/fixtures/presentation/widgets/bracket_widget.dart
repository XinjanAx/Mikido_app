import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_footer.dart';
import '../../../../core/widgets/tournament_phase_header.dart';
import '../../domain/entities/match_entity.dart';

/// Nombres de ronda de eliminación, en orden — igual a los que usa
/// torneo_web (bracket_view.dart) para que ambos se vean idénticos.
const kEliminationRoundOrder = [
  'Sesentaicuatroavos de final',
  'Treintaidosavos de final',
  'Dieciseisavos de final',
  'Octavos de final',
  'Cuartos de final',
  'Semifinal',
  'Final',
];

/// Cuadro de eliminatorias ("llave"): una columna por ronda, de izquierda
/// a derecha, con líneas conectando cada partido con el siguiente del que
/// sale su clasificado. El número de jugadores es variable, así que el
/// número de partidos por ronda no siempre es una potencia de dos (los
/// "bye" —número impar de clasificados— reducen en 1 el total); el layout
/// soporta cualquier combinación de conteos, no solo brackets
/// perfectamente balanceados. Las rondas que todavía no se generaron se
/// muestran como casillas vacías ("Por definir"), para que se vea la
/// llave completa desde el inicio del torneo. Mismo diseño que
/// torneo_web (bracket_view.dart), portado para que ambos coincidan.
///
/// La barra con los nombres de ronda (OCTAVOS, CUARTOS, ...) va justo
/// debajo del encabezado con el logo. Al hacer scroll, el encabezado sube
/// y desaparece como el resto del contenido, pero apenas la barra de
/// rondas llega al borde superior se queda flotando ahí (igual que un
/// encabezado de hoja de cálculo) mientras el resto sigue desplazándose
/// debajo, para que siempre se sepa en qué ronda se está mirando.
class BracketWidget extends StatefulWidget {
  final List<MatchEntity> matches;
  final String tournamentName;

  const BracketWidget({
    super.key,
    required this.matches,
    required this.tournamentName,
  });

  static const double _boxHeight = 30;
  static const double _boxGap = 6;
  static const double _slotHeight = 100;
  static const double _colWidth = 190;
  static const double _colGap = 48;
  static const double _labelBarPaddingTop = 10;
  static const double _labelBarHeight = 32 + _labelBarPaddingTop;

  @override
  State<BracketWidget> createState() => _BracketWidgetState();
}

class _BracketWidgetState extends State<BracketWidget> {
  // Único controlador: la barra de títulos no tiene su propio scroll, se
  // dibuja corrida por -offset (ver [_RoundLabelsBar]) leyendo este mismo
  // controlador con un AnimatedBuilder — así usa exactamente la misma
  // aritmética que el cuerpo de la llave y no puede desalinearse (nada
  // de sincronizar dos scrolls / anchos de viewport independientes).
  final _bodyController = ScrollController();

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // El partido por el 3er puesto no es parte de la progresión lineal del
    // cuadro (no alimenta a ningún partido siguiente, sale directo de los
    // dos perdedores de semifinal) — se excluye de las columnas principales.
    // Su ganador se muestra en la columna de la Final (más abajo) recién
    // cuando el partido termina, igual que el podio del campeón.
    final thirdPlaceMatch = widget.matches
        .where((m) => m.round == 'Tercer puesto')
        .cast<MatchEntity?>()
        .firstOrNull;
    final thirdPlaceWinnerMatch =
        thirdPlaceMatch != null && thirdPlaceMatch.winner != null
            ? thirdPlaceMatch
            : null;

    final byRound = <String, List<MatchEntity>>{};
    for (final m in widget.matches) {
      if (m.round == 'Tercer puesto') continue;
      byRound.putIfAbsent(m.round ?? '', () => []).add(m);
    }
    for (final list in byRound.values) {
      list.sort((a, b) => (a.matchNumber ?? 0).compareTo(b.matchNumber ?? 0));
    }

    // El campeón se destaca con un podio propio (logo del club de fondo)
    // junto a la columna Final, además del resaltado normal que ya recibe
    // como ganador dentro de esa caja — solo aparece cuando la Final
    // existe y ya se jugó.
    final finalMatches = byRound['Final'];
    MatchEntity? championMatch;
    if (finalMatches != null && finalMatches.isNotEmpty) {
      final f = finalMatches.first;
      if (f.winner != null) championMatch = f;
    }

    final presentRounds =
        kEliminationRoundOrder.where(byRound.containsKey).toList();
    if (presentRounds.isEmpty) {
      return const Center(child: Text('Sin encuentros generados'));
    }
    final startIndex = kEliminationRoundOrder.indexOf(presentRounds.first);
    final roundNames = kEliminationRoundOrder.sublist(startIndex);

    // Rondas reales + rondas futuras (todavía no generadas) como
    // casillas vacías, para completar la forma de la llave.
    final rounds = <List<MatchEntity?>>[];
    List<MatchEntity?>? previous;
    for (final name in roundNames) {
      if (byRound.containsKey(name)) {
        final list = byRound[name]!;
        rounds.add(list);
        previous = list;
      } else {
        final prevCount = previous?.length ?? 1;
        final count = (prevCount / 2).ceil().clamp(1, prevCount);
        rounds.add(List<MatchEntity?>.filled(count, null));
        previous = rounds.last;
      }
    }

    final multiRound = rounds.length > 1;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: TournamentPhaseHeader(
              tournamentName: widget.tournamentName,
              phaseLabel: 'Fase eliminatoria',
            ),
          ),
        ),
        if (multiRound)
          SliverPersistentHeader(
            pinned: true,
            delegate: _RoundLabelsHeaderDelegate(
              bodyController: _bodyController,
              rounds: rounds,
              roundNames: roundNames,
            ),
          )
        else
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: !multiRound
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: BracketWidget._boxHeight * 2 +
                              BracketWidget._boxGap,
                          child: _MatchPair(match: rounds.first.first),
                        ),
                        if (championMatch != null) ...[
                          const SizedBox(width: 24),
                          _ChampionPodium(match: championMatch),
                        ],
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    controller: _bodyController,
                    scrollDirection: Axis.horizontal,
                    child: _BracketCanvasBody(
                      rounds: rounds,
                      championMatch: championMatch,
                      thirdPlaceMatch: thirdPlaceWinnerMatch,
                    ),
                  ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const _Legend(),
                const SizedBox(height: 20),
                const BrandFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Envuelve [_RoundLabelsBar] como encabezado fijo ("pinned") de un
/// [CustomScrollView]: altura constante, se queda flotando en el borde
/// superior en cuanto el scroll lo alcanza.
class _RoundLabelsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _RoundLabelsHeaderDelegate({
    required this.bodyController,
    required this.rounds,
    required this.roundNames,
  });

  final ScrollController bodyController;
  final List<List<MatchEntity?>> rounds;
  final List<String> roundNames;

  @override
  double get minExtent => BracketWidget._labelBarHeight;

  @override
  double get maxExtent => BracketWidget._labelBarHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _RoundLabelsBar(
      bodyController: bodyController,
      rounds: rounds,
      roundNames: roundNames,
    );
  }

  @override
  bool shouldRebuild(covariant _RoundLabelsHeaderDelegate oldDelegate) =>
      oldDelegate.rounds != rounds || oldDelegate.roundNames != roundNames;
}

/// Contenido de la barra con los nombres de ronda (OCTAVOS DE FINAL,
/// CUARTOS, ...), alineada por columna con el cuadro de abajo. En vez de
/// tener su propio scroll horizontal (que podría desalinearse del cuerpo
/// si sus anchos de viewport no coinciden pixel a pixel), simplemente se
/// dibuja corrida por `-offset` leyendo en vivo el mismo
/// [ScrollController] que usa el cuerpo — la misma aritmética, así que
/// siempre coincide exactamente con las columnas de abajo.
class _RoundLabelsBar extends StatelessWidget {
  const _RoundLabelsBar({
    required this.bodyController,
    required this.rounds,
    required this.roundNames,
  });

  final ScrollController bodyController;
  final List<List<MatchEntity?>> rounds;
  final List<String> roundNames;

  @override
  Widget build(BuildContext context) {
    const colWidth = BracketWidget._colWidth;
    const colGap = BracketWidget._colGap;
    final finalCol = rounds.length - 1;
    final width = rounds.length * colWidth + finalCol * colGap;
    double colX(int col) => col * (colWidth + colGap);

    return Container(
      height: BracketWidget._labelBarHeight,
      width: double.infinity,
      color: AppColors.surface,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: bodyController,
          builder: (context, _) {
            final offset =
                bodyController.hasClients ? bodyController.offset : 0.0;
            // 20 = mismo padding izquierdo que envuelve al cuerpo de la
            // llave (SliverPadding más abajo), para que el origen de
            // coordenadas (offset 0) quede en el mismo x en pantalla.
            return Transform.translate(
              offset: Offset(20 - offset, 0),
              // OverflowBox libera el ancho real del contenido (`width`,
              // el ancho de TODAS las rondas) de la restricción del
              // Container de afuera (que solo mide el ancho de la
              // pantalla) — si no, el Stack quedaba comprimido al ancho
              // de pantalla y las rondas fuera de ese rango (Cuartos,
              // Semifinal, Final) no se llegaban a dibujar.
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: width,
                maxWidth: width,
                minHeight: BracketWidget._labelBarHeight,
                maxHeight: BracketWidget._labelBarHeight,
                child: Stack(
                  children: [
                    for (var r = 0; r < rounds.length; r++)
                      _roundLabel(context, roundNames[r], colX(r), colWidth,
                          isFinal: r == finalCol),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _roundLabel(BuildContext context, String name, double x, double w,
      {bool isFinal = false}) {
    return Positioned(
      left: x,
      top: BracketWidget._labelBarPaddingTop,
      width: w,
      child: Text(
        name.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isFinal ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Dibuja el cuerpo de la llave como columnas por ronda (una por debajo
/// de otra, de izquierda a derecha), en vez de dos mitades espejadas. Con
/// jugadores variables, el número de partidos por ronda no siempre es una
/// potencia de dos (cada bye reduce en 1 el número de "clasificados" de
/// esa ronda), así que no siempre es posible partir la llave en dos
/// mitades simétricas que converjan en el centro. Este layout es correcto
/// para cualquier combinación de conteos por ronda: cada partido de la
/// ronda r se conecta con el/los partido(s) de la ronda r-1 de los que
/// salen sus dos participantes (o uno solo, si ese participante ya venía
/// de un bye). Los nombres de ronda van aparte, en [_RoundLabelsBar].
class _BracketCanvasBody extends StatelessWidget {
  const _BracketCanvasBody({
    required this.rounds,
    this.championMatch,
    this.thirdPlaceMatch,
  });

  final List<List<MatchEntity?>> rounds;
  final MatchEntity? championMatch;

  /// Ganador del partido por el 3er puesto (ya decidido) — se muestra en
  /// la misma columna que la Final, debajo de esa caja.
  final MatchEntity? thirdPlaceMatch;

  @override
  Widget build(BuildContext context) {
    const boxHeight = BracketWidget._boxHeight;
    const boxGap = BracketWidget._boxGap;
    const slotHeight = BracketWidget._slotHeight;
    const colWidth = BracketWidget._colWidth;
    const colGap = BracketWidget._colGap;
    final matchHeight = boxHeight * 2 + boxGap;

    final hasThirdPlace = thirdPlaceMatch != null;
    // Borde inferior de la llave principal (todas las filas de la primera
    // ronda) — la Final queda centrada ahí en medio, no al fondo, así que
    // la fila del 3er puesto se ubica respecto a ESTE borde y no respecto
    // a la Final, o se solaparía con la última fila del cuadro apenas
    // hubiera más de una ronda antes de semifinales.
    final gridBottom = rounds.first.length * slotHeight;
    // Espacio extra abajo para la caja del 3er puesto, que cuelga debajo
    // de toda la llave — no reemplaza ninguna fila existente, así que hay
    // que darle su propio lugar.
    final height = gridBottom + (hasThirdPlace ? matchHeight + 40 : 0);
    final finalCol = rounds.length - 1;
    // Columna extra para el podio del campeón, junto a la Final — solo se
    // reserva espacio cuando hay campeón para mostrar.
    final hasChampion = championMatch != null;
    final width = rounds.length * colWidth +
        finalCol * colGap +
        (hasChampion ? colWidth + colGap : 0);

    double colX(int col) => col * (colWidth + colGap);

    // Posición vertical de cada partido: la primera ronda se reparte de
    // forma pareja; cada ronda siguiente ubica su partido k en el punto
    // medio de los partidos 2k y 2k+1 de la ronda anterior (o alineado
    // con el único partido 2k si 2k+1 no existe, es decir, si ese cupo
    // llegó por bye).
    final yPositions = <List<double>>[
      List<double>.generate(rounds.first.length, (i) => (i + 0.5) * slotHeight),
    ];
    for (var r = 1; r < rounds.length; r++) {
      final prevY = yPositions[r - 1];
      final prevCount = rounds[r - 1].length;
      yPositions.add(List<double>.generate(rounds[r].length, (k) {
        final c0 = 2 * k;
        final c1 = 2 * k + 1;
        return c1 < prevCount ? (prevY[c0] + prevY[c1]) / 2 : prevY[c0];
      }));
    }

    final boxes = <Widget>[];
    final linePaths = <Path>[];
    final dots = <_Dot>[];
    final lineColor = AppColors.grey600;

    for (var r = 0; r < rounds.length; r++) {
      final round = rounds[r];
      final joinX = colX(r) + colWidth;
      for (var i = 0; i < round.length; i++) {
        final y = yPositions[r][i];
        boxes.add(Positioned(
          left: colX(r),
          top: y - matchHeight / 2,
          width: colWidth,
          height: matchHeight,
          child: _MatchPair(match: round[i]),
        ));
        // Unión visual entre los dos equipos del mismo partido.
        linePaths.add(Path()
          ..moveTo(joinX, y - matchHeight / 2 + boxHeight / 2)
          ..lineTo(joinX, y + matchHeight / 2 - boxHeight / 2));
        dots.add(_Dot(Offset(joinX, y), round[i]?.isFinished ?? false));
      }
    }

    for (var r = 1; r < rounds.length; r++) {
      final prevCount = rounds[r - 1].length;
      final childX = colX(r - 1) + colWidth;
      final parentX = colX(r);
      final midX = (childX + parentX) / 2;
      for (var k = 0; k < rounds[r].length; k++) {
        final c0 = 2 * k;
        final c1 = 2 * k + 1;
        final yP = yPositions[r][k];
        if (c1 < prevCount) {
          final y1 = yPositions[r - 1][c0];
          final y2 = yPositions[r - 1][c1];
          linePaths.add(Path()
            ..moveTo(childX, y1)
            ..lineTo(midX, y1)
            ..moveTo(childX, y2)
            ..lineTo(midX, y2)
            ..moveTo(midX, y1)
            ..lineTo(midX, y2)
            ..moveTo(midX, yP)
            ..lineTo(parentX, yP));
        } else {
          // El cupo llegó directo (bye en la ronda anterior): una sola
          // línea recta, sin unión en "V".
          linePaths.add(Path()
            ..moveTo(childX, yP)
            ..lineTo(parentX, yP));
        }
        dots.add(_Dot(Offset(parentX, yP), rounds[r][k]?.isFinished ?? false));
      }
    }

    // Fila del 3er puesto, debajo del cuadro principal — la caja de
    // partido con los dos perdedores de semifinal, conectada solo con la
    // caja del ganador (en la columna de la Final). Sin línea hacia las
    // semifinales: en cuadros grandes esa línea cruzaba por encima de
    // rondas intermedias enteras y se veía como un cable suelto.
    double? thirdPlaceRowY;
    if (hasThirdPlace && finalCol >= 1) {
      final semifinalCol = finalCol - 1;
      final semifinalY = yPositions[semifinalCol];
      if (semifinalY.length == 2) {
        thirdPlaceRowY = gridBottom + 40 + matchHeight / 2;
        final pairJoinX = colX(semifinalCol) + colWidth;

        // Caja de partido → caja del ganador, en la columna de la Final.
        linePaths.add(Path()
          ..moveTo(pairJoinX, thirdPlaceRowY)
          ..lineTo(colX(finalCol), thirdPlaceRowY));
        dots.add(_Dot(Offset(colX(finalCol), thirdPlaceRowY), true));
      }
    }

    // Línea que conecta la Final con el podio del campeón, igual que el
    // resto de las rondas se conectan entre sí.
    if (hasChampion) {
      final finalY = yPositions.last[0];
      final finalRightX = colX(finalCol) + colWidth;
      final podiumLeftX = colX(finalCol) + colWidth + colGap;
      linePaths.add(Path()
        ..moveTo(finalRightX, finalY)
        ..lineTo(podiumLeftX, finalY));
      dots.add(_Dot(Offset(podiumLeftX, finalY), true));
    }

    final emblemSize = (height * 0.5).clamp(100.0, 220.0);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // El emblema decorativo de fondo solo va sobre la Final mientras
          // el torneo sigue en curso — en cuanto hay campeón, el logo vive
          // únicamente en su podio (más abajo), no repetido en los dos
          // lugares a la vez.
          if (!hasChampion)
            Positioned(
              left: colX(finalCol) + colWidth / 2 - emblemSize / 2,
              top: height / 2 - emblemSize / 2,
              width: emblemSize,
              height: emblemSize,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  AppColors.isDark
                      ? 'assets/images/logo_positivo.png'
                      : 'assets/images/logo_negativo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          if (hasChampion)
            Positioned(
              left: colX(finalCol) + colWidth + colGap,
              top: yPositions.last[0] - _ChampionPodium.height / 2,
              width: colWidth,
              child: _ChampionPodium(match: championMatch!),
            ),
          if (thirdPlaceRowY != null) ...[
            Positioned(
              left: colX(finalCol - 1),
              top: thirdPlaceRowY - matchHeight / 2 - 26,
              width: colWidth * 2 + colGap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.military_tech_outlined,
                      size: 14, color: AppColors.bronze),
                  const SizedBox(width: 6),
                  Text(
                    '3ER PUESTO',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.bronze,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: colX(finalCol - 1),
              top: thirdPlaceRowY - matchHeight / 2,
              width: colWidth,
              height: matchHeight,
              child: _MatchPair(match: thirdPlaceMatch),
            ),
            Positioned(
              left: colX(finalCol),
              top: thirdPlaceRowY - boxHeight / 2,
              width: colWidth,
              child: _TeamBox(
                name: thirdPlaceMatch!.winner == thirdPlaceMatch!.homePlayerId
                    ? thirdPlaceMatch!.homePlayerName
                    : thirdPlaceMatch!.awayPlayerName,
                score:
                    thirdPlaceMatch!.winner == thirdPlaceMatch!.homePlayerId
                        ? thirdPlaceMatch!.homeScore
                        : thirdPlaceMatch!.awayScore,
                isWinner: true,
                isFinished: true,
              ),
            ),
          ],
          Positioned(
            left: 0,
            top: 0,
            width: width,
            height: height,
            child: CustomPaint(
              painter: _ConnectorPainter(linePaths, lineColor, dots),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: width,
            height: height,
            child: Stack(children: boxes),
          ),
        ],
      ),
    );
  }
}

class _Dot {
  const _Dot(this.position, this.determined);

  final Offset position;
  final bool determined;
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter(this.paths, this.color, this.dots);

  final List<Path> paths;
  final Color color;
  final List<_Dot> dots;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final path in paths) {
      canvas.drawPath(path, linePaint);
    }

    final filledDot = Paint()..color = AppColors.primary;
    final hollowDot = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final dot in dots) {
      if (dot.determined) {
        canvas.drawCircle(dot.position, 3.5, filledDot);
      } else {
        canvas.drawCircle(dot.position, 3, hollowDot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) =>
      oldDelegate.paths != paths ||
      oldDelegate.color != color ||
      oldDelegate.dots != dots;
}

/// Los dos equipos de un mismo partido, como casillas separadas (igual
/// que en el diseño de referencia del club).
class _MatchPair extends StatelessWidget {
  const _MatchPair({required this.match});

  final MatchEntity? match;

  bool get _homeWon =>
      match != null &&
      match!.homeScore != null &&
      match!.awayScore != null &&
      match!.homeScore! > match!.awayScore!;

  bool get _awayWon =>
      match != null &&
      match!.homeScore != null &&
      match!.awayScore != null &&
      match!.awayScore! > match!.homeScore!;

  bool get _isBye => match?.isBye ?? false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TeamBox(
          name: match?.homePlayerName,
          score: match?.homeScore,
          isWinner: _homeWon,
          isFinished: match?.isFinished ?? false,
        ),
        const SizedBox(height: BracketWidget._boxGap),
        _TeamBox(
          name: match?.awayPlayerName,
          score: match?.awayScore,
          isWinner: _awayWon,
          isFinished: match?.isFinished ?? false,
          isBye: _isBye,
        ),
      ],
    );
  }
}

class _TeamBox extends StatelessWidget {
  const _TeamBox({
    required this.name,
    required this.score,
    required this.isWinner,
    required this.isFinished,
    this.isBye = false,
  });

  final String? name;
  final int? score;
  final bool isWinner;
  final bool isFinished;
  final bool isBye;

  @override
  Widget build(BuildContext context) {
    if (name == null) {
      return Container(
        height: BracketWidget._boxHeight,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text('Por definir',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.textMuted)),
      );
    }

    // El jugador avanzó automáticamente (número impar de clasificados):
    // se muestra el hueco "BYE" atenuado, sin ícono ni marcador, en vez
    // de un rival y un resultado 0 que no existieron.
    if (isBye) {
      return Container(
        height: BracketWidget._boxHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          'BYE — avanza directo',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: AppColors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Container(
      height: BracketWidget._boxHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isWinner
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isWinner ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.emoji_events, size: 12, color: AppColors.gold),
            )
          else
            const Icon(Icons.shield_outlined,
                size: 12, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
                color: isWinner ? AppColors.accent : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            score != null ? '$score' : (isFinished ? '' : '-'),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isWinner ? AppColors.accent : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Podio del campeón: junto a la columna Final, la misma caja de ganador
/// que ya se usa en el cuadro (`_TeamBox`) superpuesta sobre el logo
/// completo del club — que ya trae escudo, copa y el texto "MIKIDO
/// TORNEOS" en una sola imagen, así que no hace falta redibujar nada de
/// eso a mano.
class _ChampionPodium extends StatelessWidget {
  const _ChampionPodium({required this.match});

  final MatchEntity match;

  static const double height = 260;
  static const double _width = BracketWidget._colWidth;
  static const double _logoWidth = 170;
  // Alto real de logo_negativo.png a este ancho (proporción 2339x3413).
  static const double _logoHeight = _logoWidth * 3413 / 2339;
  // La caja del ganador y el logo completo se centran en el mismo punto
  // vertical (la mitad de [height]) — ese mismo punto es adonde llega la
  // línea que conecta con la Final (ver _BracketCanvasBody), así que la
  // caja queda "enganchada" a esa línea en vez de flotar aparte.
  static const double _logoTopOffset = height / 2 - _logoHeight / 2;
  static const double _boxTopOffset =
      height / 2 - (BracketWidget._boxHeight / 2);

  @override
  Widget build(BuildContext context) {
    final homeWon = match.homeScore != null &&
        match.awayScore != null &&
        match.homeScore! > match.awayScore!;
    final name = homeWon ? match.homePlayerName : match.awayPlayerName;
    final score = homeWon ? match.homeScore : match.awayScore;

    return SizedBox(
      width: _width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: _logoTopOffset,
            left: (_width - _logoWidth) / 2,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                AppColors.isDark
                    ? 'assets/images/logo_positivo.png'
                    : 'assets/images/logo_negativo.png',
                width: _logoWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: _boxTopOffset,
            left: 0,
            right: 0,
            child: _TeamBox(
              name: name,
              score: score,
              isWinner: true,
              isFinished: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _LegendItem(
            dot: const Icon(Icons.circle, size: 10, color: AppColors.primary),
            label: 'Clasificado',
          ),
          _LegendItem(
            dot: Container(width: 16, height: 2, color: AppColors.grey600),
            label: 'En disputa',
          ),
          _LegendItem(
            dot:
                Icon(Icons.circle_outlined, size: 10, color: AppColors.grey600),
            label: 'Pendiente',
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.dot, required this.label});

  final Widget dot;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textMuted)),
      ],
    );
  }
}
