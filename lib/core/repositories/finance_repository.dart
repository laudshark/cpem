import '../models/contract.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/user_credentials.dart';

abstract class FinanceRepository {
  Future<List<ContractRecord>> fetchContracts();

  Future<List<ExpenseRecord>> fetchExpenses();

  Future<List<IncomeRecord>> fetchIncome();

  Future<UserCredentials> fetchUserCredentials();

  Future<void> addContract(ContractRecord contract);

  Future<void> addExpense(ExpenseRecord expense);

  Future<void> addIncome(IncomeRecord income);

  Future<void> saveUserCredentials(UserCredentials credentials);
}
