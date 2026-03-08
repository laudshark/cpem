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
}
