class AppPreferences {
  const AppPreferences({
    required this.autoSyncEnabled,
    required this.budgetAlertsEnabled,
    required this.weeklySummaryEnabled,
    required this.overduePaymentsEnabled,
    required this.contractRiskAlertsEnabled,
  });

  const AppPreferences.defaults()
      : autoSyncEnabled = true,
        budgetAlertsEnabled = true,
        weeklySummaryEnabled = true,
        overduePaymentsEnabled = true,
        contractRiskAlertsEnabled = true;

  final bool autoSyncEnabled;
  final bool budgetAlertsEnabled;
  final bool weeklySummaryEnabled;
  final bool overduePaymentsEnabled;
  final bool contractRiskAlertsEnabled;

  int get enabledNotificationCount {
    return [
      budgetAlertsEnabled,
      weeklySummaryEnabled,
      overduePaymentsEnabled,
      contractRiskAlertsEnabled,
    ].where((item) => item).length;
  }

  Map<String, Object?> toJson() {
    return {
      'autoSyncEnabled': autoSyncEnabled,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'weeklySummaryEnabled': weeklySummaryEnabled,
      'overduePaymentsEnabled': overduePaymentsEnabled,
      'contractRiskAlertsEnabled': contractRiskAlertsEnabled,
    };
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? true,
      budgetAlertsEnabled: json['budgetAlertsEnabled'] as bool? ?? true,
      weeklySummaryEnabled: json['weeklySummaryEnabled'] as bool? ?? true,
      overduePaymentsEnabled: json['overduePaymentsEnabled'] as bool? ?? true,
      contractRiskAlertsEnabled:
          json['contractRiskAlertsEnabled'] as bool? ?? true,
    );
  }
}
