// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

import '../../../core/state/app_state.dart';
import 'report_export_document_builder.dart';
import 'report_export_types.dart';

ReportExportService createPlatformReportExportService({
  DateTime Function()? now,
}) {
  return _WebReportExportService(now: now);
}

class _WebReportExportService implements ReportExportService {
  _WebReportExportService({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  @override
  Future<ReportExportResult> exportCsv(AppState appState) async {
    final generatedAt = _now();
    final fileName = buildReportFileName('csv', generatedAt);
    final csvData = buildReportCsv(appState, generatedAt);

    _download(
      bytes: utf8.encode(csvData),
      fileName: fileName,
      mimeType: 'text/csv;charset=utf-8',
    );

    return ReportExportResult(
      fileName: fileName,
      destinationLabel: 'your browser downloads',
    );
  }

  @override
  Future<ReportExportResult> exportPdf(AppState appState) async {
    final generatedAt = _now();
    final fileName = buildReportFileName('pdf', generatedAt);

    _download(
      bytes: await buildReportPdf(appState, generatedAt),
      fileName: fileName,
      mimeType: 'application/pdf',
    );

    return ReportExportResult(
      fileName: fileName,
      destinationLabel: 'your browser downloads',
    );
  }

  void _download({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
