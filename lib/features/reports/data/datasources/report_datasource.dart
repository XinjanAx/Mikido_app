import 'dart:typed_data';
import '../../../../core/utils/pdf_utils.dart';
import '../../../../core/utils/excel_utils.dart';
import '../../domain/entities/report_params.dart';

abstract class ReportDataSource {
  Future<Uint8List> generatePdf(ReportParams params);
  Uint8List generateExcel(ReportParams params);
  Future<void> sharePdf(Uint8List bytes, String fileName);
}

class ReportDataSourceImpl implements ReportDataSource {
  const ReportDataSourceImpl();

  @override
  Future<Uint8List> generatePdf(ReportParams params) =>
      PdfUtils.generateTournamentReport(
        tournamentName: params.tournamentName,
        category: params.category,
        standings: params.standings,
        matches: params.matches,
      );

  @override
  Uint8List generateExcel(ReportParams params) =>
      ExcelUtils.generateTournamentExcel(
        tournamentName: params.tournamentName,
        standings: params.standings,
        matches: params.matches,
      );

  @override
  Future<void> sharePdf(Uint8List bytes, String fileName) =>
      PdfUtils.sharePdf(bytes, fileName);
}
