import 'package:flutter/material.dart';

import '../../core/models/contract.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';

Future<void> showContractFormSheet(BuildContext context, AppState appState) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _ContractFormSheet(appState: appState),
  );
}

class _ContractFormSheet extends StatefulWidget {
  const _ContractFormSheet({required this.appState});

  final AppState appState;

  @override
  State<_ContractFormSheet> createState() => _ContractFormSheetState();
}

class _ContractFormSheetState extends State<_ContractFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _contractValueController = TextEditingController();
  final _budgetAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _startDate;
  DateTime? _endDate;
  ContractStatus _status = ContractStatus.active;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.appState.today;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _contractValueController.dispose();
    _budgetAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;

    return FractionallySizedBox(
      heightFactor: 0.96,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, insets.bottom + 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New contract',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Create a contract record that is stored locally and available offline.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Contract title',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Client name',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contractValueController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Contract value',
                  border: OutlineInputBorder(),
                ),
                validator: _positiveMoney,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Working budget',
                  border: OutlineInputBorder(),
                ),
                validator: _positiveMoney,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ContractStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ContractStatus.values.map((status) {
                  return DropdownMenuItem<ContractStatus>(
                    value: status,
                    child: Text(status.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              _DateTile(
                label: 'Start date',
                value: formatDate(_startDate),
                onPressed: () => _pickDate(
                  initialDate: _startDate,
                  onSelected: (date) {
                    setState(() {
                      _startDate = date;
                      if (_endDate != null && _endDate!.isBefore(_startDate)) {
                        _endDate = _startDate;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              _DateTile(
                label: 'End date',
                value: _endDate == null ? 'Optional' : formatDate(_endDate!),
                action: _endDate == null
                    ? null
                    : TextButton(
                        onPressed: () {
                          setState(() {
                            _endDate = null;
                          });
                        },
                        child: const Text('Clear'),
                      ),
                onPressed: () => _pickDate(
                  initialDate: _endDate ?? _startDate,
                  firstDate: _startDate,
                  onSelected: (date) {
                    setState(() {
                      _endDate = date;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
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
                      child: Text(_isSaving ? 'Saving...' : 'Save contract'),
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

  Future<void> _pickDate({
    required DateTime initialDate,
    DateTime? firstDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.appState.addContract(
      title: _titleController.text.trim(),
      clientName: _clientController.text.trim(),
      contractValue: _parseMoney(_contractValueController.text)!,
      budgetAmount: _parseMoney(_budgetAmountController.text)!,
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      description: _descriptionController.text,
    );

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Contract saved locally.')),
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

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onPressed,
    this.action,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(child: Text(value)),
            if (action != null) ...[
              action!,
              const SizedBox(width: 8),
            ],
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
