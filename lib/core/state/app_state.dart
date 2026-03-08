import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../models/contract.dart';
import '../models/expense.dart';
import '../models/financial_summary.dart';
import '../models/income.dart';
import '../models/sync_status.dart';
import '../repositories/finance_repository.dart';
import '../utils/formatters.dart';

class AppState extends ChangeNotifier {
  AppState({
    required FinanceRepository repository,
    DateTime Function()? now,
  })  : _repository = repository,
        _now = now ?? DateTime.now;

  final FinanceRepository _repository;
  final DateTime Function() _now;

  bool _isLoading = true;
  bool _isOnline = true;
  bool _isSyncing = false;
  int _pendingSyncEntries = 0;
  DateTime? _lastSyncedAt;
  List<ContractRecord> _contracts = const [];
  List<ExpenseRecord> _expenses = const [];
  List<IncomeRecord> _income = const [];

  bool get isLoading => _isLoading;

  bool get isOnline => _isOnline;

  bool get isSyncing => _isSyncing;

  List<ContractRecord> get contracts => _contracts;

  List<ExpenseRecord> get expenses => _expenses;

  List<IncomeRecord> get income => _income;

  SyncStatus get syncStatus => SyncStatus(
        isOnline: _isOnline,
        isSyncing: _isSyncing,
        localStorageEnabled: true,
        autoSyncEnabled: true,
        pendingChanges: _pendingSyncEntries,
        lastSyncedAt: _lastSyncedAt,
      );

  DateTime get today => _startOfDay(_now());

  DateTime get weekStart => _startOfDay(
        today.subtract(Duration(days: today.weekday - DateTime.monday)),
      );

  DateTime get monthStart => DateTime(today.year, today.month);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final contracts = await _repository.fetchContracts();
    final expenses = await _repository.fetchExpenses();
    final income = await _repository.fetchIncome();

    _contracts = contracts;
    _expenses = expenses;
    _income = income;
    _lastSyncedAt = _now();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setConnectivity(bool isOnline) async {
    if (_isOnline == isOnline) {
      return;
    }

    _isOnline = isOnline;
    if (!isOnline && _pendingSyncEntries == 0) {
      _pendingSyncEntries = 2;
    }
    notifyListeners();

    if (isOnline) {
      await syncPendingChanges();
    }
  }

  Future<void> syncPendingChanges() async {
    if (!_isOnline || _isSyncing) {
      return;
    }

    _isSyncing = true;
    notifyListeners();

    _pendingSyncEntries = 0;
    _lastSyncedAt = _now();
    _isSyncing = false;
    notifyListeners();
  }

  Future<void> addContract({
    required String title,
    required String clientName,
    required double contractValue,
    required double budgetAmount,
    required DateTime startDate,
    DateTime? endDate,
    ContractStatus status = ContractStatus.active,
    String? description,
  }) async {
    final contract = ContractRecord(
      id: _generateId('ct'),
      title: title,
      clientName: clientName,
      contractValue: contractValue,
      budgetAmount: budgetAmount,
      startDate: _startOfDay(startDate),
      endDate: endDate == null ? null : _startOfDay(endDate),
      status: status,
      description: _normalizeOptionalText(description),
    );

    await _repository.addContract(contract);
    _contracts = [..._contracts, contract];
    _recordLocalChange();
  }

  Future<void> addExpense({
    String? contractId,
    required ExpenseCategory category,
    required double amount,
    required DateTime date,
    required PaymentMethod paymentMethod,
    required String vendor,
    required String description,
    String? receiptReference,
  }) async {
    final expense = ExpenseRecord(
      id: _generateId('ex'),
      contractId: contractId,
      category: category,
      amount: amount,
      date: _startOfDay(date),
      paymentMethod: paymentMethod,
      vendor: vendor,
      description: description,
      receiptReference: _normalizeOptionalText(receiptReference),
    );

    await _repository.addExpense(expense);
    _expenses = [..._expenses, expense];
    _recordLocalChange();
  }

  FinancialSummary get businessSummary {
    return FinancialSummary(
      revenue: _income.fold<double>(0, (sum, item) => sum + item.amount),
      expenses: _expenses.fold<double>(0, (sum, item) => sum + item.amount),
    );
  }

  FinancialSummary summaryForContract(String contractId) {
    final contractIncome = _income
        .where((entry) => entry.contractId == contractId)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final contractExpenses = _expenses
        .where((entry) => entry.contractId == contractId)
        .fold<double>(0, (sum, item) => sum + item.amount);

    return FinancialSummary(
        revenue: contractIncome, expenses: contractExpenses);
  }

  FinancialSummary summaryForRange(
      DateTime startInclusive, DateTime endExclusive) {
    final revenue = _income
        .where((entry) => _isInRange(entry.date, startInclusive, endExclusive))
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expenses = _expenses
        .where((entry) => _isInRange(entry.date, startInclusive, endExclusive))
        .fold<double>(0, (sum, item) => sum + item.amount);

    return FinancialSummary(revenue: revenue, expenses: expenses);
  }

  int get activeContractsCount =>
      _contracts.where((item) => item.status == ContractStatus.active).length;

  double get todaysExpenses => _expenseTotalForRange(today, _nextDay(today));

  double get weeklySpending =>
      _expenseTotalForRange(weekStart, _nextDay(today));

  double get monthlySpending =>
      _expenseTotalForRange(monthStart, _nextDay(today));

  FinancialSummary get currentWeekSummary =>
      summaryForRange(weekStart, _nextDay(today));

  double get generalExpenseTotal => _expenses
      .where((entry) => entry.contractId == null)
      .fold<double>(0, (sum, item) => sum + item.amount);

  List<ExpenseRecord> get overdueSupplierExpenses => _expenses.where((entry) {
        return !entry.isSettled &&
            entry.dueDate != null &&
            _startOfDay(entry.dueDate!).isBefore(today);
      }).toList();

  List<ContractRecord> get budgetExceededContracts {
    return _contracts.where((contract) {
      return contract.status == ContractStatus.active &&
          contractExpenseTotal(contract.id) > contract.budgetAmount;
    }).toList();
  }

  List<ContractRecord> get contractsNearingLoss {
    return _contracts.where((contract) {
      if (contract.status != ContractStatus.active) {
        return false;
      }

      final margin = projectedMarginForContract(contract.id);
      return margin >= 0 && margin <= 12;
    }).toList();
  }

  List<AppNotification> get notifications {
    final items = <AppNotification>[];

    if (budgetExceededContracts.isNotEmpty) {
      final overrunTotal =
          budgetExceededContracts.fold<double>(0, (sum, contract) {
        return sum +
            (contractExpenseTotal(contract.id) - contract.budgetAmount);
      });
      final subject = budgetExceededContracts.length == 1
          ? budgetExceededContracts.first.title
          : '${budgetExceededContracts.length} active contracts';

      items.add(
        AppNotification(
          type: AppNotificationType.budgetExceeded,
          severity: AppNotificationSeverity.critical,
          title: 'Budget exceeded alert',
          message:
              '$subject has exceeded budget by ${formatMoney(overrunTotal)}.',
        ),
      );
    }

    if (contractsNearingLoss.isNotEmpty) {
      final contract = contractsNearingLoss.first;
      items.add(
        AppNotification(
          type: AppNotificationType.contractNearingLoss,
          severity: AppNotificationSeverity.warning,
          title: 'Contract nearing loss',
          message:
              '${contract.title} is operating at a projected margin of ${formatPercent(projectedMarginForContract(contract.id))}.',
        ),
      );
    }

    if (overdueSupplierExpenses.isNotEmpty) {
      final overdueTotal = overdueSupplierExpenses.fold<double>(
        0,
        (sum, entry) => sum + entry.amount,
      );
      items.add(
        AppNotification(
          type: AppNotificationType.overdueSupplierPayment,
          severity: AppNotificationSeverity.warning,
          title: 'Overdue supplier payments',
          message:
              '${overdueSupplierExpenses.length} supplier payments are overdue totalling ${formatMoney(overdueTotal)}.',
        ),
      );
    }

    final weeklySummary = currentWeekSummary;
    items.add(
      AppNotification(
        type: AppNotificationType.weeklySummary,
        severity: AppNotificationSeverity.info,
        title: 'Weekly financial summary',
        message:
            'Revenue ${formatMoney(weeklySummary.revenue)}, expenses ${formatMoney(weeklySummary.expenses)}, net ${formatMoney(weeklySummary.profit)}.',
      ),
    );

    return items;
  }

  List<ExpenseRecord> get recentExpenses {
    final items = [..._expenses];
    items.sort((a, b) => b.date.compareTo(a.date));
    return items.take(5).toList();
  }

  Map<ExpenseCategory, double> get expenseCategoryTotals {
    final totals = <ExpenseCategory, double>{};

    for (final entry in _expenses) {
      totals.update(
        entry.category,
        (value) => value + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }

    return totals;
  }

  Map<String, FinancialSummary> get monthlySummaries {
    final monthlyRevenue = <String, double>{};
    final monthlyExpenses = <String, double>{};

    for (final entry in _income) {
      final key = _monthKey(entry.date);
      monthlyRevenue.update(
        key,
        (value) => value + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }

    for (final entry in _expenses) {
      final key = _monthKey(entry.date);
      monthlyExpenses.update(
        key,
        (value) => value + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }

    final allKeys = {...monthlyRevenue.keys, ...monthlyExpenses.keys}.toList()
      ..sort();
    return {
      for (final key in allKeys)
        key: FinancialSummary(
          revenue: monthlyRevenue[key] ?? 0,
          expenses: monthlyExpenses[key] ?? 0,
        ),
    };
  }

  double contractExpenseTotal(String contractId) {
    return _expenses
        .where((entry) => entry.contractId == contractId)
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double projectedProfitForContract(String contractId) {
    final contract = _contractById(contractId);
    return contract == null
        ? 0
        : contract.contractValue - contractExpenseTotal(contractId);
  }

  double projectedMarginForContract(String contractId) {
    final contract = _contractById(contractId);
    if (contract == null || contract.contractValue == 0) {
      return 0;
    }

    return (projectedProfitForContract(contractId) / contract.contractValue) *
        100;
  }

  double budgetUtilizationForContract(String contractId) {
    final contract = _contractById(contractId);
    if (contract == null || contract.budgetAmount == 0) {
      return 0;
    }

    return (contractExpenseTotal(contractId) / contract.budgetAmount) * 100;
  }

  String contractTitle(String? contractId) {
    if (contractId == null) {
      return 'General business';
    }

    for (final contract in _contracts) {
      if (contract.id == contractId) {
        return contract.title;
      }
    }

    return 'Unknown contract';
  }

  ContractRecord? _contractById(String contractId) {
    for (final contract in _contracts) {
      if (contract.id == contractId) {
        return contract;
      }
    }

    return null;
  }

  double _expenseTotalForRange(DateTime startInclusive, DateTime endExclusive) {
    return _expenses
        .where((entry) => _isInRange(entry.date, startInclusive, endExclusive))
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  bool _isInRange(
      DateTime date, DateTime startInclusive, DateTime endExclusive) {
    return !date.isBefore(startInclusive) && date.isBefore(endExclusive);
  }

  DateTime _nextDay(DateTime date) =>
      _startOfDay(date).add(const Duration(days: 1));

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _recordLocalChange() {
    if (_isOnline) {
      _lastSyncedAt = _now();
    } else {
      _pendingSyncEntries += 1;
    }
    notifyListeners();
  }

  String _generateId(String prefix) {
    return '$prefix-${_now().microsecondsSinceEpoch}';
  }

  String? _normalizeOptionalText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String _monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }
}
