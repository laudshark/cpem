import '../models/contract.dart';
import '../models/expense.dart';
import '../models/income.dart';

abstract class FinanceRepository {
  Future<List<ContractRecord>> fetchContracts();

  Future<List<ExpenseRecord>> fetchExpenses();

  Future<List<IncomeRecord>> fetchIncome();
}
