import 'package:flutter/foundation.dart';

import '../models/contract.dart';
import '../models/expense.dart';
import '../models/financial_summary.dart';
import '../models/income.dart';
import '../repositories/finance_repository.dart';

class AppState extends ChangeNotifier {
  AppState({required FinanceRepository repository}) : _repository = repository;

  final FinanceRepository _repository;

  bool _isLoading = true;
  List<ContractRecord> _contracts = const [];
  List<ExpenseRecord> _expenses = const [];
  List<IncomeRecord> _income = const [];

  bool get isLoading => _isLoading;

  List<ContractRecord> get contracts => _contracts;

  List<ExpenseRecord> get expenses => _expenses;

  List<IncomeRecord> get income => _income;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final contracts = await _repository.fetchContracts();
    final expenses = await _repository.fetchExpenses();
    final income = await _repository.fetchIncome();

    _contracts = contracts;
    _expenses = expenses;
    _income = income;
    _isLoading = false;
    notifyListeners();
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

    return FinancialSummary(revenue: contractIncome, expenses: contractExpenses);
  }

  int get activeContractsCount =>
      _contracts.where((item) => item.status == ContractStatus.active).length;

  double get generalExpenseTotal => _expenses
      .where((entry) => entry.contractId == null)
      .fold<double>(0, (sum, item) => sum + item.amount);

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

    final allKeys = {...monthlyRevenue.keys, ...monthlyExpenses.keys}.toList()..sort();
    return {
      for (final key in allKeys)
        key: FinancialSummary(
          revenue: monthlyRevenue[key] ?? 0,
          expenses: monthlyExpenses[key] ?? 0,
        ),
    };
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

  String _monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }
}
