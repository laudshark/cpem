import 'package:cpem/core/repositories/in_memory_finance_repository.dart';
import 'package:cpem/core/state/app_state.dart';
import 'package:cpem/features/reports/services/report_export_document_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppState appState;
  final generatedAt = DateTime(2026, 3, 8, 10, 30);

  setUp(() async {
    appState = AppState(
      repository: InMemoryFinanceRepository(),
      now: () => generatedAt,
    );
    await appState.load();
  });

  test('csv export contains summary, contract, and ledger sections', () {
    final csv = buildReportCsv(appState, generatedAt);

    expect(csv, contains('CPEM Financial Report'));
    expect(csv, contains('Business summary'));
    expect(csv, contains('Municipal Road Rehabilitation'));
    expect(csv, contains('Category spending'));
    expect(csv, contains('Payments received'));
    expect(csv, contains('Payment follow-up'));
    expect(csv, contains('Asset Disposal'));
  });

  test('pdf export produces a non-empty document', () async {
    final pdfBytes = await buildReportPdf(appState, generatedAt);

    expect(pdfBytes.length, greaterThan(1000));
  });
}
