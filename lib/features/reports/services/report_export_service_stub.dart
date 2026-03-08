import '../../../core/state/app_state.dart';
import 'report_export_types.dart';

ReportExportService createPlatformReportExportService({
  DateTime Function()? now,
}) {
  return _UnsupportedReportExportService();
}

class _UnsupportedReportExportService implements ReportExportService {
  @override
  Future<ReportExportResult> exportCsv(AppState appState) {
    throw UnsupportedError('CSV export is not supported on this platform.');
  }

  @override
  Future<ReportExportResult> exportPdf(AppState appState) {
    throw UnsupportedError('PDF export is not supported on this platform.');
  }
}
