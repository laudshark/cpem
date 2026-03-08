enum ExpenseCategory {
  materials('Materials'),
  labour('Labour'),
  transportation('Transportation'),
  fuel('Fuel'),
  feeding('Feeding'),
  equipment('Equipment'),
  rent('Rent'),
  taxes('Taxes'),
  miscellaneous('Miscellaneous');

  const ExpenseCategory(this.label);

  final String label;
}

enum PaymentMethod {
  cash('Cash'),
  bankTransfer('Bank transfer'),
  mobileMoney('Mobile money'),
  card('Card');

  const PaymentMethod(this.label);

  final String label;
}

class ExpenseRecord {
  const ExpenseRecord({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.vendor,
    required this.description,
    this.contractId,
    this.receiptReference,
    this.isSettled = true,
    this.dueDate,
  });

  final String id;
  final String? contractId;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String vendor;
  final String description;
  final String? receiptReference;
  final bool isSettled;
  final DateTime? dueDate;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'contractId': contractId,
      'category': category.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod.name,
      'vendor': vendor,
      'description': description,
      'receiptReference': receiptReference,
      'isSettled': isSettled,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseRecord(
      id: json['id'] as String? ?? '',
      contractId: json['contractId'] as String?,
      category: _categoryFromName(json['category'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      paymentMethod: _paymentMethodFromName(json['paymentMethod'] as String?),
      vendor: json['vendor'] as String? ?? '',
      description: json['description'] as String? ?? '',
      receiptReference: json['receiptReference'] as String?,
      isSettled: json['isSettled'] as bool? ?? true,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'] as String),
    );
  }
}

ExpenseCategory _categoryFromName(String? name) {
  for (final category in ExpenseCategory.values) {
    if (category.name == name) {
      return category;
    }
  }

  return ExpenseCategory.miscellaneous;
}

PaymentMethod _paymentMethodFromName(String? name) {
  for (final method in PaymentMethod.values) {
    if (method.name == name) {
      return method;
    }
  }

  return PaymentMethod.cash;
}
