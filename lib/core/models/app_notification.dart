enum AppNotificationType {
  budgetExceeded,
  weeklySummary,
  overdueSupplierPayment,
  contractNearingLoss,
}

enum AppNotificationSeverity {
  info,
  warning,
  critical,
}

class AppNotification {
  const AppNotification({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
  });

  final AppNotificationType type;
  final AppNotificationSeverity severity;
  final String title;
  final String message;
}
