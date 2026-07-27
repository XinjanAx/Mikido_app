import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/report_datasource.dart';
import '../../domain/entities/report_params.dart';
import '../../domain/usecases/export_usecases.dart';

final reportDataSourceProvider = Provider<ReportDataSource>(
  (_) => const ReportDataSourceImpl(),
);
final exportPdfUseCaseProvider = Provider(
  (ref) => ExportPdfUseCase(ref.watch(reportDataSourceProvider)),
);
final exportExcelUseCaseProvider = Provider(
  (ref) => ExportExcelUseCase(ref.watch(reportDataSourceProvider)),
);

class ReportState {
  final bool isGeneratingPdf;
  final bool isGeneratingExcel;
  final String? errorMessage;
  final String? successMessage;

  const ReportState({
    this.isGeneratingPdf = false,
    this.isGeneratingExcel = false,
    this.errorMessage,
    this.successMessage,
  });

  ReportState copyWith({
    bool? isGeneratingPdf,
    bool? isGeneratingExcel,
    String? errorMessage,
    String? successMessage,
  }) =>
      ReportState(
        isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
        isGeneratingExcel: isGeneratingExcel ?? this.isGeneratingExcel,
        errorMessage: errorMessage,
        successMessage: successMessage,
      );
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ExportPdfUseCase _exportPdf;
  final ExportExcelUseCase _exportExcel;
  final ReportDataSource _dataSource;

  ReportNotifier({
    required ExportPdfUseCase exportPdf,
    required ExportExcelUseCase exportExcel,
    required ReportDataSource dataSource,
  })  : _exportPdf = exportPdf,
        _exportExcel = exportExcel,
        _dataSource = dataSource,
        super(const ReportState());

  Future<void> exportPdf(ReportParams params) async {
    state = state.copyWith(isGeneratingPdf: true);
    try {
      final bytes = await _exportPdf(params);
      await _dataSource.sharePdf(bytes, params.tournamentName);
      state = state.copyWith(
        isGeneratingPdf: false,
        successMessage: 'PDF generado exitosamente',
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingPdf: false,
        errorMessage: 'Error al generar PDF: $e',
      );
    }
  }

  Future<void> exportExcel(ReportParams params) async {
    state = state.copyWith(isGeneratingExcel: true);
    try {
      _exportExcel(params);
      // En implementación real usar share_plus para compartir el archivo Excel
      state = state.copyWith(
        isGeneratingExcel: false,
        successMessage: 'Excel generado exitosamente',
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingExcel: false,
        errorMessage: 'Error al generar Excel: $e',
      );
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>(
  (ref) => ReportNotifier(
    exportPdf: ref.watch(exportPdfUseCaseProvider),
    exportExcel: ref.watch(exportExcelUseCaseProvider),
    dataSource: ref.watch(reportDataSourceProvider),
  ),
);
