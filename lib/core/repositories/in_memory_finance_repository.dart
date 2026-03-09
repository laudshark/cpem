import '../models/contract.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/user_credentials.dart';
import 'finance_repository.dart';

class InMemoryFinanceRepository implements FinanceRepository {
  InMemoryFinanceRepository({
    List<ContractRecord>? contracts,
    List<ExpenseRecord>? expenses,
    List<IncomeRecord>? income,
    UserCredentials? userCredentials,
  })  : _contracts = contracts ?? _seedContracts(),
        _expenses = expenses ?? _seedExpenses(),
        _income = income ?? _seedIncome(),
        _userCredentials = userCredentials ?? const UserCredentials.empty();

  final List<ContractRecord> _contracts;
  final List<ExpenseRecord> _expenses;
  final List<IncomeRecord> _income;
  UserCredentials _userCredentials;

  @override
  Future<List<ContractRecord>> fetchContracts() async =>
      List<ContractRecord>.from(_contracts);

  @override
  Future<List<ExpenseRecord>> fetchExpenses() async =>
      List<ExpenseRecord>.from(_expenses);

  @override
  Future<List<IncomeRecord>> fetchIncome() async =>
      List<IncomeRecord>.from(_income);

  @override
  Future<UserCredentials> fetchUserCredentials() async => _userCredentials;

  @override
  Future<void> addContract(ContractRecord contract) async {
    _contracts.add(contract);
  }

  @override
  Future<void> addExpense(ExpenseRecord expense) async {
    _expenses.add(expense);
  }

  @override
  Future<void> addIncome(IncomeRecord income) async {
    _income.add(income);
  }

  @override
  Future<void> saveUserCredentials(UserCredentials credentials) async {
    _userCredentials = credentials;
  }

  static List<ContractRecord> _seedContracts() {
    return [
      ContractRecord(
        id: 'ct-001',
        title: 'Municipal Road Rehabilitation',
        clientName: 'Accra Metro Works',
        contractValue: 240000,
        budgetAmount: 68000,
        startDate: DateTime(2026, 1, 10),
        endDate: DateTime(2026, 6, 10),
        status: ContractStatus.active,
        description: 'Drainage, grading, and asphalt resurfacing package.',
      ),
      ContractRecord(
        id: 'ct-002',
        title: 'Estate Housing Electrical Fit-Out',
        clientName: 'Bluecrest Developments',
        contractValue: 98000,
        budgetAmount: 94000,
        startDate: DateTime(2026, 2, 4),
        endDate: DateTime(2026, 4, 28),
        status: ContractStatus.active,
      ),
      ContractRecord(
        id: 'ct-003',
        title: 'Office Renovation and Joinery',
        clientName: 'Northline Logistics',
        contractValue: 67000,
        budgetAmount: 62000,
        startDate: DateTime(2025, 11, 18),
        endDate: DateTime(2026, 1, 28),
        status: ContractStatus.completed,
      ),
    ];
  }

  static List<ExpenseRecord> _seedExpenses() {
    return [
      ExpenseRecord(
        id: 'ex-001',
        contractId: 'ct-001',
        category: ExpenseCategory.materials,
        amount: 38000,
        date: DateTime(2026, 1, 15),
        paymentMethod: PaymentMethod.bankTransfer,
        vendor: 'Prime Aggregate Supply',
        description: 'Granite, sand, and asphalt binder.',
        receiptReference: 'REC-1001',
      ),
      ExpenseRecord(
        id: 'ex-002',
        contractId: 'ct-001',
        category: ExpenseCategory.labour,
        amount: 21400,
        date: DateTime(2026, 1, 31),
        paymentMethod: PaymentMethod.mobileMoney,
        vendor: 'Field Crew Payroll',
        description: 'January site labour wages.',
      ),
      ExpenseRecord(
        id: 'ex-003',
        contractId: 'ct-001',
        category: ExpenseCategory.fuel,
        amount: 7200,
        date: DateTime(2026, 2, 3),
        paymentMethod: PaymentMethod.cash,
        vendor: 'GoFuel Station',
        description: 'Excavator and truck diesel top-up.',
      ),
      ExpenseRecord(
        id: 'ex-004',
        contractId: 'ct-002',
        category: ExpenseCategory.materials,
        amount: 46950,
        date: DateTime(2026, 2, 8),
        paymentMethod: PaymentMethod.bankTransfer,
        vendor: 'Volta Cables',
        description: 'Electrical cables, breakers, conduits.',
      ),
      ExpenseRecord(
        id: 'ex-005',
        contractId: 'ct-002',
        category: ExpenseCategory.transportation,
        amount: 7100,
        date: DateTime(2026, 3, 4),
        paymentMethod: PaymentMethod.mobileMoney,
        vendor: 'Swift Dispatch',
        description: 'Site delivery and pickup runs.',
        isSettled: false,
        dueDate: DateTime(2026, 3, 6),
      ),
      ExpenseRecord(
        id: 'ex-006',
        contractId: 'ct-003',
        category: ExpenseCategory.equipment,
        amount: 8450,
        date: DateTime(2025, 12, 6),
        paymentMethod: PaymentMethod.card,
        vendor: 'Makita Pro Center',
        description: 'Power tools and accessory replacements.',
      ),
      ExpenseRecord(
        id: 'ex-007',
        category: ExpenseCategory.rent,
        amount: 4200,
        date: DateTime(2026, 3, 1),
        paymentMethod: PaymentMethod.bankTransfer,
        vendor: 'Main Street Office Suites',
        description: 'Office rent allocation.',
      ),
      ExpenseRecord(
        id: 'ex-008',
        category: ExpenseCategory.feeding,
        amount: 1250,
        date: DateTime(2026, 3, 8),
        paymentMethod: PaymentMethod.cash,
        vendor: 'Site Catering',
        description: 'Crew lunch provision.',
      ),
      ExpenseRecord(
        id: 'ex-009',
        category: ExpenseCategory.taxes,
        amount: 5600,
        date: DateTime(2026, 2, 20),
        paymentMethod: PaymentMethod.bankTransfer,
        vendor: 'GRA',
        description: 'Quarterly tax remittance.',
      ),
      ExpenseRecord(
        id: 'ex-010',
        contractId: 'ct-001',
        category: ExpenseCategory.transportation,
        amount: 4200,
        date: DateTime(2026, 3, 8),
        paymentMethod: PaymentMethod.bankTransfer,
        vendor: 'Metro Heavy Haulage',
        description: 'Emergency haulage and equipment transfer.',
      ),
      ExpenseRecord(
        id: 'ex-011',
        contractId: 'ct-002',
        category: ExpenseCategory.labour,
        amount: 32500,
        date: DateTime(2026, 3, 7),
        paymentMethod: PaymentMethod.mobileMoney,
        vendor: 'Field Crew Payroll',
        description: 'Electrical installation crew wages.',
      ),
      ExpenseRecord(
        id: 'ex-012',
        contractId: 'ct-002',
        category: ExpenseCategory.equipment,
        amount: 6200,
        date: DateTime(2026, 3, 8),
        paymentMethod: PaymentMethod.card,
        vendor: 'Tool Depot',
        description: 'Test meters and cable puller service.',
      ),
      ExpenseRecord(
        id: 'ex-013',
        contractId: 'ct-003',
        category: ExpenseCategory.labour,
        amount: 10000,
        date: DateTime(2026, 1, 10),
        paymentMethod: PaymentMethod.bankTransfer,
        vendor: 'Joinery Crew',
        description: 'Final carpentry labour settlement.',
      ),
    ];
  }

  static List<IncomeRecord> _seedIncome() {
    return [
      IncomeRecord(
        id: 'in-001',
        contractId: 'ct-001',
        type: IncomeType.advancePayment,
        amount: 85000,
        date: DateTime(2026, 1, 12),
        payer: 'Accra Metro Works',
        description: 'Mobilization advance.',
      ),
      IncomeRecord(
        id: 'in-002',
        contractId: 'ct-001',
        type: IncomeType.milestonePayment,
        amount: 64000,
        date: DateTime(2026, 2, 18),
        payer: 'Accra Metro Works',
        description: 'Phase one completion payment.',
      ),
      IncomeRecord(
        id: 'in-003',
        contractId: 'ct-002',
        type: IncomeType.advancePayment,
        amount: 40000,
        date: DateTime(2026, 2, 6),
        payer: 'Bluecrest Developments',
        description: 'Project advance.',
      ),
      IncomeRecord(
        id: 'in-004',
        contractId: 'ct-003',
        type: IncomeType.balancePayment,
        amount: 67000,
        date: DateTime(2026, 1, 27),
        payer: 'Northline Logistics',
        description: 'Final contract settlement.',
      ),
      IncomeRecord(
        id: 'in-005',
        type: IncomeType.miscellaneous,
        amount: 3200,
        date: DateTime(2026, 3, 2),
        payer: 'Asset Disposal',
        description: 'Sale of unused timber stock.',
      ),
      IncomeRecord(
        id: 'in-006',
        contractId: 'ct-002',
        type: IncomeType.milestonePayment,
        amount: 35000,
        date: DateTime(2026, 3, 5),
        payer: 'Bluecrest Developments',
        description: 'Wiring completion milestone payment.',
      ),
    ];
  }
}
