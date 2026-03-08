import '../../../core/state/app_state.dart';

class ReportExportResult {
  const ReportExportResult({
    required this.fileName,
    required this.destinationLabel,
  });

  final String fileName;
  final String destinationLabel;
}

abstract class ReportExportService {
  Future<ReportExportResult> exportCsv(AppState appState);

  Future<ReportExportResult> exportPdf(AppState appState);
}
