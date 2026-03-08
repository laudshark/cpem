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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'contractId': contractId,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'payer': payer,
      'description': description,
    };
  }

  factory IncomeRecord.fromJson(Map<String, dynamic> json) {
    return IncomeRecord(
      id: json['id'] as String? ?? '',
      contractId: json['contractId'] as String?,
      type: _incomeTypeFromName(json['type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      payer: json['payer'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

IncomeType _incomeTypeFromName(String? name) {
  for (final type in IncomeType.values) {
    if (type.name == name) {
      return type;
    }
  }

  return IncomeType.miscellaneous;
}
