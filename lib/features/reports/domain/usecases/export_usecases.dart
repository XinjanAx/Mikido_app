import 'dart:typed_data';
import '../../../reports/data/datasources/report_datasource.dart';
import '../entities/report_params.dart';

class ExportPdfUseCase {
  final ReportDataSource _dataSource;
  const ExportPdfUseCase(this._dataSource);

  Future<Uint8List> call(ReportParams params) =>
      _dataSource.generatePdf(params);
}

class ExportExcelUseCase {
  final ReportDataSource _dataSource;
  const ExportExcelUseCase(this._dataSource);

  Uint8List call(ReportParams params) => _dataSource.generateExcel(params);
}
