import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../constants/app_constants.dart';

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
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();
    final logo = await _loadLogo();
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final isElimination = mode == AppConstants.tournamentModeElimination;
    final isGroups = mode == AppConstants.tournamentModeGroups;
    final matchesByRound = _groupByRound(matches, mode);
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
          // Título del torneo
          pw.Text(
            tournamentName,
            style: pw.TextStyle(font: boldFont, fontSize: 18),
          ),
          pw.Text(
            'Categoría: $category',
            style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

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

  /// Tabla de posiciones de un solo grupo, calculada solo con los partidos
  /// finalizados de ese grupo — mismo criterio (3/1/0 puntos) que
  /// StandingsCalculator, pero operando sobre los mapas genéricos que ya
  /// recibe esta utilidad en vez de importar la entidad de dominio.
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

    final list = stats.values.toList()
      ..sort((x, y) => y.points.compareTo(x.points));
    return list
        .map((s) => {
              'player_name': s.name,
              'played': s.played,
              'won': s.won,
              'lost': s.lost,
              'points': s.points,
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
    final headers = ['#', 'Participante', 'PJ', 'PG', 'PP', 'Pts'];
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: standings.asMap().entries.map((e) {
        final s = e.value;
        return [
          '${e.key + 1}',
          s['player_name'] ?? '',
          '${s['played'] ?? 0}',
          '${s['won'] ?? 0}',
          '${s['lost'] ?? 0}',
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
    final headers = ['Fecha', 'Local', 'Resultado', 'Visitante'];
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: matches.map((m) {
        return [
          m['date'] ?? '',
          m['home'] ?? '',
          '${m['home_score'] ?? '-'} - ${m['away_score'] ?? '-'}',
          m['away'] ?? '',
        ];
      }).toList(),
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      cellAlignments: const {2: pw.Alignment.center},
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
      headerDecoration: const pw.BoxDecoration(color: _brandRed),
      oddRowDecoration: const pw.BoxDecoration(color: _brandRedLight),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
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
  _GroupPlayerStat(this.name);
}
