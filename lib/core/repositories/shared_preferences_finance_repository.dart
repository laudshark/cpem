import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/contract.dart';
import '../models/expense.dart';
import '../models/income.dart';
import 'finance_repository.dart';
import 'in_memory_finance_repository.dart';

class SharedPreferencesFinanceRepository implements FinanceRepository {
  SharedPreferencesFinanceRepository._(this._preferences);

  static const _contractsKey = 'cpem.contracts';
  static const _expensesKey = 'cpem.expenses';
  static const _incomeKey = 'cpem.income';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesFinanceRepository> create({
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final repository = SharedPreferencesFinanceRepository._(prefs);
    await repository._seedDefaultsIfNeeded();
    return repository;
  }

  @override
  Future<List<ContractRecord>> fetchContracts() async => _readContracts();

  @override
  Future<List<ExpenseRecord>> fetchExpenses() async => _readExpenses();

  @override
  Future<List<IncomeRecord>> fetchIncome() async => _readIncome();

  @override
  Future<void> addContract(ContractRecord contract) async {
    final contracts = _readContracts()..add(contract);
    await _preferences.setString(_contractsKey, _encodeContracts(contracts));
  }

  @override
  Future<void> addExpense(ExpenseRecord expense) async {
    final expenses = _readExpenses()..add(expense);
    await _preferences.setString(_expensesKey, _encodeExpenses(expenses));
  }

  Future<void> _seedDefaultsIfNeeded() async {
    final defaults = InMemoryFinanceRepository();

    if (!_preferences.containsKey(_contractsKey)) {
      await _preferences.setString(
        _contractsKey,
        _encodeContracts(await defaults.fetchContracts()),
      );
    }

    if (!_preferences.containsKey(_expensesKey)) {
      await _preferences.setString(
        _expensesKey,
        _encodeExpenses(await defaults.fetchExpenses()),
      );
    }

    if (!_preferences.containsKey(_incomeKey)) {
      await _preferences.setString(
        _incomeKey,
        _encodeIncome(await defaults.fetchIncome()),
      );
    }
  }

  List<ContractRecord> _readContracts() {
    final raw = _preferences.getString(_contractsKey);
    if (raw == null || raw.isEmpty) {
      return <ContractRecord>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ContractRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<ExpenseRecord> _readExpenses() {
    final raw = _preferences.getString(_expensesKey);
    if (raw == null || raw.isEmpty) {
      return <ExpenseRecord>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ExpenseRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<IncomeRecord> _readIncome() {
    final raw = _preferences.getString(_incomeKey);
    if (raw == null || raw.isEmpty) {
      return <IncomeRecord>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => IncomeRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _encodeContracts(List<ContractRecord> contracts) {
    return jsonEncode(contracts.map((item) => item.toJson()).toList());
  }

  String _encodeExpenses(List<ExpenseRecord> expenses) {
    return jsonEncode(expenses.map((item) => item.toJson()).toList());
  }

  String _encodeIncome(List<IncomeRecord> income) {
    return jsonEncode(income.map((item) => item.toJson()).toList());
  }
}
