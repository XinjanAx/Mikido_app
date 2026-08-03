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

class ReportState {
  final bool isGeneratingPdf;
  final String? errorMessage;
  final String? successMessage;

  const ReportState({
    this.isGeneratingPdf = false,
    this.errorMessage,
    this.successMessage,
  });

  ReportState copyWith({
    bool? isGeneratingPdf,
    String? errorMessage,
    String? successMessage,
  }) =>
      ReportState(
        isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
        errorMessage: errorMessage,
        successMessage: successMessage,
      );
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ExportPdfUseCase _exportPdf;
  final ReportDataSource _dataSource;

  ReportNotifier({
    required ExportPdfUseCase exportPdf,
    required ReportDataSource dataSource,
  })  : _exportPdf = exportPdf,
        _dataSource = dataSource,
        super(const ReportState());

  Future<void> exportPdf(ReportParams params) async {
    state = state.copyWith(isGeneratingPdf: true);
    try {
      final bytes = await _exportPdf(params);
      final saved = await _dataSource.savePdf(bytes, params.tournamentName);
      // Si el usuario canceló el diálogo de guardado no mostramos ni éxito
      // ni error — simplemente no pasó nada.
      state = state.copyWith(
        isGeneratingPdf: false,
        successMessage: saved ? 'PDF guardado exitosamente' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingPdf: false,
        errorMessage: 'Error al generar PDF: $e',
      );
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>(
  (ref) => ReportNotifier(
    exportPdf: ref.watch(exportPdfUseCaseProvider),
    dataSource: ref.watch(reportDataSourceProvider),
  ),
);
