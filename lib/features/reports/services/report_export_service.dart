import 'report_export_service_stub.dart'
    if (dart.library.io) 'report_export_service_io.dart'
    if (dart.library.html) 'report_export_service_web.dart';
import 'report_export_types.dart';

ReportExportService createReportExportService({DateTime Function()? now}) {
  return createPlatformReportExportService(now: now);
}
