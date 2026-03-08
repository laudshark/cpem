class SyncStatus {
  const SyncStatus({
    required this.isOnline,
    required this.isSyncing,
    required this.localStorageEnabled,
    required this.autoSyncEnabled,
    required this.pendingChanges,
    this.lastSyncedAt,
  });

  final bool isOnline;
  final bool isSyncing;
  final bool localStorageEnabled;
  final bool autoSyncEnabled;
  final int pendingChanges;
  final DateTime? lastSyncedAt;

  bool get isOffline => !isOnline;

  bool get hasPendingChanges => pendingChanges > 0;
}
