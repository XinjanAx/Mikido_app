import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfUtils {
  PdfUtils._();

  static Future<Uint8List> generateTournamentReport({
    required String tournamentName,
    required String category,
    required List<Map<String, dynamic>> standings,
    required List<Map<String, dynamic>> matches,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          // Encabezado
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Club MIKIDO',
                  style: pw.TextStyle(font: boldFont, fontSize: 20),
                ),
                pw.Text(
                  'Reporte de Torneo',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Título del torneo
          pw.Text(
            tournamentName,
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.Text(
            'Categoría: $category',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.SizedBox(height: 24),

          // Tabla de posiciones
          if (standings.isNotEmpty) ...[
            pw.Text(
              'Tabla de Posiciones',
              style: pw.TextStyle(font: boldFont, fontSize: 14),
            ),
            pw.SizedBox(height: 8),
            _buildStandingsTable(standings, font, boldFont),
            pw.SizedBox(height: 24),
          ],

          // Resultados de partidos
          if (matches.isNotEmpty) ...[
            pw.Text(
              'Resultados',
              style: pw.TextStyle(font: boldFont, fontSize: 14),
            ),
            pw.SizedBox(height: 8),
            _buildMatchesTable(matches, font, boldFont),
          ],
        ],
      ),
    );

    return pdf.save();
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
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 10),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      border: pw.TableBorder.all(width: 0.5),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
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
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 10),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      border: pw.TableBorder.all(width: 0.5),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
    );
  }

  static Future<void> sharePdf(Uint8List bytes, String fileName) async {
    await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
  }
}
