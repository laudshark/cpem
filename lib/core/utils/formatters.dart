String formatMoney(double amount) {
  final negative = amount < 0;
  final absolute = amount.abs();
  final fixed = absolute.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts[0];
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    final reverseIndex = digits.length - index;
    buffer.write(digits[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }

  final prefix = negative ? '-\$' : '\$';
  return '$prefix${buffer.toString()}.${parts[1]}';
}

String formatPercent(double value) => '${value.toStringAsFixed(1)}%';

String formatDate(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatMonthKey(String key) {
  final parts = key.split('-');
  if (parts.length != 2) {
    return key;
  }

  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final monthNumber = int.tryParse(parts[1]);
  if (monthNumber == null || monthNumber < 1 || monthNumber > 12) {
    return key;
  }

  return '${months[monthNumber - 1]} ${parts[0]}';
}
