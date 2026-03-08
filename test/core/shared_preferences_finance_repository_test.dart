import 'package:cpem/core/models/contract.dart';
import 'package:cpem/core/models/expense.dart';
import 'package:cpem/core/models/income.dart';
import 'package:cpem/core/repositories/shared_preferences_finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists added contracts and expenses across repository instances',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = await SharedPreferencesFinanceRepository.create(
      preferences: preferences,
    );

    final initialContracts = await repository.fetchContracts();
    final initialExpenses = await repository.fetchExpenses();
    final initialIncome = await repository.fetchIncome();

    await repository.addContract(
      ContractRecord(
        id: 'ct-test',
        title: 'Persisted Test Contract',
        clientName: 'Test Client',
        contractValue: 15000,
        budgetAmount: 12000,
        startDate: DateTime(2026, 3, 8),
        status: ContractStatus.active,
      ),
    );

    await repository.addExpense(
      ExpenseRecord(
        id: 'ex-test',
        category: ExpenseCategory.miscellaneous,
        amount: 575,
        date: DateTime(2026, 3, 8),
        paymentMethod: PaymentMethod.cash,
        vendor: 'Test Vendor',
        description: 'Persisted expense',
      ),
    );

    await repository.addIncome(
      IncomeRecord(
        id: 'in-test',
        contractId: 'ct-test',
        type: IncomeType.contractPayment,
        amount: 2400,
        date: DateTime(2026, 3, 8),
        payer: 'Test Client',
        description: 'Persisted income',
      ),
    );

    final reloadedRepository = await SharedPreferencesFinanceRepository.create(
      preferences: await SharedPreferences.getInstance(),
    );
    final contracts = await reloadedRepository.fetchContracts();
    final expenses = await reloadedRepository.fetchExpenses();
    final income = await reloadedRepository.fetchIncome();

    expect(contracts.length, initialContracts.length + 1);
    expect(expenses.length, initialExpenses.length + 1);
    expect(income.length, initialIncome.length + 1);
    expect(contracts.any((item) => item.id == 'ct-test'), isTrue);
    expect(expenses.any((item) => item.id == 'ex-test'), isTrue);
    expect(income.any((item) => item.id == 'in-test'), isTrue);
  });
}
