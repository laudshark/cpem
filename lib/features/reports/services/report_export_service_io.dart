import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/state/app_state.dart';
import 'report_export_document_builder.dart';
import 'report_export_types.dart';

ReportExportService createPlatformReportExportService({
  DateTime Function()? now,
}) {
  return _IoReportExportService(now: now);
}

class _IoReportExportService implements ReportExportService {
  _IoReportExportService({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  @override
  Future<ReportExportResult> exportCsv(AppState appState) async {
    final generatedAt = _now();
    final fileName = buildReportFileName('csv', generatedAt);
    final exportDirectory = await _resolveExportDirectory();
    final file = File(
      '${exportDirectory.path}${Platform.pathSeparator}$fileName',
    );

    await file.writeAsString(
      buildReportCsv(appState, generatedAt),
      flush: true,
    );

    return ReportExportResult(
      fileName: fileName,
      destinationLabel: file.path,
    );
  }

  @override
  Future<ReportExportResult> exportPdf(AppState appState) async {
    final generatedAt = _now();
    final fileName = buildReportFileName('pdf', generatedAt);
    final exportDirectory = await _resolveExportDirectory();
    final file = File(
      '${exportDirectory.path}${Platform.pathSeparator}$fileName',
    );

    await file.writeAsBytes(
      await buildReportPdf(appState, generatedAt),
      flush: true,
    );

    return ReportExportResult(
      fileName: fileName,
      destinationLabel: file.path,
    );
  }

  Future<Directory> _resolveExportDirectory() async {
    final downloadsDirectory = await _tryGetDownloadsDirectory();
    final baseDirectory =
        downloadsDirectory ?? await getApplicationDocumentsDirectory();
    final exportDirectory = Directory(
      '${baseDirectory.path}${Platform.pathSeparator}cpem_exports',
    );

    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }

    return exportDirectory;
  }

  Future<Directory?> _tryGetDownloadsDirectory() async {
    try {
      return await getDownloadsDirectory();
    } catch (_) {
      return null;
    }
  }
}
