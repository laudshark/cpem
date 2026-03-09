import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.appState, super.key});

  final AppState appState;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _emailAddressController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _roleTitleController;
  bool _autoSyncEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _weeklySummaryEnabled = true;
  bool _overduePaymentsEnabled = true;
  bool _contractRiskAlertsEnabled = true;
  bool _isSavingCredentials = false;
  bool _isSavingPreferences = false;

  @override
  void initState() {
    super.initState();
    final credentials = widget.appState.userCredentials;
    _fullNameController = TextEditingController(text: credentials.fullName);
    _businessNameController =
        TextEditingController(text: credentials.businessName);
    _emailAddressController =
        TextEditingController(text: credentials.emailAddress);
    _phoneNumberController =
        TextEditingController(text: credentials.phoneNumber);
    _roleTitleController = TextEditingController(text: credentials.roleTitle);
    final preferences = widget.appState.appPreferences;
    _autoSyncEnabled = preferences.autoSyncEnabled;
    _budgetAlertsEnabled = preferences.budgetAlertsEnabled;
    _weeklySummaryEnabled = preferences.weeklySummaryEnabled;
    _overduePaymentsEnabled = preferences.overduePaymentsEnabled;
    _contractRiskAlertsEnabled = preferences.contractRiskAlertsEnabled;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _emailAddressController.dispose();
    _phoneNumberController.dispose();
    _roleTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final credentials = widget.appState.userCredentials;
    final preferences = widget.appState.appPreferences;

    return PageScaffold(
      title: 'Settings',
      subtitle:
          'Store your business identity, sync controls, and alert preferences locally so the app matches how you operate.',
      eyebrow: 'User profile',
      headerIcon: Icons.settings_rounded,
      accentColor: const Color(0xFF334155),
      statusLabel: credentials.completionLabel,
      statusColor: credentials.isComplete
          ? const Color(0xFFBBF7D0)
          : const Color(0xFFFDE68A),
      highlights: [
        PageHeaderHighlight(
          label: 'Owner',
          value:
              credentials.fullName.isEmpty ? 'Not set' : credentials.fullName,
        ),
        PageHeaderHighlight(
          label: 'Alerts enabled',
          value: '${preferences.enabledNotificationCount} active',
        ),
        PageHeaderHighlight(
          label: 'Sync mode',
          value: _autoSyncEnabled ? 'Automatic' : 'Manual',
        ),
      ],
      actions: [
        FilledButton.icon(
          onPressed: _isSavingCredentials ? null : _saveCredentials,
          icon: const Icon(Icons.save_outlined),
          label: Text(_isSavingCredentials ? 'Saving...' : 'Save credentials'),
        ),
      ],
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 980;
              final width =
                  wide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Profile credentials',
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildField(
                              controller: _fullNameController,
                              label: 'Full name',
                              textInputAction: TextInputAction.next,
                              validator: _requiredValue,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _businessNameController,
                              label: 'Business / company name',
                              textInputAction: TextInputAction.next,
                              validator: _requiredValue,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _emailAddressController,
                              label: 'Email address',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _emailValue,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _phoneNumberController,
                              label: 'Phone number',
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: _requiredValue,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _roleTitleController,
                              label: 'Role / title',
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: _isSavingCredentials
                                    ? null
                                    : _saveCredentials,
                                icon: const Icon(Icons.save_outlined),
                                label: Text(
                                  _isSavingCredentials
                                      ? 'Saving...'
                                      : 'Save credentials',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Operational preferences',
                      child: Column(
                        children: [
                          _PreferenceSwitchTile(
                            title: 'Automatic synchronization',
                            subtitle:
                                'Sync pending changes automatically when the app comes back online.',
                            value: _autoSyncEnabled,
                            onChanged: (value) {
                              setState(() {
                                _autoSyncEnabled = value;
                              });
                            },
                          ),
                          const Divider(height: 24),
                          _PreferenceSwitchTile(
                            title: 'Budget exceeded alerts',
                            subtitle:
                                'Show alerts when active contracts spend beyond their planned budget.',
                            value: _budgetAlertsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _budgetAlertsEnabled = value;
                              });
                            },
                          ),
                          const Divider(height: 24),
                          _PreferenceSwitchTile(
                            title: 'Weekly financial summary',
                            subtitle:
                                'Keep the weekly revenue, expense, and net summary visible in alerts.',
                            value: _weeklySummaryEnabled,
                            onChanged: (value) {
                              setState(() {
                                _weeklySummaryEnabled = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _isSavingPreferences
                                  ? null
                                  : _savePreferences,
                              icon: const Icon(Icons.tune_rounded),
                              label: Text(
                                _isSavingPreferences
                                    ? 'Saving...'
                                    : 'Save preferences',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Notification preferences',
                      child: Column(
                        children: [
                          _PreferenceSwitchTile(
                            title: 'Overdue supplier payment alerts',
                            subtitle:
                                'Warn when supplier payments remain unpaid past their due dates.',
                            value: _overduePaymentsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _overduePaymentsEnabled = value;
                              });
                            },
                          ),
                          const Divider(height: 24),
                          _PreferenceSwitchTile(
                            title: 'Contract risk alerts',
                            subtitle:
                                'Highlight active contracts whose projected margin is getting too low.',
                            value: _contractRiskAlertsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _contractRiskAlertsEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Storage & usage',
                      child: Column(
                        children: [
                          _SettingsInfoRow(
                            icon: Icons.storage_rounded,
                            title: 'Local storage',
                            subtitle:
                                'Your settings are saved on this device and remain available offline.',
                            value: 'Active',
                          ),
                          const Divider(height: 24),
                          _SettingsInfoRow(
                            icon: Icons.badge_outlined,
                            title: 'Profile status',
                            subtitle: credentials.isComplete
                                ? 'Your account details are complete and ready to use.'
                                : 'Complete the core fields so reports and identity details are accurate.',
                            value: credentials.completionLabel,
                          ),
                          const Divider(height: 24),
                          _SettingsInfoRow(
                            icon: Icons.sync_outlined,
                            title: 'Sync readiness',
                            subtitle: widget.appState.syncStatus.isOnline
                                ? _autoSyncEnabled
                                    ? 'Pending changes will sync automatically when connectivity is available.'
                                    : 'Sync is online but requires a manual action because automatic sync is turned off.'
                                : '${widget.appState.syncStatus.pendingChanges} local changes are waiting while offline.',
                            value: widget.appState.syncStatus.isOnline
                                ? (_autoSyncEnabled ? 'Auto' : 'Manual')
                                : 'Offline',
                          ),
                          const Divider(height: 24),
                          _SettingsInfoRow(
                            icon: Icons.notifications_active_outlined,
                            title: 'Alert coverage',
                            subtitle:
                                'Control how many dashboard and report alerts remain active in the app.',
                            value:
                                '${preferences.enabledNotificationCount} enabled',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSavingCredentials = true;
    });

    await widget.appState.saveUserCredentials(
      fullName: _fullNameController.text,
      businessName: _businessNameController.text,
      emailAddress: _emailAddressController.text,
      phoneNumber: _phoneNumberController.text,
      roleTitle: _roleTitleController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSavingCredentials = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credentials saved locally.')),
    );
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSavingPreferences = true;
    });

    await widget.appState.saveAppPreferences(
      autoSyncEnabled: _autoSyncEnabled,
      budgetAlertsEnabled: _budgetAlertsEnabled,
      weeklySummaryEnabled: _weeklySummaryEnabled,
      overduePaymentsEnabled: _overduePaymentsEnabled,
      contractRiskAlertsEnabled: _contractRiskAlertsEnabled,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSavingPreferences = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved locally.')),
    );
  }

  String? _requiredValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _emailValue(String? value) {
    final requiredCheck = _requiredValue(value);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    final normalized = value!.trim();
    if (!normalized.contains('@') || !normalized.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }
}

class _PreferenceSwitchTile extends StatelessWidget {
  const _PreferenceSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(subtitle),
      ),
    );
  }
}

class _SettingsInfoRow extends StatelessWidget {
  const _SettingsInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3EB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF334155)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
