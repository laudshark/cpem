import '../models/contract.dart';
import '../models/expense.dart';
import '../models/income.dart';
import 'finance_repository.dart';

class InMemoryFinanceRepository implements FinanceRepository {
  @override
  Future<List<ContractRecord>> fetchContracts() async {
    return [
      ContractRecord(
        id: 'ct-001',
        title: 'Municipal Road Rehabilitation',
        clientName: 'Accra Metro Works',
        contractValue: 240000,
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
        startDate: DateTime(2026, 2, 4),
        endDate: DateTime(2026, 4, 28),
        status: ContractStatus.active,
      ),
      ContractRecord(
        id: 'ct-003',
        title: 'Office Renovation and Joinery',
        clientName: 'Northline Logistics',
        contractValue: 67000,
        startDate: DateTime(2025, 11, 18),
        endDate: DateTime(2026, 1, 28),
        status: ContractStatus.completed,
      ),
    ];
  }

  @override
  Future<List<ExpenseRecord>> fetchExpenses() async {
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
        amount: 16950,
        date: DateTime(2026, 2, 8),
        paymentMethod: PaymentMethod.bankTransfer,
        vendor: 'Volta Cables',
        description: 'Electrical cables, breakers, conduits.',
      ),
      ExpenseRecord(
        id: 'ex-005',
        contractId: 'ct-002',
        category: ExpenseCategory.transportation,
        amount: 3100,
        date: DateTime(2026, 2, 12),
        paymentMethod: PaymentMethod.mobileMoney,
        vendor: 'Swift Dispatch',
        description: 'Site delivery and pickup runs.',
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
        date: DateTime(2026, 2, 1),
        paymentMethod: PaymentMethod.bankTransfer,
        vendor: 'Main Street Office Suites',
        description: 'Office rent allocation.',
      ),
      ExpenseRecord(
        id: 'ex-008',
        category: ExpenseCategory.feeding,
        amount: 1250,
        date: DateTime(2026, 2, 5),
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
    ];
  }

  @override
  Future<List<IncomeRecord>> fetchIncome() async {
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
        date: DateTime(2026, 2, 16),
        payer: 'Asset Disposal',
        description: 'Sale of unused timber stock.',
      ),
    ];
  }
}
