import 'dart:typed_data';
import '../../../../core/utils/pdf_utils.dart';
import '../../domain/entities/report_params.dart';

abstract class ReportDataSource {
  Future<Uint8List> generatePdf(ReportParams params);

  /// Devuelve `true` si el PDF quedó guardado y `false` si el usuario
  /// canceló el diálogo de guardado.
  Future<bool> savePdf(Uint8List bytes, String fileName);
}

class ReportDataSourceImpl implements ReportDataSource {
  const ReportDataSourceImpl();

  @override
  Future<Uint8List> generatePdf(ReportParams params) =>
      PdfUtils.generateTournamentReport(
        tournamentName: params.tournamentName,
        category: params.category,
        mode: params.mode,
        standings: params.standings,
        matches: params.matches,
      );

  @override
  Future<bool> savePdf(Uint8List bytes, String fileName) =>
      PdfUtils.savePdf(bytes, fileName);
}
