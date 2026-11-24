import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../constants/app_constants.dart';
import '../theme/category_colors.dart';

class PdfUtils {
  PdfUtils._();

  /// Rojo institucional del Club MIKIDO (muestreado del logo oficial:
  /// assets/images/club_mikido.png), usado en encabezado, pie de página y
  /// cabeceras de tabla para que el reporte se vea consistente con la marca.
  static const _brandRed = PdfColor.fromInt(0xFFE30321);
  static const _brandRedLight = PdfColor.fromInt(0xFFFBE3E6);

  /// Orden canónico de rondas de eliminación simple. Duplica
  /// EliminationBracketService.roundOrder en vez de importarla: pdf_utils
  /// es una utilidad de `core/` que solo recibe `Map<String, dynamic>`
  /// genéricos y no debe depender de una feature concreta.
  static const _eliminationRoundOrder = [
    'Sesentaicuatroavos de final',
    'Treintaidosavos de final',
    'Dieciseisavos de final',
    'Octavos de final',
    'Cuartos de final',
    'Semifinal',
    'Final',
  ];

  static pw.MemoryImage? _logoCache;

  static Future<pw.MemoryImage> _loadLogo() async {
    if (_logoCache != null) return _logoCache!;
    final data = await rootBundle.load('assets/images/club_mikido.png');
    _logoCache = pw.MemoryImage(data.buffer.asUint8List());
    return _logoCache!;
  }

  static Future<Uint8List> generateTournamentReport({
    required String tournamentName,
    required String category,
    required String mode,
    required List<Map<String, dynamic>> standings,
    required List<Map<String, dynamic>> matches,
    Map<String, List<Map<String, dynamic>>>? groupedStandings,
    String? categoryColorHex,
    String? mesaName,
  }) async {
    // Código de color de la categoría (el mismo de la app).
    final categoryColor = CategoryColors.parse(categoryColorHex);
    final categoryPdfColor =
        categoryColor == null ? null : PdfColor.fromInt(categoryColor.toARGB32());
    final categoryColorName = CategoryColors.palette
        .where((c) => c.hex == categoryColorHex?.toUpperCase())
        .map((c) => c.name)
        .firstOrNull;
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();
    final logo = await _loadLogo();
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final isElimination = mode == AppConstants.tournamentModeElimination;
    final isGroups = mode == AppConstants.tournamentModeGroups;
    final matchesByRound = _groupByRound(matches, mode);
    final bracketDiagram = isElimination
        ? _buildBracketDiagram(matchesByRound, font, boldFont)
        : null;
    // Con una sola "ronda" y sin nombre real (partidos sin `round`), mostrar
    // el nombre de grupo genérico sería redundante con el título de sección.
    final showRoundHeadings =
        matchesByRound.length > 1 || !matchesByRound.containsKey(_noRoundKey);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 24, 32, 24),
        header: (context) => _buildHeader(logo, font, boldFont),
        footer: (context) => _buildFooter(context, font, generatedAt),
        build: (pw.Context context) => [
          // Título, con el código de color de la categoría (franja a la
          // izquierda + etiqueta con el nombre del color + línea debajo).
          _buildTitleBlock(
            title: tournamentName,
            // `category` trae la modalidad (ej. "Eliminación simple").
            subtitle: [
              'Modalidad: $category',
              if (mesaName != null && mesaName.isNotEmpty) 'Mesa: $mesaName',
            ].join('   ·   '),
            color: categoryPdfColor,
            colorName: categoryColorName,
            font: font,
            boldFont: boldFont,
          ),
          pw.SizedBox(height: 20),

          // Llave visual del bracket: solo eliminación simple, y solo con
          // las rondas ya generadas (misma fuente que las tablas de abajo).
          if (bracketDiagram != null) bracketDiagram,

          // Tabla de posiciones global: solo tiene sentido en liga (un único
          // grupo, todos contra todos). En eliminación cada jugador juega
          // pocos partidos antes de quedar afuera — un ranking por
          // PJ/PG/PP/Pts no es representativo. En grupos, mezclar a todos
          // los jugadores en una sola tabla ignora que solo compiten dentro
          // de su propio grupo — cada grupo tiene su tabla más abajo, junto
          // a sus resultados.
          if (!isElimination && !isGroups && standings.isNotEmpty) ...[
            _buildSectionTitle('Tabla de Posiciones', boldFont),
            pw.SizedBox(height: 8),
            _buildStandingsTable(standings, font, boldFont),
            pw.SizedBox(height: 24),
          ],

          // Resultados de partidos, agrupados por ronda/grupo para que se
          // vean todos los combates y no una lista plana sin distinguir
          // de qué ronda es cada uno.
          if (matchesByRound.isNotEmpty) ...[
            _buildSectionTitle('Resultados', boldFont),
            pw.SizedBox(height: 8),
            for (final entry in matchesByRound.entries) ...[
              if (showRoundHeadings) ...[
                pw.Text(
                  entry.key,
                  style: pw.TextStyle(font: boldFont, fontSize: 11, color: _brandRed),
                ),
                pw.SizedBox(height: 4),
              ],
              _buildMatchesTable(entry.value, font, boldFont),
              if (isGroups) ...[
                pw.SizedBox(height: 6),
                _buildStandingsTable(
                  groupedStandings?[entry.key] ??
                      _computeGroupStandings(entry.value),
                  font,
                  boldFont,
                ),
              ],
              pw.SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static const _noRoundKey = 'Resultados';

  /// Agrupa los partidos por `round` y ordena las claves según la
  /// modalidad: orden canónico fijo en eliminación (no alfabético — "Final"
  /// no va antes que "Semifinal"), y orden natural (numérico) en el resto,
  /// para que "Jornada 2" no quede después de "Jornada 10".
  static Map<String, List<Map<String, dynamic>>> _groupByRound(
    List<Map<String, dynamic>> matches,
    String mode,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final m in matches) {
      final round = (m['round'] as String?)?.trim();
      final key = (round == null || round.isEmpty) ? _noRoundKey : round;
      grouped.putIfAbsent(key, () => []).add(m);
    }

    final keys = grouped.keys.toList();
    if (mode == AppConstants.tournamentModeElimination) {
      keys.sort((a, b) {
        final ia = _eliminationRoundOrder.indexOf(a);
        final ib = _eliminationRoundOrder.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });
    } else {
      keys.sort(_naturalCompare);
    }

    return {for (final k in keys) k: grouped[k]!};
  }

  /// Compara extrayendo los números como enteros ("Jornada 2" < "Jornada
  /// 10") en vez de letra por letra ("Jornada 10" < "Jornada 2" si se
  /// comparara como texto plano).
  static int _naturalCompare(String a, String b) {
    final numA = RegExp(r'\d+')
        .allMatches(a)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    final numB = RegExp(r'\d+')
        .allMatches(b)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    for (var i = 0; i < numA.length && i < numB.length; i++) {
      final cmp = numA[i].compareTo(numB[i]);
      if (cmp != 0) return cmp;
    }
    if (numA.length != numB.length) return numA.length.compareTo(numB.length);
    return a.compareTo(b);
  }

  /// Respaldo si no se pasó `groupedStandings` (la tabla real, ya
  /// calculada y ordenada por la app): recalcula la posición de un grupo
  /// solo con sus partidos finalizados, mismo criterio de puntos (3/1/0)
  /// que StandingsCalculator. No conoce el desempate manual del admin —
  /// por eso se prefiere siempre `groupedStandings` cuando existe.
  static List<Map<String, dynamic>> _computeGroupStandings(
    List<Map<String, dynamic>> groupMatches,
  ) {
    final stats = <String, _GroupPlayerStat>{};
    _GroupPlayerStat statFor(String name) =>
        stats.putIfAbsent(name, () => _GroupPlayerStat(name));

    for (final m in groupMatches) {
      if (m['status'] != AppConstants.matchStatusFinished) continue;
      final home = m['home'] as String? ?? '';
      final away = m['away'] as String? ?? '';
      if (home.isEmpty || away.isEmpty || home == away) continue;
      final homeScore = (m['home_score'] as int?) ?? 0;
      final awayScore = (m['away_score'] as int?) ?? 0;

      final h = statFor(home);
      final a = statFor(away);
      h.played++;
      a.played++;
      h.goalsFor += homeScore;
      h.goalsAgainst += awayScore;
      a.goalsFor += awayScore;
      a.goalsAgainst += homeScore;

      if (homeScore > awayScore) {
        h.won++;
        h.points += AppConstants.pointsForWin;
        a.lost++;
        a.points += AppConstants.pointsForLoss;
      } else if (awayScore > homeScore) {
        a.won++;
        a.points += AppConstants.pointsForWin;
        h.lost++;
        h.points += AppConstants.pointsForLoss;
      } else {
        h.points += AppConstants.pointsForDraw;
        a.points += AppConstants.pointsForDraw;
      }
    }

    // Mismo criterio de desempate que la tabla real de la app
    // (AppDatabase.getStandingsByTournament/watchStandings): puntos,
    // luego diferencia de gol. El desempate manual del admin no aplica
    // acá — esta tabla se recalcula desde cero a partir de los partidos,
    // no lee la fila de standings donde vive ese ajuste manual.
    final list = stats.values.toList()
      ..sort((x, y) {
        final byPoints = y.points.compareTo(x.points);
        if (byPoints != 0) return byPoints;
        final xDiff = x.goalsFor - x.goalsAgainst;
        final yDiff = y.goalsFor - y.goalsAgainst;
        return yDiff.compareTo(xDiff);
      });
    return list
        .map((s) => {
              'player_name': s.name,
              'played': s.played,
              'won': s.won,
              'lost': s.lost,
              'points': s.points,
              'goals_for': s.goalsFor,
              'goals_against': s.goalsAgainst,
            })
        .toList();
  }

  static pw.Widget _buildHeader(
      pw.MemoryImage logo, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      margin: const pw.EdgeInsets.only(bottom: 14),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _brandRed, width: 1.6)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(width: 46, height: 48, child: pw.Image(logo, fit: pw.BoxFit.contain)),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('CLUB MIKIDO',
                    style: pw.TextStyle(font: boldFont, fontSize: 15, color: _brandRed)),
                pw.Text('Reporte de Torneo',
                    style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font, String generatedAt) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      margin: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _brandRed, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Club MIKIDO · Generado el $generatedAt',
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600)),
          pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _buildTitleBlock({
    required String title,
    required String subtitle,
    required PdfColor? color,
    required String? colorName,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    final texts = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 18)),
        pw.Text(subtitle,
            style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),
      ],
    );
    if (color == null) return texts; // categoría sin color: como antes

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: color, width: 2.5)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(width: 7, height: 40, color: color),
          pw.SizedBox(width: 10),
          pw.Expanded(child: texts),
          if (colorName != null)
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                'Color: $colorName',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 10,
                  // Texto oscuro sobre colores claros (amarillo, celeste).
                  color: color.luminance > 0.5
                      ? PdfColors.black
                      : PdfColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font boldFont) {
    return pw.Row(
      children: [
        pw.Container(width: 4, height: 14, color: _brandRed),
        pw.SizedBox(width: 6),
        pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 13)),
      ],
    );
  }

  static pw.Widget _buildStandingsTable(
    List<Map<String, dynamic>> standings,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final headers = ['#', 'Participante', 'PJ', 'PG', 'PP', 'DG', 'Pts'];
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: standings.asMap().entries.map((e) {
        final s = e.value;
        final goalsFor = s['goals_for'] as int? ?? 0;
        final goalsAgainst = s['goals_against'] as int? ?? 0;
        final dg = goalsFor - goalsAgainst;
        return [
          '${e.key + 1}',
          s['player_name'] ?? '',
          '${s['played'] ?? 0}',
          '${s['won'] ?? 0}',
          '${s['lost'] ?? 0}',
          dg > 0 ? '+$dg' : '$dg',
          '${s['points'] ?? 0}',
        ];
      }).toList(),
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      cellAlignments: const {
        0: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
      },
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
      headerDecoration: const pw.BoxDecoration(color: _brandRed),
      oddRowDecoration: const pw.BoxDecoration(color: _brandRedLight),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    );
  }

  static pw.Widget _buildMatchesTable(
    List<Map<String, dynamic>> matches,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final headers = ['Local', 'Resultado', 'Visitante'];
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: matches.map((m) {
        return [
          m['home'] ?? '',
          '${m['home_score'] ?? '-'} - ${m['away_score'] ?? '-'}',
          m['away'] ?? '',
        ];
      }).toList(),
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      cellAlignments: const {1: pw.Alignment.center},
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
      headerDecoration: const pw.BoxDecoration(color: _brandRed),
      oddRowDecoration: const pw.BoxDecoration(color: _brandRedLight),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    );
  }

  /// Diagrama visual de la llave completa (árbol de eliminación simple),
  /// como el BracketWidget de la app: una columna por ronda, cajas
  /// conectadas con líneas. Las rondas ya generadas en la base muestran los
  /// contendientes reales; las fases futuras que aún no se generaron (por
  /// no haberse completado la ronda anterior) se dibujan igual, pero con
  /// cajas vacías — la cantidad de cupos de cada fase futura se proyecta
  /// desde el número de partidos de la última ronda generada, reduciendo a
  /// la mitad (redondeando hacia arriba, igual que
  /// EliminationBracketService.generateNextRound) hasta llegar a la Final.
  /// Devuelve `null` si el torneo todavía no tiene ningún partido de
  /// eliminación generado.
  static pw.Widget? _buildBracketDiagram(
    Map<String, List<Map<String, dynamic>>> matchesByRound,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final generatedRoundNames = _eliminationRoundOrder
        .where((r) =>
            matchesByRound.containsKey(r) && matchesByRound[r]!.isNotEmpty)
        .toList();
    if (generatedRoundNames.isEmpty) return null;

    final roundNames = List<String>.from(generatedRoundNames);
    final rounds = <List<Map<String, dynamic>?>>[
      for (final r in generatedRoundNames)
        List<Map<String, dynamic>?>.from(matchesByRound[r]!),
    ];

    // Proyecta las fases futuras (sin generar aún) hasta la Final.
    final lastGeneratedIdx =
        _eliminationRoundOrder.indexOf(generatedRoundNames.last);
    if (lastGeneratedIdx != -1 &&
        lastGeneratedIdx < _eliminationRoundOrder.length - 1) {
      var count = rounds.last.length;
      for (var idx = lastGeneratedIdx + 1;
          idx < _eliminationRoundOrder.length;
          idx++) {
        count = (count / 2).ceil();
        roundNames.add(_eliminationRoundOrder[idx]);
        rounds.add(List<Map<String, dynamic>?>.filled(count, null));
        if (count <= 1) break; // ya llegó a la Final
      }
    }

    const colWidth = 118.0;
    const colGap = 30.0;
    const boxHeight = 32.0;
    const slotHeight = 44.0;
    const headerHeight = 20.0;
    const maxDiagramWidth = 530.0;

    final gridHeight = rounds.first.length * slotHeight;
    final totalWidth =
        rounds.length * colWidth + (rounds.length - 1) * colGap;
    var totalHeight = headerHeight + gridHeight;

    // Posición vertical (desde arriba) de cada caja: la 1ª ronda se reparte
    // en franjas iguales, y cada ronda siguiente se centra entre el par de
    // cajas que la originan — mismo cálculo que BracketWidget.
    final yPositions = <List<double>>[
      List<double>.generate(
          rounds.first.length, (i) => headerHeight + (i + 0.5) * slotHeight),
    ];
    for (var r = 1; r < rounds.length; r++) {
      final prevY = yPositions[r - 1];
      yPositions.add(List<double>.generate(rounds[r].length, (k) {
        final c0 = k * 2;
        final c1 = c0 + 1 < prevY.length ? c0 + 1 : c0;
        return (prevY[c0] + prevY[c1]) / 2;
      }));
    }

    double colX(int c) => c * (colWidth + colGap);

    // Partido por el 3er puesto: debajo de la Final, igual que en la app.
    // Si ya se generó, con sus contendientes; si no, una caja vacía para
    // llenar a mano — solo cuando va a existir, es decir, cuando las
    // semifinales no tienen BYE (con 3 competidores no hay 3er puesto).
    final finalCol = roundNames.indexOf('Final');
    final semiCol = roundNames.indexOf('Semifinal');
    final thirdMatches = matchesByRound['Tercer puesto'];
    final thirdMatch = (thirdMatches == null || thirdMatches.isEmpty)
        ? null
        : thirdMatches.first;
    var showThird = false;
    if (finalCol != -1 && semiCol != -1) {
      final semis = rounds[semiCol];
      if (thirdMatch != null) {
        showThird = true;
      } else if (semis.every((m) => m != null)) {
        // Semifinales ya generadas: hay 3er puesto si ninguna es BYE.
        showThird = semis.length == 2 &&
            semis.every((m) => m!['is_bye'] != true);
      } else {
        // Semifinales proyectadas: habrá BYE si la ronda anterior deja un
        // número impar de clasificados (uno por partido).
        final prevCount = semiCol > 0 ? rounds[semiCol - 1].length : 4;
        showThird = semis.length == 2 && prevCount.isEven;
      }
    }
    const thirdLabelHeight = 12.0;
    double? thirdLabelTop;
    if (showThird) {
      thirdLabelTop = yPositions[finalCol][0] + boxHeight / 2 + 14;
      final bottom = thirdLabelTop + thirdLabelHeight + boxHeight + 4;
      if (bottom > totalHeight) totalHeight = bottom;
    }

    final children = <pw.Widget>[];

    if (rounds.length > 1) {
      children.add(pw.Positioned(
        left: 0,
        top: 0,
        child: pw.CustomPaint(
          size: PdfPoint(totalWidth, totalHeight),
          painter: (canvas, size) {
            canvas
              ..setStrokeColor(PdfColors.grey500)
              ..setLineWidth(0.8);
            for (var r = 1; r < rounds.length; r++) {
              final prevY = yPositions[r - 1];
              final joinX = colX(r - 1) + colWidth;
              final parentX = colX(r);
              final midX = joinX + colGap / 2;
              for (var k = 0; k < rounds[r].length; k++) {
                final c0 = k * 2;
                final c1 = c0 + 1 < prevY.length ? c0 + 1 : c0;
                // El canvas de CustomPaint usa origen inferior-izquierdo
                // (convención PDF), mientras que yPositions está medido
                // desde arriba — de ahí el `size.y - y`.
                final y1 = size.y - prevY[c0];
                final y2 = size.y - prevY[c1];
                final yP = size.y - yPositions[r][k];
                canvas
                  ..moveTo(joinX, y1)
                  ..lineTo(midX, y1)
                  ..strokePath();
                if (c1 != c0) {
                  canvas
                    ..moveTo(joinX, y2)
                    ..lineTo(midX, y2)
                    ..strokePath();
                  canvas
                    ..moveTo(midX, y1)
                    ..lineTo(midX, y2)
                    ..strokePath();
                }
                canvas
                  ..moveTo(midX, yP)
                  ..lineTo(parentX, yP)
                  ..strokePath();
              }
            }
          },
        ),
      ));
    }

    for (var r = 0; r < roundNames.length; r++) {
      children.add(pw.Positioned(
        left: colX(r),
        top: 0,
        child: pw.SizedBox(
          width: colWidth,
          height: headerHeight,
          child: pw.Center(
            child: pw.Text(
              roundNames[r],
              textAlign: pw.TextAlign.center,
              style:
                  pw.TextStyle(font: boldFont, fontSize: 7.5, color: _brandRed),
            ),
          ),
        ),
      ));
    }

    for (var r = 0; r < rounds.length; r++) {
      for (var i = 0; i < rounds[r].length; i++) {
        final m = rounds[r][i];
        children.add(pw.Positioned(
          left: colX(r),
          top: yPositions[r][i] - boxHeight / 2,
          child: m == null
              ? _bracketPlaceholderBox(colWidth, boxHeight)
              : _bracketMatchBox(m, colWidth, boxHeight, font, boldFont),
        ));
      }
    }

    if (showThird && thirdLabelTop != null) {
      children.add(pw.Positioned(
        left: colX(finalCol),
        top: thirdLabelTop,
        child: pw.SizedBox(
          width: colWidth,
          height: thirdLabelHeight,
          child: pw.Center(
            child: pw.Text(
              'Tercer puesto',
              style:
                  pw.TextStyle(font: boldFont, fontSize: 7.5, color: _brandRed),
            ),
          ),
        ),
      ));
      children.add(pw.Positioned(
        left: colX(finalCol),
        top: thirdLabelTop + thirdLabelHeight,
        child: thirdMatch == null
            ? _bracketPlaceholderBox(colWidth, boxHeight)
            : _bracketMatchBox(thirdMatch, colWidth, boxHeight, font, boldFont),
      ));
    }

    final diagram = pw.SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: pw.Stack(children: children),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Llave del Torneo', boldFont),
        pw.SizedBox(height: 10),
        totalWidth > maxDiagramWidth
            ? pw.SizedBox(
                width: maxDiagramWidth,
                height: totalHeight * (maxDiagramWidth / totalWidth),
                child: pw.FittedBox(
                  fit: pw.BoxFit.contain,
                  alignment: pw.Alignment.topLeft,
                  child: diagram,
                ),
              )
            : diagram,
        pw.SizedBox(height: 24),
      ],
    );
  }

  /// Caja de un partido dentro de la llave: local arriba, visitante abajo,
  /// separador fino, marcador a la derecha de cada nombre y el ganador
  /// resaltado en rojo institucional (mismo criterio visual que las cajas
  /// de BracketWidget en la app).
  static pw.Widget _bracketMatchBox(
    Map<String, dynamic> m,
    double width,
    double height,
    pw.Font font,
    pw.Font boldFont,
  ) {
    // Nombre sin gremio: las cajas del cuadro son angostas.
    final home = (m['home_name'] as String?) ?? (m['home'] as String?) ?? '';
    final away = (m['away_name'] as String?) ?? (m['away'] as String?) ?? '';
    final isFinished = m['status'] == AppConstants.matchStatusFinished;
    final homeScore = m['home_score'] as int?;
    final awayScore = m['away_score'] as int?;
    final homeWins = isFinished &&
        homeScore != null &&
        awayScore != null &&
        homeScore > awayScore;
    final awayWins = isFinished &&
        homeScore != null &&
        awayScore != null &&
        awayScore > homeScore;

    // Acrónimo del gremio: va al lado del nombre, en letra normal, y queda
    // siempre visible (si el nombre no cabe, se recorta el nombre).
    final homeAcronym = m['home_acronym'] as String?;
    final awayAcronym = m['away_acronym'] as String?;

    pw.Widget row(String name, String? acronym, int? score, bool isWinner) {
      final color = isWinner ? _brandRed : PdfColors.black;
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Row(
                children: [
                  pw.Flexible(
                    child: pw.Text(
                      name.isEmpty ? '-' : name,
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                      style: pw.TextStyle(
                        font: isWinner ? boldFont : font,
                        fontSize: 7,
                        color: color,
                      ),
                    ),
                  ),
                  if (acronym != null && acronym.isNotEmpty) ...[
                    pw.SizedBox(width: 3),
                    pw.Text(
                      acronym,
                      maxLines: 1,
                      style:
                          pw.TextStyle(font: font, fontSize: 7, color: color),
                    ),
                  ],
                  pw.SizedBox(width: 3),
                ],
              ),
            ),
            pw.Text(
              score?.toString() ?? '-',
              style: pw.TextStyle(
                font: isWinner ? boldFont : font,
                fontSize: 7,
                color: isWinner ? _brandRed : PdfColors.black,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      width: width,
      height: height,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.6),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        color: PdfColors.white,
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          row(home, homeAcronym, homeScore, homeWins),
          pw.Container(height: 0.6, color: PdfColors.grey300),
          row(away, awayAcronym, awayScore, awayWins),
        ],
      ),
    );
  }

  /// Caja vacía para una fase futura aún no generada — mismo tamaño y
  /// estilo que una caja real (borde sólido, fondo blanco), pero sin texto
  /// dentro: se deja en blanco a propósito para que se pueda completar a
  /// mano con esfero una vez impreso el reporte.
  static pw.Widget _bracketPlaceholderBox(double width, double height) {
    return pw.Container(
      width: width,
      height: height,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.6),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        color: PdfColors.white,
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(child: pw.SizedBox()),
          pw.Container(height: 0.6, color: PdfColors.grey300),
          pw.Expanded(child: pw.SizedBox()),
        ],
      ),
    );
  }

  /// Guarda el PDF en el dispositivo. Devuelve `true` si quedó guardado y
  /// `false` si el usuario canceló el diálogo.
  ///
  /// - Windows: abre el diálogo nativo "Guardar como" (comdlg32) y escribe
  ///   los bytes en la ruta elegida.
  /// - Android: abre el selector del sistema (Storage Access Framework) vía
  ///   `ACTION_CREATE_DOCUMENT`, que entrega los bytes directamente al
  ///   documento creado — el usuario elige la carpeta (por defecto
  ///   Descargas), sin permisos de almacenamiento adicionales.
  /// - Otras plataformas: se mantiene el flujo de compartir como respaldo.
  static Future<bool> savePdf(Uint8List bytes, String fileName) async {
    final safeName = _sanitizeFileName(fileName);

    if (Platform.isAndroid) {
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar reporte PDF',
        fileName: '$safeName.pdf',
        bytes: bytes,
      );
      return savedPath != null;
    }

    if (Platform.isWindows) {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar reporte PDF',
        fileName: '$safeName.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (path == null) return false;
      await File(path).writeAsBytes(bytes);
      return true;
    }

    return Printing.sharePdf(bytes: bytes, filename: '$safeName.pdf');
  }

  static String _sanitizeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
    return cleaned.isEmpty ? 'reporte_torneo' : cleaned;
  }
}

class _GroupPlayerStat {
  final String name;
  int played = 0;
  int won = 0;
  int lost = 0;
  int points = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  _GroupPlayerStat(this.name);
}
