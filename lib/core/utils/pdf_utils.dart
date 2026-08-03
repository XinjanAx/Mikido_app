import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfUtils {
  PdfUtils._();

  /// Rojo institucional del Club MIKIDO (muestreado del logo oficial:
  /// assets/images/club_mikido.png), usado en encabezado, pie de página y
  /// cabeceras de tabla para que el reporte se vea consistente con la marca.
  static const _brandRed = PdfColor.fromInt(0xFFE30321);
  static const _brandRedLight = PdfColor.fromInt(0xFFFBE3E6);

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
    required List<Map<String, dynamic>> standings,
    required List<Map<String, dynamic>> matches,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();
    final logo = await _loadLogo();
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

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

          // Tabla de posiciones
          if (standings.isNotEmpty) ...[
            _buildSectionTitle('Tabla de Posiciones', boldFont),
            pw.SizedBox(height: 8),
            _buildStandingsTable(standings, font, boldFont),
            pw.SizedBox(height: 24),
          ],

          // Resultados de partidos
          if (matches.isNotEmpty) ...[
            _buildSectionTitle('Resultados', boldFont),
            pw.SizedBox(height: 8),
            _buildMatchesTable(matches, font, boldFont),
          ],
        ],
      ),
    );

    return pdf.save();
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
