import 'package:flutter/material.dart';

import '../../core/models/contract.dart';
import '../../core/models/income.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';

Future<void> showIncomeFormSheet(BuildContext context, AppState appState) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _IncomeFormSheet(appState: appState),
  );
}

class _IncomeFormSheet extends StatefulWidget {
  const _IncomeFormSheet({required this.appState});

  final AppState appState;

  @override
  State<_IncomeFormSheet> createState() => _IncomeFormSheetState();
}

class _IncomeFormSheetState extends State<_IncomeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _payerController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _contractId;
  IncomeType _incomeType = IncomeType.contractPayment;
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
    _payerController.dispose();
    _descriptionController.dispose();
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
      heightFactor: 0.94,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, insets.bottom + 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New income',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Record payments received and keep them available offline on this device.',
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
              DropdownButtonFormField<IncomeType>(
                initialValue: _incomeType,
                decoration: const InputDecoration(
                  labelText: 'Income type',
                  border: OutlineInputBorder(),
                ),
                items: IncomeType.values.map((type) {
                  return DropdownMenuItem<IncomeType>(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _incomeType = value;
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
                  labelText: 'Amount received',
                  border: OutlineInputBorder(),
                ),
                validator: _positiveMoney,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _payerController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Payer / client',
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
                label: 'Income date',
                value: formatDate(_date),
                onPressed: _pickDate,
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
                      child: Text(_isSaving ? 'Saving...' : 'Save income'),
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

    await widget.appState.addIncome(
      contractId: _contractId,
      type: _incomeType,
      amount: _parseMoney(_amountController.text)!,
      date: _date,
      payer: _payerController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Income saved locally.')),
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
