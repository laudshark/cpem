enum ContractStatus {
  draft('Draft'),
  active('Active'),
  onHold('On hold'),
  completed('Completed');

  const ContractStatus(this.label);

  final String label;
}

class ContractRecord {
  const ContractRecord({
    required this.id,
    required this.title,
    required this.clientName,
    required this.contractValue,
    required this.budgetAmount,
    required this.startDate,
    required this.status,
    this.endDate,
    this.description,
  });

  final String id;
  final String title;
  final String clientName;
  final double contractValue;
  final double budgetAmount;
  final DateTime startDate;
  final DateTime? endDate;
  final ContractStatus status;
  final String? description;
}
