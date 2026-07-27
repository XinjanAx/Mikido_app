import 'dart:typed_data';
import 'package:excel/excel.dart';

class ExcelUtils {
  ExcelUtils._();

  static Uint8List generateTournamentExcel({
    required String tournamentName,
    required List<Map<String, dynamic>> standings,
    required List<Map<String, dynamic>> matches,
  }) {
    final excel = Excel.createExcel();

    // Hoja de posiciones
    final standingsSheet = excel['Posiciones'];
    excel.setDefaultSheet('Posiciones');

    // Encabezados posiciones
    final standingHeaders = ['#', 'Participante', 'PJ', 'PG', 'PP', 'GF', 'GC', 'Pts'];
    for (var i = 0; i < standingHeaders.length; i++) {
      standingsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(standingHeaders[i])
        ..cellStyle = CellStyle(bold: true);
    }

    // Datos posiciones
    for (var i = 0; i < standings.length; i++) {
      final s = standings[i];
      final row = i + 1;
      final values = [
        IntCellValue(row),
        TextCellValue(s['player_name'] ?? ''),
        IntCellValue(s['played'] ?? 0),
        IntCellValue(s['won'] ?? 0),
        IntCellValue(s['lost'] ?? 0),
        IntCellValue(s['goals_for'] ?? 0),
        IntCellValue(s['goals_against'] ?? 0),
        IntCellValue(s['points'] ?? 0),
      ];
      for (var j = 0; j < values.length; j++) {
        standingsSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
          .value = values[j];
      }
    }

    // Hoja de partidos
    final matchesSheet = excel['Partidos'];
    final matchHeaders = ['Fecha', 'Local', 'Goles Local', 'Goles Visitante', 'Visitante', 'Estado'];
    for (var i = 0; i < matchHeaders.length; i++) {
      matchesSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(matchHeaders[i])
        ..cellStyle = CellStyle(bold: true);
    }

    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      final row = i + 1;
      final values = [
        TextCellValue(m['date'] ?? ''),
        TextCellValue(m['home'] ?? ''),
        IntCellValue(m['home_score'] ?? 0),
        IntCellValue(m['away_score'] ?? 0),
        TextCellValue(m['away'] ?? ''),
        TextCellValue(m['status'] ?? ''),
      ];
      for (var j = 0; j < values.length; j++) {
        matchesSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
          .value = values[j];
      }
    }

    final encoded = excel.encode();
    return Uint8List.fromList(encoded!);
  }
}
