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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'clientName': clientName,
      'contractValue': contractValue,
      'budgetAmount': budgetAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'description': description,
    };
  }

  factory ContractRecord.fromJson(Map<String, dynamic> json) {
    final contractValue = (json['contractValue'] as num?)?.toDouble() ?? 0;

    return ContractRecord(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      contractValue: contractValue,
      budgetAmount: (json['budgetAmount'] as num?)?.toDouble() ?? contractValue,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now(),
      endDate: json['endDate'] == null
          ? null
          : DateTime.tryParse(json['endDate'] as String),
      status: _statusFromName(json['status'] as String?),
      description: json['description'] as String?,
    );
  }
}

ContractStatus _statusFromName(String? name) {
  for (final status in ContractStatus.values) {
    if (status.name == name) {
      return status;
    }
  }

  return ContractStatus.active;
}
