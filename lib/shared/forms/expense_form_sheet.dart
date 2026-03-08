import 'package:flutter/material.dart';

import '../../core/models/contract.dart';
import '../../core/models/expense.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';

Future<void> showExpenseFormSheet(BuildContext context, AppState appState) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _ExpenseFormSheet(appState: appState),
  );
}

class _ExpenseFormSheet extends StatefulWidget {
  const _ExpenseFormSheet({required this.appState});

  final AppState appState;

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _receiptController = TextEditingController();

  String? _contractId;
  ExpenseCategory _category = ExpenseCategory.materials;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  late DateTime _date;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _date = widget.appState.today;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _vendorController.dispose();
    _descriptionController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    final contractOptions = [
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('General business'),
      ),
      ...widget.appState.contracts.map((contract) {
        return DropdownMenuItem<String?>(
          value: contract.id,
          child: Text(_contractLabel(contract)),
        );
      }),
    ];

    return FractionallySizedBox(
      heightFactor: 0.96,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, insets.bottom + 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New expense',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Capture a new expense and keep it available offline on this device.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String?>(
                initialValue: _contractId,
                decoration: const InputDecoration(
                  labelText: 'Contract / project',
                  border: OutlineInputBorder(),
                ),
                items: contractOptions,
                onChanged: (value) {
                  setState(() {
                    _contractId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ExpenseCategory.values.map((category) {
                  return DropdownMenuItem<ExpenseCategory>(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: _positiveMoney,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment method',
                  border: OutlineInputBorder(),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem<PaymentMethod>(
                    value: method,
                    child: Text(method.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _paymentMethod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vendorController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Supplier / vendor',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 16),
              _DatePickerTile(
                label: 'Expense date',
                value: formatDate(_date),
                onPressed: _pickDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _receiptController,
                decoration: const InputDecoration(
                  labelText: 'Receipt reference',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _submit,
                      child: Text(_isSaving ? 'Saving...' : 'Save expense'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.appState.addExpense(
      contractId: _contractId,
      category: _category,
      amount: _parseMoney(_amountController.text)!,
      date: _date,
      paymentMethod: _paymentMethod,
      vendor: _vendorController.text.trim(),
      description: _descriptionController.text.trim(),
      receiptReference: _receiptController.text,
    );

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Expense saved locally.')),
    );
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _positiveMoney(String? value) {
    final parsed = _parseMoney(value);
    if (parsed == null || parsed <= 0) {
      return 'Enter an amount greater than 0';
    }
    return null;
  }

  String _contractLabel(ContractRecord contract) {
    return '${contract.title} (${contract.status.label})';
  }
}

double? _parseMoney(String? value) {
  if (value == null) {
    return null;
  }

  final normalized = value.replaceAll(',', '').trim();
  if (normalized.isEmpty) {
    return null;
  }

  return double.tryParse(normalized);
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        child: Row(
          children: [
            Expanded(child: Text(value)),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
