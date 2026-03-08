enum IncomeType {
  contractPayment('Contract payment'),
  advancePayment('Advance payment'),
  milestonePayment('Milestone payment'),
  balancePayment('Balance payment'),
  miscellaneous('Miscellaneous income');

  const IncomeType(this.label);

  final String label;
}

class IncomeRecord {
  const IncomeRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.payer,
    required this.description,
    this.contractId,
  });

  final String id;
  final String? contractId;
  final IncomeType type;
  final double amount;
  final DateTime date;
  final String payer;
  final String description;
}
